# docker-homelab
Repo for all of my homelab configurations

## Directions for Use

### TailScale

The whole homelab will be setup using [TailScale](https://tailscale.com).

#### ProxMox

The first time you run the Playbook against ProxMox, you may run into ssh not working for the nodes.

Do the following:
- ssh login to the node as `root`
- `sudo adduser stephenfroeber`
- Fill in the same password as the Web UI
- `ssh-copy-id -i ~/.ssh/coachlight-homelab.pub stephenfroeber@<node name>.rohu-shark.ts.net`

#### Synology

To get Synology setup on TailScale with https:
- Install Tailscale from the Package Manager in the GUI
- `ssh stephenfroeber@srfaudio.rohu-shark.ts.net`
- `tailscale cert srfaudio.rohu-shark.ts.net`
- `sudo cp ~/srfaudio.rohu-shark.ts.net.crt /usr/syno/etc/certificate/system/default/cert.pem`
- `sudo cp ~/srfaudio.rohu-shark.ts.net.key /usr/syno/etc/certificate/system/default/privkey.pem`
- Reboot Synology

#### Home Assistant OS

To get Tailscale to always run in HAOS:
- `curl -fsSL https://tailscale.com/install.sh | sh` (It will fail on `rc-update`)
- `sudo tailscaled &`
- `sudo nano /usr/local/bin/start-tailscale.sh` and paste the following:
```
#!/bin/sh
/usr/sbin/tailscaled &
sleep 5
/usr/sbin/tailscale up --authkey <YOUR_AUTH_KEY>
```
- `sudo chmod +x /usr/local/bin/start-tailscale.sh`
- `sudo crontab -e` and add `@reboot /usr/local/bin/start-tailscale.sh`
- `tailscale up`



### Prerequisites

#### 1Password

- [1Password CLI](https://developer.1password.com/docs/cli/get-started/)

All files ending in .tpl must be run through the [`op inject`](https://developer.1password.com/docs/cli/secrets-config-files/) command first before they can be used.

Example:
`op inject -i debian-docker-host-preseed.cfg.tpl -o debian-docker-host-preseed.cfg`


#### Synology


NOTES:
- Don't install Tailscale into the template. It produces duplicate hostname keys in Tailscale. Stop when the VM's have been created.
- Disable firewall in Fedora for Tailscale:
```
sudo firewall-cmd --permanent --zone=trusted --add-interface=tailscale0
sudo firewall-cmd --reload
```
- Rename k8s cluster
- permanently add kubeconfg
