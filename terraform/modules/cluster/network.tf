resource "google_compute_network" "cluster" {
  project                 = var.project_id
  name                    = local.cluster_name
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "cluster" {
  project       = var.project_id
  name          = local.cluster_name
  network       = google_compute_network.cluster.name
  ip_cidr_range = var.subnet_ip_cidr_range
  region        = var.region

  # To access Google APIs without going over the public Internet
  private_ip_google_access = true

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_router" "cluster" {
  project = var.project_id
  name    = local.cluster_name
  region  = var.region
  network = google_compute_network.cluster.name
}

resource "google_compute_router_nat" "cluster" {
  project = var.project_id
  name    = local.cluster_name
  router  = google_compute_router.cluster.name
  region  = var.region

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "LIST_OF_SUBNETWORKS"

  subnetwork {
    name                    = google_compute_subnetwork.cluster.self_link
    source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
  }

  log_config {
    enable = false
    filter = "ALL"
  }
}
