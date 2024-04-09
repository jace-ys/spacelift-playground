resource "spacelift_context" "google_provider" {
  space_id    = "root"
  name        = "google-provider"
  description = "Configuration for the Terraform google provider"
  labels      = ["autoattach:google-provider"]
}

resource "spacelift_mounted_file" "google_application_credentials" {
  context_id    = spacelift_context.google_provider.id
  relative_path = "gcp.json"
  content       = filebase64("${path.module}/.tfvars/credentials.json")
  write_only    = false
}

resource "spacelift_environment_variable" "google_application_credentials" {
  context_id = spacelift_context.google_provider.id
  name       = "GOOGLE_APPLICATION_CREDENTIALS"
  value      = "/mnt/workspace/${spacelift_mounted_file.google_application_credentials.relative_path}"
  write_only = false
}

resource "spacelift_environment_variable" "google_project" {
  context_id = spacelift_context.google_provider.id
  name       = "GOOGLE_PROJECT"
  value      = "emp-jace-a850"
  write_only = false
}

resource "spacelift_environment_variable" "google_region" {
  context_id = spacelift_context.google_provider.id
  name       = "GOOGLE_REGION"
  value      = "europe-west1"
  write_only = false
}
