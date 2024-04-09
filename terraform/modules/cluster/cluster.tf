resource "google_container_cluster" "cluster" {
  provider = google-beta

  project  = var.project_id
  name     = local.cluster_name
  location = var.region

  network    = google_compute_network.cluster.name
  subnetwork = google_compute_subnetwork.cluster.name

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  initial_node_count       = 1
  remove_default_node_pool = true
  enable_shielded_nodes    = true

  # Enable Dataplane V2
  datapath_provider          = "ADVANCED_DATAPATH"
  enable_fqdn_network_policy = true

  release_channel {
    channel = "REGULAR"
  }

  networking_mode = "VPC_NATIVE"
  ip_allocation_policy {
    cluster_ipv4_cidr_block  = var.cluster_ip_cidr_range
    services_ipv4_cidr_block = var.services_ip_cidr_range
  }

  private_cluster_config {
    enable_private_endpoint = false
    enable_private_nodes    = true
    master_ipv4_cidr_block  = var.master_ip_cidr_range
  }

  database_encryption {
    state    = "ENCRYPTED"
    key_name = "projects/${var.project_id}/locations/${var.region}/keyRings/${google_kms_key_ring.keyring.name}/cryptoKeys/${google_kms_crypto_key.application_layer_secrets_encryption_key.name}"
  }

  dns_config {
    cluster_dns        = "CLOUD_DNS"
    cluster_dns_scope  = "VPC_SCOPE"
    cluster_dns_domain = "cluster.${var.name}"
  }

  logging_config {
    enable_components = ["SYSTEM_COMPONENTS", "SCHEDULER", "WORKLOADS"]
  }

  monitoring_config {
    enable_components = ["SYSTEM_COMPONENTS", "APISERVER", "SCHEDULER", "CONTROLLER_MANAGER"]

    managed_prometheus {
      enabled = false
    }

    advanced_datapath_observability_config {
      enable_metrics = false
    }
  }

  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  authenticator_groups_config {
    security_group = "gke-security-groups@duffel.com"
  }

  security_posture_config {
    mode               = "BASIC"
    vulnerability_mode = "VULNERABILITY_BASIC"
  }

  cost_management_config {
    enabled = true
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }

  addons_config {
    dns_cache_config {
      enabled = true
    }

    config_connector_config {
      enabled = true
    }
  }

  depends_on = [google_project_iam_member.application_layer_secrets_encryption]
}

resource "google_container_node_pool" "node_pool" {
  provider = google-beta
  for_each = { for np in var.node_pools : np.name => np }

  project  = var.project_id
  name     = "${each.key}-${var.region}"
  location = var.region
  cluster  = google_container_cluster.cluster.name

  autoscaling {
    min_node_count = each.value.min_node_count
    max_node_count = each.value.max_node_count
  }

  # This setting is only for Kubernetes upgrades and does not affect Terraform plans
  upgrade_settings {
    max_surge       = 3
    max_unavailable = 1
  }

  node_config {
    machine_type = each.value.machine_type
    image_type   = "COS_CONTAINERD"

    disk_size_gb    = 50
    service_account = google_service_account.cluster_nodes.email

    dynamic "sandbox_config" {
      for_each = each.value.sandbox ? toset([1]) : toset([])

      content {
        sandbox_type = "gvisor"
      }
    }

    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    resource_labels = {
      workload = each.value.workload_type != null ? each.value.workload_type : null
    }

    labels = {
      workload = each.value.workload_type != null ? each.value.workload_type : null
    }

    dynamic "taint" {
      for_each = each.value.workload_type != null ? toset([1]) : toset([])

      content {
        effect = "NO_SCHEDULE"
        key    = "workload"
        value  = each.value.workload_type
      }
    }
  }
}
