#!/bin/bash

# Install Docker, only for Arch
PACKAGES="docker git wget"
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

# Prepare the Automatic Reverse proxy manager certs folder
echo ">> Creating /srv/certs folder..."
mkdir -p /srv/certs &>/dev/null

# Prepare the generic git projects container folder
echo ">> Creating /srv/git folder..."
mkdir -p /srv/git &>/dev/null

# Clone the referrals spam protection
echo ">> Cloning the referrals spam protection project into /srv/git/apache-nginx-referral-spam-blacklist..."
git clone https://github.com/Stevie-Ray/apache-nginx-referral-spam-blacklist.git /srv/git/apache-nginx-referral-spam-blacklist &>/dev/null

# Prepare the generic template container folder
echo ">> Creating /srv/tmpl folder..."
mkdir -p /srv/tmpl &>/dev/null

# Get the new nginx template for the reverse proxy
echo ">> Getting the nginx template for the reverse proxy which includes referrals spam protection..."
wget -q https://raw.githubusercontent.com/julianxhokaxhiu/vps-powered-by-docker/master/nginx.tmpl -O /srv/tmpl/nginx.tmpl &>/dev/null

# Get the nginx proxy custom configuration
echo ">> Getting the nginx custom proxy configuration..."
wget -q https://raw.githubusercontent.com/julianxhokaxhiu/vps-powered-by-docker/master/proxy.conf -O /srv/tmpl/proxy.conf &>/dev/null

# Prepare the generic vhost container folder
echo ">> Creating /srv/vhost folder..."
mkdir -p /srv/vhost &>/dev/null

# Preparing the DNS service for containers
echo ">> Enabling DNS Container Discovery..."
if ! [ -f "/etc/docker/daemon.json" ]; then
  echo "{\"bip\": \"172.17.0.1/24\",\"dns\": [\"172.17.0.1\"]}" > /etc/docker/daemon.json
else
  echo -e "\nIMPORTANT! ADD THIS MANUALLY TO YOUR '/etc/docker/daemon.json' FILE:\n\n{\"bip\": \"172.17.0.1/24\",\"dns\": [\"172.17.0.1\"]}\n\nTO ENABLE CONTAINER DISCOVERY IN DOCKER!\n"
fi

# Run the DNS container
echo ">> Running DNS Container Discovery..."
docker run \
  --restart=always \
  --name=docker-auto-dnsdiscovery \
  -d \
  -p 172.17.0.1:53:53/udp \
  -v /var/run/docker.sock:/var/run/docker.sock \
  julianxhokaxhiu/dnsdock --nameserver="8.8.8.8:53" --nameserver="8.8.4.4:53" --alias &>/dev/null

# Install Automatic Reverse proxy manager
echo ">> Running Reverse Proxy manager..."
docker run \
    --restart=always \
    --name=docker-auto-reverse-proxy \
    -d \
    -p 80:80 \
    -p 443:443 \
    -e "ENABLE_IPV6=true" \
    -v /usr/share/nginx/html \
    -v /srv/certs:/etc/nginx/certs:ro \
    -v /srv/tmpl/nginx.tmpl:/app/nginx.tmpl:ro \
    -v /srv/tmpl/proxy.conf:/etc/nginx/proxy.conf:ro \
    -v /srv/vhost/:/etc/nginx/vhost.d \
    -v /srv/git/apache-nginx-referral-spam-blacklist/referral-spam.conf:/etc/nginx/referral-spam.conf:ro \
    -v /var/run/docker.sock:/tmp/docker.sock:ro \
    jwilder/nginx-proxy:alpine &>/dev/null

# Install the Let's Encrypt Reverse Proxy companion
echo ">> Running Let's Encrypt Reverse Proxy companion..."
docker run \
  --restart=always \
  --name=docker-auto-reverse-proxy-companion \
  -d \
  -v /srv/certs:/etc/nginx/certs:rw \
  --volumes-from docker-auto-reverse-proxy \
  -v /var/run/docker.sock:/var/run/docker.sock:ro \
  jrcs/letsencrypt-nginx-proxy-companion &>/dev/null

# Autoupdate Dockers from time to time and cleanup old images
echo ">> Running Docker Auto-Update manager..."
docker run \
  --restart=always \
  --name=docker-autoupdate \
  -d \
  -v /var/run/docker.sock:/var/run/docker.sock \
  v2tec/watchtower --cleanup &>/dev/null

# Restart the whole docker service to finalize the setup
echo ">> Restarting Docker Daemon to complete the setup..."
systemctl restart docker.service &>/dev/null

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. Have a nice day!"
echo "-----------------------------------------------------"