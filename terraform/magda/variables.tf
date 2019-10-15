# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------

variable "project" {
  description = "The project ID to host the deployed Magda"
  type        = string
}

variable "region" {
  type        = string
  description = "The region to host the deployed Magda"
}

variable "namespace" {
  type        = string
  description = "The namespace to host the deployed Magda"
}

variable "credential_file_path" {
  type        = string
  description = "Google service account key file path"
}

variable "aws_access_key" {
  type        = string
  description = "AWS access key"
}

variable "aws_secret_key" {
  type        = string
  description = "AWS secret key"
}

variable "external_domain_root" {
  type        = string
  description = "The external domain root: e.g. if we provide `demo.magda.io` here, the final accessible domain will be xxx-xxx-xxx-xx.demo.magda.io"
}

variable "external_domain_zone" {
  type        = string
  description = "The external domain zone: depends on your route53 setup. For magda.io, the zone name is `magda.io`"
}

variable "cert_s3_bucket" {
  type        = string
  description = "the s3 bucket that stores the certificate"
}

variable "cert_s3_folder" {
  type        = string
  description = "the s3 folder that stores the certificate data files"
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# Generally, these values won't need to be changed.
# ---------------------------------------------------------------------------------------------------------------------

variable "aws_default_region" {
  type        = string
  description = "AWS default region; Default to sydney"
  default     = "ap-southeast-2"
}

variable "acme_email" {
  type        = string
  description = "ACME email; Default to contact@magda.io"
  default     = "contact@magda.io"
}

variable "acme_server_url" {
  type        = string
  description = "ACME server url; Default to let's letsencrypt staging endpoint (higher limit for testing)"
  default     = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

variable "cert_min_days_remaining" {
  type        = string
  description = "The minimum amount of days remaining on the expiration of a certificate before a renewal is attempted. The default is 30"
  default     = 30
}

variable "db_password" {
  description = "The db password; Will auto created if not specfied"
  type        = string
  default     = null
}

variable "jwt_secret" {
  description = "The jwt_secret; Will auto created if not specfied"
  type        = string
  default     = null
}

variable "session_secret" {
  description = "The session_secret; Will auto created if not specfied"
  type        = string
  default     = null
}

variable "facebook_client_secret" {
  description = "facebook SSO client secret; Will not create if not specfied"
  type        = string
  default     = null
}

variable "google_client_secret" {
  description = "google SSO client secret; Will not create if not specfied"
  type        = string
  default     = null
}

variable "arcgis_client_secret" {
  description = "arcgis SSO client secret; Will not create if not specfied"
  type        = string
  default     = null
}

variable "vanguard_certificate" {
  description = "vanguard SSO certificate; Will not create if not specfied"
  type        = string
  default     = null
}

variable "smtp_username" {
  description = "smtp server username; Will not create if not specfied"
  type        = string
  default     = null
}

variable "smtp_password" {
  description = "smtp server password; Will not create if not specfied"
  type        = string
  default     = null
}

variable "kubernetes_dashboard" {
  type        = bool
  description = "Whether turn on kubernetes_dashboard or not; Default: false"
  default     = false
}
