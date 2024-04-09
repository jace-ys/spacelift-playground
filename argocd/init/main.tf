resource "google_service_account" "argocd" {
  project     = data.google_project.this.project_id
  account_id  = "argocd"
  description = "ArgoCD Pods"
}

resource "google_service_account_iam_binding" "argocd_workload_identity" {
  service_account_id = google_service_account.argocd.id
  role               = "roles/iam.workloadIdentityUser"
  members = [
    "serviceAccount:${data.google_project.this.project_id}.svc.id.goog[${var.argocd_namespace}/argocd-application-controller]",
    "serviceAccount:${data.google_project.this.project_id}.svc.id.goog[${var.argocd_namespace}/argocd-server]"
  ]
}

resource "google_project_iam_member" "argocd_container_admin" {
  project = data.google_project.this.project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.argocd.email}"
}

resource "kubernetes_secret" "repository_github" {
  metadata {
    name      = "repository-github"
    namespace = "argocd"

    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type          = "git"
    url           = "git@github.com:jace-ys/spacelift-playground"
    sshPrivateKey = file("${path.module}/.tfvars/id_ed25519")
  }
}

resource "kubernetes_secret" "cluster_operator" {
  metadata {
    name      = "cluster-operator"
    namespace = "argocd"

    labels = {
      "argocd.argoproj.io/secret-type" = "cluster"
    }
  }

  data = {
    name   = "operator"
    server = "https://kubernetes.default.svc"
    config = <<EOT
{
  "tlsClientConfig": {
      "insecure": false
  }
}
EOT
  }
}
