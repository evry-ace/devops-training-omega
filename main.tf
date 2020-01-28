provider "azurerm" {
  version = "= 1.38.0"
}


resource "azurerm_resource_group" "rg" {
    name     = "omega-rg"
    location = "West Europe"

    tags = {
        environment = "DevOps learning Team Omega"
    }
}