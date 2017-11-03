# vps-powered-by-docker
Arch Linux setup script to obtain a full VPS with Automatic Reverse Proxy without pain

## Stack
- IPv4/IPv6 support ( Dual Stack )
- [Docker](https://www.docker.com/)
- [CenturyLinkLabs/watchtower](https://github.com/CenturyLinkLabs/watchtower) as the Docker auto-update manager
- [julianxhokaxhiu/docker-nginx-reloaded](https://github.com/julianxhokaxhiu/docker-nginx-reloaded) as Reverse Proxy, DNS and Autodiscovery manager

## Modules
- [ampache](http://ampache.org/) ( [ampache.lan.sh](modules/ampache.lan.sh) )
- Atlassian Stack: [JIRA](https://www.atlassian.com/software/jira) + [Confluence](https://www.atlassian.com/software/confluence) + [BitBucket Server](https://bitbucket.org/product/server) ( [atlassian.lan.sh](modules/atlassian.lan.sh) )
- [DNS Server](https://github.com/julianxhokaxhiu/docker-powerdns) ( [dns.lan.sh](modules/dns.lan.sh) )
- [goaccess](https://goaccess.io/) ( [goaccess.lan.sh](modules/goaccess.lan.sh) )
- [gogs](https://gogs.io/) ( [gogs.lan.sh](modules/gogs.lan.sh) )
- [koel](https://koel.phanan.net/) ( [koel.lan.sh](modules/koel.lan.sh) )
- [Lineage](http://lineageos.org/) [CI/CD](https://github.com/julianxhokaxhiu/docker-lineage-cicd) + [OTA](https://github.com/julianxhokaxhiu/LineageOTA) ( [lineage.lan.sh](modules/lineage.lan.sh) )
- [Poste](https://poste.io) ( [mail.lan.sh](modules/mail.lan.sh) )
- [Nextcloud](https://nextcloud.com/) ( [nextcloud.lan.sh](modules/nextcloud.lan.sh) )
- [ownCloud](https://owncloud.org/) ( [owncloud.lan.sh](modules/owncloud.lan.sh) )
- [Portainer](https://github.com/portainer/portainer) ( [portainer.lan.sh](modules/portainer.lan.sh) )
- [Rainloop](http://www.rainloop.net/) ( [rainloop.lan.sh](modules/rainloop.lan.sh) )
- [Typo3](https://typo3.org/) ( [typo3.lan.sh](modules/typo3.lan.sh) )
- [UI for Docker](https://github.com/kevana/ui-for-docker) ( [ui-for-docker.lan.sh](modules/ui-for-docker.lan.sh) )
- [WebDAV](https://hub.docker.com/r/idelsink/webdav/) ( [webdav.lan.sh](modules/webdav.lan.sh) )
- [Winds](http://winds.getstream.io/) ( [winds.lan.sh](modules/winds.lan.sh) )

## Requirements
A clean Arch Linux install with SSH capability as root user ( or any user which has sudo powers ).

## Installation
```bash
wget https://github.com/julianxhokaxhiu/vps-powered-by-docker/archive/master.zip
unzip master.zip && cd vps-powered-by-docker-master
find ./ -name "*.sh" -exec chmod +x {} \;
LETSENCRYPT_EMAIL="foo@bar.mail" ./install.sh
```
> Remember to configure with the right email the `LETSENCRYPT_EMAIL` environment variable.

## Module setup
Edit the configuration variables to fit your needs, inside every module, then
```bash
./modules/<module_name>.sh
# example ./modules/mail.lan.sh
```

## Performance monitoring
Take a look at your Docker status thanks to this awesome CLI tool called [ctop](https://github.com/bcicen/ctop).

## Disclaimer
- The mapping of the domains to the Host IP is considered done already externally to this project ( through DNS Server or statically inside your `hosts` file )
