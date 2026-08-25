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

# google_dataflow_flex_template_job and google_data_pipeline_pipeline pull
# their container spec from flex_template_gcs_path, which is not assumed to
# be bucket_name's bucket (see the objectViewer grant above) — needs its own
# grant on flex_template_bucket_name.
resource "google_storage_bucket_iam_member" "flex_template" {
  count = var.flex_template_gcs_path == "" ? 0 : 1

  bucket = var.flex_template_bucket_name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.dataflow.email}"
}

# Flex Template jobs run from a container image; the worker SA needs pull
# access to whatever Artifact Registry repository hosts it.
resource "google_project_iam_member" "flex_template_image_pull" {
  count = var.flex_template_gcs_path == "" ? 0 : 1

  project = var.project
  role    = "roles/artifactregistry.reader"
  member  = "serviceAccount:${google_service_account.dataflow.email}"
}

# roles/dataflow.worker (above) lets the SA run as a worker but does not
# include job-creation — google_data_pipeline_pipeline's
# scheduler_service_account_email needs to actually launch jobs on schedule.
resource "google_project_iam_member" "dataflow_developer" {
  count = var.pipeline_schedule == "" ? 0 : 1

  project = var.project
  role    = "roles/dataflow.developer"
  member  = "serviceAccount:${google_service_account.dataflow.email}"
}
