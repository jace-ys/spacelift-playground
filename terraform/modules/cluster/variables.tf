locals {
  cluster_name = "jace-${var.name}-${var.region}"
}

variable "project_id" {
  type = string
}

variable "project_number" {
  type = number
}

variable "name" {
  type        = string
  description = "Name for the cluster, which will be prefixed with duffel- and suffixed with the region."
}

variable "region" {
  type = string
}

variable "subnet_ip_cidr_range" {
  type        = string
  description = "The IPv4 range of internal addresses that are owned by this subnetwork."
}

variable "master_ip_cidr_range" {
  type        = string
  description = "The IPv4 range in CIDR notation to use for the hosted master network. This range will be used for assigning private IP addresses to the cluster master(s) and the ILB VIP. This range must not overlap with any other ranges in use within the cluster's network, and it must be a /28 subnet."
}

variable "cluster_ip_cidr_range" {
  type        = string
  description = "The IPv4 address range for the cluster pod IPs."
}

variable "services_ip_cidr_range" {
  type        = string
  description = "The IPv4 address range of the services IPs in this cluster."
}

variable "node_pools" {
  type = list(object({
    name           = string
    machine_type   = string
    min_node_count = number
    max_node_count = number
    workload_type  = optional(string, null)
    sandbox        = optional(bool, false)
  }))
}
