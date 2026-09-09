variable "location" {
  description = "Azure region used for the deployment"
  type        = string
  default     = "Central US"
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

variable "sql_database_sku" {
  description = "Azure SQL Database SKU"
  type        = string
}
