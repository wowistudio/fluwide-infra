#!/bin/bash

if [ "$1" == "show" ]; then
  terraform "$@"
else
  terraform "$@" -var "access_token=${DO_PAT}" -var "private_key=$HOME/.ssh/digitalocean"
  if [ "$1" == "apply" ]; then
    echo $(terraform output -json | jq -r '.droplet_ip.value') > droplet_ip.txt
  fi
fi