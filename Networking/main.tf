provider "azurerm" {

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

}

terraform {
  backend "atlas" {
    name = "devops-training-omega/front-end-vm1"
    address = "https://app.terraform.io" # optional
  }
}

data "azurerm_resource_group" "example" {
  name = "production"
}

# Create Vnet


resource "azurerm_virtual_network" "omegavnet" {
    name                = "omegaVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "westeurope"
    resource_group_name = azurerm_resource_group.example.name

    tags = {
        environment = "assignment"
    }
}

# Create subnet
resource "azurerm_subnet" "frontend" {
    name                 = "omegafront"
    resource_group_name  = data.azurerm_resource_group.example.name
    virtual_network_name = azurerm_virtual_network.omegavnet.name
    address_prefix       = "10.0.1.0/24"
}

# Create subnet
resource "azurerm_subnet" "backend" {
    name                 = "omegaback"
    resource_group_name  = data.azurerm_resource_group.example.name
    virtual_network_name = azurerm_virtual_network.omegavnet.name
    address_prefix       = "10.0.2.0/24"
}

# Create subnet
resource "azurerm_subnet" "db" {
    name                 = "omegadb"
    resource_group_name  = data.azurerm_resource_group.example.name
    virtual_network_name = azurerm_virtual_network.omegavnet.name
    address_prefix       = "10.0.3.0/24"
}