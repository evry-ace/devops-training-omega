provider "azurerm" {

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id

}

# Create a resource group
resource "azurerm_resource_group" "example" {
  name     = "production"
  location = "westeurope"

  tags = {
    owner = "david.haugli@tietoevry.com"
  }
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
    resource_group_name  = azurerm_resource_group.example.name
    virtual_network_name = azurerm_virtual_network.omegavnet.name
    address_prefix       = "10.0.1.0/24"
}

# Create subnet
resource "azurerm_subnet" "backend" {
    name                 = "omegaback"
    resource_group_name  = azurerm_resource_group.example.name
    virtual_network_name = azurerm_virtual_network.omegavnet.name
    address_prefix       = "10.0.2.0/24"
}

# Create subnet
resource "azurerm_subnet" "db" {
    name                 = "omegadb"
    resource_group_name  = azurerm_resource_group.example.name
    virtual_network_name = azurerm_virtual_network.omegavnet.name
    address_prefix       = "10.0.3.0/24"
}

# Create public IPs
resource "azurerm_public_ip" "omegapublicip" {
    name                         = "omegaPublicIP"
    location                     = "westeurope"
    resource_group_name          = azurerm_resource_group.example.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "assignment"
    }
}

resource "azurerm_network_security_group" "omegansg" {
    name                = "omegaNetworkSecurityGroup"
    location            = "westeurope"
    resource_group_name = azurerm_resource_group.example.name

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

    tags {
        environment = "assignment"
    }
}

# Create network interface
resource "azurerm_network_interface" "omeganic" {
    name                      = "omegaNIC"
    location                  = "westeurope"
    resource_group_name       = azurerm_resource_group.example.name
    network_security_group_id = azurerm_network_security_group.omegansg.id

    ip_configuration {
        name                          = "omegaNicConfiguration"
        subnet_id                     = azurerm_subnet.frontend.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.omegapublicip.id
    }

    tags = {
        environment = "assignment"
    }
}

# Random for storage account
resource "random_id" "randomId" {
    keepers = {
        resource_group = azurerm_resource_group.example.name
    }
    
    byte_length = 8
}

resource "azurerm_storage_account" "omegastorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.example.name
    location                    = "westeurope"
    account_replication_type    = "LRS"
    account_tier                = "Standard"

    tags = {
        environment = "assignment"
    }
}

resource "azurerm_virtual_machine" "omegavm" {
    name                  = "darkstar"
    location              = "westeurope"
    resource_group_name   = azurerm_resource_group.example.name
    network_interface_ids = [azurerm_network_interface.omeganic.id]
    vm_size               = "Standard_A1_v2"

    storage_os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        create_option     = "FromImage"
        managed_disk_type = "Premium_LRS"
    }

    storage_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }

    os_profile {
        computer_name  = "darkstar"
        admin_username = "olebole"
    }

    os_profile_linux_config {
        disable_password_authentication = true
        ssh_keys {
            path     = "/home/olebole/.ssh/authorized_keys"
            key_data = "ssh-rsa here..."
        }
    }

    boot_diagnostics {
        enabled     = "true"
        storage_uri = azurerm_storage_account.omegastorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "assignment"
    }
}
