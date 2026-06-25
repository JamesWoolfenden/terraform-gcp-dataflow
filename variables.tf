variable "name" {
  type        = string
  description = "Name of the Dataflow job"

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "var.name must be a non-empty string"
  }
}

variable "template_gcs_path" {
  type        = string
  description = "GCS path to the Dataflow job template"

  validation {
    condition     = length(trimspace(var.template_gcs_path)) > 0
    error_message = "var.template_gcs_path must be a non-empty string"
  }
}

variable "temp_gcs_location" {
  type        = string
  description = "GCS path for temporary Dataflow job files"

  validation {
    condition     = length(trimspace(var.temp_gcs_location)) > 0
    error_message = "var.temp_gcs_location must be a non-empty string"
  }
}

variable "kms_key_name" {
  type        = string
  description = "CMEK key used to encrypt worker disks, shuffle storage and pipeline state"

  validation {
    condition     = length(trimspace(var.kms_key_name)) > 0
    error_message = "var.kms_key_name must be a non-empty string"
  }
}

variable "network" {
  type        = string
  description = "Self-link of the VPC network for Dataflow workers"

  validation {
    condition     = length(trimspace(var.network)) > 0
    error_message = "var.network must be a non-empty string"
  }
}

variable "subnetwork" {
  type        = string
  description = "Self-link of the subnetwork for Dataflow workers"

  validation {
    condition     = length(trimspace(var.subnetwork)) > 0
    error_message = "var.subnetwork must be a non-empty string"
  }
}