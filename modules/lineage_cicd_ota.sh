#!/bin/bash

# Configuration variables
LINOTA_DOMAIN="lineage.lan"
LINOTA_NAME="lineage-ota"
LETSENCRYPT_EMAIL="foo@bar.mail"
LINCICD_NAME="lineage-cicd"
USER_NAME="John Doe"
USER_MAIL="john.doe@awesome.email"
DEVICE_LIST="hammerhead" # See https://github.com/julianxhokaxhiu/docker-lineage-cicd/blob/master/Dockerfile#L22
BRANCH_NAME="cm-14.1" # See https://github.com/LineageOS/android_vendor_cm/branches
OTA_URL="$LINOTA_DOMAIN/api" # See https://blog.julianxhokaxhiu.com/how-the-cm-ota-server-works-and-how-to-implement-and-use-ours/

# Prepare the Lineage OTA data folder
echo ">> Creating /srv/data/$LINOTA_NAME folder..."
mkdir -p "/srv/data/$LINOTA_NAME" &>/dev/null

# Prepare the Lineage CICD data folder
echo ">> Creating /srv/data/$LINCICD_NAME folder..."
mkdir -p "/srv/data/$LINCICD_NAME/ccache" &>/dev/null
mkdir -p "/srv/data/$LINCICD_NAME/src" &>/dev/null

# Install Lineage OTA server
echo ">> Running Lineage OTA Server..."
docker run \
    -d \
    --name="$LINOTA_NAME" \
    --restart=always \
    -v "/srv/data/$LINOTA_NAME:/var/www/html/builds/full" \
    -e "VIRTUAL_HOST=$LINOTA_DOMAIN" \
    -e "LETSENCRYPT_HOST=$LINOTA_DOMAIN" \
    -e "LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL" \
    julianxhokaxhiu/lineageota &>/dev/null

# Wait until the docker is up and running
echo -n ">> Waiting for Lineage OTA Server to start..."
while [ ! $(docker top $LINOTA_NAME &>/dev/null && echo $?) ]
do
    echo -n "."
    sleep 0.5
done
echo "started!"

# Install Lineage CICD container
echo ">> Running Lineage CICD..."
docker run \
    --restart=always \
    -d \
    -e "USER_NAME=$USER_NAME" \
    -e "USER_MAIL=$USER_MAIL" \
    -e "DEVICE_LIST=$DEVICE_LIST" \
    -e "BRANCH_NAME=$BRANCH_NAME" \
    -e "OTA_URL=$OTA_URL" \
    -v "/srv/data/$LINCICD_NAME/ccache:/srv/ccache" \
    -v "/srv/data/$LINCICD_NAME/src:/srv/src" \
    -v "/srv/data/$LINOTA_NAME:/srv/out" \
    julianxhokaxhiu/docker-lineage-cicd &>/dev/null

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. Have a nice day!"
echo ">> URL: https://${LINOTA_DOMAIN}/"
echo "-----------------------------------------------------"