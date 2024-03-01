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

  provisioner "file" {
    source      = "../files/fluwidecom.conf"
    destination = "/etc/nginx/sites-available/fluwidecom.conf"
  }

  provisioner "file" {
    source      = "../files/jeroenlife.conf"
    destination = "/etc/nginx/sites-available/jeroenlife.conf"
  }

  provisioner "file" {
    source      = "../files/jeroenlife-cert.pem"
    destination = "/etc/ssl/jeroenlife-cert.pem"
  }

  provisioner "file" {
    source      = "../files/jeroenlife-key.pem"
    destination = "/etc/ssl/jeroenlife-key.pem"
  }

  provisioner "file" {
    source      = "../files/fluwide-cert.pem"
    destination = "/etc/ssl/fluwide-cert.pem"
  }

  provisioner "file" {
    source      = "../files/fluwide-key.pem"
    destination = "/etc/ssl/fluwide-key.pem"
  }

  provisioner "file" {
    source      = "../files/cloudflare.crt"
    destination = "/etc/ssl/cloudflare.crt"
  }

  provisioner "remote-exec" {
    inline = [
      "export PATH=$PATH:/usr/bin",
      # install nginx
      "sudo apt update",
      "sudo apt install -y nginx",

      # install docker on the machine
      "sudo apt-get update",
      "sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common",
      "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -",
      "sudo add-apt-repository \"deb [arch=amd64] https://download.docker.com/linux/ubuntu focal stable\"",
      "apt-cache policy docker-ce",
      "sudo apt install -y docker-ce",
      "sudo systemctl status docker",

      # if you want to let user xxx run docker without sudo
      # "sudo usermod -aG docker xxx"
      # "su - xxx"
      # "groups"
      "docker pull jphuisman92/fluwide:latest",
      "docker run -p 3000:3000 -d jphuisman92/fluwide:latest",
      "docker pull jphuisman92/jeroenlife:latest",
      "docker run -p 4000:3000 -d jphuisman92/jeroenlife:latest",
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
