variable "policy_definition_ids" {
  description = "Map of assignment_name => policy_definition_id"
  type        = map(string)
}

variable "subscription_id" {
  type = string
}

variable "location" {
  type = string
}

variable "guest_configuration_tag_assignments" {
  description = "Tag-based Guest Configuration policy assignments. Parameter names must match the target policy definition."
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
