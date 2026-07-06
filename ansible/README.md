# Ansible Infrastructure

This folder provides Ansible automation for Windows hosts and Arc onboarding, designed to work alongside the Terraform baseline.

## Structure

- `ansible.cfg` - Ansible defaults
- `requirements.yml` - required collections
- `inventories/` - dev/test/prod inventories and variables
- `playbooks/` - entry points for baseline runs
- `roles/` - reusable automation logic

## Install Dependencies

```powershell
cd ansible
ansible-galaxy collection install -r requirements.yml
```

## Run Examples

```powershell
cd ansible
ansible-playbook -i inventories/dev/hosts.yml playbooks/baseline-windows.yml
ansible-playbook -i inventories/test/hosts.yml playbooks/baseline-windows.yml
ansible-playbook -i inventories/prod/hosts.yml playbooks/baseline-windows.yml
ansible-playbook -i inventories/dev/hosts.yml playbooks/onboard-arc.yml
```

Use the inventory that matches the deployment stage:

- dev: `inventories/dev/hosts.yml`
- test: `inventories/test/hosts.yml`
- prod: `inventories/prod/hosts.yml`

## Security Notes

- Move passwords and service principal secrets to Ansible Vault before production usage.
- Prefer Kerberos and certificate validation in production.
- For Arc onboarding, use short-lived credentials and rotate often.

## Integration with Terraform

Use Terraform outputs from `../terraform` to populate inventory targets for managed Windows VMs and Arc-connected servers.
