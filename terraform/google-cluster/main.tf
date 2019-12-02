
terraform {
  # The modules used in this example have been updated with 0.12 syntax, which means the example is no longer
  # compatible with any versions below 0.12.
  required_version = ">= 0.12"
}

data "google_container_engine_versions" "available_k8s_version" {
  location = "${var.region}"
}

resource "google_container_cluster" "primary_magda_cluster" {
  provider = google-beta
  name     = var.cluster_name
  location = var.region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.

  # So why create node pool throught a separate resource? 
  # It's important to do so as we will have a direct maping in the terraform `state` and make it possible to migrate existing cluster. 
  # e.g. Reuse the existing node pools that has been created
  remove_default_node_pool = true
  initial_node_count       = 1

  min_master_version = data.google_container_engine_versions.available_k8s_version.latest_master_version
  node_version       = data.google_container_engine_versions.available_k8s_version.latest_node_version

  master_auth {
    # Disable basic auth
    username = ""
    password = ""

    client_certificate_config {
      issue_client_certificate = false
    }
  }

  addons_config {
    kubernetes_dashboard {
      disabled = var.kubernetes_dashboard ? false : true
    }
  }

}

resource "google_container_node_pool" "primary_magda_node_pool" {
  provider   = google-beta
  name       = var.node_pool_name
  location   = var.region
  cluster    = google_container_cluster.primary_magda_cluster.name
  node_count = 1

  version = data.google_container_engine_versions.available_k8s_version.latest_node_version

  node_config {
    preemptible  = var.preemptible
    machine_type = var.machine_type

    metadata = {
      disable-legacy-endpoints = "true"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
    ]
  }
}

