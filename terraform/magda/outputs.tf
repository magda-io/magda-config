# ------------------------------------------------------------------------------
# MASTER OUTPUTS
# ------------------------------------------------------------------------------

output "external_access_url" {
  description = "The external access url of the deployed magda"
  value       = "${local.runtime_external_url}"
}

output "external_ip" {
  description = "The external access ip of the deployed magda"
  value       = "${module.external_ip.address}"
}
output "metadata" {
  description = "The metadata of the helm deployment"
  value       = "${helm_release.magda_helm_release.metadata}"
}
