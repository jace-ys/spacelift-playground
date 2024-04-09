variable "google_project" {
  type    = string
  default = "emp-jace-a850"
}

variable "google_region" {
  type    = string
  default = "europe-west1"
}

variable "argocd_cluster" {
  type    = string
  default = "jace-operator-europe-west1"
}

variable "argocd_namespace" {
  type    = string
  default = "argocd"
}
