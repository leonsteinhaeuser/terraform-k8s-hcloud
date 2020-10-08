# define a cloud network

resource "hcloud_network" "hetzner_kubernetes_private_network" {
  name = "k8s-net"
  ip_range = var.hetzner_machine_network
}

## create a subnet based on the cloud network
resource "hcloud_network_subnet" "master" {
  network_id = hcloud_network.hetzner_kubernetes_private_network.id
  type = "cloud"
  network_zone = "eu-central"
  ip_range   = var.hetzner_machine_network_subnet_range
}

#data "hcloud_network" "hetzner_kubernetes_private_network" {
#  with_selector = format("private_network=%s", var.hetzner_machine_label_type_private_network)
#}

