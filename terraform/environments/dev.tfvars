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

# Tag-based Guest Configuration assignments - leave empty until real policy definition IDs are available.
guest_configuration_tag_assignments = {}

# Add built-in or custom policy definition IDs - leave empty until real IDs are confirmed.
policy_definition_ids = {}
