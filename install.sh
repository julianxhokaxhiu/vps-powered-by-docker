#!/bin/bash

# Configuration variables
RANCHER_DOMAIN="docker.lan"
RANCHER_SERVER_NAME="rancher-server"
RANCHER_AGENT_NAME="rancher-agent"
MAILSERVER_DOMAIN="mail.lan"
MAILSERVER_NAME="mail-server"

# Install Docker
echo ">> Installing required packages..."
yes '' | pacman -Sy --noprogressbar --noconfirm --needed docker openssl git wget &>/dev/null

# Enable and Start docker host service
echo ">> Enabling docker service..."
systemctl enable docker.service &>/dev/null
systemctl start docker.service &>/dev/null

# Prepare the Automatic Reverse proxy manager certs folder
echo ">> Creating /srv/certs folder..."
mkdir -p /srv/certs &>/dev/null

# Create self-signed certificate for mail server
echo ">> Generating $MAILSERVER_DOMAIN self-signed certificate..."
openssl req \
    -subj "/O=Mail Server/CN=$MAILSERVER_DOMAIN" \
    -newkey rsa:2048 -nodes -keyout "/srv/certs/$MAILSERVER_DOMAIN.key" \
    -x509 -days 365 -out "/srv/certs/$MAILSERVER_DOMAIN.crt" &>/dev/null

# Prepare the generic git projects container folder
echo ">> Creating /srv/git folder..."
mkdir -p /srv/git &>/dev/null

# Clone the referrals spam protection
echo ">> Cloning the referrals spam protection project into /srv/git/apache-nginx-referral-spam-blacklist"
git clone https://github.com/Stevie-Ray/apache-nginx-referral-spam-blacklist.git /srv/git/apache-nginx-referral-spam-blacklist &>/dev/null

# Prepare the generic template container folder
echo ">> Creating /srv/tmpl folder..."
mkdir -p /srv/tmpl &>/dev/null

# Get the new nginx template for the reverse proxy
echo ">> Getting the nginx template for the reverse proxy which includes referrals spam protection..."
wget -P /srv/tmpl/ https://raw.githubusercontent.com/julianxhokaxhiu/vps-powered-by-docker/master/nginx.tmpl &>/dev/null

# Prepare the generic vhost container folder
echo ">> Creating /srv/vhost folder..."
mkdir -p /srv/vhost &>/dev/null

# Install Automatic Reverse proxy manager
echo ">> Running Reverse Proxy docker..."
docker run \
    --restart=always \
    --name=docker-auto-reverse-proxy \
    -d \
    -p 80:80 \
    -p 443:443 \
    -v /srv/certs:/etc/nginx/certs \
    -v /srv/tmpl/nginx.tmpl:/app/nginx.tmpl:ro \
    -v /srv/vhost/:/etc/nginx/vhost.d:ro \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    jwilder/nginx-proxy &>/dev/null

# Install Rancher Server
echo ">> Running Rancher Server..."
docker run \
    --restart=always \
    --name="$RANCHER_SERVER_NAME" \
    -d \
    -e "CATTLE_API_HOST=http://$RANCHER_SERVER_NAME:8080" \
    -e "VIRTUAL_HOST=$RANCHER_DOMAIN" \
    -e "VIRTUAL_PORT=8080" \
    rancher/server:v1.0.0 &>/dev/null

# Register Rancher Agent
echo ">> Running Rancher Agent..."
docker run \
    --name="register-$RANCHER_AGENT_NAME" \
    --link=$RANCHER_SERVER_NAME \
    --privileged \
    -d \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/lib/rancher:/var/lib/rancher \
    rancher/agent:v0.11.0 "http://$RANCHER_SERVER_NAME:8080/v1" &>/dev/null

# Wait until the rancher agent is up and running
echo -n ">> Waiting for Rancher Agent to start..."
while [ ! $(docker top $RANCHER_AGENT_NAME &>/dev/null && echo $?) ]
do
    echo -n "."
    sleep 0.5
done
echo "started!"

# Push the rancher-server IP to the rancher-agent ( dirty patch until it's officially fixed )
echo ">> Creating the Unit to link Rancher Agent to Rancher Server locally..."
echo "[Unit]
Description=Patch Ranger Agent Hosts with Rancher Server IP ( dirty way to link them )
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
ExecStart=/usr/bin/bash -c \"/usr/bin/echo \\\"\$(/usr/bin/docker inspect --format '{{ .NetworkSettings.IPAddress }}' $RANCHER_SERVER_NAME) $RANCHER_SERVER_NAME\\\" >> /var/lib/docker/containers/\$(/usr/bin/docker inspect --format '{{ .Id }}' $RANCHER_AGENT_NAME)/hosts\"

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/patch-rancher-agent-hosts.service
# Do it on every reboot
systemctl enable patch-rancher-agent-hosts.service &>/dev/null
# And do it now please :)
systemctl start patch-rancher-agent-hosts.service &>/dev/null

# Prepare the Mail Server data folder
echo ">> Creating /srv/mail folder..."
mkdir -p /srv/mail &>/dev/null

# Install the Mail Server
echo ">> Running Mail server..."
docker run \
    -d \
    --name="$MAILSERVER_NAME" \
    --restart=always \
    --expose=80 \
    --expose=443 \
    -p 25:25 \
    -p 110:110 \
    -p 143:143 \
    -p 465:465 \
    -p 587:587 \
    -p 993:993 \
    -p 995:995 \
    -v /etc/localtime:/etc/localtime:ro \
    -v /srv/mail:/data \
    -e "VIRTUAL_HOST=$MAILSERVER_DOMAIN" \
    -e "VIRTUAL_PROTO=https" \
    -e "VIRTUAL_PORT=443" \
    analogic/poste.io &>/dev/null

# Wait until the mail server is up and running
echo -n ">> Waiting for Mail server to start..."
while [ ! $(docker top $MAILSERVER_NAME &>/dev/null && echo $?) ]
do
    echo -n "."
    sleep 0.5
done
echo "started!"

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. It's truly suggested to reboot now your system to get everything up and running."
echo "Have a nice day!"
echo "-----------------------------------------------------"