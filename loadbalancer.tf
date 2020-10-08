resource "hcloud_load_balancer" "load_balancer" {
  name       = var.k8s_loadbalancer_name
  load_balancer_type = var.k8s_loadbalancer_type
  location   = var.k8s_loadbalancer_location
  count = "${var.hetzner_master_count > 1 ? 1 : 0}"

  dynamic "target" {
    for_each = hcloud_server.k8s_nodes_master
    content {
      type = "server"
      server_id = target.value["id"]
    }
  }

  algorithm {
    type = var.k8s_loadbalancer_algorithm
  }
}

## attach servers identified by labels to the loadbalancer
#resource "hcloud_load_balancer_target" "load_balancer_target" {
#  type             = "label_selector"
#  load_balancer_id = hcloud_load_balancer.load_balancer[0].id
#  label_selector = format("machine_type=%s", var.hetzner_machine_label_type_private_network)
#  use_private_ip = var.k8s_loadbalancer_use_private_ip
#  count = "${var.hetzner_master_count > 1 ? 1 : 0}"
#}


resource "hcloud_load_balancer_service" "http_80_lb_service" {
  count = "${var.hetzner_master_count > 1 ? 1 : 0}"
  load_balancer_id = hcloud_load_balancer.load_balancer[0].id
  protocol         = "http"
  listen_port      = "80"
  destination_port = "80"

  health_check {
    protocol = "http"
    port     = "80"
    interval = "10"
    timeout  = "10"
    http {
      path         = "/"
      status_codes = ["2??", "3??"]
    }
  }
}

resource "hcloud_load_balancer_service" "http_443_lb_service" {
  count = "${var.hetzner_master_count > 1 ? 1 : 0}"
  load_balancer_id = hcloud_load_balancer.load_balancer[0].id
  protocol         = "https"
  listen_port      = "443"
  destination_port = "443"

  health_check {
    protocol = "https"
    port     = "443"
    interval = "10"
    timeout  = "10"
    http {
      path         = "/"
      status_codes = ["2??", "3??"]
    }
  }
}

resource "hcloud_load_balancer_service" "http_6443_lb_service" {
  count = "${var.hetzner_master_count > 1 ? 1 : 0}"
  load_balancer_id = hcloud_load_balancer.load_balancer[0].id
  protocol         = "https"
  listen_port      = "6443"
  destination_port = "6443"

  health_check {
    protocol = "https"
    port     = "6443"
    interval = "10"
    timeout  = "10"
    http {
      path         = "/"
      status_codes = ["2??", "3??"]
    }
  }
}

resource "hcloud_load_balancer_network" "kubernetes_network" {
  count = "${var.hetzner_master_count > 1 ? 1 : 0}"
  load_balancer_id        = hcloud_load_balancer.load_balancer[0].id
  subnet_id               = hcloud_network_subnet.master.id
  enable_public_interface = var.k8s_loadbalancer_use_private_ip
}


