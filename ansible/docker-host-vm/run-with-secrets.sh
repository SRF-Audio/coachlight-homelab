#!/bin/bash

# Define the base directory relative to the current directory
BASE_DIR=$(pwd)

# Ensure the outputs directory exists
mkdir -p "$BASE_DIR/outputs"

# Define paths to your template files and the output files
PRESEED_TEMPLATE="$BASE_DIR/debian-docker-host-preseed.cfg.tpl"
PRESEED_OUTPUT="$BASE_DIR/outputs/debian-docker-host-preseed.cfg"

# Check if 1Password CLI is installed
if ! command -v op &>/dev/null; then
    echo "1Password CLI (op) could not be found. Please install it to proceed."
    exit 1
fi

# Authenticate with 1Password CLI if needed
if ! op whoami &>/dev/null; then
    echo "You are not signed in to 1Password CLI. Please sign in."
    op signin
fi

# Inject secrets into the preseed template
echo "Injecting secrets into Debian preseed template..."
op inject -i "$PRESEED_TEMPLATE" -o "$PRESEED_OUTPUT"
if [ $? -ne 0 ]; then
    echo "Failed to inject secrets into the Debian preseed configuration."
    exit 1
else
    echo "Debian preseed configuration is ready."
fi

# Retrieve playbook secrets and export them
echo "Retrieving secrets..."
export PROXMOX_API_TOKEN_SECRET=$(op read "op://HomeLab/ProxMox Server/API Tokens/2cnt647gewnu2urx6di5grvk7e")
export PROXMOX_HOST=$(op read "op://HomeLab/ProxMox Server/macmini1")
export MAC_ADDRESS=$(op read "op://HomeLab/coachlight-homelab SSH key/docker host vm/mac address")

ansible-playbook ./proxmox-docker-host.yml --extra-vars "proxmox_host=$PROXMOX_HOST proxmox_api_token=$PROXMOX_API_TOKEN_SECRET mac_address=$MAC_ADDRESS"

rm -rf ./outputs
