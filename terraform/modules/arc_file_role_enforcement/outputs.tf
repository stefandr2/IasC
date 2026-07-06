output "policy_definition_id" {
  value = try(azurerm_policy_definition.arc_fileserver[0].id, null)
}

output "policy_assignment_id" {
  value = try(azurerm_resource_group_policy_assignment.arc_fileserver[0].id, null)
}
