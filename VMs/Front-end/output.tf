#output "virtual_network_id" {
#  value = data.azurerm_virtual_network.vnet.id
#}

output "subnet_id" {
  value = data.azurerm_subnet.frontend.id
}
