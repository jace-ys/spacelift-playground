terraform {
  required_version = "~> 1.5.7"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.19.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 5.19.0"
    }
  }
}

provider "google" {
  add_terraform_attribution_label = true
}

provider "google-beta" {
  add_terraform_attribution_label = true
}

data "google_client_config" "default" {}

provider "kubernetes" {
  host  = "https://${module.cluster.cluster_public_endpoint}"
  token = data.google_client_config.default.access_token

  client_certificate     = base64decode(module.cluster.cluster_client_certificate)
  client_key             = base64decode(module.cluster.cluster_client_key)
  cluster_ca_certificate = base64decode(module.cluster.cluster_ca_certificate)
}

data "google_container_cluster" "operator" {
  project = data.google_project.this.project_id
  name    = var.argocd_cluster
}

provider "kubernetes" {
  alias = "operator"

  host  = "https://${data.google_container_cluster.operator.endpoint}"
  token = data.google_client_config.default.access_token

  client_certificate     = base64decode(data.google_container_cluster.operator.master_auth[0].client_certificate)
  client_key             = base64decode(data.google_container_cluster.operator.master_auth[0].client_key)
  cluster_ca_certificate = base64decode(data.google_container_cluster.operator.master_auth[0].cluster_ca_certificate)
}
