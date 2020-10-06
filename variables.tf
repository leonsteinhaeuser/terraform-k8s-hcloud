# Set the variable value in *.tfvars file
# or using the -var="hcloud_token=..." CLI option
variable "hcloud_token" {
    description = "Hetzner Cloud API token"
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

variable "k8s_master_machine_type" {
    description = "Defines the machine type used for master nodes"
    default     = "cx21"
    type = string
}

variable "k8s_worker_machine_type" {
    description = "Defines the machine type used for worker nodes"
    default     = "cx21"
    type = string
}

##################################################
#                                                #
#  define the amount of master and worker nodes  #
#                                                #
##################################################

variable "k8s_master_count" {
    description = "Defines the amount of master nodes used for the k8s cluster"
    default     = 1
    type = number
}

variable "k8s_worker_count" {
    description = "Defines the amount of worker nodes used for the k8s cluster"
    default     = 3
    type = number
}

###################################################
#                                                 #
# define the name for the master and worker nodes #
#                                                 #
###################################################

variable "k8s_master_machine_prefix" {
    description = "Defines the name prefix for the master machine"
    default     = "k8s-master"
    type = string
}

variable "k8s_worker_machine_prefix" {
    description = "Defines the name prefix for the master machine"
    default     = "k8s-worker"
    type = string
}

##################################################
#                                                #
#     define the cluster datacenter location     #
#                                                #
##################################################
variable "k8s_hetzner_datacenter" {
    description = "Defines the datacenter in which the cluster should run"
    default     = "fsn1"
    type = string
}

##################################################
#                                                #
#     defines the machine operation system       #
#                                                #
##################################################
variable "k8s_machine_operation_system" {
    description = "Defines the operation system for each node. For the available options refer to https://www.hetzner.com/cloud"
    default     = "debian-10"
    type = string
}

############################################################
#                                                          #
# define if hetzner should create backups for the machines #
#                                                          #
############################################################

variable "k8s_machine_master_backups" {
    description = "Defines the name prefix for the master machine"
    default     = false
    type = bool
}

variable "k8s_machine_worker_backups" {
    description = "Defines the name prefix for the master machine"
    default     = false
    type = bool
}

##################################################
#                                                #
#             k8s network definition             #
#                                                #
##################################################
variable "k8s_network_ip_range" {
    description = "Defines the cluster network address range"
    default = "10.0.0.0/8"
    type = string
}

# pod-cidr
variable "k8s_network_ip_cluster_subnet_range" {
    description = "Defines the cluster network subnet address range"
    default = "10.0.0.0/16"
    type = string
}

variable "k8s_network_ip_service_subnet_range" {
    description = "Defined the cluster ip service subnet range"
    default = "10.128.0.0/16"
    type = string
}

# if var.k8s_master_count > 1 a loadbalancer is created and the address is assigned to such service
variable "k8s_external_kubernetes_address" {
    description = "Defines the external kubernetes api address"
    default = "k8s.example.local"
    type = string
}

##################################################
#                                                #
#              hetzner loadbalancer              #
#                                                #
##################################################

variable "k8s_loadbalancer_name" {
    description = "Defines the loadbalancer name"
    default = "k8s-lb"
    type = string
}

variable "k8s_loadbalancer_type" {
    description = "Defines the loadbalancer type"
    default = "lb11"
    type = string
}

variable "k8s_loadbalancer_location" {
    description = "Defines the loadbalancer location"
    default = "nbg1"
    type = string
}