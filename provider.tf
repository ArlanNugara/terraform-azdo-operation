terraform {
  required_version = "~> 1.7.2"

  required_providers {
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.0.1"
    }
  }

  backend "azurerm" {
    resource_group_name  = "PLACEHOLDER"
    storage_account_name = "PLACEHOLDER"
    container_name       = "tfstate"
    key                  = "PLACEHOLDER"
  }
}

provider "azuredevops" {}