resource "azurerm_user_assigned_identity" "github_oidc" {
  name                = "oidc-msi-a77c"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_federated_identity_credential" "github_main" {
  name                = "github-main"
  resource_group_name = azurerm_resource_group.main.name

  audience = [
    "api://AzureADTokenExchange"
  ]

  issuer    = "https://token.actions.githubusercontent.com"
  parent_id = azurerm_user_assigned_identity.github_oidc.id
  subject   = "repo:${var.github_repository_owner}/azure-secure-web-app:ref:refs/heads/main"
}
