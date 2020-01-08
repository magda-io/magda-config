

terraform {
  # The modules used in this example have been updated with 0.12 syntax, which means the example is no longer
  # compatible with any versions below 0.12.
  required_version = ">= 0.12"
}

resource "google_compute_global_address" "external_ip" {
  provider = google-beta
  name = var.name
  address_type = "EXTERNAL"
  ip_version = "IPV4"
}