provider "azurerm" {

  subscription_id = "ARM_SUBSCRIPTION_ID"
  client_id       = "ARM_CLIENT_ID"
  client_secret   = "ARM_CLIENT_SECRET"
  tenant_id       = "ARM_TENANT_ID"

}


resource "azurerm_resource_group" "rg" {
  name     = "omega-rg"
  location = "West Europe"

  tags = {
    environment = "DevOps learning Team Omega"
  }
}