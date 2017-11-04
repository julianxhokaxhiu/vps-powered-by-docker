#!/bin/bash

# Configuration variables
UIFORDOCKER_DOMAIN="$(basename -- "$0" .sh)"

# Install UI for Docker
echo ">> Running UI for Docker..."
docker run \
    --restart=always \
    --name="$UIFORDOCKER_DOMAIN" \
    --privileged \
    -d \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -e "VIRTUAL_HOST=$UIFORDOCKER_DOMAIN" \
    -e "VIRTUAL_PORT=9000" \
    uifd/ui-for-docker &>/dev/null

# Wait until the docker is up and running
echo -n ">> Waiting for UI for Docker to start..."
while [ ! $(docker top $UIFORDOCKER_DOMAIN &>/dev/null && echo $?) ]
do
    echo -n "."
    sleep 0.5
done
echo "started!"

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. Have a nice day!"
echo ">> URL: http://${UIFORDOCKER_DOMAIN}/"
echo "-----------------------------------------------------"