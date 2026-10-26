resource "google_data_pipeline_pipeline" "main" {
  count = var.flex_template_gcs_path == "" || var.pipeline_schedule == "" ? 0 : 1

  name         = "projects/${var.project}/locations/${var.region}/pipelines/${var.name}"
  display_name = var.name
  type         = "PIPELINE_TYPE_BATCH"
  state        = "STATE_ACTIVE"
  region       = var.region
  project      = var.project

  schedule_info {
    schedule  = var.pipeline_schedule
    time_zone = var.pipeline_time_zone
  }

  scheduler_service_account_email = google_service_account.scheduler[0].email

  workload {
    dataflow_launch_template_request {
      project_id = var.project
      gcs_path   = var.flex_template_gcs_path

      launch_parameters {
        job_name   = "${var.name}-scheduled"
        parameters = var.parameters

        environment {
          temp_location           = var.temp_gcs_location
          kms_key_name            = var.kms_key_name
          ip_configuration        = "WORKER_IP_PRIVATE"
          network                 = var.network
          subnetwork              = var.subnetwork
          service_account_email   = google_service_account.dataflow.email
          machine_type            = var.machine_type
          max_workers             = var.max_workers
          additional_experiments  = var.additional_experiments
          enable_streaming_engine = var.enable_streaming_engine
          additional_user_labels  = var.labels
        }
      }
    }
  }

  depends_on = [
    google_project_iam_member.dataflow_worker,
    google_project_iam_member.dataflow_developer,
    google_service_account_iam_member.scheduler_act_as_worker,
    google_kms_crypto_key_iam_member.dataflow_service_agent,
    google_kms_crypto_key_iam_member.dataflow_worker_kms,
    google_storage_bucket_iam_member.flex_template,
    google_project_iam_member.flex_template_image_pull,
  ]
}
