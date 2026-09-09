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
