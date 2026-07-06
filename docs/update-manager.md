# Azure Update Manager Baseline

The `update_manager` Terraform module creates a monthly Windows in-guest patch schedule.

## Usage

1. Apply Terraform baseline.
2. Target VMs and Arc machines to the maintenance configuration using dynamic scope and tags.
3. Validate patch deployment history and reboot behavior.

## Patch Ring Strategy

- `pilot`: second Tuesday, 02:00 UTC
- `broad`: second Wednesday, 02:00 UTC
- `critical`: second Thursday, 02:00 UTC

Create separate maintenance configurations per ring if needed.
