provider "azurerm" {

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
      name = "devops-training-omega-back-end-vm1"
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

data "azurerm_subnet" "backend" {
  name                 = "omegaback"
  virtual_network_name = "omegaVnet"
  resource_group_name  = data.azurerm_resource_group.rg.name
}

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

resource "azurerm_lb" "back-lb" {
  name                = "omega-back-lb"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku                 = "Basic"
  frontend_ip_configuration {
    name                          = "omega-back-ip-conf"
    subnet_id                     = data.azurerm_subnet.backend.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.0.2.5"
  }
}

resource "azurerm_lb_backend_address_pool" "back-end-address-pool" {
  resource_group_name = data.azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.back-lb.id
  name                = "backendaddresspool"
}

resource "azurerm_linux_virtual_machine_scale_set" "backendvmss" {
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
      subnet_id = data.azurerm_subnet.backend.id
    }
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
}
