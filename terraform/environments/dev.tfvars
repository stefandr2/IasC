subscription_id = "113f91f0-83f2-4b50-8e5a-111f1d89e1e1"
location        = "northeurope"
environment     = "dev"
prefix          = "arcops"

admin_username = "localadmin"
admin_password = "ReplaceWithSecureSecret!"
vm_size        = "Standard_D4s_v5"
aum_target_resource_group_name = "Nestle2"
enable_arc_file_role_enforcement        = false
arc_file_role_target_resource_group_name = "Nestle2"
arc_file_role_tag_name                   = "ServerRole"
arc_file_role_tag_value                  = "File"
enable_guest_configuration_package_enforcement = true
gc_package_target_resource_group_name          = "Nestle2"
gc_package_tag_name                            = "ServerRole"
gc_package_tag_value                           = "File"
gc_package_name                                = "WindowsFileServerRole"
gc_package_version                             = "1.*"
gc_package_content_uri                         = ""
gc_package_content_hash                        = ""

aum_windows_tag_schedules = {
  pilot = {
    tag_name        = "PatchRing"
    tag_values      = ["pilot"]
    start_date_time = "2026-07-14 02:00"
    recur_every     = "Month Second Tuesday"
  }
  broad = {
    tag_name        = "PatchRing"
    tag_values      = ["broad"]
    start_date_time = "2026-07-15 02:00"
    recur_every     = "Month Second Wednesday"
  }
}

# Tag-based Guest Configuration assignments for Windows role/feature baselines.
# Parameter keys must match the selected policy definition.
guest_configuration_tag_assignments = {
  gc-windows-web-features = {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/11111111-1111-1111-1111-111111111111"
    display_name         = "GC - Windows Web feature baseline by tag"
    description          = "Applies Windows web feature checks to machines tagged ServerRole=Web"
    parameters = {
      tagName               = "ServerRole"
      tagValues             = ["Web"]
      listOfWindowsFeatures = [
        "Web-Server",
        "Web-WebServer",
        "Web-Common-Http",
        "Web-Default-Doc",
        "Web-Static-Content",
        "Web-Http-Logging",
        "Web-Windows-Auth",
        "Web-Mgmt-Console"
      ]
      effect = "AuditIfNotExists"
    }
  }

  gc-windows-file-features = {
    policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/22222222-2222-2222-2222-222222222222"
    display_name         = "GC - Windows File feature baseline by tag"
    description          = "Applies Windows file server feature checks to machines tagged ServerRole=File"
    parameters = {
      tagName               = "ServerRole"
      tagValues             = ["File"]
      listOfWindowsFeatures = [
        "FS-FileServer",
        "FS-Data-Deduplication",
        "FS-Resource-Manager"
      ]
      effect = "AuditIfNotExists"
    }
  }
}

# Add built-in or custom policy definition IDs.
policy_definition_ids = {
  "audit-defender-agent-on-machines" = "/providers/Microsoft.Authorization/policyDefinitions/00000000-0000-0000-0000-000000000001"
  "enable-guest-configuration"       = "/providers/Microsoft.Authorization/policyDefinitions/00000000-0000-0000-0000-000000000002"
}
