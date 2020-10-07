resource "hcloud_load_balancer" "load_balancer" {
  name       = var.k8s_loadbalancer_name
  load_balancer_type = var.k8s_loadbalancer_type
  location   = var.k8s_loadbalancer_location
  count = "${var.hetzner_master_count > 1 ? 1 : 0}"

  target {
    type = "server"
    server_id = hcloud_server.k8s_nodes_master.*.id
  }

#  provisioner "local-exec" {
#    command = "scripts/lvl-create-dns-entry.sh ${self.ipv4} ${var.k8s_external_kubernetes_address} ${var.autodns_brearer_token}"
#  }
}