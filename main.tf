provider "azurerm" {

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

}

terraform {
  backend "atlas" {
    name = "devops-training-omega/rg/"
    address = "https://app.terraform.io" # optional
  }
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "production"
  location = "westeurope"

  tags = {
    owner = "david.haugli@tietoevry.com"
  }
}