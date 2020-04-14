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
      name = "devops-training-omega-aks"
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

data "azurerm_virtual_network" "omegavnet" {
  name                = "omegaVnet"
  resource_group_name = "devops-training-omega"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-k8s"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  dns_prefix          = "${var.prefix}-k8s"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_B1ms"
  }

  service_principal {
    client_id     = var.sp_client_id
    client_secret = var.sp_client_secret
  }

  tags = local.tags
}


#module "aks" {
#  source = "github.com/evry-ace/tf-azure-aks?ref=0.8.0-az-cni"
#
#  resource_group_name     = azurerm_resource_group.rg.name
#  resource_group_location = azurerm_resource_group.rg.location
#
#  ssh_public_key          = "${var.ssh_public_key}"
#  cluster_name            = "aks-${local.name_affix}"
#  dns_prefix              = local.name_affix
#
#  client_id     = var.sp_client_id
#  client_secret = var.sp_client_secret
#
#  rbac_server_app_id     = var.sp_client_id
#  rbac_server_app_secret = var.sp_client_secret
#  rbac_client_app_id     = var.sp_client_id
#
#  k8s_version = "1.15.5"
#  aks_docker_bridge_cidr = "172.17.0.1/16"
#
#  aks_service_cidr   = local.svc_cidr
#  aks_dns_service_ip = cidrhost(local.svc_cidr, 4)
#  
#  aks_network_plugin = "azure"
#  aks_network_policy = "calico"
#  aks_vnet_subnet_id = data.azurerm_virtual_network.omegavnet.id
# 
#  create_vnet        = false
#  oms_agent_enable = false
#  default_pool = {
#    node_count = 2
#    vm_size    = "Standard_B1ms"
#  }
#
#  tags = local.tags
#}