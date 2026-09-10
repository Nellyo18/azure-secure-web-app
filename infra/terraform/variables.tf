variable "location" {
  description = "Azure region used for the deployment"
  type        = string
  default     = "Central US"
}

variable "resource_group_location" {
  description = "Azure region where the resource group metadata is stored"
  type        = string
  default     = "West US 2"
}

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  default     = "rg-secure-web-prod"
}

variable "vnet_name" {
  description = "Name of the Azure Virtual Network"
  type        = string
  default     = "vnet-secure-web-prod"
}

variable "tenant_id" {
  description = "Microsoft Entra tenant ID"
  type        = string
}

variable "sql_entra_admin_name" {
  description = "Display name of the Microsoft Entra administrator for Azure SQL"
  type        = string
}

variable "sql_entra_admin_object_id" {
  description = "Object ID of the Microsoft Entra administrator for Azure SQL"
  type        = string
}

variable "alert_email_address" {
  description = "Email address that receives Azure Monitor alert notifications"
  type        = string
  sensitive   = true
}

variable "github_repository_owner" {
  description = "GitHub username or organization that owns the repository"
  type        = string
}