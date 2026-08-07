resource "google_dataflow_job" "main" {
  name              = var.name
  template_gcs_path = var.template_gcs_path
  temp_gcs_location = var.temp_gcs_location
  kms_key_name      = var.kms_key_name
  ip_configuration  = "WORKER_IP_PRIVATE"
  network           = var.network
  subnetwork        = var.subnetwork

  project                 = var.project
  region                  = var.region
  zone                    = var.zone
  service_account_email   = google_service_account.dataflow.email
  machine_type            = var.machine_type
  max_workers             = var.max_workers
  labels                  = var.labels
  parameters              = var.parameters
  transform_name_mapping  = var.transform_name_mapping
  additional_experiments  = var.additional_experiments
  enable_streaming_engine = var.enable_streaming_engine

  skip_wait_on_job_termination = var.skip_wait_on_job_termination
  on_delete                    = var.on_delete

  # Ensure every IAM prerequisite the API validates at job-creation time
  # already exists — none of these are referenced by attribute above, so
  # without this Terraform's scheduler is free to create the job first.
  depends_on = [
    google_project_iam_member.dataflow_worker,
    google_kms_crypto_key_iam_member.dataflow_service_agent,
    google_kms_crypto_key_iam_member.dataflow_worker_kms,
    google_storage_bucket_iam_member.template,
    google_storage_bucket_iam_member.temp_gcs,
  ]
}
