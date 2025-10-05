#!/bin/bash

# Configuration variables
IMAPSYNC_DOMAIN="$(basename -- "$0" .sh)"

# Install imapsync
echo ">> Running imapsync container..."
docker run \
    -d \
    --restart=always \
    --name="$IMAPSYNC_DOMAIN" \
    -e "VIRTUAL_HOST=$IMAPSYNC_DOMAIN" \
    -e "VIRTUAL_PORT=80" \
    gilleslamiral/imapsync /servimapsync &>/dev/null

# Wait until the docker is up and running
echo -n ">> Waiting for imapsync to start..."
while [ ! $(docker top $IMAPSYNC_DOMAIN &>/dev/null && echo $?) ]
do
    echo -n "."
    sleep 0.5
done
echo "started!"

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. Have a nice day!"
echo ">> URL: https://${IMAPSYNC_DOMAIN}/"
echo "-----------------------------------------------------"
