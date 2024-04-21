#!/bin/bash

# Define the base directory relative to the current directory
BASE_DIR=$(pwd)


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

export GITHUB_SSH_PRIVATE_KEY=$(op read "op://HomeLab/github-ssh/private key")
export VM_SSH_PUBLIC_KEY=$(op read "op://HomeLab/coachlight-homelab SSH key/public key")
export VM_PASSWORD=$(op read "op://HomeLab/coachlight-homelab SSH key/user credentials/password")

ansible-playbook ./docker-host-setup.yml -i ../inventory.yml --extra-vars "GIT_SSH_PRIVATE_KEY=$GITHUB_SSH_PRIVATE_KEY VM_SSH_PUBLIC_KEY=$VM_SSH_PUBLIC_KEY VM_PASSWORD=$VM_PASSWORD"
