resource "google_kms_key_ring" "main" {
  name     = "dataflow-keyring"
  location = "europe-west2"
}

resource "google_kms_crypto_key" "main" {
  name                       = "dataflow-key"
  key_ring                   = google_kms_key_ring.main.id
  rotation_period            = "2592000s" # 30 days
  destroy_scheduled_duration = "2592000s" # 1 day

  lifecycle {
    prevent_destroy = true
  }
}
