#!/bin/bash

if [ "$1" == "show" ]; then
  terraform "$@"
else
  terraform "$@" -var "access_token=${DO_PAT}" -var "private_key=$HOME/.ssh/digitalocean"
  if [ "$1" == "apply" ]; then
    echo "Host fluwide
  HostName $(terraform output -json | jq -r '.droplet_ip.value')
  User root
  IdentityFile ~/.ssh/digitalocean" > ~/.ssh/config.d/fluwide
  fi
fi