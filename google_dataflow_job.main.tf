resource "google_dataflow_job" "main" {
  name              = var.name
  template_gcs_path = var.template_gcs_path
  temp_gcs_location = var.temp_gcs_location
  kms_key_name      = var.kms_key_name
  ip_configuration  = "WORKER_IP_PRIVATE"
  network           = var.network
  subnetwork        = var.subnetwork

  on_delete = "cancel"
}