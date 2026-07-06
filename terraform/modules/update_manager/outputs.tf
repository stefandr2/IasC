output "maintenance_configuration_id" {
  value = azurerm_maintenance_configuration.windows_monthly.id
}

output "vm_dynamic_scope_name" {
  value = azurerm_maintenance_assignment_dynamic_scope.vm_scope.name
}

output "arc_dynamic_scope_name" {
  value = azurerm_maintenance_assignment_dynamic_scope.arc_scope.name
}
