output "print_machine_names_master" {
  value = hcloud_server.k8s_nodes_master.*.name
}

output "print_machine_ipv4_master" {
  value = hcloud_server.k8s_nodes_master.*.ipv4_address
}

output "print_machine_names_worker" {
  value = hcloud_server.k8s_nodes_worker.*.name
}

output "print_machine_ipv4_worker" {
  value = hcloud_server.k8s_nodes_worker.*.ipv4_address
}


/*
# print ipv4 of the first node
output "master_ipv4" {
  value = ["${hcloud_server.k8s_nodes_master.*.ipv4_address}"]
}

output "worker_ipv4" {
  value = ["${hcloud_server.k8s_nodes_worker.*.ipv4_address}"]
}

output "print" {
  value = hcloud_server.k8s_nodes_worker.*.id
}
*/