# Introduction

To be filled by **Arlan / Anubhav**

# Prerequisites

## Azure Storage Account

Please create an [Azure Storage Account](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-create?tabs=azure-portal#create-a-storage-account-1) and a [container](https://learn.microsoft.com/en-us/azure/storage/blobs/storage-quickstart-blobs-portal#create-a-container) named **tfstate** to store Terraform State Files (You may change the name of the container in **providers.tf**). Please note the Service Principle should have access to the Storage Account. Note the [Access Key](https://learn.microsoft.com/en-us/azure/storage/common/storage-account-keys-manage?tabs=azure-portal#view-account-access-keys) for the Storage Account from Azure Portal.

|Key Name|Value|
|:---|:---|
|ARM-ACCESS-KEY|Azure Storage Account Access Key|

Note :: The details of the Storage Account must be filled in **provider.tf** file backend configuration.

## Service Connection
Azure DevOps Pipeline requires Service Connection to run tasks. The Service Principle should have access to Key Vault Secrets ([Get and List Permission](https://learn.microsoft.com/en-us/azure/devops/pipelines/release/azure-key-vault?view=azure-devops&tabs=yaml#set-up-azure-key-vault-access-policies)) to retrieve Key Vault Secret Values required during running the task. Please refer to this [official article](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/service-endpoints?view=azure-devops&tabs=yaml#create-a-service-connection) for creating the Service Connection from a Service Principle. Note the following values for a Service Principle from Azure Portal.

|Key Name|Value|
|:---|:---|
|ARM-CLIENT-ID|Application ID of the Service Principle|
|ARM-CLIENT-SECRET|Client Secret of the Service Principle|
|ARM-SUBSCRIPTION-ID|Subscription ID of the Key Vault|
|ARM-TENANT-ID|Azure Tenant ID|

## Azure DevOps PAT and URL

Please use this [official article](https://learn.microsoft.com/en-us/azure/devops/organizations/accounts/use-personal-access-tokens-to-authenticate?view=azure-devops&tabs=Windows) to generate a Personal Access Token. The user must have administrative permission over the Azure DevOps Organization to create and delete projects. Note the following values from Azure DevOps side.

|Key Name|Value|
|:---|:---|
|AZDO-PERSONAL-ACCESS-TOKEN|The Personal Access Token|
|AZDO-ORG-SERVICE-URL|The Azure DevOps Organization URL|

## Key Vault
An Azure Key Vault is required to store Secrets which are used by the pipeline to authenticate against Azure and Azure DevOps to perform it's desired operation. Please note the Service Principle mentioned [above](#service-connection) must have **GET** and **LIST** for the Key Vault Secrets. Please [create the secrets](https://learn.microsoft.com/en-us/azure/key-vault/secrets/quick-create-portal#add-a-secret-to-key-vault) in Azure Key Vault. You may refer to the [Service Connection](#service-connection) and [Azure DevOps PAT and URL](#azure-devops-pat-and-url) section for values.

Secrets to be created in Azure Key Vault

```
ARM-CLIENT-ID
ARM-CLIENT-SECRET
ARM-SUBSCRIPTION-ID
ARM-TENANT-ID
AZDO-PERSONAL-ACCESS-TOKEN
AZDO-ORG-SERVICE-URL
ARM-ACCESS-KEY
```

## Variable Groups
The code needs an Azure DevOps Pipeline Variable Group linked to an existing Azure Key Vault containing the Secrets. Please refer to this [official article](https://learn.microsoft.com/en-us/azure/devops/pipelines/library/variable-groups?view=azure-devops&tabs=yaml#link-secrets-from-an-azure-key-vault) for more details.

# Understanding the Code

This simple code base is drafted as POC for AZDO operations using Terraform.

|Name|Function|
|:---|:---|
|.pipelines|Contain Azure DevOps YAML file for Pipelines|
|modules|Terraform code for creating Azure DevOPs Project, Repository, Project Permissions etc|
|local.tf|Terraform Code for local values. The values can be converted into variables and passed on from a tfvars file|
|main.tf|Main Terraform file for calling the module|
|provider.tf|Terraform Code for provider configuration|

Please refer below for changes that are needed to be made prior to running pipelines. Push the code to repository once the following changes are made.

## Updating Pipeline YAML file with values

Once done with all the [above steps](#prerequisites) update the both the pipeline files inside **.pipelines** folder in the repository.

```
variables:
  - name: AZURE_SERVICE_CONNECTION
    value: '< SERVICE CONNECTION NAME >'
  - group: '< VARIABLE GROUP NAME LINKED TO KEY VAULT >'
```

## Update local file with values

You need to update **local.tf** file with values.

```
locals {
  user_entitlement = {
    "project-1" = {
      email = ["someone@somedomain.com", "someone@somedomain.com"]
    }
    "project-2" = {
      email = ["someone@somedomain.com", "someone@somedomain.com"]
    }
  }
  projects = {
    "project-1" = {
      name        = "< Project 1 Name >"
      description = "< Project 1 Description>"
      visibility  = "< private or public >"
      vcs         = "< Git or Tfvc >"
      template    = "< Scrum or Agile >"
      owner_email = module.user_entitlement["project-1"].output_user_entitlement
      group_name  = "< Project 1 Owner Group Name >"
      repo_name   = "< Repository Name >"
    }
    "project-2" = {
      name        = "< Project 2 Name >"
      description = "< Project 2 Description >"
      visibility  = "< private or public >"
      vcs         = "< Git or Tfvc >"
      template    = "< Scrum or Agile >"
      owner_email = module.user_entitlement["project-2"].output_user_entitlement
      group_name  = "< Project 2 Owner Group Name >"
      repo_name   = "< Repository Name >"
    }
  }
}
```

## Update Provider file with values

You need to update **provider.tf** file with values for the [Azure Storage Account](#azure-storage-account) which will host the Terraform State file.

```
backend "azurerm" {
  resource_group_name  = "< Storage Account Resource Group Name >"
  storage_account_name = "< Storage Account Name >"
  container_name       = "tfstate"
  key                  = "< TFSTATE file name >"
}
```

# Pipelines

Once the [updates](#understanding-the-code) to the code is complete and the latest code is pushed to the repository please proceed to create the pipelines in Azure DevOps. Please follow the below instruction to create both ([Deploy](#creating-deploy-pipeline) and [Destroy](#creating-destroy-pipeline)) Pipelines.

## Creating Deploy Pipeline

Please follow this instruction to create the deploy pipeline

- Go to **Pipelines** in Azure DevOps
- Click on **New Pipeline** from right top corner
- Select **Azure Repos Git**
- Select your repository containing this code
- Select **Existing Azure Pipelines YAML file**
- Select the branch and select path as **/.pipelines/deploy.yaml**
- Click on **Continue**
- Click on **Save** from **Run** drop down menu on top right corner
- You may rename the pipeline by choosing **Rename/move** from top right corner Kebab menu

### Running the Deploy Pipeline

Please follow the instruction to run deploy pipelines

- Go to **Pipelines** in Azure DevOps.
- Click on **All** option and click on the deploy pipeline created [above](#creating-deploy-pipeline)
- Click on **Run Pipeline** from top right corner
- Select **Apply Option** as **No** and click on **Run** button
- Follow the Pipeline Status

**Note :** - It is recommended to keep **Apply Option** as **No** for first time. Once satisfied with the Terraform Plan output you neeed to rerun the Pipeline keeping **Apply Option** as **Yes**.

## Creating Destroy Pipeline

Please follow this instruction to create the destroy pipeline

- Go to **Pipelines** in Azure DevOps
- Click on **New Pipeline** from right top corner
- Select **Azure Repos Git**
- Select your repository containing this code
- Select **Existing Azure Pipelines YAML file**
- Select the branch and select path as **/.pipelines/destroy.yaml**
- Click on **Continue**
- Click on **Variables** button and then **New Variable**
- Provide **Name** as **ProjectName** and keep **Value** empty. Select **Let users override this value when running this pipeline**
- Click on **OK** button and then on **Save** button
- Click on **Save** from **Run** drop down menu on top right corner
- You may rename the pipeline by choosing **Rename/move** from top right corner Kebab menu

### Running the Destroy Pipeline

Please follow the instruction to run destroy pipelines

- Go to **Pipelines** in Azure DevOps.
- Click on **All** option and click on the destroy pipeline created [above](#creating-destroy-pipeline)
- Click on **Run Pipeline** from top right corner
- Select **Apply Option** as **No** and click on **Variables** option.
- Click on the variable name **ProjectName** and provide the project name to be destroyed. Please refer note section below for more details.
- Click on **Update** button and go back.
- Click on **Run** button
- Follow the Pipeline Status

**Note :** - It is recommended to keep **Apply Option** as **No** for first time. Once satisfied with the Terraform Plan output you neeed to rerun the Pipeline keeping **Apply Option** as **Yes**.

**Note :** - The **ProjectName** variable value is the map key name of the project mentioned in **local.tf** file. Ex - **project-1** or **project-2** from projects map in the file. Do not provide literal name of the project.

```
projects = {
  "project-1" = {
    name        = "< Project 1 Name >"
    description = "< Project 1 Description>"
    visibility  = "< private or public >"
    vcs         = "< Git or Tfvc >"
    template    = "< Scrum or Agile >"
    owner_email = module.user_entitlement["project-1"].output_user_entitlement
    group_name  = "< Project 1 Owner Group Name >"
    repo_name   = "< Repository Name >"
  }
  "project-2" = {
    name        = "< Project 2 Name >"
    description = "< Project 2 Description >"
    visibility  = "< private or public >"
    vcs         = "< Git or Tfvc >"
    template    = "< Scrum or Agile >"
    owner_email = module.user_entitlement["project-2"].output_user_entitlement
    group_name  = "< Project 2 Owner Group Name >"
    repo_name   = "< Repository Name >"
  }
}
```

### Post-Deployment Task for Destroy Pipeline

The destroy pipeline will update the Terraform state file with the project which has been destroyed. However, there is no programmatic way currently to delete the entry from the repository. As the code for the project still recides in the repository Terraform [Deploy Pipeline](#creating-deploy-pipeline) will try to recreate the project next time time it runs. Please delete the project entry from **local.tf** file and push the updated code to the repository. As you can see, **project-1** has been deleted from the file.

```
projects = {
  "project-2" = {
    name        = "< Project 2 Name >"
    description = "< Project 2 Description >"
    visibility  = "< private or public >"
    vcs         = "< Git or Tfvc >"
    template    = "< Scrum or Agile >"
    owner_email = module.user_entitlement["project-2"].output_user_entitlement
    group_name  = "< Project 2 Owner Group Name >"
    repo_name   = "< Repository Name >"
  }
}
```

**Note :** - Please do not delete **user_entitlement** entry for the project. You will lose access to the Azure DevOps Organization. Keep the entry active even though the project is deleted. Ex - see below

```
user_entitlement = {
  "project-1" = {
    email = ["someone@somedomain.com", "someone@somedomain.com"]
  }
  "project-2" = {
    email = ["asomeone@somedomain.com", "someone@somedomain.com"]
  }
}
```

# Resources Deployed

The code is defined for deploying following resources 

* Create Azure DevOps Project
* Create Repository
* Create Users
* Create a Group
* Add multiple members to the group
* Give administrative permission to the group for the project

# Resources Destroyed

The code is defined for destroying all resources mentioned [above](#resources-deployed) except the users.