# docker-homelab
Repo for all of my Docker service configs

## Directions for Use

### Prerequisites

#### 1Password

- [1Password CLI](https://developer.1password.com/docs/cli/get-started/)

All files ending in .tpl must be run through the [[`op inject`](https://developer.1password.com/docs/cli/secrets-config-files/) command first before they can be used.

Example:
`op inject -i debian-docker-host-preseed.cfg.tpl -o debian-docker-host-preseed.cfg`
