#!/bin/bash

# Configure Domains
RANCHER_DOMAIN="docker.lan"
MAILSERVER_DOMAIN="mail.lan"

# Install Docker
yes '' | pacman -Sy --noprogressbar --noconfirm --needed docker openssl

# Enable and Start docker host service
systemctl enable docker.service
systemctl start docker.service

# Prepare the Automatic Reverse proxy manager certs folder
mkdir -p /srv/certs

# Create self-signed certificate for mail server
openssl req \
    -subj "/O=Mail Server/CN=$MAILSERVER_DOMAIN" \
    -newkey rsa:2048 -nodes -keyout "/srv/certs/$MAILSERVER_DOMAIN.key" \
    -x509 -days 365 -out "/srv/certs/$MAILSERVER_DOMAIN.crt"

# Install Automatic Reverse proxy manager
docker run \
    --restart=always \
    --name=docker-auto-reverse-proxy \
    -d \
    -p 80:80 \
    -p 443:443 \
    -v /srv/certs:/etc/nginx/certs \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    jwilder/nginx-proxy

# Install Rancher Server
docker run \
    --restart=always \
    --name=rancher-server \
    -d \
    -e "CATTLE_API_HOST=http://rancher-server:8080" \
    -e "VIRTUAL_HOST=$RANCHER_DOMAIN" \
    -e "VIRTUAL_PORT=8080" \
    rancher/server:v1.0.0

# Register Rancher Agent
docker run \
    --name=register-rancher-agent \
    --link=rancher-server \
    --privileged \
    -d \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v /var/lib/rancher:/var/lib/rancher \
    rancher/agent:v0.11.0 http://rancher-server:8080/v1

# Wait until the rancher agent is up and running
until [ "$(/usr/bin/docker inspect -f {{.State.Running}} rancher-agent)"=="true" ]; do
    sleep 0.1;
done;

# Push the rancher-server IP to the rancher-agent ( dirty patch until it's officially fixed )
echo "[Unit]
Description=Patch Ranger Agent Hosts with Rancher Server IP ( dirty way to link them )
After=docker.service
Requires=docker.service

[Service]
Type=oneshot
ExecStart=/usr/bin/bash -c \"/usr/bin/echo \\\"\$(/usr/bin/docker inspect --format '{{ .NetworkSettings.IPAddress }}' rancher-server) rancher-server\\\" >> /var/lib/docker/containers/\$(/usr/bin/docker inspect --format '{{ .Id }}' rancher-agent)/hosts\"

[Install]
WantedBy=multi-user.target" >> /etc/systemd/system/patch-rancher-agent-hosts.service
# Do it on every reboot
systemctl enable patch-rancher-agent-hosts.service
# And do it now please :)
systemctl start patch-rancher-agent-hosts.service

# Prepare the Mail Server data folder
mkdir -p /srv/mail

# Install the Mail Server
docker run \
    -d \
    --name=mail-server \
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
    analogic/poste.io

# Wait until the mail server is up and running
until [ "$(/usr/bin/docker inspect -f {{.State.Running}} rancher-agent)"=="true" ]; do
    sleep 0.1;
done;

# Print friendly done message
echo "All right! Everything seems to be up and running. Enjoy :)"