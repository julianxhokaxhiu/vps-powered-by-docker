#!/bin/bash

# Configuration variables
DNSSERVER_DOMAIN="dns.lan"
DNSSERVER_NAME="dns-server"
LETSENCRYPT_EMAIL="foo@bar.mail"
CUSTOM_DNS="8.8.8.8;8.8.4.4;[2001:4860:4860::8888];[2001:4860:4860::8844]"
API_KEY=""
CRONTAB_TIME="0 10 * * *"
ENABLE_ADBLOCK=false

# Prepare the DNS Server data folder
echo ">> Creating /srv/data/$DNSSERVER_DOMAIN folder..."
mkdir -p "/srv/data/$DNSSERVER_DOMAIN" &>/dev/null

# Enable IPv6 support in Docker
echo ">> Enabling IPv6 support in your Docker service..."
if ! [ -f "/etc/docker/daemon.json" ]; then
  echo "{\"ipv6\": true,\"fixed-cidr-v6\": \"fd00:dead:beef::/48\"}" > /etc/docker/daemon.json
else
  echo -e "\nIMPORTANT! ADD THIS MANUALLY TO YOUR '/etc/docker/daemon.json' FILE:\n\n{\"ipv6\": true,\"fixed-cidr-v6\": \"fd00:dead:beef::/48\"}\n\nTO ENABLE IPV6 SUPPORT IN DOCKER!\n"
fi

# Set IPv6 SLAAC to HWADDR in order to get always the same IPv6 address
echo ">> Setting IPv6 SLAAC to HWADDR modus..."
sed -i 's/slaac private/slaac hwaddr/g' /etc/dhcpcd.conf
systemctl restart dhcpcd.service

# Provide IPv6 NAT feature
echo ">> Enabling IPv6 NAT..."
docker run \
    -d \
    --name="ipv6nat" \
    --restart=always \
    --privileged \
    --net=host \
    -v /lib/modules:/lib/modules:ro \
    -v /var/run/docker.sock:/var/run/docker.sock:ro \
    robbertkl/ipv6nat &>/dev/null

# Install DNS Server
echo ">> Running DNS Server..."
docker run \
    -d \
    --name="$DNSSERVER_DOMAIN" \
    --restart=always \
    -e "API_KEY=$API_KEY" \
    -e "CUSTOM_DNS=$CUSTOM_DNS" \
    -e "CRONTAB_TIME=$CRONTAB_TIME" \
    -e "ENABLE_ADBLOCK=$ENABLE_ADBLOCK" \
    -e "VIRTUAL_HOST=$DNSSERVER_DOMAIN" \
    -e "VIRTUAL_PORT=8080" \
    -e "LETSENCRYPT_HOST=$DNSSERVER_DOMAIN" \
    -e "LETSENCRYPT_EMAIL=$LETSENCRYPT_EMAIL" \
    -p 53:53 \
    -p 53:53/udp \
    -v "/srv/data/$DNSSERVER_DOMAIN:/srv/data" \
    julianxhokaxhiu/docker-powerdns &>/dev/null

# Wait until the docker is up and running
echo -n ">> Waiting for DNS Server to start..."
while [ ! $(docker top $DNSSERVER_DOMAIN &>/dev/null && echo $?) ]
do
    echo -n "."
    sleep 0.5
done
echo "started!"

# Print friendly done message
echo "-----------------------------------------------------"
echo "All right! Everything seems to be installed correctly. Remember to restart the Docker service to have everything working properly. Have a nice day!"
echo ">> URL: https://${DNSSERVER_DOMAIN}/"
echo ">> DNS: TCP/UDP on Port 53"
echo "-----------------------------------------------------"