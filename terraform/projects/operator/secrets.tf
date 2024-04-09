resource "google_secret_manager_secret" "tailscale_operator" {
  project   = data.google_project.this.project_id
  secret_id = "tailscale_operator_operator"

  replication {
    auto {}
  }
}

data "google_secret_manager_secret_version" "tailscale_operator" {
  project = data.google_project.this.project_id
  secret  = google_secret_manager_secret.tailscale_operator.secret_id
  version = 1
}

resource "kubernetes_secret" "operator_oauth" {
  metadata {
    name      = "operator-oauth"
    namespace = "tailscale-operator"
  }

  data = {
    client_id     = "k59kG12dh521CNTRL"
    client_secret = data.google_secret_manager_secret_version.tailscale_operator.secret_data
  }
}
