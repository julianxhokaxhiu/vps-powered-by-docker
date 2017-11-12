#!/bin/bash

# Configuration variables
MAILSERVER_DOMAIN="$(basename -- "$0" .sh)"

# Prepare the Mail Server data folder
echo ">> Creating /srv/mail folder..."
mkdir -p /srv/mail &>/dev/null

# Install the Mail Server
echo ">> Running Mail server..."
docker run \
    -d \
    --name="$MAILSERVER_DOMAIN" \
    --restart=always \
    --expose=80 \
    --expose=443 \
    -p 25:25 \
    -p 110:110 \
    -p 143:143 \
    -p 465:465 \
    -p 587:587 \
    -p 993:993 \
    -p 995:995 \
    -v /etc/localtime:/etc/localtime:ro \
    -v /srv/mail:/data \
    -e "VIRTUAL_HOST=$MAILSERVER_DOMAIN" \
    -e "VIRTUAL_PROTO=https" \
    -e "VIRTUAL_PORT=443" \
    analogic/poste.io &>/dev/null

# Wait until the docker is up and running
echo -n ">> Waiting for Mail server to start..."
while [ ! $(docker top $MAILSERVER_DOMAIN &>/dev/null && echo $?) ]
do
    echo -n "."
    sleep 0.5
done
echo "started!"

# Let's wait until Let's Encrypt SSL certificates are created
echo -n ">> Waiting for Let's Encrypt Certificates Public Key to be generated..."
while [ ! -f /srv/certs/$MAILSERVER_DOMAIN.crt ]
do
    echo -n "."
    sleep 0.5
done
echo "created!"

echo -n ">> Waiting for Let's Encrypt Certificates Private Key to be generated..."
while [ ! -f /srv/certs/$MAILSERVER_DOMAIN.key ]
do
    echo -n "."
    sleep 0.5
done
echo "created!"

# Hard Link them to the relative SSL directory, in order to use them internally also for SMTP, IMAP and POP3
echo -n ">> Linking Let's Encrypt Certificates to the newly created $MAILSERVER_DOMAIN docker..."
ln /srv/certs/$MAILSERVER_DOMAIN.crt /srv/mail/ssl/server.crt
ln /srv/certs/$MAILSERVER_DOMAIN.key /srv/mail/ssl/server.key

# Create an empty CA cert so poste.io can detect our SSL certificate
touch /srv/mail/ssl/ca.crt

# Finally restart poste.io Docker in order to use these SSL certificate from now on
echo -n ">> Restarting $MAILSERVER_DOMAIN Docker..."
docker stop $MAILSERVER_DOMAIN &>/dev/null
docker start $MAILSERVER_DOMAIN &>/dev/null

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. Have a nice day!"
echo ">> Admin URL: https://${MAILSERVER_DOMAIN}/admin/login"
echo ">> User URL: https://${MAILSERVER_DOMAIN}/"
echo "-----------------------------------------------------"