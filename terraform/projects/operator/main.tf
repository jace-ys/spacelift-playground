data "google_project" "this" {
  project_id = "emp-jace-a850"
}

module "cluster" {
  source = "../../modules/cluster"

  project_id     = data.google_project.this.project_id
  project_number = data.google_project.this.number
  name           = "operator"
  region         = "europe-west1"

  subnet_ip_cidr_range   = "10.16.0.0/22" # 4,094 useable addresses
  master_ip_cidr_range   = "172.18.0.0/28"
  cluster_ip_cidr_range  = "10.40.0.0/16" # 65,534 useable addresses
  services_ip_cidr_range = "10.28.0.0/18" # 16,382 useable addresses

  node_pools = [
    {
      name           = "default-1"
      machine_type   = "c3d-standard-4"
      min_node_count = 1
      max_node_count = 1
    },
  ]
}
