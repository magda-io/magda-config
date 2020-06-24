
terraform {
  # The modules used in this example have been updated with 0.12 syntax, which means the example is no longer
  # compatible with any versions below 0.12.
  required_version = ">= 0.12"
}

locals {
  db_password    = "${var.db_password == null ? random_password.db_password.result : var.db_password}"
  jwt_secret     = "${var.jwt_secret == null ? random_password.jwt_secret.result : var.jwt_secret}"
  session_secret = "${var.session_secret == null ? random_password.session_secret.result : var.session_secret}"
  storage_access_key     = "${var.storage_access_key == null ? random_password.storage_access_key.result : var.storage_access_key}"
  storage_access_key_secret     = "${var.storage_access_key_secret == null ? random_password.storage_access_key_secret.result : var.storage_access_key_secret}"
  should_create_oauth_secret = (var.facebook_client_secret == null &&
    var.google_client_secret == null &&
    var.arcgis_client_secret == null &&
  var.vanguard_certificate == null ? 0 : 1)
  should_create_smtp_secret = var.smtp_username == null && var.smtp_password == null ? 0 : 1
}

resource "random_password" "db_password" {
  length  = 16
  special = true
}

resource "random_password" "jwt_secret" {
  length  = 32
  special = true
}

resource "random_password" "session_secret" {
  length  = 32
  special = true
}

resource "random_password" "storage_access_key" {
  length  = 32
}

resource "random_password" "storage_access_key_secret" {
  length  = 32
  special = true
}

resource "kubernetes_secret" "auth_secrets" {
  metadata {
    name      = "auth-secrets"
    namespace = var.namespace
  }

  data = {
    "jwt-secret"     = "${local.jwt_secret}"
    "session-secret" = "${local.session_secret}"
  }

  type = "Opaque"

  depends_on = [
    kubernetes_cluster_role_binding.default_service_acc_role_binding,
    kubernetes_namespace.magda_namespace
  ]
}

resource "kubernetes_secret" "storage_secrets" {
  metadata {
    name      = "storage-secrets"
    namespace = var.namespace
  }

  data = {
    "accesskey"     = "${local.storage_access_key}"
    "secretkey" = "${local.storage_access_key_secret}"
  }

  type = "Opaque"

  depends_on = [
    kubernetes_cluster_role_binding.default_service_acc_role_binding,
    kubernetes_namespace.magda_namespace
  ]
}

resource "kubernetes_secret" "db_passwords" {
  metadata {
    name      = "db-passwords"
    namespace = var.namespace
  }

  data = {
    "combined-db"             = "${local.db_password}"
    "authorization-db"        = "${local.db_password}"
    "content-db"              = "${local.db_password}"
    "session-db"              = "${local.db_password}"
    "registry-db"             = "${local.db_password}"
    "tenant-db"               = "${local.db_password}"
    "combined-db-client"      = "${local.db_password}"
    "authorization-db-client" = "${local.db_password}"
    "content-db-client"       = "${local.db_password}"
    "session-db-client"       = "${local.db_password}"
    "registry-db-client"      = "${local.db_password}"
    "tenant-db-client"        = "${local.db_password}"
  }

  type = "Opaque"

  depends_on = [
    kubernetes_cluster_role_binding.default_service_acc_role_binding,
    kubernetes_namespace.magda_namespace
  ]
}

resource "kubernetes_secret" "oauth_secrets" {

  count = local.should_create_oauth_secret

  metadata {
    name      = "oauth-secrets"
    namespace = var.namespace
  }

  data = {
    "facebook-client-secret" = "${var.facebook_client_secret}"
    "google-client-secret"   = "${var.google_client_secret}"
    "arcgis-client-secret"   = "${var.arcgis_client_secret}"
    "vanguard_certificate"   = "${var.vanguard_certificate}"
  }

  type = "Opaque"

  depends_on = [
    kubernetes_cluster_role_binding.default_service_acc_role_binding,
    kubernetes_namespace.magda_namespace
  ]
}

resource "kubernetes_secret" "smtp_secret" {

  count = local.should_create_smtp_secret

  metadata {
    name      = "smtp-secret"
    namespace = var.namespace
  }

  data = {
    "smtp_username" = "${var.smtp_username}"
    "smtp_password" = "${var.smtp_password}"
  }

  type = "Opaque"

  depends_on = [
    kubernetes_cluster_role_binding.default_service_acc_role_binding,
    kubernetes_namespace.magda_namespace
  ]
}
