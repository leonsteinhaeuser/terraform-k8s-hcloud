# terraform-hcloud

This repository provides terraform scripts that installs a kubernetes cluster in the [hetzner cloud](https://www.hetzner.com/cloud).

## Variables

| Name | Type | Default value | Description |
|------|------|---------------|-------------|
| `hcloud_token` | string |  | Contains the **hetzner cloud** api token |
| `ssh_public_key` | string | `~/.ssh/id_rsa.pub` | Defines the path to your ***ssh public key*** |
| `ssh_private_key` | string | `~/.ssh/id_rsa` | Defines the path to your ***ssh private key*** |
| `ssh_username` | string | `root` | Defines the username used for ssh connections |
| `k8s_master_machine_type` | string | `cx21` | Defines the machine type used for kubernetes master machines. For such types refer to https://www.hetzner.com/cloud |
| `k8s_worker_machine_type` | string | `cx21` | Defines the machine type used for kubernetes worker machines. For such types refer to https://www.hetzner.com/cloud |
| `k8s_master_count` | int | 1 | Defines the amount of master machines used for your kubernetes cluster. If count > 1 a loadbalancer is automatically created and the external address of the loadbalancer is set as kubernetes api address |
| `k8s_worker_count` | int | 3 | Defines the amount of worker nodes running in your cluster |
| `k8s_master_machine_prefix` | string | `k8s-master` | Defines the master machine prefix. A trailing `-` is added after the prefix |
| `k8s_worker_machine_prefix` | string | `k8s-worker` | Defines the worker machine prefix. A trailing `-` is added after the prefix |
| `k8s_hetzner_datacenter` | string | `fsn1` | Defines the datacenter in which the cluster should run |
| `k8s_machine_operation_system` | string | `debian-10` | Defines the operation system used on your kubernetes nodes (master and workers). Currently the hetzner cloud only supports the following operation systems: `ubuntu-20.04`, `ubuntu-18.04`, `ubuntu-16.04`, `debian-10`, `debian-9`, `fedora-32`, `centos-8`, `centos-7` |
| `k8s_machine_master_backups` | boolean | false | Defines if hetzner should create backups for your master machines |
| `k8s_machine_worker_backups` | boolean | false | Defines if hetzner should create backups for your worker machines |
| `k8s_network_ip_range` | string | `10.0.0.0/8` | Defines the ip network range used for your kubernetes cluster |
| `k8s_network_ip_cluster_subnet_range` | string | `10.0.0.0/16` | Defines the ipv4 range used for your pods |
| `k8s_network_ip_service_subnet_range` | string | `10.128.0.0/16` | Defines the ipv4 range used as service range |
| `k8s_external_kubernetes_address` | string | `k8s.example.local` | Defines the external DNS name used for your cluster (if master cound > 1 the address is set to the loadbalancer) |
| `k8s_loadbalancer_name` | string | `k8s-lb` | Defines the loadbalancer name |
| `k8s_loadbalancer_type` | string | `lb11` | Defines the type used for the loadbalancer. Refer to https://www.hetzner.com/cloud/load-balancer |
| `k8s_loadbalancer_location` | string | `nbg1` | Defines the datacenter in which the loadbalancer should run |