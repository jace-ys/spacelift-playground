resource "google_secret_manager_secret" "tailscale_operator" {
  project   = data.google_project.this.project_id
  secret_id = "tailscale_operator_staging"

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
    client_id     = "kBin2YP67S11CNTRL"
    client_secret = data.google_secret_manager_secret_version.tailscale_operator.secret_data
  }
}

resource "kubernetes_secret" "cluster_operator" {
  provider = kubernetes.operator

  metadata {
    name      = "staging-operator"
    namespace = "argocd"

    labels = {
      "argocd.argoproj.io/secret-type" = "cluster"
      "example.com/apps-cluster"       = "true"
    }
  }

  data = {
    name   = "staging"
    server = "https://${module.cluster.cluster_public_endpoint}"
    config = <<EOT
{
  "execProviderConfig": {
    "command": "argocd-k8s-auth",
    "args": ["gcp"],
    "apiVersion": "client.authentication.k8s.io/v1beta1"
  },
  "tlsClientConfig": {
    "insecure": false,
    "caData": "${module.cluster.cluster_ca_certificate}"
  }
}
EOT
  }
}
