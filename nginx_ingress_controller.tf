resource "hcloud_load_balancer" "nginx_ingress_loadbalancer" {
  name       = var.hetzner_loadbalancer_name
  load_balancer_type = var.hetzner_loadbalancer_type
  location   = var.hetzner_loadbalancer_datacenter_location
  count = var.k8s_enable_nginx_ingress_controller ? 1 : 0
  depends_on  = [hcloud_server.k8s_nodes_worker]

  dynamic "target" {
    for_each = hcloud_server.k8s_nodes_worker
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
  count = var.k8s_enable_nginx_ingress_controller ? 1 : 0
  load_balancer_id = hcloud_load_balancer.nginx_ingress_loadbalancer[0].id
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
  count = var.k8s_enable_nginx_ingress_controller ? 1 : 0
  load_balancer_id = hcloud_load_balancer.nginx_ingress_loadbalancer[0].id
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