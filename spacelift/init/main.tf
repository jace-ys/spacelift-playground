resource "google_iam_workload_identity_pool" "spacelift" {
  project                   = data.google_project.this.project_id
  workload_identity_pool_id = "spacelift"
}

resource "google_iam_workload_identity_pool_provider" "spacelift" {
  project                            = data.google_project.this.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.spacelift.workload_identity_pool_id
  workload_identity_pool_provider_id = "jace-ys"
  display_name                       = "jace-ys@spacelift.io"
  description                        = "OIDC identity pool provider for Spacelift"

  attribute_mapping = {
    "google.subject"  = "assertion.sub"
    "attribute.space" = "assertion.spaceId"
  }

  oidc {
    allowed_audiences = ["https://jace-ys.app.spacelift.io", "jace-ys.app.spacelift.io"]
    issuer_uri        = "https://jace-ys.app.spacelift.io"
  }
}

resource "google_service_account" "spacelift" {
  project      = data.google_project.this.project_id
  account_id   = "spacelift"
  display_name = "Spacelift"
}

resource "google_project_iam_member" "spacelift_editor" {
  project = data.google_project.this.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.spacelift.email}"
}

resource "google_project_iam_member" "spacelift_project_iam_admin" {
  project = data.google_project.this.project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:${google_service_account.spacelift.email}"
}

resource "google_project_iam_member" "spacelift_service_account_admin" {
  project = data.google_project.this.project_id
  role    = "roles/iam.serviceAccountAdmin"
  member  = "serviceAccount:${google_service_account.spacelift.email}"
}

resource "google_project_iam_member" "spacelift_secret_accessor" {
  project = data.google_project.this.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.spacelift.email}"
}

resource "google_service_account_iam_binding" "spacelift" {
  service_account_id = google_service_account.spacelift.name
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "principalSet://iam.googleapis.com/projects/${data.google_project.this.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.spacelift.workload_identity_pool_id}/attribute.space/root"
  ]
}

resource "spacelift_stack" "root" {
  space_id                     = "root"
  name                         = "root"
  description                  = "Root stack"
  repository                   = "spacelift-playground"
  branch                       = "main"
  project_root                 = "spacelift/root"
  additional_project_globs     = ["terraform/projects/*/*.tf"]
  terraform_version            = "1.5.7"
  terraform_smart_sanitization = true
  administrative               = true
}

resource "spacelift_gcp_service_account" "root" {
  stack_id = spacelift_stack.root.id
  token_scopes = [
    "https://www.googleapis.com/auth/compute",
    "https://www.googleapis.com/auth/cloud-platform",
    "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
    "https://www.googleapis.com/auth/devstorage.full_control",
    "https://www.googleapis.com/auth/userinfo.email",
  ]
}

resource "google_project_iam_member" "spacelift_gcp_editor" {
  project = data.google_project.this.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${spacelift_gcp_service_account.root.service_account_email}"
}

resource "google_project_iam_member" "spacelift_gcp_project_iam_admin" {
  project = data.google_project.this.project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:${spacelift_gcp_service_account.root.service_account_email}"
}

resource "google_project_iam_member" "spacelift_gcp_service_account_admin" {
  project = data.google_project.this.project_id
  role    = "roles/iam.serviceAccountAdmin"
  member  = "serviceAccount:${spacelift_gcp_service_account.root.service_account_email}"
}

resource "google_project_iam_member" "spacelift_gcp_secret_accessor" {
  project = data.google_project.this.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${spacelift_gcp_service_account.root.service_account_email}"
}
