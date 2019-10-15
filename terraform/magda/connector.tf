
terraform {
  # The modules used in this example have been updated with 0.12 syntax, which means the example is no longer
  # compatible with any versions below 0.12.
  required_version = ">= 0.12"
}

resource "kubernetes_config_map" "connector" {
  metadata {
    name      = "connector-config"
    namespace = "${var.namespace}"
  }

  data = {
    "dga.json" : "{\"id\":\"dga\",\"ignoreHarvestSources\":[\"*\"],\"image\":{\"name\":\"magda-ckan-connector\"},\"name\":\"data.gov.au\",\"pageSize\":1000,\"schedule\":\"0 * * * *\",\"sourceUrl\":\"https://data.gov.au/\"}"
  }

  depends_on = [
    kubernetes_namespace.magda_namespace
  ]
}

resource "kubernetes_job" "connector" {
  metadata {
    name      = "connector-dga"
    namespace = "${var.namespace}"
  }
  spec {
    template {
      metadata {
        name = "connector-data.gov.au"
      }
      spec {
        container {
          name  = "connector-dga"
          image = "data61/magda-ckan-connector:0.0.53"
          command = [
            "node",
            "/usr/src/app/component/dist/index.js",
            "--config",
            "/etc/config/connector.json",
            "--registryUrl",
            "http://registry-api/v0"
          ]
          resources {
            limits {
              cpu = "100m"
            }
            requests {
              cpu    = "50m"
              memory = "30Mi"
            }
          }
          volume_mount {
            name       = "config"
            mount_path = "/etc/config"
          }

          env {
            name  = "USER_ID"
            value = "00000000-0000-4000-8000-000000000000"
          }

          env {
            name = "JWT_SECRET"
            value_from {
              secret_key_ref {
                name = "auth-secrets"
                key  = "jwt-secret"
              }
            }
          }
        }
        restart_policy = "OnFailure"
        volume {
          name = "config"
          config_map {
            name = "connector-config"
            items {
              key  = "dga.json"
              path = "connector.json"
            }
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_config_map.connector,
    helm_release.magda_helm_release
  ]
}
