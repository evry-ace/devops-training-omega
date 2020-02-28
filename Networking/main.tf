provider "azurerm" {

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

}

# State of infrastructure in terraform cloud. 

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "omega-devops"

    workspaces {
      name = "devops-training-omega-network"
    }
  }
}

locals {

  tags = {
    team = "devops-training-omega"
  }

}
# data source for RG

data "azurerm_resource_group" "rg" {
  name = "devops-training-omega"
}

# Create Vnet


resource "azurerm_virtual_network" "omegavnet" {
  name                = "omegaVnet"
  address_space       = ["10.0.0.0/16"]
  location            = "westeurope"
  resource_group_name = data.azurerm_resource_group.rg.name

  tags = {
    environment = "assignment"
  }
}

# Create subnet
resource "azurerm_subnet" "frontend" {
  name                 = "omegafront"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.omegavnet.name
  address_prefix       = "10.0.1.0/24"
}

# Create subnet
resource "azurerm_subnet" "backend" {
  name                 = "omegaback"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.omegavnet.name
  address_prefix       = "10.0.2.0/24"
}

# Create subnet
resource "azurerm_subnet" "db" {
  name                 = "omegadb"
  resource_group_name  = data.azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.omegavnet.name
  address_prefix       = "10.0.3.0/24"
}