#!/bin/bash

# Configuration variables
TYPO3_DOMAIN="typo3.lan"
TYPO3_NAME="typo3"
LETSENCRYPT_EMAIL="foo@bar.mail"
MYSQL_DATABASE="typo3"
MYSQL_USER="typo3"
MYSQL_PASSWORD="typo3"
MYSQL_ROOT_PASSWORD="root"

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
    --name="$TYPO3_DOMAIN-db" \
    -e "MYSQL_DATABASE=$MYSQL_DATABASE" \
    -e "MYSQL_USER=$MYSQL_USER" \
    -e "MYSQL_PASSWORD=$MYSQL_PASSWORD" \
    -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" \
    -v "/srv/dbs/$TYPO3_DOMAIN:/var/lib/mysql" \
    mariadb \
    --character-set-server=utf8 \
    --collation-server=utf8_unicode_ci &>/dev/null

# Install TYPO3
echo ">> Running Typo3 Docker..."
docker run \
    -d \
    --name="$TYPO3_NAME" \
    --restart=always \
    --link="$TYPO3_DOMAIN-db:db" \
    -e "VIRTUAL_HOST=$TYPO3_DOMAIN" \
    -e "LETSENCRYPT_HOST=$TYPO3_DOMAIN" \
    -e "LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL" \
    -v "/srv/http/$TYPO3_DOMAIN:/app" \
    "webdevops/php-apache:alpine-php7" &>/dev/null

# Wait until the docker is up and running
echo -n ">> Waiting for TYPO3 to start..."
while [ ! $(docker top $TYPO3_NAME &>/dev/null && echo $?) ]
do
    echo -n "."
    sleep 0.5
done
echo "started!"

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. Have a nice day!"
echo ">> NAME: $TYPO3_NAME"
echo ">> URL: http://${TYPO3_DOMAIN}/"
echo ">> DATABASE HOSTNAME: db"
echo ">> DATABASE NAME: $MYSQL_DATABASE"
echo ">> DATABSE USER USERNAME: $MYSQL_USER"
echo ">> DATABSE USER PASSWORD: $MYSQL_PASSWORD"
echo ">> DATABSE ROOT USERNAME: root"
echo ">> DATABSE ROOT PASSWORD: $MYSQL_ROOT_PASSWORD"
echo "-----------------------------------------------------"