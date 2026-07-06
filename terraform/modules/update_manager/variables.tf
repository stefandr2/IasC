variable "name_prefix" {
  type = string
}

variable "environment" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "target_resource_group_name" {
  description = "Resource group containing Azure VMs and Arc machines to include in patching scope"
  type        = string
}

variable "maintenance_start_date_time" {
  description = "Start date/time for maintenance window in YYYY-MM-DD HH:mm format"
  type        = string
  default     = "2026-07-14 02:00"
}

variable "maintenance_duration" {
  description = "Maintenance window duration"
  type        = string
  default     = "03:00"
}

variable "maintenance_recur_every" {
  description = "Maintenance recurrence pattern"
  type        = string
  default     = "Month Second Tuesday"
}

variable "maintenance_time_zone" {
  description = "Maintenance window time zone"
  type        = string
  default     = "UTC"
}

variable "default_scope_os_types" {
  description = "OS types covered by the default scope when tag-based Windows schedules are not used"
  type        = list(string)
  default     = ["Windows", "Linux"]
}

variable "windows_tag_schedules" {
  description = "Map of Windows schedules keyed by schedule name. Each item targets machines by tag."
  type = map(object({
    tag_filter                           = optional(string, "All")
    tag_name                             = string
    tag_values                           = list(string)
    start_date_time                      = string
    duration                             = optional(string, "03:00")
    recur_every                          = string
    time_zone                            = optional(string, "UTC")
    reboot                               = optional(string, "IfRequired")
    windows_classifications_to_include   = optional(list(string), ["Critical", "Security", "UpdateRollup"])
  }))
  default = {}
}
