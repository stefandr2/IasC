# Machine Configuration for Windows

This repository includes policy-as-code scaffolding for Guest Configuration style controls.

## Implementation Pattern

1. Start with built-in Guest Configuration policies for Windows security baseline.
2. Assign policies at subscription or management group scope.
3. Use exemptions for justified deviations.
4. Track compliance in Azure Policy and Defender for Cloud recommendations.

## Typical Windows Settings to Govern

- Password policy and lockout thresholds
- RDP hardening
- Local Administrators group membership
- Defender AV and attack surface reduction settings
- Windows Update service configuration

## Where to Configure

- Policy definitions and initiatives: `policies/`
- Terraform assignment bindings: `terraform/modules/policy_assignments`
- Environment-specific assignment IDs: `terraform/environments/*.tfvars`
