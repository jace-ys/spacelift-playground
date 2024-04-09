resource "google_service_account" "cluster_nodes" {
  project      = var.project_id
  account_id   = "${var.name}-cluster-nodes"
  display_name = "Cluster Nodes Service Account [${var.name}]"
}

resource "google_project_iam_member" "cluster_nodes_gke_node_service_account" {
  project = var.project_id
  role    = "roles/container.nodeServiceAccount"
  member  = "serviceAccount:${google_service_account.cluster_nodes.email}"
}

# https://cloud.google.com/kubernetes-engine/docs/how-to/encrypting-secrets#grant_permission_to_use_the_key
resource "google_project_iam_member" "application_layer_secrets_encryption" {
  project = var.project_id
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member  = "serviceAccount:service-${var.project_number}@container-engine-robot.iam.gserviceaccount.com"
}
