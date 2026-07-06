subscription_id = "00000000-0000-0000-0000-000000000000"
location        = "eastus2"
environment     = "prod"
prefix          = "arcops"

admin_username = "localadmin"
admin_password = "ReplaceWithSecureSecret!"
vm_size        = "Standard_D8s_v5"
aum_target_resource_group_name = "Nestle2"
aum_windows_tag_schedules      = {}
guest_configuration_tag_assignments = {}
enable_arc_file_role_enforcement         = false
arc_file_role_target_resource_group_name = "Nestle2"
arc_file_role_tag_name                   = "ServerRole"
arc_file_role_tag_value                  = "File"
enable_guest_configuration_package_enforcement = false
gc_package_target_resource_group_name          = "Nestle2"
gc_package_tag_name                            = "ServerRole"
gc_package_tag_value                           = "File"
gc_package_name                                = "WindowsFileServerRole"
gc_package_version                             = "1.*"
gc_package_content_uri                         = ""
gc_package_content_hash                        = ""

policy_definition_ids = {}
