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
