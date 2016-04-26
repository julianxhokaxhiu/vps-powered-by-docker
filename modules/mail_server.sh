#!/bin/bash

# Configuration variables
MAILSERVER_DOMAIN="mail.lan"
MAILSERVER_NAME="mail-server"
LETSENCRYPT_EMAIL="foo@bar.mail"

# Prepare the Mail Server data folder
echo ">> Creating /srv/mail folder..."
mkdir -p /srv/mail &>/dev/null

# Install the Mail Server
echo ">> Running Mail server..."
docker run \
    -d \
    --name="$MAILSERVER_NAME" \
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
    -e "LETSENCRYPT_HOST=$MAILSERVER_DOMAIN" \
    -e "LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL" \
    -e "VIRTUAL_PROTO=https" \
    -e "VIRTUAL_PORT=443" \
    analogic/poste.io &>/dev/null

# Wait until the mail server is up and running
echo -n ">> Waiting for Mail server to start..."
while [ ! $(docker top $MAILSERVER_NAME &>/dev/null && echo $?) ]
do
    echo -n "."
    sleep 0.5
done
echo "started!"

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. Have a nice day!"
echo ">> Admin URL: https://${MAILSERVER_DOMAIN}/admin/login"
echo ">> User URL: https://${MAILSERVER_DOMAIN}/"
echo "-----------------------------------------------------"