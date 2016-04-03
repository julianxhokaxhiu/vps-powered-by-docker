# vps-powered-by-docker
Arch Linux setup script to obtain a full VPS with Mail and Rancher server without pain

## Stack
- Git ( https://git-scm.com/ )
- Docker ( https://www.docker.com/ )
- Rancher 1.0 as Docker Server management ( http://rancher.com/ )
- Poste as Mail Server ( https://poste.io )
- [apache-nginx-referral-spam-blacklist](https://github.com/Stevie-Ray/apache-nginx-referral-spam-blacklist) preloaded for every host

## Usage
```
wget https://raw.githubusercontent.com/julianxhokaxhiu/vps-powered-by-docker/master/install.sh
```

Edit the [configuration variables](https://github.com/julianxhokaxhiu/vps-powered-by-docker/blob/master/install.sh#L3) to fit your needs, then

```
chmod +x install.sh
./install.sh
```

## Links
- http://docker.lan/ for the Rancher Server
- https://mail.lan/admin/login for the Mail Server Admin panel
- http://mail.lan/ or https://mail.lan/ for the Email access

## Disclaimer
- The domains in the [Links](#links) section depends on your configuration that you may have done before running the `install.sh` script. By default, it assumes the ones declared in the script.
- The mapping of the domains to the Host IP is considered done already externally to this project ( through DNS Server or statically inside your `hosts` file )
