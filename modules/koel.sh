#!/bin/bash

# Configuration variables
KOEL_DOMAIN="koel.lan"
LETSENCRYPT_EMAIL="foo@bar.mail"
MYSQL_DATABASE="koel"
MYSQL_USER="koel"
MYSQL_PASSWORD="password"
MYSQL_ROOT_PASSWORD="root"

# Prepare the koel data folders
echo ">> Creating /srv/http/$KOEL_DOMAIN folder..."
mkdir -p "/srv/http/$KOEL_DOMAIN" &>/dev/null
echo ">> Creating /srv/dbs/$KOEL_DOMAIN folder..."
mkdir -p "/srv/dbs/$KOEL_DOMAIN" &>/dev/null

# Run the database docker.
# This will be executed only once, when the Database docker doesn't exist,
# else will just "complain" that the docker already exists,
# which is what we want. One database docker per VM.
echo ">> Creating Database docker ( only if it doesn't already exist )..."
docker run \
    -d \
    --restart=always \
    --name="$KOEL_DOMAIN-db" \
    -e "MYSQL_DATABASE=$MYSQL_DATABASE" \
    -e "MYSQL_USER=$MYSQL_USER" \
    -e "MYSQL_PASSWORD=$MYSQL_PASSWORD" \
    -e "MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD" \
    -v "/srv/dbs/$KOEL_DOMAIN:/var/lib/mysql" \
    mariadb \
    --character-set-server=utf8 \
    --collation-server=utf8_unicode_ci &>/dev/null

# Install koel
echo ">> Creating Project Docker..."
docker run \
    -d \
    --restart=always \
    --name="$KOEL_DOMAIN" \
    --link="$KOEL_DOMAIN-db:db" \
    -e "VIRTUAL_HOST=$KOEL_DOMAIN" \
    -e "VIRTUAL_PORT=9876" \
    -e "LETSENCRYPT_HOST=$KOEL_DOMAIN" \
    -e "LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL" \
    -e "DB_HOST=db" \
    -e "APP_DEBUG=false" \
    -e "AP_ENV=production" \
    -e "DB_DATABASE=$MYSQL_DATABASE" \
    -e "DB_USERNAME=$MYSQL_USER" \
    -e "DB_PASSWORD=$MYSQL_PASSWORD" \
    -e "ADMIN_EMAIL=user@foo.bar" \
    -e "ADMIN_NAME=user" \
    -e "ADMIN_PASSWORD=admin" \
    -v "/PATH/TO/MUSIC/ON/THE/HOST/:/DATA/music/:ro" \
    julianxhokaxhiu/docker-koel &>/dev/null

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
echo ">> NAME: $KOEL_DOMAIN"
echo ">> URL: http://${KOEL_DOMAIN}/"
echo ">> WORK DIRECTORY: /srv/http/$KOEL_DOMAIN"
echo ">> DATABASE HOSTNAME: db"
echo ">> DATABASE ROOT USERNAME: root"
echo "-----------------------------------------------------"
