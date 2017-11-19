#!/bin/bash

# Configuration variables
WEBDAV_DOMAIN="$(basename -- "$0" .sh)"
WEBDAV_USER="user"
WEBDAV_PASS="pass"
WEBDAV_MOUNT="/tmp"
WEBDAV_DATA="/srv/data/$WEBDAV_DOMAIN"

# Create required directory
mkdir -p $WEBDAV_DATA/config

# Disable Gzip as it does not work on Windows
cat <<EOT > "/srv/vhost/${WEBDAV_DOMAIN}"
gzip off;
EOT

# Create HtPasswd
printf "$WEBDAV_USER:$(openssl passwd -apr1 $WEBDAV_PASS)\n" >> $WEBDAV_DATA/config/htpasswd

# Install WebDAV
echo ">> Running WebDAV..."
docker run \
    --restart=always \
    --name="$WEBDAV_DOMAIN" \
    -d \
    -e "VIRTUAL_HOST=$WEBDAV_DOMAIN" \
    -v "$WEBDAV_MOUNT:/webdav:ro" \
    -v "$WEBDAV_DATA/config:/config" \
    jgeusebroek/webdav &>/dev/null

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