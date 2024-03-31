// Azure DevOps

module "user_entitlement" {
  source        = "./modules/user_entitlement"
  for_each      = local.user_entitlement
  email_address = each.value.email
}

module "azdo_project" {
  source              = "./modules/projects"
  for_each            = local.projects
  project_name        = each.value.name
  project_description = each.value.description
  project_visibility  = each.value.visibility
  project_vcs         = each.value.vcs
  project_template    = each.value.template
  owner_email_address = each.value.owner_email
  group_name          = each.value.group_name
  repository_name     = each.value.repo_name
}