output "effective_enabled" {
  value = local.effective_enabled
}

output "policy_definition_id" {
  value = try(azurerm_policy_definition.gc_package[0].id, null)
}

output "policy_assignment_id" {
  value = try(azurerm_resource_group_policy_assignment.gc_package[0].id, null)
}
