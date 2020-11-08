# Set the variable value in *.tfvars file
# or using the -var="hcloud_token=..." CLI option
variable "hcloud_token" {
    description = "Hetzner Cloud API token"
    type = string
}

variable "ssh_private_key" {
    description = "Path to the location where the private key is stored to connect to the machines"
    default     = "~/.ssh/id_rsa"
    type = string
}

variable "ssh_public_key" {
  description = "Public Key to authorized the access for the machines"
  default     = "~/.ssh/id_rsa.pub"
  type = string
}

variable "ssh_username" {
  description = "Username that should be used to connect to the nodes"
  default = "root"
  type = string
}

variable "ssh_authorized_key_file_location" {
    description = "Defines the location for the authorized_keys file to be used to allow other users to access the machines."
    default = ""
    type = string
}

resource "hcloud_ssh_key" "k8s_admin" {
  name       = "k8s_admin"
  public_key = file(var.ssh_public_key)
}

##################################################
#                                                #
#         machine type definition                #
#                                                #
##################################################

variable "hetzner_master_machine_type" {
    description = "Defines the machine type used for master nodes"
    default     = "cx21"
    type = string
}

variable "hetzner_worker_machine_type" {
    description = "Defines the machine type used for worker nodes"
    default     = "cx21"
    type = string
}

##################################################
#                                                #
#  define the amount of master and worker nodes  #
#                                                #
##################################################

variable "hetzner_master_count" {
    description = "Defines the amount of master nodes used for the k8s cluster"
    default     = 1
    type = number
}

variable "hetzner_worker_count" {
    description = "Defines the amount of worker nodes used for the k8s cluster"
    default     = 3
    type = number
}

###################################################
#                                                 #
# define the name for the master and worker nodes #
#                                                 #
###################################################

variable "hetzner_master_machine_prefix" {
    description = "Defines the name prefix for the master machine"
    default     = "k8s-master"
    type = string
}

variable "hetzner_worker_machine_prefix" {
    description = "Defines the name prefix for the master machine"
    default     = "k8s-worker"
    type = string
}

##################################################
#                                                #
#     define the cluster datacenter location     #
#                                                #
##################################################
variable "hetzner_datacenter" {
    description = "Defines the datacenter in which the cluster should run"
    default     = "fsn1-dc3"
    type = string
}

##################################################
#                                                #
#     defines the machine operation system       #
#                                                #
##################################################
variable "hetzner_machine_operation_system" {
    description = "Defines the operation system for each node. For the available options refer to https://www.hetzner.com/cloud"
    default     = "ubuntu-20.04"
    type = string
}

############################################################
#                                                          #
# define if hetzner should create backups for the machines #
#                                                          #
############################################################

variable "hetzner_machine_master_backups" {
    description = "Defines the name prefix for the master machine"
    default     = false
    type = bool
}

variable "hetzner_machine_worker_backups" {
    description = "Defines the name prefix for the master machine"
    default     = false
    type = bool
}

##################################################
#                                                #
#             k8s network definition             #
#                                                #
##################################################

variable "k8s_cluster_network_driver_url" {
    description = "Defines the pod network driver url"
    default = "https://docs.projectcalico.org/manifests/canal.yaml"
    type = string
}

# pod-cidr
variable "k8s_network_ip_cluster_subnet_range" {
    description = "Defines the cluster network subnet address range"
    default = "10.0.0.0/9"
    type = string
}

variable "k8s_network_ip_service_subnet_range" {
    description = "Defined the cluster ip service subnet range"
    default = "10.128.0.0/16"
    type = string
}

##################################################
#                                                #
#             k8s cluster definition             #
#                                                #
##################################################

variable "k8s_cluster_internal_dns_name" {
    description = "Defines the internal cluster dns address"
    default = "cluster.local"
    type = string
}

variable "k8s_cluster_version" {
    description = "Defines the version of kubernetes included in the package manager that terraform should install. Under Debian you can run: `apt-cache policy kubeadm`"
    default = "1.19.3-00"
    type = string
}

##################################################
#                                                #
#           external cluster dns name            #
#                                                #
##################################################

# if var.hetzner_master_count > 1 a loadbalancer is created and the address is assigned to such service
variable "k8s_external_kubernetes_address" {
    description = "Defines the external kubernetes api address"
    default = "k8s.example.local"
    type = string
}

##################################################
#                                                #
#             hetzner machine labels             #
#                                                #
##################################################

variable "hetzner_machine_label_type_master" {
    description = "Defines the master machine label used to identify master nodes"
    default = "master"
    type = string
}

variable "hetzner_machine_label_type_worker" {
    description = "Defines the worker machine label used to identify master nodes"
    default = "worker"
    type = string
}

variable "hetzner_machine_label_type_private_network" {
    description = "Defines the private network machine label name"
    default = "private_network"
    type = string
}

##################################################
#                                                #
#            hetzner machine network             #
#                                                #
##################################################

variable "hetzner_machine_network" {
    description = "Defines the private network address used to connect the machines together"
    default = "192.168.0.0/24"
    type = string
}

variable "hetzner_machine_network_subnet_range" {
    description = "Defines the private network address used to connect the machines together"
    default = "192.168.0.0/24"
    type = string
}

##################################################
#                                                #
#              hetzner loadbalancer              #
#                                                #
##################################################

variable "hetzner_loadbalancer_name" {
    description = "Defines the loadbalancer name"
    default = "k8s-lb"
    type = string
}

variable "hetzner_loadbalancer_type" {
    description = "Defines the loadbalancer type"
    default = "lb11"
    type = string
}

variable "hetzner_loadbalancer_datacenter_location" {
    description = "Defines the loadbalancer location"
    default = "nbg1"
    type = string
}

variable "hetzner_loadbalancer_use_public_network_ip" {
    description = "Defines if the loadbalancer should use the public ipv4 to addresses it's targets"
    default = true
    type = bool
}

variable "hetzner_loadbalancer_algorithm" {
    description = "Defines the loadbalancer algorith used by hetzners loadbalancer"
    default = "round_robin"
    type = string
}

##################################################
#                                                #
#            kube admin config options           #
#                                                #
##################################################

variable "k8s_copy_config_to_local_system" {
    description = "Defines if the kubernetes administration configuration should be copied to a local defined directory"
    default = false
    type = bool
}

variable "k8s_copy_config_to_local_system_path" {
    description = "Defines if the kubernetes administration configuration should be copied to a local defined directory"
    default = "~/.kube/config"
    type = string
}

##################################################
#                                                #
#       kubernetes nginx ingress controller      #
#                                                #
##################################################

variable "k8s_enable_nginx_ingress_controller" {
    description = "Defines whether the nginx-Ingress-Controller should be used in the cluster. This option automatically creates a load balancer that accesses the node port on the worker machines. Since we do not support the creation of DNS records, you have to do this manually."
    default = false
    type = bool
}

variable "k8s_nginx_ingress_install_url" {
    description = "Defines the installation URL of the nginx Ingress Controller version to be installed"
    default = "https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.40.2/deploy/static/provider/baremetal/deploy.yaml"
    type = string
}

variable "k8s_nginx_ingress_nodeport_http" {
    description = "Defines the node-port that is used for the nginx http-Ingress-Controller"
    default = 31110
    type = string
}

variable "k8s_nginx_ingress_nodeport_https" {
    description = "Defines the node-port that is used for the nginx https-Ingress-Controller"
    default = 31111
    type = string
}

variable "k8s_nginx_ingress_loadbalancer_timeout" {
    description = "Defines the timeout when a health check try will be canceled if there is no response, in seconds"
    default = 15
    type = number
}

variable "k8s_nginx_ingress_loadbalancer_interval" {
    description = "Defines the interval how often the health check will be performed, in seconds"
    default = 15
    type = number
}

variable "k8s_nginx_ingress_controller_loadbalancer_status_codes" {
    description = "Defines the list of status codes that the load balancer accepts to maintain healthy mode"
    default = ["2??", "3??"]
    type = list(string)
}

##################################################
#                                                #
#             kubernetes cert-manager            #
#                                                #
##################################################

variable "k8s_deploy_acme_cert_manager" {
    description = "Defines whether the acme cert-manager should be used"
    default = false
    type = bool
}

variable "k8s_acme_issuer_email" {
    description = "Defines the e-mail address of the issuer, which is used for letsencrypt as target mail for expiring certificates and problems related to your account"
    default = ""
    type = string
}

variable "k8s_certmanager_acme_installation_version" {
    description = "Defines the version of the acme cert-manager which should be installed. See https://github.com/jetstack/cert-manager/releases/ to see the available versions"
    default = "v1.0.4"
    type = string
}