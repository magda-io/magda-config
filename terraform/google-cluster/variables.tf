# ---------------------------------------------------------------------------------------------------------------------
# REQUIRED PARAMETERS
# These variables are expected to be passed in by the operator
# ---------------------------------------------------------------------------------------------------------------------

variable "project" {
  description = "The project ID to host the cluster in."
  type = string
}

variable "region" {
  type = string
  description = "The region to host the cluster in."
}

# ---------------------------------------------------------------------------------------------------------------------
# OPTIONAL PARAMETERS
# Generally, these values won't need to be changed.
# ---------------------------------------------------------------------------------------------------------------------

variable "machine_type" {
  description = "The machine type to use, see https://cloud.google.com/sql/pricing for more details"
  type = string
  default     = "n1-standard-4"
}

variable "preemptible" {
  description = "Whether to create a preemptible node pool or non-preemptible node pool"
  type        = bool
  default     = false
}

variable "node_pool_name" {
  type  = string
  description = "the name of the node pool. Auto generate if not supplied"
  default = null
}

variable "cluster_name" {
  type  = string
  description = "the name of the cluster pool. Auto generate if not supplied"
  default = "main-magda-cluster"
}

variable "kubernetes_dashboard" {
  type  = bool
  description = "Whether turn on kubernetes_dashboard or not; Default: false"
  default = false
}
