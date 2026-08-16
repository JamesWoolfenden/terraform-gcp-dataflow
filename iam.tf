data "google_project" "current" {
  project_id = var.project
}

resource "google_service_account" "dataflow" {
  account_id   = var.service_account_id
  display_name = "Dataflow service account for ${var.name}"
  project      = var.project
}

resource "google_project_iam_member" "dataflow_worker" {
  project = var.project
  role    = "roles/dataflow.worker"
  member  = "serviceAccount:${google_service_account.dataflow.email}"
}

# The Dataflow Service Agent must hold decrypt access on the CMEK key before
# the API will use it — see HLD_GCP_483. Terraform accepts a missing grant;
# GCP only rejects it at apply/first-use time.
resource "google_kms_crypto_key_iam_member" "dataflow_service_agent" {
  crypto_key_id = var.kms_key_name
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:service-${data.google_project.current.number}@dataflow-service-producer-prod.iam.gserviceaccount.com"
}

# The worker controller SA needs the same decrypt access, separately from the
# Dataflow Service Agent grant above.
resource "google_kms_crypto_key_iam_member" "dataflow_worker_kms" {
  crypto_key_id = var.kms_key_name
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_service_account.dataflow.email}"
}

resource "google_storage_bucket_iam_member" "template" {
  bucket = var.bucket_name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.dataflow.email}"
}

resource "google_storage_bucket_iam_member" "temp_gcs" {
  bucket = var.bucket_name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.dataflow.email}"
}
