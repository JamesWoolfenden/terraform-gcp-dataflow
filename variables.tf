# holden:ignore:HLD_TF_027 — the module deliberately exposes google_dataflow_job's full argument
# surface rather than a curated subset, since it exists to exercise holden's dataflow policy set
variable "name" {
  type        = string
  description = "Name of the Dataflow job"

  validation {
    condition     = length(trimspace(var.name)) > 0
    error_message = "var.name must be a non-empty string"
  }
}

variable "service_account_id" {
  type        = string
  description = "account_id for the dedicated service account Dataflow workers run as"

  validation {
    condition     = length(var.service_account_id) >= 6 && length(var.service_account_id) <= 30
    error_message = "var.service_account_id must be between 6 and 30 characters"
  }

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.service_account_id))
    error_message = "var.service_account_id must start with a lowercase letter, end with a lowercase letter or digit, and contain only lowercase letters, digits, and hyphens"
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
  sensitive   = true

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

variable "project" {
  type        = string
  description = "Project to run the Dataflow job in"

  validation {
    condition     = length(trimspace(var.project)) > 0
    error_message = "var.project must be a non-empty string"
  }
}

variable "region" {
  type        = string
  description = "Region to run the Dataflow job in. Defaults to the provider region when null"
  default     = null

  validation {
    condition     = var.region == null || length(trimspace(var.region)) > 0
    error_message = "var.region must be null or a non-empty string"
  }
}

variable "zone" {
  type        = string
  description = "Zone to run the Dataflow job in. Defaults to the provider zone when null"
  default     = null

  validation {
    condition     = var.zone == null || length(trimspace(var.zone)) > 0
    error_message = "var.zone must be null or a non-empty string"
  }
}

variable "machine_type" {
  type        = string
  description = "GCE machine type for Dataflow workers"
  default     = null

  validation {
    condition     = var.machine_type == null || length(trimspace(var.machine_type)) > 0
    error_message = "var.machine_type must be null or a non-empty string"
  }
}

variable "max_workers" {
  type        = number
  description = "Maximum number of workers the job can autoscale to"
  default     = null

  validation {
    condition     = var.max_workers == null || var.max_workers > 0
    error_message = "var.max_workers must be a positive number"
  }
}

variable "labels" {
  type        = map(string)
  description = "Labels applied to the Dataflow job"
  default     = {}

  validation {
    condition     = alltrue([for k in keys(var.labels) : length(trimspace(k)) > 0])
    error_message = "var.labels keys must be non-empty strings"
  }
}

variable "parameters" {
  type        = map(string)
  description = "Runtime parameters passed to the Dataflow template"
  default     = {}

  validation {
    condition     = alltrue([for k in keys(var.parameters) : length(trimspace(k)) > 0])
    error_message = "var.parameters keys must be non-empty strings"
  }
}

variable "transform_name_mapping" {
  type        = map(string)
  description = "Mapping of existing transform names to new ones, used when updating a running streaming job in place"
  default     = {}

  validation {
    condition     = alltrue([for k in keys(var.transform_name_mapping) : length(trimspace(k)) > 0])
    error_message = "var.transform_name_mapping keys must be non-empty strings"
  }
}

variable "additional_experiments" {
  type        = set(string)
  description = "Additional experiment flags passed to the Dataflow job"
  default     = []

  validation {
    condition     = alltrue([for e in var.additional_experiments : length(trimspace(e)) > 0])
    error_message = "var.additional_experiments entries must be non-empty strings"
  }
}

variable "enable_streaming_engine" {
  type        = bool
  description = "Enable Streaming Engine, which moves streaming state off worker VMs into the Dataflow service"
  default     = false
}

variable "skip_wait_on_job_termination" {
  type        = bool
  description = "If true, do not wait for the job to reach a terminal state before removing it from Terraform state on destroy"
  default     = false
}

variable "on_delete" {
  type        = string
  description = "Behavior of google_dataflow_job on terraform destroy/replace: \"cancel\" or \"drain\". Streaming jobs should use \"drain\" to avoid dropping in-flight data"
  default     = "cancel"

  validation {
    condition     = contains(["cancel", "drain"], var.on_delete)
    error_message = "var.on_delete must be \"cancel\" or \"drain\""
  }
}

variable "bucket_name" {
  type        = string
  description = "Name of the GCS bucket used for Dataflow templates and temporary files"

  validation {
    condition     = length(trimspace(var.bucket_name)) > 0
    error_message = "var.bucket_name must be a non-empty string"
  }
}

variable "flex_template_gcs_path" {
  type        = string
  description = "Cloud Storage path of the Flex Template container spec. Empty to create no Flex Template job"
  default     = ""

  validation {
    condition     = var.flex_template_gcs_path == "" || can(regex("^gs://", var.flex_template_gcs_path))
    error_message = "var.flex_template_gcs_path must be a gs:// URI"
  }
}

variable "pipeline_schedule" {
  type        = string
  description = "Cron schedule for a Data Pipelines job that launches the Flex Template. Empty to create no pipeline"
  default     = ""

  validation {
    condition     = var.pipeline_schedule == "" || length(split(" ", trimspace(var.pipeline_schedule))) == 5
    error_message = "var.pipeline_schedule must be a five-field cron expression"
  }
}

variable "pipeline_time_zone" {
  type        = string
  description = "IANA time zone the pipeline schedule is interpreted in"
  default     = "Etc/UTC"

  validation {
    condition     = length(trimspace(var.pipeline_time_zone)) > 0
    error_message = "var.pipeline_time_zone must be a non-empty string"
  }
}

variable "flex_template_bucket_name" {
  type        = string
  description = "Name of the GCS bucket that flex_template_gcs_path's container spec lives in. Required when flex_template_gcs_path is set; ignored otherwise"
  default     = ""

  validation {
    condition     = var.flex_template_bucket_name == "" || length(trimspace(var.flex_template_bucket_name)) > 0
    error_message = "var.flex_template_bucket_name must be null or a non-empty string"
  }

  validation {
    condition     = var.flex_template_gcs_path == "" || var.flex_template_bucket_name != ""
    error_message = "var.flex_template_bucket_name is required when var.flex_template_gcs_path is set"
  }
}

variable "scheduler_service_account_id" {
  type        = string
  description = "account_id for the dedicated service account used to launch scheduled Data Pipelines jobs. Kept separate from service_account_id (the worker identity) so a compromised pipeline transform can't inherit project-wide job-launch privileges. Required when pipeline_schedule is set; ignored otherwise"
  default     = ""

  validation {
    condition     = var.scheduler_service_account_id == "" || (length(var.scheduler_service_account_id) >= 6 && length(var.scheduler_service_account_id) <= 30)
    error_message = "var.scheduler_service_account_id must be between 6 and 30 characters"
  }

  validation {
    condition     = var.scheduler_service_account_id == "" || can(regex("^[a-z][a-z0-9-]*[a-z0-9]$", var.scheduler_service_account_id))
    error_message = "var.scheduler_service_account_id must start with a lowercase letter, end with a lowercase letter or digit, and contain only lowercase letters, digits, and hyphens"
  }

  validation {
    condition     = var.pipeline_schedule == "" || var.scheduler_service_account_id != ""
    error_message = "var.scheduler_service_account_id is required when var.pipeline_schedule is set"
  }
}
