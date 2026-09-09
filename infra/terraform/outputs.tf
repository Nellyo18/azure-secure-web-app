output "resource_group_name" {
  description = "Name of the Azure resource group"
  value       = azurerm_resource_group.main.name
}

output "virtual_network_name" {
  description = "Name of the Azure Virtual Network"
  value       = azurerm_virtual_network.main.name
}

output "app_subnet_id" {
  description = "Resource ID of the App Service integration subnet"
  value       = azurerm_subnet.app.id
}

output "private_endpoints_subnet_id" {
  description = "Resource ID of the private endpoints subnet"
  value       = azurerm_subnet.private_endpoints.id
}

output "management_subnet_id" {
  description = "Resource ID of the management subnet"
  value       = azurerm_subnet.management.id
}
