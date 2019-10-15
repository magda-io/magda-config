terraform {
  # The modules used in this example have been updated with 0.12 syntax, which means the example is no longer
  # compatible with any versions below 0.12.
  required_version = ">= 0.12"
}

resource "null_resource" "attemp_apply_cert" {
  provisioner "local-exec" {
    command     = "./apply.sh"
    working_dir = "../wildcard-acme-certificate"
    environment = {
      TF_VAR_aws_access_key          = "${var.aws_access_key}"
      TF_VAR_aws_secret_key          = "${var.aws_secret_key}"
      TF_VAR_aws_default_region      = "${var.aws_default_region}"
      TF_VAR_domain_root             = "${var.external_domain_root}"
      TF_VAR_cert_s3_bucket          = "${var.cert_s3_bucket}"
      TF_VAR_cert_s3_folder          = "${var.cert_s3_folder}"
      TF_VAR_acme_email              = "${var.acme_email}"
      TF_VAR_acme_server_url         = "${var.acme_server_url}"
      TF_VAR_cert_min_days_remaining = "${var.cert_min_days_remaining}"
    }
    on_failure = "fail"
  }
}

data "aws_s3_bucket_object" "cert_data" {
  bucket = "${var.cert_s3_bucket}"
  key    = "${var.cert_s3_folder}/cert_data.json"

  depends_on = [
    null_resource.attemp_apply_cert
  ]
}

locals {
  cert_data               = jsondecode(data.aws_s3_bucket_object.cert_data.body)
  issuer_pem              = lookup(local.cert_data, "issuer_pem", "")
  certificate_pem         = lookup(local.cert_data, "certificate_pem", "")
  private_key_pem         = lookup(local.cert_data, "private_key_pem", "")
  domain_zone_record_name = replace(local.external_domain, ".${var.external_domain_zone}", "")
}

data "aws_route53_zone" "external_domain_zone" {
  name = "${var.external_domain_zone}."
}

resource "aws_route53_record" "complete_domain" {
  zone_id = "${data.aws_route53_zone.external_domain_zone.zone_id}"
  name    = "${local.domain_zone_record_name}"
  type    = "A"
  ttl     = "300"
  records = ["${module.external_ip.address}"]
}

resource "kubernetes_secret" "magda_cert_tls" {
  metadata {
    name      = "magda-cert-tls"
    namespace = "${var.namespace}"
  }

  data = {
    "tls.crt" = "${local.certificate_pem}${local.issuer_pem}"
    "tls.key" = "${local.private_key_pem}"
  }

  type = "kubernetes.io/tls"

  depends_on = [
    kubernetes_cluster_role_binding.default_service_acc_role_binding,
    kubernetes_namespace.magda_namespace
  ]
}

# Ingress will be created before helm complete as it takes time 
resource "kubernetes_ingress" "default" {
  metadata {
    name      = "magda-primary-ingress"
    namespace = "${var.namespace}"
    annotations = {
      "kubernetes.io/ingress.global-static-ip-name" = module.external_ip.name
    }
  }

  spec {
    tls {
      secret_name = "magda-cert-tls"
    }
    backend {
      service_name = "gateway"
      service_port = 80
    }
  }

  depends_on = [
    kubernetes_cluster_role_binding.default_service_acc_role_binding,
    kubernetes_secret.magda_cert_tls
  ]
}
