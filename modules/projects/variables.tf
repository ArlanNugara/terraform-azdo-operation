// Azure DevOps Project Variables

variable "project_name" {
  type        = string
  description = "Azure DevOps Project Name"
}

variable "project_description" {
  type        = string
  description = "Azure DevOps Project Description"
}

variable "project_visibility" {
  type        = string
  description = "Azure DevOps Project Visibility"
}

variable "project_vcs" {
  type        = string
  description = "Azure DevOps Project Version Control System"
}

variable "project_template" {
  type        = string
  description = "Azure DevOps Project Work Item Template"
}

variable "owner_email_address" {
  type        = set(string)
  description = "Azure DevOps Project Owner Email Address"
}

variable "group_name" {
  type        = string
  description = "Azure DevOps Group Name"
}

variable "repository_name" {
  type        = string
  description = "Azure DevOps repository Name"
}