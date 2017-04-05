#!/bin/bash

# Configuration variables
AMPACHE_DOMAIN="ampache.lan"
AMPACHE_NAME="ampache"
LETSENCRYPT_EMAIL="foo@bar.mail"

# Prepare the ampache data folders
echo ">> Creating /srv/data/$AMPACHE_DOMAIN folders..."
mkdir -p "/srv/data/$AMPACHE_DOMAIN/config" &>/dev/null
mkdir -p "/srv/data/$AMPACHE_DOMAIN/themes" &>/dev/null
mkdir -p "/srv/dbs/$AMPACHE_DOMAIN" &>/dev/null

# Run the database docker.
# This will be executed only once, when the Database docker doesn't exist,
# else will just "complain" that the docker already exists,
# which is what we want. One database docker per VM.
echo ">> Creating Database docker ( only if it doesn't already exist )..."
docker run \
    -d \
    --restart=always \
    --name="$AMPACHE_DOMAIN-db" \
    -e "MYSQL_DATABASE=ampache" \
    -e "MYSQL_USER=ampache" \
    -e "MYSQL_PASSWORD=password" \
    -e "MYSQL_ROOT_PASSWORD=root" \
    -v "/srv/dbs/$AMPACHE_DOMAIN:/var/lib/mysql" \
    mariadb \
    --character-set-server=utf8 \
    --collation-server=utf8_unicode_ci &>/dev/null

# Install ampache
echo ">> Running ampache..."
docker run \
    -d \
    --name="$AMPACHE_NAME" \
    --restart=always \
    --link="$AMPACHE_DOMAIN-db:db" \
    -e "VIRTUAL_HOST=$AMPACHE_DOMAIN" \
    -e "LETSENCRYPT_HOST=$AMPACHE_DOMAIN" \
    -e "LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL" \
    -v "/PATH/TO/MUSIC/ON/THE/HOST:/var/data:ro" \
    -v "/srv/data/$AMPACHE_DOMAIN/config:/var/www/html/config" \
    -v "/srv/data/$AMPACHE_DOMAIN/themes:/var/www/html/themes" \
    plusminus/ampache &>/dev/null

# Wait until the docker is up and running
echo -n ">> Waiting for ampache to start..."
while [ ! $(docker top $AMPACHE_NAME &>/dev/null && echo $?) ]
do
    echo -n "."
    sleep 0.5
done
echo "started!"

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. Have a nice day!"
echo ">> NAME: $AMPACHE_NAME"
echo ">> URL: http://${AMPACHE_DOMAIN}/"
echo ">> WORK DIRECTORY: /srv/http/$AMPACHE_DOMAIN"
echo ">> DATABASE HOSTNAME: db"
echo ">> DATABASE ROOT USERNAME: root"
echo "-----------------------------------------------------"