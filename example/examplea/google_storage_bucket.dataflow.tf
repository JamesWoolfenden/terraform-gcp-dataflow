resource "google_storage_bucket" "dataflow" {
  name                        = "${data.google_project.current.project_id}-dataflow-example"
  location                    = "europe-west2"
  uniform_bucket_level_access = true
  force_destroy               = true

  public_access_prevention = "enforced"

  encryption {
    default_kms_key_name = google_kms_crypto_key.main.id
  }

  versioning {
    enabled = true
  }

  logging {
    log_bucket = "${data.google_project.current.project_id}-dataflow-example"
  }

  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type = "Delete"
    }
  }

  soft_delete_policy {
    retention_duration_seconds = 604800
  }

  depends_on = [google_kms_crypto_key_iam_member.gcs_service_agent]
}

# GCS's own service agent must hold decrypt access on the CMEK key before it
# will use it for this bucket — same pattern as the Dataflow grants in
# ../../iam.tf.
resource "google_kms_crypto_key_iam_member" "gcs_service_agent" {
  crypto_key_id = google_kms_crypto_key.main.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.current.number}@gs-project-accounts.iam.gserviceaccount.com"
}
