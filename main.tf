module "droplet" {
  source     = "./droplet"
  ssh_key_id = data.digitalocean_ssh_key.terraform.id
  private_key = var.private_key
}

#output droplet ip from droplet module
output "droplet_ip" {
  value = module.droplet.ip
}
