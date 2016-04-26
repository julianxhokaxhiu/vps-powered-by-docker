# vps-powered-by-docker
Arch Linux setup script to obtain a full VPS with Automatic Reverse Proxy without pain

## Stack
- IPv4/IPv6 support ( Dual Stack )
- [Git](https://git-scm.com/)
- [Docker](https://www.docker.com/)
- [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy) as Reverse Proxy
- [jrcs/letsencrypt-nginx-proxy-companion](https://hub.docker.com/r/jrcs/letsencrypt-nginx-proxy-companion/) as automatic Let's Encrypt provisioner ( official companion docker for jwilder/nginx-proxy )
- [apache-nginx-referral-spam-blacklist](https://github.com/Stevie-Ray/apache-nginx-referral-spam-blacklist) preloaded for every host

## Modules
- [Poste](https://poste.io) ( [mail_server.sh](modules/mail_server.sh) )

## Requirements
A clean Arch Linux install with SSH capability as root user ( or any user which has sudo powers ).

## Installation
```
wget https://raw.githubusercontent.com/julianxhokaxhiu/vps-powered-by-docker/master/install.sh
chmod -r +x *.sh
./install.sh
```

## Module setup
Edit the configuration variables to fit your needs, inside every module, then
```
./modules/<module_name>.sh # example ./modules/mail_server.sh
```

## Disclaimer
- The mapping of the domains to the Host IP is considered done already externally to this project ( through DNS Server or statically inside your `hosts` file )
