resource "azurerm_security_center_subscription_pricing" "virtual_machines" {
  tier          = "Standard"
  resource_type = "VirtualMachines"
}

resource "azurerm_security_center_subscription_pricing" "servers" {
  tier          = "Standard"
  resource_type = "Servers"
}
