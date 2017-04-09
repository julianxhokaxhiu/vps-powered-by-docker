#!/bin/bash

# Configuration variables
GOACCESS_DOMAIN="goaccess.lan"
GOACCESS_NAME="goaccess"
LETSENCRYPT_EMAIL="foo@bar.mail"

# Prepare the goaccess data folders
echo ">> Creating /srv/data/$GOACCESS_DOMAIN folder..."
mkdir -p "/srv/data/$GOACCESS_DOMAIN" &>/dev/null

# Install Goaccess
echo ">> Running Goaccess..."
docker run \
    --restart=always \
    --name="$GOACCESS_NAME" \
    -d \
    -e "VIRTUAL_HOST=$GOACCESS_DOMAIN" \
    -e "VIRTUAL_PORT=7890" \
    -e "LETSENCRYPT_HOST=$GOACCESS_DOMAIN" \
    -e "LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL" \
    -v "/srv/data/$GOACCESS_DOMAIN:/srv/data" \
    allinurl/goaccess &>/dev/null

# Wait until the docker is up and running
echo -n ">> Waiting for Goaccess to start..."
while [ ! $(docker top $GOACCESS_NAME &>/dev/null && echo $?) ]
do
    echo -n "."
    sleep 0.5
done
echo "started!"

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. Have a nice day!"
echo ">> URL: http://${GOACCESS_DOMAIN}/"
echo "-----------------------------------------------------"