#!/bin/bash

# Install Docker, only for Arch
PACKAGES="docker"
echo ">> Installing required packages..."
if [ -f "/etc/arch-release" ]; then
  yes '' | pacman -Sy --noprogressbar --noconfirm --needed $PACKAGES &>/dev/null
else
  echo "[WARNING] It seems you are not running Arch Linux. Please make sure the following packages are installed: $PACKAGES"
fi

# Enable and Start docker host service
echo ">> Enabling docker service..."
systemctl enable docker.service &>/dev/null
systemctl start docker.service &>/dev/null

# Prepare required directories
echo ">> Preparing required folders..."
mkdir -p /srv/acme &>/dev/null
mkdir -p /srv/certs &>/dev/null
mkdir -p /srv/vhost &>/dev/null
mkdir -p /srv/htpasswd &>/dev/null

# Install Automatic Reverse proxy manager, DNS and Autodiscovery
echo ">> Running Reverse Proxy manager..."
docker run \
    --restart=always \
    --name=docker-reverse-proxy \
    -d \
    -e "ACCOUNT_EMAIL=$LETSENCRYPT_EMAIL" \
    -p 172.17.0.1:53:53/udp \
    -p 80:80 \
    -p 443:443 \
    -v /srv/acme:/etc/acme.le \
    -v /srv/certs:/etc/nginx/certs \
    -v /srv/vhost:/etc/nginx/vhost.d \
    -v /srv/htpasswd:/etc/nginx/htpasswd \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    julianxhokaxhiu/docker-nginx-reloaded &>/dev/null

# Wait for the docker to be up and running
while [ ! -f /srv/certs/dhparam.pem ]
do
    sleep 0.5
done

# Autoupdate Dockers from time to time and cleanup old images
echo ">> Running Docker Auto-Update manager..."
docker run \
  --restart=always \
  --name=docker-autoupdate \
  -d \
  -v /var/run/docker.sock:/var/run/docker.sock \
  v2tec/watchtower --cleanup &>/dev/null

# Preparing the DNS service for containers
echo ">> Enabling Auto Discovery..."
if ! [ -f "/etc/docker/daemon.json" ]; then
  echo "{\"bip\": \"172.17.0.1/24\",\"dns\": [\"172.17.0.1\"]}" > /etc/docker/daemon.json
else
  echo -e "\nIMPORTANT! ADD THIS MANUALLY TO YOUR '/etc/docker/daemon.json' FILE:\n\n{\"bip\": \"172.17.0.1/24\",\"dns\": [\"172.17.0.1\"]}\n\nTO ENABLE THE AUTO DISCOVERY!\n"
fi

# Restart the whole docker service to finalize the setup
echo ">> Restarting Docker Daemon to complete the setup..."
systemctl restart docker.service &>/dev/null

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. Have a nice day!"
echo "-----------------------------------------------------"