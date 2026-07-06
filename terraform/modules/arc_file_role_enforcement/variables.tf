variable "subscription_id" {
  description = "Subscription where policy definition is created"
  type        = string
}

variable "location" {
  description = "Azure location for policy assignment identity"
  type        = string
}

variable "target_resource_group_name" {
  description = "Resource group scope where policy is assigned"
  type        = string
}

variable "enabled" {
  description = "Enable Arc file role enforcement policy"
  type        = bool
  default     = false
}

variable "tag_name" {
  description = "Tag key used to select file servers"
  type        = string
  default     = "ServerRole"
}

variable "tag_value" {
  description = "Tag value used to select file servers"
  type        = string
  default     = "File"
}

variable "policy_name" {
  description = "Policy definition name"
  type        = string
  default     = "enforce-arc-fileserver-role-by-tag"
}

variable "policy_display_name" {
  description = "Policy definition display name"
  type        = string
  default     = "Enforce Arc Windows File Server role by tag"
}

variable "enforcement_effect" {
  description = "Policy effect"
  type        = string
  default     = "DeployIfNotExists"
}
