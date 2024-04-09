variable "google_project" {
  type    = string
  default = "emp-jace-a850"
}

variable "google_region" {
  type    = string
  default = "europe-west1"
}

variable "spacelift_key_id" {
  type    = string
  default = "01HRPR7A2TF3JC7H193HTVZNC3"
}

variable "spacelift_key_secret" {
  type      = string
  sensitive = true
}
