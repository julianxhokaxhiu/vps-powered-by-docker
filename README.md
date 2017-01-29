# vps-powered-by-docker
Arch Linux setup script to obtain a full VPS with Automatic Reverse Proxy without pain

## Stack
- IPv4/IPv6 support ( Dual Stack )
- [Git](https://git-scm.com/)
- [Docker](https://www.docker.com/)
- [CenturyLinkLabs/watchtower](https://github.com/CenturyLinkLabs/watchtower) as the Docker auto-update manager
- [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy) as Reverse Proxy
- [alastaircoote/docker-letsencrypt-nginx-proxy-companion](https://github.com/alastaircoote/docker-letsencrypt-nginx-proxy-companion) as automatic Let's Encrypt provisioner ( official companion docker for jwilder/nginx-proxy )
- [apache-nginx-referral-spam-blacklist](https://github.com/Stevie-Ray/apache-nginx-referral-spam-blacklist) preloaded for every host

## Modules
- [Poste](https://poste.io) ( [mail_server.sh](modules/mail_server.sh) )
- [UI for Docker](https://github.com/kevana/ui-for-docker) ( [ui_for_docker.sh](modules/ui_for_docker.sh) )
- [Rainloop](http://www.rainloop.net/) ( [rainloop.sh](modules/rainloop.sh) )
- [Winds](http://winds.getstream.io/) ( [getstream_winds.sh](modules/getstream_winds.sh) )
- [Lineage](http://lineageos.org/) [CI/CD](https://github.com/julianxhokaxhiu/docker-lineage-cicd) + [OTA](https://github.com/julianxhokaxhiu/LineageOTA) ( [lineage_cicd_ota.sh](modules/lineage_cicd_ota.sh) )
- [DNS Server](https://github.com/julianxhokaxhiu/docker-powerdns) ( [dns_server.sh](modules/dns_server.sh) )

## Requirements
A clean Arch Linux install with SSH capability as root user ( or any user which has sudo powers ).

## Installation
```bash
wget https://github.com/julianxhokaxhiu/vps-powered-by-docker/archive/master.zip
unzip master.zip && cd vps-powered-by-docker-master
find ./ -name "*.sh" -exec chmod +x {} \;
./install.sh
```

## Module setup
Edit the configuration variables to fit your needs, inside every module, then
```bash
./modules/<module_name>.sh
# example ./modules/mail_server.sh
```

## Disclaimer
- The mapping of the domains to the Host IP is considered done already externally to this project ( through DNS Server or statically inside your `hosts` file )
