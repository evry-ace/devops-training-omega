provider "azurerm" {
  subscription_id = ""
  client_id       = ""
  client_secret   = ""
  tenant_id       = ""
}


resource "azurerm_resource_group" "rg" {
  name     = "omega-rg"
  location = "West Europe"

  tags = {
    environment = "DevOps learning Team Omega"
  }
}