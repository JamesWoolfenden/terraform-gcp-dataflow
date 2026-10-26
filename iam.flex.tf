# IAM for the optional Flex Template job and its scheduled Data Pipelines
# launcher — kept separate from iam.tf's classic-job grants (google_service_
# account.dataflow, the worker identity) since roles/dataflow.developer below
# must never be reachable from worker code.

# google_dataflow_flex_template_job and google_data_pipeline_pipeline pull
# their container spec from flex_template_gcs_path, which is not assumed to
# be bucket_name's bucket (see iam.tf's objectViewer grant) — needs its own
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

# Dedicated identity for google_data_pipeline_pipeline's
# scheduler_service_account_email — kept separate from google_service_account
# .dataflow (the worker identity, which runs pipeline transform code against
# potentially untrusted data) so that roles/dataflow.developer's project-wide
# job-launch/manage/cancel power is never reachable from a compromised worker.
resource "google_service_account" "scheduler" {
  count = var.pipeline_schedule == "" ? 0 : 1

  account_id   = var.scheduler_service_account_id
  display_name = "Data Pipelines scheduler service account for ${var.name}"
  project      = var.project
}

# The scheduler launches jobs that run as the worker SA, so it needs actAs on
# that one account (not project-wide).
resource "google_service_account_iam_member" "scheduler_act_as_worker" {
  count = var.pipeline_schedule == "" ? 0 : 1

  service_account_id = google_service_account.dataflow.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.scheduler[0].email}"
}

resource "google_project_iam_member" "dataflow_developer" {
  count = var.pipeline_schedule == "" ? 0 : 1

  project = var.project
  role    = "roles/dataflow.developer"
  member  = "serviceAccount:${google_service_account.scheduler[0].email}"
}
