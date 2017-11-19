#!/bin/bash

# Configuration variables
WEBDAV_DOMAIN="$(basename -- "$0" .sh)"

# Disable Gzip as it does not work on Windows
cat <<EOT > "/srv/vhost/${WEBDAV_DOMAIN}"
gzip off;
EOT

# Install WebDAV
echo ">> Running WebDAV..."
docker run \
    --restart=always \
    --name="$WEBDAV_DOMAIN" \
    -d \
    -e "USERNAME=user" \
    -e "PASSWORD=pass" \
    -e "VIRTUAL_HOST=$WEBDAV_DOMAIN" \
    -v "/PATH/TO/LOCATION:/webdav" \
    idelsink/webdav &>/dev/null

# Wait until the docker is up and running
echo -n ">> Waiting for WebDAV to start..."
while [ ! $(docker top $WEBDAV_DOMAIN &>/dev/null && echo $?) ]
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