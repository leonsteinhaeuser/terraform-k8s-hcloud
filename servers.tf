##################################################
#                                                #
# server definition for worker and master nodes  #
#                                                #
##################################################

resource "hcloud_server" "k8s_nodes_master" {
  count       = var.hetzner_master_count
  name        = format("%s-%d", var.hetzner_master_machine_prefix, count.index + 1)
  server_type = var.hetzner_master_machine_type
  image       = var.hetzner_machine_operation_system
  datacenter  = var.hetzner_datacenter
  backups     = var.hetzner_machine_master_backups
  ssh_keys    = [hcloud_ssh_key.k8s_admin.id]
  labels      = {
    machine_type=var.hetzner_machine_label_type_master, 
    network_name=var.hetzner_machine_label_type_private_network
  }

  connection {
    host        = self.ipv4_address
    user        = var.ssh_username
    type        = "ssh"
    private_key = file(var.ssh_private_key)
  }

  provisioner "file" {
    source      = "scripts/install.sh"
    destination = "/root/install.sh"
  }

  provisioner "remote-exec" {
    inline = ["bash /root/install.sh ${var.k8s_cluster_version}"]
  }

  provisioner "file" {
    source = "scripts/init-cluster.sh"
    destination = "/root/init-cluster.sh"
  }

  # provision cluster
  provisioner "remote-exec" {
    #inline = ["bash /root/init-cluster.sh ${var.k8s_network_ip_range} ${var.k8s_network_ip_service_subnet_range} ${var.k8s_external_kubernetes_address} ${var.hetzner_master_machine_prefix}"]
    inline = ["bash /root/init-cluster.sh ${var.hetzner_master_count} ${var.k8s_cluster_internal_dns_name} ${var.k8s_external_kubernetes_address} ${var.k8s_network_ip_cluster_subnet_range} ${var.k8s_network_ip_service_subnet_range} ${var.hetzner_master_machine_prefix} ${var.k8s_cluster_network_driver_url}"]
  }

  # copy provision token from kubernetes cluster
  provisioner "local-exec" {
    command = "bash scripts/local-exec/copy-kubeadm-token.sh"

    environment = {
      SSH_PRIVATE_KEY = var.ssh_private_key
      SSH_USERNAME = var.ssh_username
      SSH_HOST = hcloud_server.k8s_nodes_master[0].ipv4_address
      TARGET = ".secrets/kubeadm_join/"
    }
  }

  # install k8s nginx ingress controller
  provisioner "local-exec" {
    command = "bash scripts/local-exec/k8s_install_nginx_ingress.sh"

    environment = {
      K8S_NGINX_HTTP_NODEPORT = var.k8s_nginx_ingress_nodeport_http
      K8S_NGINX_HTTPS_NODEPORT = var.k8s_nginx_ingress_nodeport_https
      INGRESS_SVC_STORE_LOCATION = ".secrets/nginx-svc.yml"
      KUBECONFIG_SAVED = ".secrets/kubeadm_join/admin.conf"
      INSTALL_NGINX_INGRESS = var.k8s_enable_nginx_ingress_controller
      INGRES_INSTALL_URL = var.k8s_nginx_ingress_install_url
      HOST_ID = count.index
    }
  }

  provisioner "file" {
    source = ".secrets/kubeadm_join"
    destination = "/root/kubeadm_join"
  }

  #provisioner "file" {
  #  source = "scripts/provision-as-master.sh"
  #  destination = "/root/provision-as-master.sh"
  #}

  provisioner "file" {
    source = ".secrets/kubeadm_join/k8s_control_plane_join.txt"
    destination = "/root/k8s_control_plane_join.txt"
  }

  provisioner "file" {
    source = ".secrets/kubeadm_join/admin.conf"
    destination = "/root/.kube/config"
  }

  #provisioner "remote-exec" {
  #  inline = [
  #    "bash /root/provision-as-master.sh ${var.hetzner_master_machine_prefix} ${hcloud_server.k8s_nodes_master[0].ipv4_address} ${var.k8s_external_kubernetes_address}",
  #  ]
  #}

  provisioner "local-exec" {
    command = "bash scripts/local-exec/copy-authorized-keys.sh"

    environment = {
      "SSH_PRIVATE_KEY_LOCATION" = var.ssh_private_key
      "SSH_USERNAME" = var.ssh_username
      "SSH_TARGET_ADDRESS" = self.ipv4_address
      "SSH_AUTHORIZED_KEY_FILE_LOCATION" = var.ssh_authorized_key_file_location
    }
  }
}

resource "hcloud_server_network" "master_node_network" {
  count = var.hetzner_master_count
  server_id = hcloud_server.k8s_nodes_master[count.index].id
  subnet_id = hcloud_network_subnet.master.id
}

# do the etcd setup thing
resource "null_resource" "setup_etcd_cluster_provisioning" {
  provisioner "local-exec" {
    command = "bash scripts/local-exec/setup_etcd_cluster.sh"

    environment = {
      "MASTER_MACHINE_PREFIX" = var.hetzner_master_machine_prefix
      "MASTER_MAX_COUNT" = var.hetzner_master_count
      "SSH_PRIVATE_KEY_LOCATION" = var.ssh_private_key
      "SSH_USERNAME" = var.ssh_username
      "K8S_ETCD_YAML_DIR" = ".secrets/etcd"
      "ALL_MASTER_IPV4" = join(",", hcloud_server.k8s_nodes_master.*.ipv4_address)
      "K8S_EXTERNAL_DNS_NAME" = var.k8s_external_kubernetes_address
      "K8S_ADMIN_FILE_LOCATION" = ".secrets/kubeadm_join/admin.conf"
    }
  }
}


resource "hcloud_server" "k8s_nodes_worker" {
  count       = var.hetzner_worker_count
  name        = format("%s-%d", var.hetzner_worker_machine_prefix, count.index + 1)
  server_type = var.hetzner_worker_machine_type
  image       = var.hetzner_machine_operation_system
  datacenter  = var.hetzner_datacenter
  backups     = var.hetzner_machine_worker_backups
  ssh_keys    = [hcloud_ssh_key.k8s_admin.id]
  depends_on  = [hcloud_server.k8s_nodes_master]
  labels      = {
    machine_type=var.hetzner_machine_label_type_worker, 
    network_name=var.hetzner_machine_label_type_private_network
  }

  connection {
    host        = self.ipv4_address
    user        = var.ssh_username
    type        = "ssh"
    private_key = file(var.ssh_private_key)
  }

  provisioner "file" {
    source      = "scripts/install.sh"
    destination = "/root/install.sh"
  }

  provisioner "remote-exec" {
    inline = ["bash /root/install.sh ${var.k8s_cluster_version}"]
  }

  provisioner "file" {
    source = ".secrets/kubeadm_join"
    destination = "/root/kubeadm_join"
  }

  provisioner "file" {
    source = "scripts/provision-at-cluster.sh"
    destination = "/root/provision-at-cluster.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "bash /root/provision-at-cluster.sh ${var.hetzner_master_machine_prefix} ${hcloud_server.k8s_nodes_master[0].ipv4_address} ${var.k8s_external_kubernetes_address}",
    ]
  }

  # install k8s acme certificate manager
  provisioner "local-exec" {
    command = "bash scripts/local-exec/k8s_install_letsencrypt_certmanager.sh"

    environment = {
      KUBECONFIG_SAVED = ".secrets/kubeadm_join/admin.conf"
      K8S_CERTMANAGER_ACME_INSTALLATION_VERSION = var.k8s_certmanager_acme_installation_version
      K8S_ACME_ISSUER_CONFIG = "k8s-files/acme-certificate-issuer.yml"
      INSTALL_ACME_CERTMANAGER = var.k8s_deploy_acme_cert_manager
      ACME_ISSUER_EMAIL = var.k8s_acme_issuer_email
      HOST_ID = count.index
    }
  }

  provisioner "local-exec" {
    command = "bash scripts/local-exec/copy-authorized-keys.sh"

    environment = {
      "SSH_PRIVATE_KEY_LOCATION" = var.ssh_private_key
      "SSH_USERNAME" = var.ssh_username
      "SSH_TARGET_ADDRESS" = self.ipv4_address
      "SSH_AUTHORIZED_KEY_FILE_LOCATION" = var.ssh_authorized_key_file_location
    }
  }
}

resource "hcloud_server_network" "worker_node_network" {
  count = var.hetzner_worker_count
  server_id = hcloud_server.k8s_nodes_worker[count.index].id
  subnet_id = hcloud_network_subnet.master.id
}
