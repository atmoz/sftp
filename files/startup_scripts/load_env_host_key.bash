#!/bin/bash

if [[ -n "$SSH_HOST_ED25519_KEY_B64" ]]; then
    echo "Decoding and setting up ED25519 host key..."
    echo "$SSH_HOST_ED25519_KEY_B64" | base64 -d > /etc/ssh/ssh_host_ed25519_key
    ssh-keygen -y -f /etc/ssh/ssh_host_ed25519_key > /etc/ssh/ssh_host_ed25519_key.pub
    chmod 600 /etc/ssh/ssh_host_ed25519_key
    echo "ED25519 host key setup complete."
else
    echo "No ED25519 host key provided."
fi

if [[ -n "$SSH_HOST_RSA_KEY_B64" ]]; then
    echo "Decoding and setting up RSA host key..."
    echo "$SSH_HOST_RSA_KEY_B64" | base64 -d > /etc/ssh/ssh_host_rsa_key
    ssh-keygen -y -f /etc/ssh/ssh_host_rsa_key > /etc/ssh/ssh_host_rsa_key.pub
    chmod 600 /etc/ssh/ssh_host_rsa_key
    echo "RSA host key setup complete."
else
    echo "No RSA host key provided."
fi
