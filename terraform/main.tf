locals {
  base_tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    Repo        = "IasC"
    Workload    = "Arc-Windows-Management"
  }
}

module "azure_compute_gallery" {
  source              = "./modules/azure_compute_gallery"
  name_prefix         = var.prefix
  location            = var.location
  environment         = var.environment
  resource_group_name = "rg-${var.prefix}-${var.environment}-images"
  tags                = local.base_tags
}

module "windows_vm" {
  source              = "./modules/windows_vm"
  name_prefix         = var.prefix
  environment         = var.environment
  location            = var.location
  resource_group_name = "rg-${var.prefix}-${var.environment}-compute"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  vm_size             = var.vm_size
  tags                = local.base_tags
}

module "defender_for_cloud" {
  source = "./modules/defender_for_cloud"
}

module "update_manager" {
  source              = "./modules/update_manager"
  name_prefix         = var.prefix
  environment         = var.environment
  location            = var.location
  resource_group_name = module.windows_vm.resource_group_name
  target_resource_group_name = var.aum_target_resource_group_name
  windows_tag_schedules      = var.aum_windows_tag_schedules
}

module "policy_assignments" {
  source                = "./modules/policy_assignments"
  policy_definition_ids = var.policy_definition_ids
  guest_configuration_tag_assignments = var.guest_configuration_tag_assignments
  subscription_id       = var.subscription_id
  location              = var.location
}

module "arc_file_role_enforcement" {
  source                     = "./modules/arc_file_role_enforcement"
  enabled                    = var.enable_arc_file_role_enforcement
  subscription_id            = var.subscription_id
  location                   = var.location
  target_resource_group_name = var.arc_file_role_target_resource_group_name
  tag_name                   = var.arc_file_role_tag_name
  tag_value                  = var.arc_file_role_tag_value
}

module "guest_configuration_package_enforcement" {
  source                           = "./modules/guest_configuration_package_enforcement"
  enabled                          = var.enable_guest_configuration_package_enforcement
  location                         = var.location
  target_resource_group_name       = var.gc_package_target_resource_group_name
  tag_name                         = var.gc_package_tag_name
  tag_value                        = var.gc_package_tag_value
  guest_configuration_name         = var.gc_package_name
  guest_configuration_version      = var.gc_package_version
  guest_configuration_content_uri  = var.gc_package_content_uri
  guest_configuration_content_hash = var.gc_package_content_hash
}
