provider "azurerm" {
   version         = "=2.0.0"

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

  features {}
}

terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "omega-devops"

    workspaces {
      name = "devops-training-omega-front-end-vm1"
    }
  }
}

locals {

  tags = {
    team = "devops-training-omega"
  }

}



data "azurerm_resource_group" "rg" {
  name = "devops-training-omega"
}

#data "azurerm_virtual_network" "vnet" {
#  name                = "production"
#  resource_group_name = data.azurerm_resource_group.rg.name
#}

data "azurerm_subnet" "frontend" {
  name                 = "omegafront"
  virtual_network_name = "omegaVnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
}

/*
resource "azurerm_network_security_group" "omegansg" {
  name                = "omegaNetworkSecurityGroup"
  location            = "westeurope"
  resource_group_name = data.azurerm_resource_group.rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 120
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Port_80"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "Port_5432"
    priority                   = 150
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5432"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = local.tags


}
*/


# Random for storage account
resource "random_id" "randomId" {
  keepers = {
    resource_group = data.azurerm_resource_group.rg.name
  }

  byte_length = 8
}

resource "azurerm_storage_account" "omegastorageaccount" {
  name                     = "diag${random_id.randomId.hex}"
  resource_group_name      = data.azurerm_resource_group.rg.name
  location                 = "westeurope"
  account_replication_type = "LRS"
  account_tier             = "Standard"

  tags = local.tags


}

resource "azurerm_linux_virtual_machine_scale_set" "main" {
  name                            = "${var.prefix}-vmss"
  resource_group_name             = data.azurerm_resource_group.rg.name
  location                        = data.azurerm_resource_group.rg.location
  sku                             = "Standard_B1ms"
  instances                       = 3
  admin_username                  = "adminuser"
  admin_password                  = "P@ssw0rd1234!"
  disable_password_authentication = false

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  network_interface {
    name    = "frnic"
    primary = true

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = data.azurerm_subnet.frontend.id
    }
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}
