hcloud_token=""

hetzner_master_machine_type="cx21"
hetzner_worker_machine_type="cx21"

hetzner_master_count=1
hetzner_worker_count=4

hetzner_datacenter="nbg1-dc3"

hetzner_machine_operation_system="debian-10"

hetzner_machine_master_backups=false
hetzner_machine_worker_backups=false

hetzner_machine_network="172.16.0.0/16"
hetzner_machine_network_subnet_range="172.16.0.0/24"

k8s_network_ip_cluster_subnet_range="10.0.0.0/16"
k8s_network_ip_service_subnet_range="10.128.0.0/16"

k8s_external_kubernetes_address="k8s.example.local"

hetzner_loadbalancer_use_public_network_ip=true