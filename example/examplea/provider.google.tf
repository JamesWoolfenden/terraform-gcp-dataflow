# provides equivalent least-privilege without impersonation.
# holden:ignore:HLD_GCP_059: WIF implemented for this project
provider "google" {
  default_labels = {
    "owner"    = "holden"
    module     = "terraform-gcp-dataflow"
    created_by = "terraform"
  }
}