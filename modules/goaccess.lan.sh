#!/bin/bash

# Configuration variables
GOACCESS_DOMAIN="$(basename -- "$0" .sh)"

# Prepare the goaccess data folders
echo ">> Creating /srv/data/$GOACCESS_DOMAIN folder..."
mkdir -p "/srv/data/$GOACCESS_DOMAIN" &>/dev/null

# Install Goaccess
echo ">> Running Goaccess..."
docker run \
    --restart=always \
    --name="$GOACCESS_DOMAIN" \
    -d \
    -e "VIRTUAL_HOST=$GOACCESS_DOMAIN" \
    -e "VIRTUAL_PORT=7890" \
    -v "/srv/data/$GOACCESS_DOMAIN:/srv/data" \
    allinurl/goaccess &>/dev/null

# Wait until the docker is up and running
echo -n ">> Waiting for Goaccess to start..."
while [ ! $(docker top $GOACCESS_DOMAIN &>/dev/null && echo $?) ]
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