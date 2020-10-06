# https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}

variable "ssh_private_key" {
    description = "Path to the location where the private key is stored to connect to the machines"
    default     = "~/.ssh/id_rsa"
    type = string
}

variable "ssh_public_key" {
  description = "Public Key to authorized the access for the machines"
  default     = "~/.ssh/id_rsa.pub"
  type = string
}

variable "ssh_username" {
  description = "Username that should be used to connect to the nodes"
  default = "root"
  type = string
}