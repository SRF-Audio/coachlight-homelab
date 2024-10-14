# docker-homelab
Repo for all of my homelab configurations

## Directions for Use

### TailScale

The whole homelab will be setup using [TailScale](https://tailscale.com).

#### Synology

To get Synology setup on TailScale with https:
- Install Tailscale from the Package Manager in the GUI
- `ssh stephenfroeber@srfaudio.rohu-shark.ts.net`
- `tailscale cert srfaudio.rohu-shark.ts.net`
- `sudo cp ~/srfaudio.rohu-shark.ts.net.crt /usr/syno/etc/certificate/system/default/cert.pem`
- `sudo cp ~/srfaudio.rohu-shark.ts.net.key /usr/syno/etc/certificate/system/default/privkey.pem`
- Reboot Synology

### Prerequisites

#### 1Password

- [1Password CLI](https://developer.1password.com/docs/cli/get-started/)

All files ending in .tpl must be run through the [`op inject`](https://developer.1password.com/docs/cli/secrets-config-files/) command first before they can be used.

Example:
`op inject -i debian-docker-host-preseed.cfg.tpl -o debian-docker-host-preseed.cfg`


#### Synology
