// Azure DevOps Local

locals {
  user_entitlement = {
    "project-1" = {
      email = ["Some.One@somedomain.com"]
    }
  }
  projects = {
    "project-1" = {
      name        = "AZDO Terraform Project Test 01"
      description = "This Project is created from Terraform for testing"
      visibility  = "private"
      vcs         = "Git"
      template    = "Agile"
      owner_email = module.user_entitlement["project-1"].output_user_entitlement
      group_name  = "AZDO Terraform Test Team"
      repo_name   = "azdo-terraform-test-02"
    }
  }
}