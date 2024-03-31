// Azure DevOps Project

resource "azuredevops_project" "project" {
  name               = var.project_name
  description        = var.project_description
  visibility         = var.project_visibility
  version_control    = var.project_vcs
  work_item_template = var.project_template
}

resource "azuredevops_group" "group" {
  scope        = azuredevops_project.project.id
  display_name = var.group_name
  members      = var.owner_email_address
}

resource "azuredevops_project_permissions" "permission" {
  project_id = azuredevops_project.project.id
  principal  = azuredevops_group.group.id
  permissions = {
    GENERIC_READ  = "Allow"
    GENERIC_WRITE = "Allow"
    DELETE        = "Allow"
  }
}

resource "azuredevops_git_repository" "repository" {
  project_id = azuredevops_project.project.id
  name       = var.repository_name
  initialization {
    init_type = "Clean"
  }
}