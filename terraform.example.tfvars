hcloud_token=""

hetzner_master_machine_type="cx21"
hetzner_worker_machine_type="cx21"

hetzner_master_count=1
hetzner_worker_count=4

hetzner_datacenter="nbg1-dc3"

hetzner_machine_operation_system="ubuntu-20.04"

hetzner_machine_master_backups=false
hetzner_machine_worker_backups=false

hetzner_machine_network="172.16.0.0/16"
hetzner_machine_network_subnet_range="172.16.0.0/16"

k8s_network_ip_cluster_subnet_range="10.0.0.0/9"
k8s_network_ip_service_subnet_range="10.128.0.0/16"

k8s_external_kubernetes_address="k8s.example.local"

k8s_enable_nginx_ingress_controller=true
k8s_deploy_acme_cert_manager=true
k8s_acme_issuer_email="my-admin-mail@example.local"