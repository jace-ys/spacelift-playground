resource "google_kms_key_ring" "keyring" {
  project  = var.project_id
  name     = "${local.cluster_name}-keyring"
  location = var.region
}

resource "google_kms_crypto_key" "application_layer_secrets_encryption_key" {
  name     = "${local.cluster_name}-encryption-key"
  key_ring = google_kms_key_ring.keyring.id

  purpose = "ENCRYPT_DECRYPT"
  version_template {
    algorithm        = "GOOGLE_SYMMETRIC_ENCRYPTION"
    protection_level = "SOFTWARE"
  }

  # Secrets remain encrypted (and decrypt-able) with the key version they were originally encrypted with.
  # It is however possible to force secrets to be re-encrypted with the latest key version.
  # See: https://cloud.google.com/kubernetes-engine/docs/how-to/encrypting-secrets#reencrypt-secrets
  rotation_period = "2592000s" # 30 days
}
