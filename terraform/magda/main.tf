terraform {
  # The modules used in this example have been updated with 0.12 syntax, which means the example is no longer
  # compatible with any versions below 0.12.
  required_version = ">= 0.12"
  required_providers {
    helm       = "1.1.1"
    kubernetes = "1.10.0"
    random     = "2.2.1"
  }
}

provider "google-beta" {
  version     = ">= 2.11.0"
  project     = var.project
  region      = var.region
  credentials = var.credential_file_path
}

provider "google" {
  version     = ">= 2.11.0"
  project     = var.project
  region      = var.region
  credentials = var.credential_file_path
}

locals {
  cluster_access_toekn          = "${data.google_client_config.default.access_token}"
  cluster_access_host           = "https://${module.cluster.endpoint}"
  cluster_access_ca_certificate = "${base64decode(module.cluster.master_auth.0.cluster_ca_certificate)}"
  setup_ssl                     = var.external_domain == null ? false : true
  runtime_external_domain       = var.external_domain == null ? "${module.external_ip.address}.xip.io" : "${var.external_domain}"
  runtime_external_url          = local.setup_ssl ? "https://${local.runtime_external_domain}/" : "http://${local.runtime_external_domain}/"
}

data "google_client_config" "default" {}

provider "kubernetes" {
  # We use the oauth2 token of the google provider client
  # and get cluster parameter from module
  # this will ensure right live parameter in place
  # avoid using google_container_cluster as it might be difficult to control triming at both `refresh` & `apply` stage
  load_config_file = false

  host                   = local.cluster_access_host
  token                  = local.cluster_access_toekn
  cluster_ca_certificate = local.cluster_access_ca_certificate
}

provider "helm" {
  kubernetes {
    load_config_file = false

    host                   = local.cluster_access_host
    token                  = local.cluster_access_toekn
    cluster_ca_certificate = local.cluster_access_ca_certificate
  }
}

module "external_ip" {
  source = "../google-reserved-ip"
}

module "cluster" {
  source               = "../google-cluster"
  project              = var.project
  region               = var.region
  machine_type         = var.cluster_node_pool_machine_type
}

resource "kubernetes_cluster_role_binding" "default_service_acc_role_binding" {
  metadata {
    name = "default-service-acc-role-binding"
  }
  role_ref {
    kind      = "ClusterRole"
    name      = "cluster-admin"
    api_group = "rbac.authorization.k8s.io"
  }
  subject {
    kind      = "ServiceAccount"
    name      = "default"
    namespace = "kube-system"
  }

  depends_on = [
    module.cluster
  ]
}

resource "kubernetes_namespace" "magda_namespace" {
  metadata {
    name = var.namespace
  }
  depends_on = [
    kubernetes_cluster_role_binding.default_service_acc_role_binding
  ]
}

resource "kubernetes_namespace" "magda_openfaas_namespace" {
  metadata {
    name = "${var.namespace}-openfaas"
    labels = {
      role: "openfaas-system"
      access: "openfaas-system"
      istio-injection: "enabled"
    }
  }
  depends_on = [
    kubernetes_cluster_role_binding.default_service_acc_role_binding
  ]
}

resource "kubernetes_namespace" "magda_openfaas_fn_namespace" {
  metadata {
    name = "${var.namespace}-openfaas-fn"
    labels = {
      role: "openfaas-fn"
      istio-injection: "enabled"
    }
  }
  depends_on = [
    kubernetes_cluster_role_binding.default_service_acc_role_binding
  ]
}

resource "helm_release" "magda_helm_release" {
  name = "magda"
  # or repository = "../../helm" for local repo
  repository    = "https://charts.magda.io/"
  chart         = "magda"
  version       = var.magda_version
  devel         = var.allow_dev_magda_version
  timeout       = 3600
  force_update  = true
  wait          = true
  skip_crds     = false

  namespace = var.namespace

  values = [
    "${file("../../config.yaml")}"
  ]

  set {
    name  = "global.externalUrl"
    value = local.runtime_external_url
  }

  set {
    name  = "global.useCombinedDb"
    value = true
  }

  set {
    name  = "global.useCloudSql"
    value = false
  }

  set {
    name  = "tags.cloud-sql-proxy"
    value = false
  }

  set {
    name  = "tags.ingress"
    value = false
  }

  set {
    name  = "magda-core.gateway.service.type"
    value = "NodePort"
  }

  # turn off auto namespace creation as terraform handles it better (and helm provider behave differently)
  set {
    name  = "magda-core.openfaas.createMainNamespace"
    value = false
  }

  set {
    name  = "magda-core.openfaas.createFunctionNamespace"
    value = false
  }

  set {
    name  = "global.openfaas.mainNamespace"
    value = "openfaas"
  }

  set {
    name  = "global.openfaas.namespacePrefix"
    value = var.namespace
  }

  depends_on = [
    kubernetes_cluster_role_binding.default_service_acc_role_binding,
    kubernetes_namespace.magda_namespace,
    kubernetes_namespace.magda_openfaas_namespace,
    kubernetes_namespace.magda_openfaas_fn_namespace,
    kubernetes_secret.auth_secrets,
    kubernetes_secret.db_passwords
  ]
}


