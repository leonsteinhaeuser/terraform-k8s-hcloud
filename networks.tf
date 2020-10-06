# define a cloud network
resource "hcloud_network" "k8s_local_net" {
  name = "k8s-net"
  ip_range = var.k8s_network_ip_range
}

# create a subnet based on the cloud network
resource "hcloud_network_subnet" "master" {
  network_id = hcloud_network.k8s_local_net.id
  type = "cloud"
  network_zone = "eu-central"
  ip_range   = var.k8s_network_ip_cluster_subnet_range
}
