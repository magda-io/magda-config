terraform {
  # The modules used in this example have been updated with 0.12 syntax, which means the example is no longer
  # compatible with any versions below 0.12.
  required_version = ">= 0.12"
}

resource "google_compute_managed_ssl_certificate" "default" {
  count    = local.setup_ssl ? 1 : 0
  provider = google-beta

  name = "magda-certificate"

  managed {
    domains = ["${local.runtime_external_domain}"]
  }

  depends_on = [
    kubernetes_cluster_role_binding.default_service_acc_role_binding,
    kubernetes_namespace.magda_namespace
  ]
}

# Ingress will be created before helm complete as it takes time 
resource "kubernetes_ingress" "default" {
  metadata {
    name      = "magda-primary-ingress"
    namespace = var.namespace
    annotations = {
      "ingress.gcp.kubernetes.io/pre-shared-cert"   = local.setup_ssl ? google_compute_managed_ssl_certificate.default[0].name : null
      "kubernetes.io/ingress.global-static-ip-name" = module.external_ip.name
    }
  }

  spec {
    backend {
      service_name = "gateway"
      service_port = 80
    }
  }

  depends_on = [
    kubernetes_cluster_role_binding.default_service_acc_role_binding,
    kubernetes_namespace.magda_namespace
  ]
}
