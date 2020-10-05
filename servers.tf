##################################################
#                                                #
# server definition for worker and master nodes  #
#                                                #
##################################################

resource "hcloud_server" "k8s_nodes_master" {
  count       = var.k8s_master_count
  name        = format("%s-%d", var.k8s_master_machine_prefix, count.index + 1)
  server_type = var.k8s_master_machine_type
  image       = var.k8s_machine_operation_system
  #datacenter  = var.k8s_hetzner_datacenter
  #datacenter  = "fsn1"
  backups     = var.k8s_machine_master_backups
  ssh_keys    = [hcloud_ssh_key.k8s_admin.id]

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.ssh_private_key)
  }

  provisioner "file" {
    source      = "scripts/install.sh"
    destination = "/root/install.sh"
  }

  provisioner "file" {
    source = "configs/kubeadm.conf"
    destination = "/root/kubeadm.conf"
  }

  provisioner "remote-exec" {
    inline = ["bash /root/install.sh"]
  }

  provisioner "file" {
    source = "scripts/init-cluster.sh"
    destination = "/root/init-cluster.sh"
  }

  # provisio
  provisioner "remote-exec" {
    inline = ["bash /root/init-cluster.sh ${var.k8s_network_ip_range}"]
  }
}

resource "hcloud_server" "k8s_nodes_worker" {
  count       = var.k8s_worker_count
  name        = format("%s-%d", var.k8s_worker_machine_prefix, count.index + 1)
  server_type = var.k8s_worker_machine_type
  image       = var.k8s_machine_operation_system
  #datacenter  = var.k8s_hetzner_datacenter
  #datacenter  = "fsn1"
  backups     = var.k8s_machine_worker_backups
  ssh_keys    = [hcloud_ssh_key.k8s_admin.id]

  connection {
    host        = self.ipv4_address
    user        = "root"
    type        = "ssh"
    private_key = file(var.ssh_private_key)
  }

  provisioner "file" {
    source      = "scripts/install.sh"
    destination = "/root/install.sh"
  }

  provisioner "file" {
    source = "configs/kubeadm.conf"
    destination = "/root/kubeadm.conf"
  }

  provisioner "remote-exec" {
    inline = ["bash /root/install.sh"]
  }

  provisioner "local-exec" {
    inline = ["bash scripts/lvl-create-dns-entry.sh ${self.ipv4_address} ${self.name}"]
  }
}

##################################################
#                                                #
# server definition for worker and master nodes  #
#                                                #
##################################################
/*
resource "hcloud_server_network" "k8s_master_network" {
  server_id = hcloud_server.k8s_nodes_master.*.id
  subnet_id = hcloud_network_subnet.master.id
}

resource "hcloud_server_network" "k8s_nodes_worker" {
  server_id = hcloud_server.k8s_nodes_worker.*.id
  subnet_id = hcloud_network_subnet.master.id
}
*/
/*





# defines the server
resource "hcloud_server" "k8s_nodes" {
  count = $(var.k8s_master_count)
  name        = "k8s-node-0"
  server_type = "cx11"
  image       = "debian-10"
  datacenter = "fsn1"
  ssh_keys = ["${hcloud_ssh_key.admin-*.id}"]

  connection {
    private_key = "${file(var.ssh_private_key)}"
  }

  
  # 







  # define the installation script
  provisioner "file" {
    source      = "scripts/install-docker.sh"
    destination = "/root/install-docker.sh"
  }

  # execute the installation on the remote host
  provisioner "remote-exec" {
    inline = "DOCKER_VERSION=${var.docker_version} bash /root/bootstrap.sh"
  }
}



*/


## attach a server resource to a load balancer 
#resource "hcloud_load_balancer_target" "load_balancer_target" {
#  type             = "server"
#  load_balancer_id = "${hcloud_load_balancer.load_balcancer.id}"
#  server_id        = "${hcloud_server.k8s_node_1.id}"
#}