output "id" {
  value       = google_dataflow_job.main.id
  description = "ID of the Dataflow job"
}

output "job_id" {
  value       = google_dataflow_job.main.job_id
  description = "Dataflow job ID assigned by the service"
}

output "state" {
  value       = google_dataflow_job.main.state
  description = "Current state of the Dataflow job"
}

output "service_account_email" {
  value       = google_service_account.dataflow.email
  description = "Email of the dedicated service account the Dataflow workers run as. Grant this identity access to any resources the pipeline needs (e.g. a CMEK key's roles/cloudkms.cryptoKeyEncrypterDecrypter)"
}