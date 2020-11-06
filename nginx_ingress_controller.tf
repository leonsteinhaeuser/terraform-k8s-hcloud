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

resource "hcloud_load_balancer_service" "http_ingress_80_lb_service" {
  count = var.k8s_enable_nginx_ingress_controller ? 1 : 0
  load_balancer_id = hcloud_load_balancer.nginx_ingress_loadbalancer[0].id
  protocol         = "tcp"
  listen_port      = "80"
  destination_port = var.k8s_nginx_ingress_nodeport_http

  health_check {
    protocol = "tcp"
    port     = var.k8s_nginx_ingress_nodeport_http
    interval = var.k8s_nginx_ingress_loadbalancer_interval
    timeout  = var.k8s_nginx_ingress_loadbalancer_timeout

    http {
      path         = "/healthz"
      status_codes = var.k8s_nginx_ingress_controller_loadbalancer_status_codes
    }
  }
}

resource "hcloud_load_balancer_service" "http_ingress_443_lb_service" {
  count = var.k8s_enable_nginx_ingress_controller ? 1 : 0
  load_balancer_id = hcloud_load_balancer.nginx_ingress_loadbalancer[0].id
  protocol         = "tcp"
  listen_port      = "443"
  destination_port = var.k8s_nginx_ingress_nodeport_https

  health_check {
    protocol = "tcp"
    port     = var.k8s_nginx_ingress_nodeport_https
    interval = var.k8s_nginx_ingress_loadbalancer_interval
    timeout  = var.k8s_nginx_ingress_loadbalancer_interval

    http {
      path         = "/healthz"
      status_codes = var.k8s_nginx_ingress_controller_loadbalancer_status_codes
    }
  }
}