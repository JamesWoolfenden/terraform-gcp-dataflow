# This is the terminal log-destination bucket for google_storage_bucket.
# dataflow — pointing its own logging back at itself would trip HLD_GCP_451,
# and chaining a further log bucket behind it has no benefit.
# holden:ignore:HLD_GCP_003: this bucket is a log destination itself; no further log target is needed
resource "google_storage_bucket" "dataflow_logs" {
  name                        = "${data.google_project.current.project_id}-dataflow-example-logs"
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
    log_bucket = google_storage_bucket.dataflow_logs.name
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

# Cloud Storage delivers usage/storage logs as this group — see HLD_GCP_536.
# Without this grant, dataflow.logging.log_bucket points at a bucket that
# silently never receives anything (uniform bucket-level access removes the
# legacy ACL fallback that used to mask this).
resource "google_storage_bucket_iam_member" "log_delivery" {
  bucket = google_storage_bucket.dataflow_logs.name
  role   = "roles/storage.objectCreator"
  member = "group:cloud-storage-analytics@google.com"
}
