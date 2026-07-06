# Policy as Code Workflow

Use this workflow to manage policy lifecycle safely.

## Authoring

1. Create or update policy definition JSON under `policies/definitions`.
2. Bundle related definitions into an initiative under `policies/initiatives`.
3. Map policy definition IDs in `terraform/environments/<env>.tfvars`.

## Deployment

1. Run `terraform plan` in a non-production environment first.
2. Review assignment impact and remediation requirements.
3. Apply and monitor compliance before promoting to production.

## Operating Model

- Keep policy changes in pull requests.
- Require security/platform approval for production assignments.
- Document exemptions with expiration and owner.
