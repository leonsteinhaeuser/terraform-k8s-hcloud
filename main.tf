# https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}

variable "ssh_private_key_location" {
    description = "Path to the location where the private key is stored to connect to the machines"
    default     = "~/.ssh/id_rsa"
}