#!/bin/bash

# Configuration variables
DNSSERVER_DOMAIN="dns.lan"
DNSSERVER_NAME="dns-server"
LETSENCRYPT_EMAIL="foo@bar.mail"
CUSTOM_DNS="8.8.8.8;8.8.4.4;[2001:4860:4860::8888];[2001:4860:4860::8844]"
API_KEY=""

# Prepare the DNS Server data folder
echo ">> Creating /srv/data/$DNSSERVER_DOMAIN folder..."
mkdir -p "/srv/data/$DNSSERVER_DOMAIN" &>/dev/null

# Install DNS Server
echo ">> Running DNS Server..."
docker run \
    -d \
    --name="$DNSSERVER_DOMAIN" \
    --restart=always \
    -e "API_KEY=$API_KEY" \
    -e "CUSTOM_DNS=$CUSTOM_DNS" \
    -e "VIRTUAL_HOST=$DNSSERVER_DOMAIN" \
    -e "VIRTUAL_PORT=8080" \
    -e "LETSENCRYPT_HOST=$DNSSERVER_DOMAIN" \
    -e "LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL" \
    -p 53:53 \
    -p 53:53/udp \
    -v "/srv/data/$DNSSERVER_DOMAIN:/srv/data" \
    julianxhokaxhiu/docker-powerdns &>/dev/null

# Wait until the docker is up and running
echo -n ">> Waiting for DNS Server to start..."
while [ ! $(docker top $DNSSERVER_DOMAIN &>/dev/null && echo $?) ]
do
    echo -n "."
    sleep 0.5
done
echo "started!"

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. Have a nice day!"
echo ">> URL: https://${DNSSERVER_DOMAIN}/"
echo ">> DNS: TCP/UDP on Port 53"
echo "-----------------------------------------------------"