variable "enabled" {
  description = "Enable Guest Configuration package enforcement"
  type        = bool
  default     = false
}

variable "location" {
  description = "Azure location for policy assignment identity"
  type        = string
}

variable "target_resource_group_name" {
  description = "Resource group scope where policy is assigned"
  type        = string
}

variable "tag_name" {
  description = "Tag key used to select target machines"
  type        = string
  default     = "ServerRole"
}

variable "tag_value" {
  description = "Tag value used to select target machines"
  type        = string
  default     = "File"
}

variable "policy_name" {
  description = "Custom policy definition name"
  type        = string
  default     = "enforce-gc-package-fileserver-by-tag"
}

variable "policy_display_name" {
  description = "Custom policy definition display name"
  type        = string
  default     = "Enforce Guest Configuration package for File Server role by tag"
}

variable "assignment_name" {
  description = "Policy assignment name"
  type        = string
  default     = "assign-gc-fileserver-by-tag"
}

variable "guest_configuration_name" {
  description = "Guest configuration package name"
  type        = string
  default     = "WindowsFileServerRole"
}

variable "guest_configuration_version" {
  description = "Guest configuration package version"
  type        = string
  default     = "1.*"
}

variable "guest_configuration_content_uri" {
  description = "HTTPS URI to the Guest Configuration package zip in storage"
  type        = string
  default     = ""
}

variable "guest_configuration_content_hash" {
  description = "SHA256 hash of the Guest Configuration package content"
  type        = string
  default     = ""
}

variable "assignment_type" {
  description = "Guest configuration assignment type"
  type        = string
  default     = "ApplyAndAutoCorrect"
}

variable "enforcement_effect" {
  description = "Policy effect"
  type        = string
  default     = "DeployIfNotExists"
}
