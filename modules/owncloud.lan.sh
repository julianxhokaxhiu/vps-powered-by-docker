#!/bin/bash

# Configuration variables
OWNCLOUD_DOMAIN="$(basename -- "$0" .sh)"

# Prepare the ownCloud data folder
echo ">> Creating /srv/data/$OWNCLOUD_DOMAIN folder..."
mkdir -p "/srv/data/$OWNCLOUD_DOMAIN/apps" &>/dev/null
mkdir -p "/srv/data/$OWNCLOUD_DOMAIN/config" &>/dev/null
mkdir -p "/srv/data/$OWNCLOUD_DOMAIN/data" &>/dev/null

# Install ownCloud
echo ">> Running ownCloud..."
docker run \
    -d \
    --name="$OWNCLOUD_DOMAIN" \
    --restart=always \
    -e "VIRTUAL_HOST=$OWNCLOUD_DOMAIN" \
    -v "/srv/data/$OWNCLOUD_DOMAIN/apps:/var/www/html/apps" \
    -v "/srv/data/$OWNCLOUD_DOMAIN/config:/var/www/html/config" \
    -v "/srv/data/$OWNCLOUD_DOMAIN/data:/var/www/html/data" \
    owncloud &>/dev/null

# Wait until the docker is up and running
echo -n ">> Waiting for ownCloud to start..."
while [ ! $(docker top $OWNCLOUD_DOMAIN &>/dev/null && echo $?) ]
do
    echo -n "."
    sleep 0.5
done
echo "started!"

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. Have a nice day!"
echo ">> URL: http://${OWNCLOUD_DOMAIN}/"
echo "-----------------------------------------------------"