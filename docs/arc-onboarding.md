# Arc Onboarding Baseline

Use this baseline to onboard non-Azure Windows servers into Azure Arc so they can be governed with Policy, Defender for Cloud, and Update Manager.

## Recommended Flow

1. Prepare target servers (network egress, required TLS, local admin rights).
2. Install Arc agent (`azcmagent`) using onboarding script generated from Azure Portal or automation account.
3. Group machines by tags (for policy targeting and patch scheduling).
4. Verify resource type `Microsoft.HybridCompute/machines` appears in your subscription.

## Suggested Tag Model

- `Environment`: dev/test/prod
- `PatchRing`: pilot/broad/critical
- `Role`: domain-controller/sql/app
- `Owner`: team or service owner

## Notes

- Arc onboarding itself is typically handled outside Terraform due to bootstrap requirements.
- After onboarding, use policy assignments and maintenance configurations from this repo for steady-state governance.
