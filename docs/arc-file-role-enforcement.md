# Arc File Server Role Enforcement (Policy As Code)

This repository now includes Terraform-based enforcement for File Server role installation on Arc-enabled Windows servers.

## How It Works

- A custom Azure Policy definition is created with `DeployIfNotExists` effect.
- Scope is a target resource group (default `Nestle2`).
- Match condition is tag-based (default `ServerRole=File`).
- If extension `install-fileserver-role` is missing, policy deploys Arc Custom Script Extension to install `FS-FileServer`.

## Terraform Controls

Set in `terraform/environments/<env>.tfvars`:

- `enable_arc_file_role_enforcement`
- `arc_file_role_target_resource_group_name`
- `arc_file_role_tag_name`
- `arc_file_role_tag_value`

## Dev Defaults

Dev is enabled by default and targets:

- Resource group: `Nestle2`
- Tag: `ServerRole=File`

## Operational Note

This is enforced by Azure Policy from your GitHub-managed Terraform flow. Any Arc Windows machine in scope with matching tag will be remediated automatically when policy evaluates and remediations run.
