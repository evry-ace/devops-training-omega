provider "azurerm" {

}


resource "azurerm_resource_group" "rg" {
  name     = "omega-rg"
  location = "West Europe"

  tags = {
    environment = "DevOps learning Team Omega"
  }
}