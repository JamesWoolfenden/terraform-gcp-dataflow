# holden:ignore:HLD_TF_026 — examples intentionally use ../../ to reference the local module root
module "dataflow" {
  source            = "../../"
  name              = "example-job"
  template_gcs_path = "gs://example-bucket/templates/example"
  temp_gcs_location = "gs://example-bucket/tmp"
  kms_key_name      = google_kms_crypto_key.main.id
  network           = google_compute_network.private.self_link
  subnetwork        = google_compute_subnetwork.workers.self_link
}