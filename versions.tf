terraform {
  required_providers {
    hcloud = {
      source = "hetznercloud/hcloud"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
  required_version = ">= 0.13"
}
