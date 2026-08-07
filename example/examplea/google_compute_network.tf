# holden:ignore:HLD_GCP_094:  Just for example
# holden:ignore:HLD_GCP_303:  Just for example
# holden:ignore:HLD_GCP_093:  Just for example
resource "google_compute_network" "private" {
  name                    = "dataflow-private"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "workers" {
  name                     = "dataflow-workers"
  ip_cidr_range            = "10.90.0.0/24"
  region                   = "europe-west2"
  network                  = google_compute_network.private.id
  private_ip_google_access = true

  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
  }
}