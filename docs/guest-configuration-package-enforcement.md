# True Guest Configuration Package Enforcement

This implementation enforces Windows File Server role settings using a Guest Configuration package artifact, not ad-hoc extension commands.

## Components

- Terraform module: `terraform/modules/guest_configuration_package_enforcement`
- Build script: `scripts/build-guestconfig-fileserver-package.ps1`
- Publish script: `scripts/publish-guestconfig-package.ps1`
- GitHub workflow: `.github/workflows/guestconfig-package-and-apply-dev.yml`

## Enforcement Flow

1. Build Guest Configuration package zip.
2. Upload package to private Azure Blob container.
3. Compute SHA256 hash.
4. Apply Terraform with `gc_package_content_uri` and `gc_package_content_hash`.
5. Azure Policy (DeployIfNotExists) deploys `guestConfigurationAssignments` to tagged Arc Windows machines.

## Required GitHub Environment Secrets (dev)

- `GC_STORAGE_ACCOUNT_NAME`
- `GC_STORAGE_CONTAINER_NAME`
- Existing: `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`, `TF_ADMIN_PASSWORD`

## Dev Defaults

Dev environment is configured to target:

- Resource group: `Nestle2`
- Tag selector: `ServerRole=File`

## Production Hardening

- Replace placeholder package builder with real `New-GuestConfigurationPackage` pipeline.
- Restrict blob container access (private endpoint and RBAC).
- Pin package version and hash per release.
- Promote package artifact across dev -> test -> prod with approvals.
