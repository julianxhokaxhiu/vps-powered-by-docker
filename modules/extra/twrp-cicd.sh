#!/bin/bash

# Configuration variables
TWRPCICD_NAME="twrp-cicd"
USER_NAME="John Doe"
USER_MAIL="john.doe@awesome.email"
DEVICE_LIST="hammerhead" # See https://github.com/julianxhokaxhiu/docker-twrp-cicd/blob/master/Dockerfile#L35
BRANCH_NAME="twrp-14.1" # See https://github.com/minimal-manifest-twrp/platform_manifest_twrp_lineageos/branches
CRONTAB_TIME="0 10 * * *" # To make it easy, use https://crontab.guru/
DEBUG=false # Set to true for more verbose logging
CLEAN_AFTER_BUILD=true # Set to false to never clean the output folder of the build
WITH_SU=true # Set to false if you don't want root capabilities built-in inside the ROM

# Prepare the TWRP CICD data folder
echo ">> Creating /srv/data/$TWRPCICD_NAME folder..."
mkdir -p "/srv/data/$TWRPCICD_NAME/ccache" &>/dev/null
mkdir -p "/srv/data/$TWRPCICD_NAME/src" &>/dev/null
mkdir -p "/srv/data/$TWRPCICD_NAME/local_manifests" &>/dev/null
mkdir -p "/srv/data/$TWRPCICD_NAME/imgs" &>/dev/null

# Install TWRP CICD container
echo ">> Running TWRP CICD..."
docker run \
    -d \
    --name="$TWRPCICD_NAME" \
    --restart=always \
    -e "USER_NAME=$USER_NAME" \
    -e "USER_MAIL=$USER_MAIL" \
    -e "DEVICE_LIST=$DEVICE_LIST" \
    -e "BRANCH_NAME=$BRANCH_NAME" \
    -e "CRONTAB_TIME=$CRONTAB_TIME" \
    -e "DEBUG=$DEBUG" \
    -e "CLEAN_AFTER_BUILD=$CLEAN_AFTER_BUILD" \
    -e "WITH_SU=$WITH_SU" \
    -v "/srv/data/$TWRPCICD_NAME/ccache:/srv/ccache" \
    -v "/srv/data/$TWRPCICD_NAME/src:/srv/src" \
    -v "/srv/data/$TWRPCICD_NAME/local_manifests:/srv/local_manifests" \
    -v "/srv/data/$TWRPCICD_NAME/imgs:/srv/imgs" \
    julianxhokaxhiu/docker-twrp-cicd &>/dev/null

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. Have a nice day!"
echo "-----------------------------------------------------"
