# vps-powered-by-docker
Arch Linux setup script to obtain a full VPS with Mail and Rancher server without pain

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
- The domains logic depends on your configuration that you may have done before running the `install` script.
- The mapping of the domains to the IP is considered done already externally to this project.
