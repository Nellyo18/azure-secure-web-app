resource "azurerm_mssql_server" "sql" {
  name                         = "sql-nelson-secure-web-prod"
  resource_group_name          = azurerm_resource_group.main.name
  location                     = azurerm_resource_group.main.location
  version                      = "12.0"
  public_network_access_enabled = false

  azuread_administrator {
    login_username              = var.sql_entra_admin_name
    object_id                   = var.sql_entra_admin_object_id
    tenant_id                   = var.tenant_id
    azuread_authentication_only = true
  }
}

resource "azurerm_mssql_database" "app" {
  name      = "sqldb-secure-web-prod"
  server_id = azurerm_mssql_server.sql.id

  sku_name = var.sql_database_sku
}

resource "azurerm_private_dns_zone" "sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql" {
  name                  = "link-sql-vnet"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.sql.name
  virtual_network_id    = azurerm_virtual_network.main.id

  registration_enabled = false
}

resource "azurerm_private_endpoint" "sql" {
  name                = "pe-sql-secure-web-prod"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "psc-sql-secure-web-prod"
    private_connection_resource_id = azurerm_mssql_server.sql.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.sql.id]
  }
}
