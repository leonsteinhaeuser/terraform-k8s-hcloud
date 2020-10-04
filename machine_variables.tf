# Set the variable value in *.tfvars file
# or using the -var="hcloud_token=..." CLI option
variable "hcloud_token" {
    description = "Hetzner Cloud API token"
}

##################################################
#                                                #
#         machine type definition                #
#                                                #
##################################################

variable "k8s_master_machine_type" {
    description = "Defines the machine type used for master nodes"
    default     = "cx11"
}

variable "k8s_worker_machine_type" {
    description = "Defines the machine type used for worker nodes"
    default     = "cx21"
}

##################################################
#                                                #
#  define the amount of master and worker nodes  #
#                                                #
##################################################

variable "k8s_master_count" {
    description = "Defines the amount of master nodes used for the k8s cluster"
    default     = 1
}

variable "k8s_worker_count" {
    description = "Defines the amount of worker nodes used for the k8s cluster"
    default     = 0
}

###################################################
#                                                 #
# define the name for the master and worker nodes #
#                                                 #
###################################################

variable "k8s_master_machine_prefix" {
    description = "Defines the name prefix for the master machine"
    default     = "k8s-master"
}

variable "k8s_worker_machine_prefix" {
    description = "Defines the name prefix for the master machine"
    default     = "k8s-worker"
}

##################################################
#                                                #
#     define the cluster datacenter location     #
#                                                #
##################################################
variable "k8s_hetzner_datacenter" {
    description = "Defines the datacenter in which the cluster should run"
    default     = "fsn1"
}

##################################################
#                                                #
#     defines the machine operation system       #
#                                                #
##################################################
variable "k8s_machine_operation_system" {
    description = "Defines the operation system for each node. For the available options refer to https://www.hetzner.com/cloud"
    default     = "debian-10"
}

############################################################
#                                                          #
# define if hetzner should create backups for the machines #
#                                                          #
############################################################

variable "k8s_machine_master_backups" {
    description = "Defines the name prefix for the master machine"
    default     = false
}

variable "k8s_machine_worker_backups" {
    description = "Defines the name prefix for the master machine"
    default     = false
}