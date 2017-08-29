#!/bin/bash

# Configuration variables
KOEL_DOMAIN="$(basename -- "$0" .sh)"
LETSENCRYPT_EMAIL="foo@bar.mail"

# Prepare the koel data folders
echo ">> Creating /srv/data/$KOEL_DOMAIN folder..."
mkdir -p "/srv/data/$KOEL_DOMAIN/config" &>/dev/null

# Install koel
echo ">> Running koel container..."
docker run \
    -d \
    --restart=always \
    --name="$KOEL_DOMAIN" \
    -e "VIRTUAL_HOST=$KOEL_DOMAIN" \
    -e "VIRTUAL_PORT=8050" \
    -e "LETSENCRYPT_HOST=$KOEL_DOMAIN" \
    -e "LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL" \
    -v "/srv/data/$KOEL_DOMAIN/config:/config" \
    -v "/etc/localtime:/etc/localtime:ro" \
    -v "/PATH/TO/MUSIC/ON/THE/HOST/:/media:ro" \
    binhex/arch-koel &>/dev/null

# Wait until the docker is up and running
echo -n ">> Waiting for koel to start..."
while [ ! $(docker top $KOEL_DOMAIN &>/dev/null && echo $?) ]
do
    echo -n "."
    sleep 0.5
done
echo "started!"

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. Have a nice day!"
echo ">> URL: https://${KOEL_DOMAIN}/"
echo "-----------------------------------------------------"
