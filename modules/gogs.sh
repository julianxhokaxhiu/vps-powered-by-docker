#!/bin/bash

# Configuration variables
GOGS_DOMAIN="gogs.lan"
GOGS_NAME="gogs"
GOGS_SSHPORT="10022"
LETSENCRYPT_EMAIL="foo@bar.mail"

# Prepare the gogs data folders
echo ">> Creating /srv/data/$GOGS_DOMAIN folder..."
mkdir -p "/srv/data/$GOGS_DOMAIN" &>/dev/null

# Install Gogs
echo ">> Running Gogs..."
docker run \
    --restart=always \
    --name="$GOGS_NAME" \
    -d \
    -p "$GOGS_SSHPORT:22" \
    -e "VIRTUAL_HOST=$GOGS_DOMAIN" \
    -e "VIRTUAL_PORT=3000" \
    -e "LETSENCRYPT_HOST=$GOGS_DOMAIN" \
    -e "LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL" \
    -v "/srv/data/$GOGS_DOMAIN:/data" \
    gogs/gogs &>/dev/null

# Wait until the docker is up and running
echo -n ">> Waiting for Gogs to start..."
while [ ! $(docker top $GOGS_NAME &>/dev/null && echo $?) ]
do
    echo -n "."
    sleep 0.5
done
echo "started!"

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. Have a nice day!"
echo ">> URL: http://${GOGS_DOMAIN}/"
echo ">> SSH: ssh://git@${GOGS_DOMAIN}:${GOGS_SSHPORT}/username/myrepo.git"
echo "-----------------------------------------------------"