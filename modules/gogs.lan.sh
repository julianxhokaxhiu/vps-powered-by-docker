#!/bin/bash

# Configuration variables
GOGS_DOMAIN="$(basename -- "$0" .sh)"
GOGS_SSHPORT="10022"
LETSENCRYPT_EMAIL="foo@bar.mail"
GOGS_WITHCICD=true
DRONE_DOMAIN="drone.$GOGS_DOMAIN"
DRONE_SECRET="3ada3f2b-94c5-463d-bbb8-97991054687a"
DRONE_SERVER_NAME="drone-server"
DRONE_AGENT_NAME="drone-agent"

# Prepare the gogs data folders
echo ">> Creating /srv/data/$GOGS_DOMAIN folder..."
mkdir -p "/srv/data/$GOGS_DOMAIN" &>/dev/null

# Install Gogs
echo ">> Running Gogs..."
docker run \
    --restart=always \
    --name="$GOGS_DOMAIN" \
    -d \
    -l "com.dnsdock.alias=$GOGS_DOMAIN" \
    -p "$GOGS_SSHPORT:22" \
    -e "VIRTUAL_HOST=$GOGS_DOMAIN" \
    -e "VIRTUAL_PORT=3000" \
    -e "LETSENCRYPT_HOST=$GOGS_DOMAIN" \
    -e "LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL" \
    -v "/srv/data/$GOGS_DOMAIN:/data" \
    gogs/gogs &>/dev/null

# Wait until the docker is up and running
echo -n ">> Waiting for Gogs to start..."
while [ ! $(docker top $GOGS_DOMAIN &>/dev/null && echo $?) ]
do
    echo -n "."
    sleep 0.5
done
echo "started!"

# Run CICD if enabled
if [ $GOGS_WITHCICD == true ]; then
  # Prepare the Drone data folders
  echo ">> Creating /srv/data/$DRONE_DOMAIN folder..."
  mkdir -p "/srv/data/$DRONE_DOMAIN" &>/dev/null

  # Run the Drone server
  echo ">> Running Drone Server..."
  docker run \
    --restart=always \
    --name="$DRONE_SERVER_NAME" \
    -d \
    -l "com.dnsdock.alias=$DRONE_DOMAIN" \
    -e "DRONE_SERVER_ADDR=0.0.0.0:80" \
    -e "DRONE_OPEN=true" \
    -e "DRONE_HOST=http://${DRONE_DOMAIN}" \
    -e "DRONE_ADMIN=gogs" \
    -e "DRONE_SECRET=${DRONE_SECRET}" \
    -e "DRONE_GOGS=true" \
    -e "DRONE_GOGS_URL=http://$GOGS_DOMAIN:3000" \
    -e "DRONE_GOGS_GIT_USERNAME=gogs" \
    -e "DRONE_GOGS_GIT_PASSWORD=gogs" \
    -e "VIRTUAL_HOST=$DRONE_DOMAIN" \
    -e "VIRTUAL_PORT=80" \
    -e "LETSENCRYPT_HOST=$DRONE_DOMAIN" \
    -e "LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL" \
    -v "/srv/data/$DRONE_DOMAIN:/var/lib/drone/" \
    drone/drone &>/dev/null

  # Wait until the docker is up and running
  echo -n ">> Waiting for Drone server to start..."
  while [ ! $(docker top $DRONE_SERVER_NAME &>/dev/null && echo $?) ]
  do
      echo -n "."
      sleep 0.5
  done
  echo "started!"

  # Run the Drone agent
  echo ">> Running Drone Agent..."
  docker run \
    --restart=always \
    --name="$DRONE_AGENT_NAME" \
    -d \
    -e "DRONE_SERVER=${DRONE_DOMAIN}:9000" \
    -e "DRONE_SECRET=${DRONE_SECRET}" \
    -v "/var/run/docker.sock:/var/run/docker.sock" \
    drone/agent &>/dev/null

  # Wait until the docker is up and running
  echo -n ">> Waiting for Drone agent to start..."
  while [ ! $(docker top $DRONE_AGENT_NAME &>/dev/null && echo $?) ]
  do
      echo -n "."
      sleep 0.5
  done
  echo "started!"
fi

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. Have a nice day!"
echo ">> URL: http://${GOGS_DOMAIN}/"
echo ">> SSH: ssh://git@${GOGS_DOMAIN}:${GOGS_SSHPORT}/username/myrepo.git"
if [ $GOGS_WITHCICD == true ]; then
echo ">> PLEASE CREATE THIS ADMIN USER IF YOU WANT TO USE THE CICD:"
echo ">> Username: gogs"
echo ">> Password: gogs"
echo ""
echo "CICD Environment:"
echo ">> URL: http://${DRONE_DOMAIN}/"
echo ">> Username: gogs"
echo ">> Password: gogs"
fi
echo "-----------------------------------------------------"
