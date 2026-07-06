# GitHub Automation (Apply On Commit)

This repository is configured so commits to `main` trigger Terraform apply from GitHub Actions.

## Workflows

- `.github/workflows/terraform-validate.yml`
  - Runs on pull requests and checks formatting + `terraform validate`.
- `.github/workflows/terraform-apply-on-commit.yml`
  - Runs on commits to `main`.
  - Applies in sequence: `dev` -> `test` -> `prod`.

## Required GitHub Environments

Create these environments in repository settings:

- `dev`
- `test`
- `prod`

Recommended protection:

- `test`: required reviewers
- `prod`: required reviewers + branch protection + wait timer

## One-Shot Bootstrap

Use the repository script to create environments (`dev`, `test`, `prod`), set required secrets, configure per-environment Azure federated credentials for GitHub OIDC, and apply required reviewers to `test` and `prod`.

```powershell
pwsh ./scripts/setup-github-environments-and-oidc.ps1
```

Optional parameters:

```powershell
pwsh ./scripts/setup-github-environments-and-oidc.ps1 `
  -Repository "stefandr2/IasC" `
  -RequiredReviewerUsernames @("stefandr2")
```

## Required Environment Secrets

Set these secrets for each environment (`dev`, `test`, `prod`):

- `AZURE_CLIENT_ID`
- `AZURE_TENANT_ID`
- `AZURE_SUBSCRIPTION_ID`
- `TF_ADMIN_PASSWORD`

Additional secrets for Guest Configuration package workflow (at least in `dev`):

- `GC_STORAGE_ACCOUNT_NAME`
- `GC_STORAGE_CONTAINER_NAME`

## Azure Authentication Model

The workflow uses `azure/login` with OpenID Connect (OIDC).

You must create a Microsoft Entra application/service principal and federated credentials for this GitHub repository + environment.

## Notes

- Terraform backend values are read from `terraform/backends/<env>.hcl`.
- Do not store sensitive values in tfvars committed to Git.
- Keep `TF_ADMIN_PASSWORD` only in GitHub environment secrets.
