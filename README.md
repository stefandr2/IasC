# Azure Arc Windows Management IaC Baseline

This repository is a starter baseline for managing Windows servers (Azure VMs and Arc-enabled machines) with Infrastructure as Code.

Primary capabilities included:

- Terraform for Windows VM creation
- Defender for Cloud plan configuration
- Azure Update Manager maintenance configuration
- Azure Compute Gallery baseline
- Policy as Code scaffold for governance
- Machine Configuration guidance for Windows settings via Guest Configuration policies

## Repository Structure

- `terraform/` - Terraform root config, environments, and modules
- `policies/` - custom policy definitions and initiatives (JSON)
- `ansible/` - automation playbooks, roles, and inventories for Windows + Arc operations
- `scripts/` - PowerShell helpers for consistent environment-based execution
- `docs/` - implementation and operations guidance

## Prerequisites

- Terraform >= 1.7
- Azure CLI authenticated to target tenant/subscription
- Contributor + Policy Contributor permissions at subscription scope
- (Optional) Arc onboarding tooling for non-Azure servers (`azcmagent`)

## Quick Start

1. Configure environment values:
   - Edit one or more files in `terraform/environments/`:
     - `dev.tfvars`
     - `test.tfvars`
     - `prod.tfvars`
2. Authenticate:
   - `az login`
   - `az account set --subscription <subscription-id>`
3. Deploy baseline:
   - `pwsh ./scripts/deploy-terraform.ps1 -Environment dev -Action plan`
   - `pwsh ./scripts/deploy-terraform.ps1 -Environment test -Action plan`
   - `pwsh ./scripts/deploy-terraform.ps1 -Environment prod -Action plan`

   Or run Terraform directly:
   - `cd terraform`
   - `terraform init -backend-config=backends/dev.hcl`
   - `terraform plan -var-file=environments/dev.tfvars`
   - `terraform apply -var-file=environments/dev.tfvars`

4. Run Ansible baseline (optional):
   - `cd ansible`
   - `ansible-galaxy collection install -r requirements.yml`
   - `pwsh ../scripts/run-ansible.ps1 -Environment dev -Playbook baseline`
   - `pwsh ../scripts/run-ansible.ps1 -Environment test -Playbook baseline`
   - `pwsh ../scripts/run-ansible.ps1 -Environment prod -Playbook baseline`

## What To Customize First

- `terraform/environments/*.tfvars`
- `terraform/backends/*.hcl`
- `policies/definitions/*.json`
- `terraform/modules/policy_assignments` inputs for built-in policy/initiative IDs
- VM image source in `terraform/modules/windows_vm`

## Notes

- For production, split subscriptions by environment and use remote state (Azure Storage backend).
- Use managed identities and avoid hardcoded credentials.
- Add CI validation (`terraform fmt`, `terraform validate`, policy linting) before merge.
- See `docs/environment-strategy.md` for recommended promotion and control model.

## Azure Update Manager For Nestle2

Use the helper script in `scripts/configure-aum-nestle2.ps1` to configure one maintenance schedule and assign it to all Azure VMs and Arc-enabled machines in the `Nestle2` resource group.

- Dry run review: open and validate parameter values in `scripts/configure-aum-nestle2.ps1`
- Execute: `pwsh ./scripts/configure-aum-nestle2.ps1`

Terraform option:

- The `terraform/modules/update_manager` module now includes dynamic scopes for both `Microsoft.Compute/virtualMachines` and `Microsoft.HybridCompute/machines`.
- Set `aum_target_resource_group_name` in `terraform/environments/*.tfvars`.
- Set `aum_windows_tag_schedules` in `terraform/environments/*.tfvars` to create separate Windows schedules based on tags (for example `PatchRing=pilot`, `PatchRing=broad`).

Guest Configuration option:

- Use `guest_configuration_tag_assignments` in `terraform/environments/*.tfvars` for tag-based Windows role/feature policy assignments.
- Use `policies/guestconfig/windows-role-feature-profiles.json` as the baseline feature catalog.
- See `docs/guest-configuration-windows-roles.md` for implementation guidance.

Arc File Role enforcement option:

- Use Terraform module `terraform/modules/arc_file_role_enforcement` to enforce `FS-FileServer` installation on Arc Windows machines by tag.
- See `docs/arc-file-role-enforcement.md` for configuration and behavior.

True Guest Configuration package enforcement option:

- Use Terraform module `terraform/modules/guest_configuration_package_enforcement` for package-based machine configuration enforcement.
- Build and publish package using `scripts/build-guestconfig-fileserver-package.ps1` and `scripts/publish-guestconfig-package.ps1`.
- Use GitHub workflow `.github/workflows/guestconfig-package-and-apply-dev.yml` for artifact delivery + apply.
- See `docs/guest-configuration-package-enforcement.md` for full flow.

## GitHub Commit Automation

- Commits to `main` apply Terraform from GitHub Actions using `.github/workflows/terraform-apply-on-commit.yml`.
- Pull requests run validation using `.github/workflows/terraform-validate.yml`.
- See `docs/github-automation.md` for required GitHub environment secrets and protection settings.
