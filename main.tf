# https://registry.terraform.io/providers/hetznercloud/hcloud/latest/docs

# Configure the Hetzner Cloud Provider
provider "hcloud" {
  token = var.hcloud_token
}