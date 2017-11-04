#!/bin/bash

# Configuration variables
TYPO3_DOMAIN="$(basename -- "$0" .sh)"
DB_HOSTNAME="db.$TYPO3_DOMAIN"
DB_DATABASE="typo3"
DB_USER="typo3"
DB_PASSWORD="typo3"
DB_ROOT_PASSWORD="root"

# Prepare the TYPO3 data folder
echo ">> Creating folders..."
mkdir -p "/srv/dbs/$TYPO3_DOMAIN" &>/dev/null
mkdir -p "/srv/http/$TYPO3_DOMAIN" &>/dev/null

# Run the database docker.
# This will be executed only once, when the Database docker doesn't exist,
# else will just "complain" that the docker already exists,
# which is what we want. One database docker per VM.
echo ">> Creating Database docker ( only if it doesn't already exist )..."
docker run \
    -d \
    --restart=always \
    --name="$DB_HOSTNAME" \
    -e "DB_DATABASE=$DB_DATABASE" \
    -e "DB_USER=$DB_USER" \
    -e "DB_PASSWORD=$DB_PASSWORD" \
    -e "DB_ROOT_PASSWORD=$DB_ROOT_PASSWORD" \
    -v "/srv/dbs/$TYPO3_DOMAIN:/var/lib/mysql" \
    mariadb \
    --character-set-server=utf8 \
    --collation-server=utf8_unicode_ci &>/dev/null

# Install TYPO3
echo ">> Running Typo3 Docker..."
docker run \
    -d \
    --name="$TYPO3_DOMAIN" \
    --restart=always \
    -e "VIRTUAL_HOST=$TYPO3_DOMAIN" \
    -v "/srv/http/$TYPO3_DOMAIN:/app" \
    "webdevops/php-apache:debian-8-php7" &>/dev/null

# Wait until the docker is up and running
echo -n ">> Waiting for TYPO3 to start..."
while [ ! $(docker top $TYPO3_DOMAIN &>/dev/null && echo $?) ]
do
    echo -n "."
    sleep 0.5
done
echo "started!"

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. Have a nice day!"
echo ">> NAME: $TYPO3_DOMAIN"
echo ">> URL: http://${TYPO3_DOMAIN}/"
echo ">> DATABASE HOSTNAME: $DB_HOSTNAME"
echo ">> DATABASE NAME: $DB_DATABASE"
echo ">> DATABSE USER USERNAME: $DB_USER"
echo ">> DATABSE USER PASSWORD: $DB_PASSWORD"
echo ">> DATABSE ROOT USERNAME: root"
echo ">> DATABSE ROOT PASSWORD: $DB_ROOT_PASSWORD"
echo "-----------------------------------------------------"