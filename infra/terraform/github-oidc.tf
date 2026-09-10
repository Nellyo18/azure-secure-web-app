resource "azurerm_user_assigned_identity" "github_oidc" {
  name                = "oidc-msi-a77c"
  location            = var.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_federated_identity_credential" "github_main" {
  name = "github-main"

  audience = [
    "api://AzureADTokenExchange"
  ]

  issuer                    = "https://token.actions.githubusercontent.com"
  user_assigned_identity_id = azurerm_user_assigned_identity.github_oidc.id
  subject                   = "repo:Nellyo18@325152691/azure-secure-web-app@1360889274:ref:refs/heads/main"
}