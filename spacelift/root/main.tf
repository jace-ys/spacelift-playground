locals {
  projects = [for i in fileset("../../terraform/projects", "*/*.tf") : dirname(i)]
}

resource "spacelift_stack" "project" {
  for_each = toset(local.projects)

  space_id                     = "root"
  name                         = each.key
  description                  = "Project - ${each.key}"
  repository                   = "spacelift-playground"
  branch                       = "main"
  project_root                 = "terraform/projects/${each.key}"
  terraform_version            = "1.5.7"
  terraform_smart_sanitization = true
  administrative               = false

  labels = ["feature:add_plan_pr_comment", "google-provider"]
}

resource "spacelift_gcp_service_account" "project" {
  for_each = toset(local.projects)

  stack_id = spacelift_stack.project[each.key].id
  token_scopes = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
    "https://www.googleapis.com/auth/devstorage.full_control",
    "https://www.googleapis.com/auth/userinfo.email",
  ]
}

resource "google_project_iam_member" "spacelift_project_editor" {
  for_each = toset(local.projects)

  project = data.google_project.this.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${spacelift_gcp_service_account.project[each.key].service_account_email}"
}

resource "google_project_iam_member" "spacelift_project_project_iam_admin" {
  for_each = toset(local.projects)

  project = data.google_project.this.project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:${spacelift_gcp_service_account.project[each.key].service_account_email}"
}

resource "google_project_iam_member" "spacelift_project_service_account_admin" {
  for_each = toset(local.projects)

  project = data.google_project.this.project_id
  role    = "roles/iam.serviceAccountAdmin"
  member  = "serviceAccount:${spacelift_gcp_service_account.project[each.key].service_account_email}"
}

resource "google_project_iam_member" "spacelift_project_secret_accessor" {
  for_each = toset(local.projects)

  project = data.google_project.this.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${spacelift_gcp_service_account.project[each.key].service_account_email}"
}
