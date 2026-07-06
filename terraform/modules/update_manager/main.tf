resource "azurerm_maintenance_configuration" "windows_monthly" {
  name                = "mc-${var.name_prefix}-${var.environment}-windows-monthly"
  resource_group_name = var.resource_group_name
  location            = var.location
  scope               = "InGuestPatch"
  in_guest_user_patch_mode = "User"

  window {
    start_date_time = var.maintenance_start_date_time
    duration        = var.maintenance_duration
    time_zone       = var.maintenance_time_zone
    recur_every     = var.maintenance_recur_every
  }

  install_patches {
    reboot = "IfRequired"

    windows {
      classifications_to_include = ["Critical", "Security", "UpdateRollup"]
      kb_numbers_to_exclude      = []
      kb_numbers_to_include      = []
    }
  }
}

# Targets all Azure IaaS VMs in the selected resource group.
resource "azurerm_maintenance_assignment_dynamic_scope" "vm_scope" {
  name                       = "aumscope-vm-${var.environment}"
  maintenance_configuration_id = azurerm_maintenance_configuration.windows_monthly.id

  filter {
    resource_groups = [var.target_resource_group_name]
    resource_types  = ["Microsoft.Compute/virtualMachines"]
    os_types        = length(var.windows_tag_schedules) > 0 ? ["Linux"] : var.default_scope_os_types
    locations       = [var.location]
  }
}

# Targets all Arc-enabled machines in the selected resource group.
resource "azurerm_maintenance_assignment_dynamic_scope" "arc_scope" {
  name                       = "aumscope-arc-${var.environment}"
  maintenance_configuration_id = azurerm_maintenance_configuration.windows_monthly.id

  filter {
    resource_groups = [var.target_resource_group_name]
    resource_types  = ["Microsoft.HybridCompute/machines"]
    os_types        = length(var.windows_tag_schedules) > 0 ? ["Linux"] : var.default_scope_os_types
    locations       = [var.location]
  }
}

resource "azurerm_maintenance_configuration" "windows_by_tag" {
  for_each            = var.windows_tag_schedules
  name                = "mc-${var.name_prefix}-${var.environment}-${replace(each.key, "_", "-")}-win"
  resource_group_name = var.resource_group_name
  location            = var.location
  scope               = "InGuestPatch"
  in_guest_user_patch_mode = "User"

  window {
    start_date_time = each.value.start_date_time
    duration        = each.value.duration
    time_zone       = each.value.time_zone
    recur_every     = each.value.recur_every
  }

  install_patches {
    reboot = each.value.reboot

    windows {
      classifications_to_include = each.value.windows_classifications_to_include
      kb_numbers_to_exclude      = []
      kb_numbers_to_include      = []
    }
  }
}

resource "azurerm_maintenance_assignment_dynamic_scope" "vm_windows_by_tag" {
  for_each                     = var.windows_tag_schedules
  name                         = "aumscope-vm-${var.environment}-${replace(each.key, "_", "-")}"
  maintenance_configuration_id = azurerm_maintenance_configuration.windows_by_tag[each.key].id

  filter {
    resource_groups = [var.target_resource_group_name]
    resource_types  = ["Microsoft.Compute/virtualMachines"]
    os_types        = ["Windows"]
    locations       = [var.location]
    tag_filter      = each.value.tag_filter

    tags {
      tag    = each.value.tag_name
      values = each.value.tag_values
    }
  }
}

resource "azurerm_maintenance_assignment_dynamic_scope" "arc_windows_by_tag" {
  for_each                     = var.windows_tag_schedules
  name                         = "aumscope-arc-${var.environment}-${replace(each.key, "_", "-")}"
  maintenance_configuration_id = azurerm_maintenance_configuration.windows_by_tag[each.key].id

  filter {
    resource_groups = [var.target_resource_group_name]
    resource_types  = ["Microsoft.HybridCompute/machines"]
    os_types        = ["Windows"]
    locations       = [var.location]
    tag_filter      = each.value.tag_filter

    tags {
      tag    = each.value.tag_name
      values = each.value.tag_values
    }
  }
}
