# Environment Strategy (dev/test/prod)

This repository uses explicit environment separation for infrastructure and configuration management.

## Terraform

- Variable files: `terraform/environments/dev.tfvars`, `test.tfvars`, `prod.tfvars`
- State backends: `terraform/backends/dev.hcl`, `test.hcl`, `prod.hcl`
- Deployment helper: `scripts/deploy-terraform.ps1`

Recommended promotion flow:

1. Apply in dev and validate.
2. Promote same change to test.
3. Promote to prod after approvals.

## Ansible

- Inventories: `ansible/inventories/dev`, `test`, `prod`
- Run helper: `scripts/run-ansible.ps1`

Recommended execution flow:

1. Run baseline in dev.
2. Validate host compliance and update behavior.
3. Repeat in test.
4. Run in prod during approved change windows.

## Security Baseline

- Keep secrets out of repository.
- Use Ansible Vault for inventory secrets.
- Use least privilege service principals for Arc onboarding.
- Enforce branch protections and PR approvals for prod changes.
