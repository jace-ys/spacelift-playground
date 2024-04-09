terraform {
  required_version = "~> 1.5.7"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.19.0"
    }
    spacelift = {
      source  = "spacelift-io/spacelift"
      version = "~> 1.10.0"
    }
  }
}

provider "google" {
  project = var.google_project
  region  = var.google_region

  add_terraform_attribution_label = true
}

provider "spacelift" {
}

data "google_project" "this" {
  project_id = var.google_project
}
