data "google_project" "current" {}

# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root
module "dataflow" {
  source             = "../../"
  name               = "example-job"
  service_account_id = "dataflow-example-job"
  bucket_name       = google_storage_bucket.dataflow.name
  template_gcs_path  = "gs://${google_storage_bucket.dataflow.name}/templates/example"
  temp_gcs_location  = "gs://${google_storage_bucket.dataflow.name}/tmp"
  kms_key_name       = google_kms_crypto_key.main.id
  network            = google_compute_network.private.self_link
  subnetwork         = google_compute_subnetwork.workers.self_link
  project            = data.google_project.current.project_id
}