variable "ssh_key_id" {
  type = string
}

variable "private_key" {
  type = string
}

resource "digitalocean_droplet" "fluwide" {
  image    = "ubuntu-20-04-x64"
  name     = "fluwide"
  region   = "fra1"
  size     = "s-1vcpu-2gb"
  ssh_keys = [
    var.ssh_key_id
  ]

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.private_key)
    timeout     = "2m"
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin:/root/code/bin"
    ]
  }
}

resource "digitalocean_firewall" "fluwide" {
  name = "fluwuide-firewall"

  droplet_ids = [digitalocean_droplet.fluwide.id]

  inbound_rule {
    port_range       = "22"
    protocol         = "tcp"
    source_addresses = ["0.0.0.0/0"]
  }

  inbound_rule {
    port_range       = "80"
    protocol         = "tcp"
    source_addresses = ["0.0.0.0/0"]
  }

  inbound_rule {
    port_range       = "443"
    protocol         = "tcp"
    source_addresses = ["0.0.0.0/0"]
  }

  outbound_rule {
    protocol              = "tcp"
    destination_addresses = ["0.0.0.0/0"]
    port_range            = "1-65535"
  }

  outbound_rule {
    protocol              = "udp"
    destination_addresses = ["0.0.0.0/0"]
    port_range            = "1-65535"
  }

  outbound_rule {
    protocol              = "icmp"
    destination_addresses = ["0.0.0.0/0"]
  }
}
