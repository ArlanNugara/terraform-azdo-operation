// User Entitlement output

output "output_user_entitlement" {
  value       = values(azuredevops_user_entitlement.user)[*].descriptor
  description = "User Entitlement Descriptor"
}