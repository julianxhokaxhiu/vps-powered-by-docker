#!/bin/bash

# Configuration variables
RAINLOOP_DOMAIN="$(basename -- "$0" .sh)"
MAILSERVER_NAME="mail.lan"

# Prepare the Rainloop Mail Client data folder
echo ">> Creating /srv/data/$RAINLOOP_DOMAIN folder..."
mkdir -p "/srv/data/$RAINLOOP_DOMAIN" &>/dev/null

# Install Rainloop client
echo ">> Running Rainloop Mail Client..."
docker run \
    -d \
    --name="$RAINLOOP_DOMAIN" \
    --restart=always \
    -v "/srv/data/$RAINLOOP_DOMAIN:/var/www/html/data" \
    -e "PHP_MAX_POST_SIZE=50M" \
    -e "PHP_MAX_UPLOAD_SIZE=25M" \
    -e "VIRTUAL_HOST=$RAINLOOP_DOMAIN" \
    runningman84/rainloop &>/dev/null

# Wait until the docker is up and running
echo -n ">> Waiting for Rainloop Mail Client to start..."
while [ ! $(docker top $RAINLOOP_DOMAIN &>/dev/null && echo $?) ]
do
    echo -n "."
    sleep 0.5
done
echo "started!"

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. Have a nice day!"
echo ">> Admin URL: https://${RAINLOOP_DOMAIN}/?admin"
echo ">> User URL: https://${RAINLOOP_DOMAIN}/"
echo ">> Default login is \"admin\", password is \"12345\""
echo ">> Server hostname is \"$MAILSERVER_NAME\""
echo "-----------------------------------------------------"