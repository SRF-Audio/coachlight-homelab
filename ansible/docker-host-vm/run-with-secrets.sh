#!/bin/bash

# Define base directory and ensure output directory exists
BASE_DIR="~/GitHub/coachlight-homelab/ansible/docker-host-vm"
mkdir -p "$BASE_DIR/outputs"

# Define paths to your template files and the output files
PRESEED_TEMPLATE="$BASE_DIR/debian-docker-host-preseed.cfg.tpl"
PRESEED_OUTPUT="$BASE_DIR/outputs/debian-docker-host-preseed.cfg"

PLAYBOOK_TEMPLATE="$BASE_DIR/proxmox-docker-host.yml.tpl"
PLAYBOOK_OUTPUT="$BASE_DIR/outputs/proxmox-docker-host.yml"

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

# Inject secrets into the Ansible playbook template
echo "Injecting secrets into Ansible playbook template..."
op inject -i "$PLAYBOOK_TEMPLATE" -o "$PLAYBOOK_OUTPUT"
if [ $? -ne 0 ]; then
    echo "Failed to inject secrets into the Ansible playbook."
    exit 1
else
    echo "Ansible playbook is ready."
fi

echo "All files have been successfully prepared with secrets."
