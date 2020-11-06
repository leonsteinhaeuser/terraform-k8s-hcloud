# terraform-hcloud

This repository provides terraform scripts that installs a kubernetes cluster in the [hetzner cloud](https://www.hetzner.com/cloud).

## Variables

**CONNECTION RELATED OPTIONS:**

| Name | Type | Default value | Description |
|------|------|---------------|-------------|
| `hcloud_token` | string |  | Contains the **hetzner cloud** api token |
| `ssh_public_key` | string | `~/.ssh/id_rsa.pub` | Defines the path to your ***ssh public key*** |
| `ssh_private_key` | string | `~/.ssh/id_rsa` | Defines the path to your ***ssh private key*** |
| `ssh_username` | string | `root` | Defines the username used for ssh connections |

**MACHINE DEFINITION OPTIONS:**

| Name | Type | Default value | Description |
|------|------|---------------|-------------|
| `hetzner_master_machine_type` | string | `cx21` | Defines the machine type used for kubernetes master machines. For such types refer to https://www.hetzner.com/cloud |
| `hetzner_worker_machine_type` | string | `cx21` | Defines the machine type used for kubernetes worker machines. For such types refer to https://www.hetzner.com/cloud |
| `hetzner_master_count` | int | 1 | Defines the number of Kubernetes master machines. If the number is > 1, a load balancer is created automatically and the external address of the load balancer is set as kubernet api address |
| `hetzner_worker_count` | int | 3 | Defines the number of Kubernetes worker machines. |
| `hetzner_master_machine_prefix` | string | `k8s-master` | Defines the master machine prefix. A trailing `-` is added after the prefix |
| `hetzner_worker_machine_prefix` | string | `k8s-worker` | Defines the worker machine prefix. A trailing `-` is added after the prefix |
| `hetzner_datacenter` | string | `fsn1-dc3` | Defines the datacenter in which the cluster should run |
| `hetzner_machine_operation_system` | string | `ubuntu-20.04` | Defines the operation system used on your kubernetes nodes (master and workers). Currently the hetzner cloud only supports the following operation systems: `ubuntu-20.04`, `ubuntu-18.04`, `ubuntu-16.04`, `debian-10`, `debian-9`, `fedora-32`, `centos-8`, `centos-7` |
| `hetzner_machine_master_backups` | boolean | false | Defines if hetzner should create backups for your master machines |
| `hetzner_machine_worker_backups` | boolean | false | Defines if hetzner should create backups for your worker machines |
| `hetzner_machine_network` | string | `192.168.0.0/24` | Defines the private network IPv4 range in hetzners cloud environment |
| `hetzner_machine_network_subnet_range` | string | `192.168.0.0/24` | Defines the subnet range used in hetzners cloud environment |

**HETZNER LOADBALANCER DEFINITION (HA MASTER NODES):**

| Name | Type | Default value | Description |
|------|------|---------------|-------------|
| `k8s_cluster_network_driver_url` | string | `https://docs.projectcalico.org/manifests/canal.yaml` | Defines the pod network driver url |
| `k8s_network_ip_cluster_subnet_range` | string | `10.0.0.0/16` | Defines the ipv4 range used for your pods |
| `k8s_network_ip_service_subnet_range` | string | `10.128.0.0/16` | Defines the ipv4 range used as service range |
| `k8s_cluster_internal_dns_name` | string | `cluster.local` | Defines the internal cluster DNS range |
| `k8s_cluster_version` | string | `1.19.3-00` | Defines the version of kubernetes included in the package manager that terraform should install. Under Debian you can run: `apt-cache policy kubeadm` |
| `k8s_external_kubernetes_address` | string | `k8s.example.local` | Defines the external DNS name used for your cluster (if master count > 1 the address is set to the loadbalancer) |

**KUBERNETES CLUSTER DEFINITION OPTIONS:**

| Name | Type | Default value | Description |
|------|------|---------------|-------------|
| `hetzner_loadbalancer_name` | string | `k8s-lb` | Defines the loadbalancer name |
| `hetzner_loadbalancer_type` | string | `lb11` | Defines the type used for the loadbalancer. Refer to https://www.hetzner.com/cloud/load-balancer |
| `hetzner_loadbalancer_datacenter_location` | string | `nbg1` | Defines the datacenter in which the loadbalancer should run |
| `hetzner_loadbalancer_use_public_network_ip` | boolean | `true` | Defines if the loadbalancer should use the public ipv4 to addresses it's targets |
| `hetzner_loadbalancer_algorithm` | string | `round_robin` | Defines the loadbalancer algorithm type. Possible algorith methods are: `round_robin` and `least_connections` |

**NGINX-INGRESS OPTIONS:**

| Name | Type | Default value | Description |
|------|------|---------------|-------------|
| `k8s_enable_nginx_ingress_controller` | boolean | `false` | Defines whether the nginx-Ingress-Controller should be used in the cluster. This option automatically creates a load balancer that accesses the node port on the worker machines. Since we do not support the creation of DNS records, you have to do this manually.  |
| `k8s_nginx_ingress_install_url` | string | `https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.40.2/deploy/static/provider/baremetal/deploy.yaml` | Defines the installation URL of the nginx Ingress Controller version to be installed |
| `k8s_nginx_ingress_nodeport_http` | number | `31110` | Defines the node-port that is used for the nginx http-Ingress-Controller |
| `k8s_nginx_ingress_nodeport_https` | number | `31111` | Defines the node-port that is used for the nginx https-Ingress-Controller |
| `k8s_nginx_ingress_loadbalancer_timeout` | number | `15` | Defines the timeout when a health check try will be canceled if there is no response, in seconds |
| `k8s_nginx_ingress_loadbalancer_interval` | number | `15` | Defines the interval how often the health check will be performed, in seconds |
| `k8s_nginx_ingress_controller_loadbalancer_status_codes` | list(string) | `["2??", "3??"]` | Defines the list of status codes that the load balancer accepts to maintain healthy mode |

**CERT_MANAGER OPTIONS:**

| Name | Type | Default value | Description |
|------|------|---------------|-------------|
| `k8s_deploy_acme_cert_manager` | boolean | `false` | Defines whether the acme cert-manager should be used |
| `k8s_acme_issuer_email` | string | Defines the e-mail address of the issuer, which is used for letsencrypt as target mail for expiring certificates and problems related to your account |
| `k8s_certmanager_acme_installation_version` | string | `v1.0.4` | Defines the version of the acme cert-manager which should be installed. See https://github.com/jetstack/cert-manager/releases/ to see the available versions |

---

## Stumbling blocks

- Since we do not support the creation of DNS entries, you have to do this manually. When creating the infrastructure you have to make sure that immediately after running terraform, you add an entry to your DNS system pointing to the first master node.

---

## Examples

### NGINX ingress with acme certificate

terraform.tfvars:
```ini
k8s_enable_nginx_ingress_controller=true
k8s_deploy_acme_cert_manager=true
k8s_acme_issuer_email="my-admin-mail@example.local"
```

Ingress deployment ***.yml***:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: nginx-ingres
  namespace: my-namespace
  annotations:
    kubernetes.io/ingress.class: "nginx"
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
spec:
  tls:
  - hosts:
    - "my.external.dns.name.example.local"
    secretName: tls-certificate-prod-leon
  rules:
  - host: "my.external.dns.name.example.local"
    http:
      paths:
      - pathType: Prefix
        path: "/"
        backend:
          service:
            name: "my-application"
            port:
              number: 8080
```
