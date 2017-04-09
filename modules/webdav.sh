#!/bin/bash

# Configuration variables
WEBDAV_DOMAIN="webdav.lan"
WEBDAV_NAME="webdav"
LETSENCRYPT_EMAIL="foo@bar.mail"

# Install WebDAV
echo ">> Running WebDAV..."
docker run \
    --restart=always \
    --name="$WEBDAV_NAME" \
    -d \
    -e "USERNAME=user" \
    -e "PASSWORD=pass" \
    -e "VIRTUAL_HOST=$WEBDAV_DOMAIN" \
    -e "LETSENCRYPT_HOST=$WEBDAV_DOMAIN" \
    -e "LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL" \
    -v "/PATH/TO/LOCATION:/webdav" \
    idelsink/webdav &>/dev/null

# Wait until the docker is up and running
echo -n ">> Waiting for WebDAV to start..."
while [ ! $(docker top $WEBDAV_NAME &>/dev/null && echo $?) ]
do
    echo -n "."
    sleep 0.5
done
echo "started!"

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. Have a nice day!"
echo ">> URL: http://${WEBDAV_DOMAIN}/"
echo "-----------------------------------------------------"