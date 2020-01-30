provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}


resource "azurerm_resource_group" "rg" {
  name     = "omega-rg"
  location = "westeurope"

  tags = {
    environment = "DevOps learning Team Omega"
  }
}