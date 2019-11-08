# ------------------------------------------------------------------------------
# MASTER OUTPUTS
# ------------------------------------------------------------------------------

output "name" {
  description = "The name of the reserved IP"
  value       = "${google_compute_global_address.external_ip.name}"
}

output "address" {
  description = "The name of the reserved IP"
  value = "${google_compute_global_address.external_ip.address}"
}
