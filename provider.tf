terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
    }
  }
}

data "digitalocean_ssh_key" "terraform" {
  name = "do"
}

provider "digitalocean" {
  token = var.access_token
}

variable "access_token" {}
variable "private_key" {}