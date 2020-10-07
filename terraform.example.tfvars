hcloud_token=""

hetzner_master_machine_type="cx21"
hetzner_worker_machine_type="cx21"

hetzner_master_count=1
hetzner_worker_count=4

hetzner_datacenter="nbg1-dc3"

hetzner_machine_operation_system="debian-10"

hetzner_machine_master_backups=false
hetzner_machine_worker_backups=false

k8s_network_ip_range="10.0.0.0/8"
k8s_network_ip_cluster_subnet_range="10.0.0.0/16"
k8s_network_ip_service_subnet_range="10.128.0.0/16"

k8s_external_kubernetes_address="k8s.example.local"