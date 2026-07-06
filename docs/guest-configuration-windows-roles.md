# Guest Configuration Windows Role and Feature Baseline (Tag-Based)

This repository supports tag-based Guest Configuration policy assignments through Terraform.

## Terraform Input

Use `guest_configuration_tag_assignments` in `terraform/environments/<env>.tfvars`.

Each assignment supports:

- `policy_definition_id`
- `display_name`
- `description`
- `enforce`
- `location`
- `parameters` (map of policy parameter name to value)

## Tag Strategy

Recommended tag key:

- `ServerRole`

Recommended values:

- `Web`
- `File`
- `DomainController`
- `Sql`
- `Management`

## Feature Catalog

A reusable role/feature catalog is provided at:

- `policies/guestconfig/windows-role-feature-profiles.json`

Use those feature lists as the value for policy parameter `listOfWindowsFeatures` when your selected Guest Configuration policy definition supports that parameter.

## Important

- Built-in Guest Configuration policy definitions can have different parameter names by version.
- Ensure the `parameters` keys in tfvars exactly match your selected policy definition parameter schema.
- Start with `AuditIfNotExists`, then move to `DeployIfNotExists` after validation.
