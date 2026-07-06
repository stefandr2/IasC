resource "azurerm_subscription_policy_assignment" "baseline" {
  for_each = var.policy_definition_ids

  name                 = each.key
  subscription_id      = "/subscriptions/${var.subscription_id}"
  policy_definition_id = each.value
  location             = var.location

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_subscription_policy_assignment" "guest_configuration_tag" {
  for_each = var.guest_configuration_tag_assignments

  name                 = each.key
  subscription_id      = "/subscriptions/${var.subscription_id}"
  policy_definition_id = each.value.policy_definition_id
  location             = coalesce(each.value.location, var.location)
  display_name         = try(each.value.display_name, null)
  description          = try(each.value.description, null)
  enforce              = each.value.enforce
  parameters = length(each.value.parameters) > 0 ? jsonencode({
    for parameter_name, parameter_value in each.value.parameters : parameter_name => {
      value = parameter_value
    }
  }) : null

  identity {
    type = "SystemAssigned"
  }
}
