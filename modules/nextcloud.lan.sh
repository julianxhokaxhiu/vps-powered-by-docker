#!/bin/bash

# Configuration variables
NEXTCLOUD_DOMAIN="$(basename -- "$0" .sh)"

# Prepare the Nextcloud data folder
echo ">> Creating /srv/data/$NEXTCLOUD_DOMAIN folder..."
mkdir -p "/srv/data/$NEXTCLOUD_DOMAIN/apps" &>/dev/null
mkdir -p "/srv/data/$NEXTCLOUD_DOMAIN/config" &>/dev/null
mkdir -p "/srv/data/$NEXTCLOUD_DOMAIN/data" &>/dev/null

# Install Nextcloud
echo ">> Running Nextcloud..."
docker run \
    -d \
    --name="$NEXTCLOUD_DOMAIN" \
    --restart=always \
    -e "VIRTUAL_HOST=$NEXTCLOUD_DOMAIN" \
    -v "/srv/data/$NEXTCLOUD_DOMAIN/apps:/var/www/html/apps" \
    -v "/srv/data/$NEXTCLOUD_DOMAIN/config:/var/www/html/config" \
    -v "/srv/data/$NEXTCLOUD_DOMAIN/data:/var/www/html/data" \
    nextcloud &>/dev/null

# Wait until the docker is up and running
echo -n ">> Waiting for Nextcloud to start..."
while [ ! $(docker top $NEXTCLOUD_DOMAIN &>/dev/null && echo $?) ]
do
    echo -n "."
    sleep 0.5
done
echo "started!"

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. Have a nice day!"
echo ">> URL: http://${NEXTCLOUD_DOMAIN}/"
echo "-----------------------------------------------------"