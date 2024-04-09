output "cluster_public_endpoint" {
  value = google_container_cluster.cluster.endpoint
}

output "cluster_client_certificate" {
  value = google_container_cluster.cluster.master_auth[0].client_certificate
}

output "cluster_client_key" {
  value = google_container_cluster.cluster.master_auth[0].client_key
}

output "cluster_ca_certificate" {
  value = google_container_cluster.cluster.master_auth[0].cluster_ca_certificate
}
