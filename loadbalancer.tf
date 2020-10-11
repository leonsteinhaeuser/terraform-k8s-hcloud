resource "hcloud_load_balancer" "load_balancer" {
  name       = var.hetzner_loadbalancer_name
  load_balancer_type = var.hetzner_loadbalancer_type
  location   = var.hetzner_loadbalancer_datacenter_location
  count = var.hetzner_master_count > 1 ? 1 : 0
  depends_on  = [hcloud_server.k8s_nodes_master]

  dynamic "target" {
    for_each = hcloud_server.k8s_nodes_master
    content {
      type = "server"
      server_id = target.value["id"]
    }
  }

  algorithm {
    type = var.hetzner_loadbalancer_algorithm
  }
}

resource "hcloud_load_balancer_service" "http_80_lb_service" {
  count = var.hetzner_master_count > 1 ? 1 : 0
  load_balancer_id = hcloud_load_balancer.load_balancer[0].id
  protocol         = "tcp"
  listen_port      = "80"
  destination_port = "80"

  health_check {
    protocol = "tcp"
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
  count = var.hetzner_master_count > 1 ? 1 : 0
  load_balancer_id = hcloud_load_balancer.load_balancer[0].id
  protocol         = "tcp"
  listen_port      = "443"
  destination_port = "443"

  health_check {
    protocol = "tcp"
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
  count = var.hetzner_master_count > 1 ? 1 : 0
  load_balancer_id = hcloud_load_balancer.load_balancer[0].id
  protocol         = "tcp"
  listen_port      = "6443"
  destination_port = "6443"

  health_check {
    protocol = "tcp"
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
  count = var.hetzner_master_count > 1 ? 1 : 0
  load_balancer_id        = hcloud_load_balancer.load_balancer[0].id
  subnet_id               = hcloud_network_subnet.master.id
  enable_public_interface = var.hetzner_loadbalancer_use_public_network_ip
}


