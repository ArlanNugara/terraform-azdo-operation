// Azure DevOps Project output

output "output_azdo_project_id" {
  value       = azuredevops_project.project.id
  description = "Azure DevOps project ID"
}