provider "azurerm" {
  version         = "=1.44.0"
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

}

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "omega-devops"

    workspaces {
      name = "devops-training-omega"
    }
  }
}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "devops-training-omega"
  location = "westeurope"

  tags = {
    owner = "david.haugli@tietoevry.com"
  }
}
