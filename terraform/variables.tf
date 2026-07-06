variable "subscription_id" {
  description = "Target Azure subscription ID"
  type        = string
}

variable "location" {
  description = "Primary Azure region"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, test, prod)"
  type        = string
}

variable "prefix" {
  description = "Naming prefix for resources"
  type        = string
}

variable "admin_username" {
  description = "Windows VM local admin username"
  type        = string
}

variable "admin_password" {
  description = "Windows VM local admin password"
  type        = string
  sensitive   = true
}

variable "vm_size" {
  description = "Windows VM SKU size"
  type        = string
  default     = "Standard_D4s_v5"
}

variable "policy_definition_ids" {
  description = "Map of assignment_name => policy_definition_id"
  type        = map(string)
  default     = {}
}

variable "arc_machine_ids" {
  description = "Arc machine resource IDs targeted by this baseline"
  type        = list(string)
  default     = []
}

variable "aum_target_resource_group_name" {
  description = "Resource group where Azure Update Manager should target all VMs and Arc machines"
  type        = string
  default     = "Nestle2"
}

variable "aum_windows_tag_schedules" {
  description = "Windows AUM schedules by tag for separate patch rings"
  type = map(object({
    tag_filter                         = optional(string, "All")
    tag_name                           = string
    tag_values                         = list(string)
    start_date_time                    = string
    duration                           = optional(string, "03:00")
    recur_every                        = string
    time_zone                          = optional(string, "UTC")
    reboot                             = optional(string, "IfRequired")
    windows_classifications_to_include = optional(list(string), ["Critical", "Security", "UpdateRollup"])
  }))
  default = {}
}

variable "guest_configuration_tag_assignments" {
  description = "Tag-based Guest Configuration policy assignments for Windows role and feature baselines"
  type = map(object({
    policy_definition_id = string
    display_name         = optional(string)
    description          = optional(string)
    enforce              = optional(bool, true)
    location             = optional(string)
    parameters           = optional(map(any), {})
  }))
  default = {}
}

variable "enable_arc_file_role_enforcement" {
  description = "Enable Azure Policy enforcement for Arc File Server role by tag"
  type        = bool
  default     = false
}

variable "arc_file_role_target_resource_group_name" {
  description = "Resource group where Arc File role enforcement policy should apply"
  type        = string
  default     = "Nestle2"
}

variable "arc_file_role_tag_name" {
  description = "Tag key used to identify file server machines"
  type        = string
  default     = "ServerRole"
}

variable "arc_file_role_tag_value" {
  description = "Tag value used to identify file server machines"
  type        = string
  default     = "File"
}

variable "enable_guest_configuration_package_enforcement" {
  description = "Enable true Guest Configuration package enforcement by tag"
  type        = bool
  default     = false
}

variable "gc_package_target_resource_group_name" {
  description = "Resource group where Guest Configuration package policy should apply"
  type        = string
  default     = "Nestle2"
}

variable "gc_package_tag_name" {
  description = "Tag key used for Guest Configuration package targeting"
  type        = string
  default     = "ServerRole"
}

variable "gc_package_tag_value" {
  description = "Tag value used for Guest Configuration package targeting"
  type        = string
  default     = "File"
}

variable "gc_package_name" {
  description = "Guest Configuration package name"
  type        = string
  default     = "WindowsFileServerRole"
}

variable "gc_package_version" {
  description = "Guest Configuration package version"
  type        = string
  default     = "1.*"
}

variable "gc_package_content_uri" {
  description = "Guest Configuration package URI"
  type        = string
  default     = ""
}

variable "gc_package_content_hash" {
  description = "Guest Configuration package content hash (SHA256)"
  type        = string
  default     = ""
}
