# define a cloud network
resource "hcloud_network" "k8s_local_net" {
  name = "k8s-net"
  ip_range = "172.16.0.0/12" //172.16.x.x - 172.31.255.255
}

# create a subnet based on the cloud network
resource "hcloud_network_subnet" "master" {
  network_id = hcloud_network.k8s_local_net.id
  type = "cloud"
  network_zone = "eu-central"
  ip_range   = "172.16.0.0/12" // 172.16.0.0 - 172.31.255.255
}
