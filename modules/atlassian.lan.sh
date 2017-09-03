#!/bin/bash

# Configuration variables
LETSENCRYPT_EMAIL="foo@bar.mail"
DOMAIN="$(basename -- "$0" .sh)"
JIRA_DOMAIN="jira.$DOMAIN"
CONFLUENCE_DOMAIN="confluence.$DOMAIN"
BITBUCKET_DOMAIN="bitbucket.$DOMAIN"

# Prepare JIRA data folder
echo ">> Creating /srv/data/$JIRA_DOMAIN folder..."
mkdir -p "/srv/data/$JIRA_DOMAIN/app" &>/dev/null
mkdir -p "/srv/data/$JIRA_DOMAIN/logs" &>/dev/null

# Workaround for the JIRA docker
chown -R bin:bin "/srv/data/$JIRA_DOMAIN/app"
chown -R bin:bin "/srv/data/$JIRA_DOMAIN/logs"

# Run JIRA container
echo ">> Running JIRA..."
docker run \
    -d \
    --name="$JIRA_DOMAIN" \
    --restart=always \
    -e "VIRTUAL_HOST=$JIRA_DOMAIN" \
    -e "VIRTUAL_PORT=8080" \
    -e "LETSENCRYPT_HOST=$JIRA_DOMAIN" \
    -e "LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL" \
    -v "/srv/data/$JIRA_DOMAIN/app:/var/atlassian/jira" \
    -v "/srv/data/$JIRA_DOMAIN/logs:/opt/atlassian/jira/logs" \
    cptactionhank/atlassian-jira &>/dev/null

# Wait until the docker is up and running
echo -n ">> Waiting for JIRA to start..."
while [ ! $(docker top $JIRA_DOMAIN &>/dev/null && echo $?) ]
do
    echo -n "."
    sleep 0.5
done
echo "started!"

# ----------------------------------------------------------------

# Prepare Confluence data folder
echo ">> Creating /srv/data/$CONFLUENCE_DOMAIN folder..."
mkdir -p "/srv/data/$CONFLUENCE_DOMAIN/app" &>/dev/null
mkdir -p "/srv/data/$CONFLUENCE_DOMAIN/logs" &>/dev/null

# Workaround for the Confluence docker
chown -R bin:bin "/srv/data/$CONFLUENCE_DOMAIN/app"
chown -R bin:bin "/srv/data/$CONFLUENCE_DOMAIN/logs"

# Run Confluence container
echo ">> Running Confluence..."
docker run \
    -d \
    --name="$CONFLUENCE_DOMAIN" \
    --restart=always \
    -e "VIRTUAL_HOST=$CONFLUENCE_DOMAIN" \
    -e "VIRTUAL_PORT=8090" \
    -e "LETSENCRYPT_HOST=$CONFLUENCE_DOMAIN" \
    -e "LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL" \
    -v "/srv/data/$CONFLUENCE_DOMAIN/app:/var/atlassian/application-data/confluence" \
    -v "/srv/data/$CONFLUENCE_DOMAIN/logs:/opt/atlassian/confluence/logs" \
    atlassian/confluence-server &>/dev/null

# Wait until the docker is up and running
echo -n ">> Waiting for Confluence to start..."
while [ ! $(docker top $CONFLUENCE_DOMAIN &>/dev/null && echo $?) ]
do
    echo -n "."
    sleep 0.5
done
echo "started!"

# ----------------------------------------------------------------

# Prepare Bitbucket data folder
echo ">> Creating /srv/data/$BITBUCKET_DOMAIN folder..."
mkdir -p "/srv/data/$BITBUCKET_DOMAIN/app" &>/dev/null
mkdir -p "/srv/data/$BITBUCKET_DOMAIN/logs" &>/dev/null

# Run Bitbucket container
echo ">> Running Bitbucket..."
docker run \
    -d \
    --name="$BITBUCKET_DOMAIN" \
    --restart=always \
    -e "VIRTUAL_HOST=$BITBUCKET_DOMAIN" \
    -e "VIRTUAL_PORT=7990" \
    -e "LETSENCRYPT_HOST=$BITBUCKET_DOMAIN" \
    -e "LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL" \
    -v "/srv/data/$BITBUCKET_DOMAIN/app:/var/atlassian/application-data/bitbucket" \
    -v "/srv/data/$BITBUCKET_DOMAIN/logs:/opt/atlassian/bitbucket/logs" \
    atlassian/bitbucket-server &>/dev/null

# Wait until the docker is up and running
echo -n ">> Waiting for Bitbucket to start..."
while [ ! $(docker top $BITBUCKET_DOMAIN &>/dev/null && echo $?) ]
do
    echo -n "."
    sleep 0.5
done
echo "started!"

# ----------------------------------------------------------------

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. Have a nice day!"
echo ">> JIRA URL: https://${JIRA_DOMAIN}/"
echo ">> Confluence URL: https://${CONFLUENCE_DOMAIN}/"
echo ">> BitBucket URL: https://${BITBUCKET_DOMAIN}/"
echo "-----------------------------------------------------"