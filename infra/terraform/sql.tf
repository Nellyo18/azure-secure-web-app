resource "azurerm_mssql_server" "sql" {
  name                          = "sql-nelson-secure-web-prod"
  resource_group_name           = azurerm_resource_group.main.name
  location                      = var.location
  version                       = "12.0"
  public_network_access_enabled = false

  azuread_administrator {
    login_username              = var.sql_entra_admin_name
    object_id                   = var.sql_entra_admin_object_id
    tenant_id                   = var.tenant_id
    azuread_authentication_only = false
  }
}

resource "azurerm_mssql_database" "app" {
  name      = "sqldb-secure-web-prod"
  server_id = azurerm_mssql_server.sql.id

  sku_name                    = "GP_S_Gen5_1"
  min_capacity                = 0.5
  auto_pause_delay_in_minutes = 60
  max_size_gb                 = 32
  zone_redundant              = false
  storage_account_type        = "Local"
}

resource "azurerm_private_dns_zone" "sql" {
  name                = "privatelink.database.windows.net"
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "sql" {
  name                  = "mxqjzf6kava2w"
  resource_group_name   = azurerm_resource_group.main.name
  private_dns_zone_name = azurerm_private_dns_zone.sql.name
  virtual_network_id    = azurerm_virtual_network.main.id

  registration_enabled = false
}

resource "azurerm_private_endpoint" "sql" {
  name                = "pe-sql-secure-web-prod"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.private_endpoints.id

  private_service_connection {
    name                           = "pe-sql-secure-web-prod"
    private_connection_resource_id = azurerm_mssql_server.sql.id
    subresource_names              = ["SqlServer"]
    is_manual_connection           = false
  }
}