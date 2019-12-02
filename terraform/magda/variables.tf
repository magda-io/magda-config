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

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# Generally, these values won't need to be changed.
# ---------------------------------------------------------------------------------------------------------------------
variable "magda_version" {
  type        = string
  description = "Specify Magda helm chart version to install"
  default     = null
}

variable "allow_dev_magda_version" {
  type        = bool
  description = "Specify whether allow to use development Magda helm chart version to install if version is not specified"
  default     = false
}

variable "external_domain" {
  type        = string
  description = "The external domain; When supplied, HTTPS access will be setup. Otherwise, http only access will be availble through domain [yourIp].xip.io"
  default     = null
}

variable "cluster_node_pool_machine_type" {
  description = "The machine type to use, see https://cloud.google.com/sql/pricing for more details"
  type        = string
  default     = "n1-standard-4"
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
