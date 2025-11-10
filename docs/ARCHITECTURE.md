# Proxmox VM IaC Architecture

## Flow

- Terraform -> Proxmox API -> VM clone from Cloud-Init template
- Cloud-Init -> initial config (hostname, user, packages, updates)
- Ansible -> post-install (optional: application stack, services, configuration)

## Components

- **Terraform**: Infrastructure provisioning via Proxmox API
- **Cloud-Init**: Initial VM configuration on first boot
- **Ansible**: Post-install automation (optional)

## Configuration

All VM specifications are configurable via Terraform variables:
- Node selection
- VM name and hostname
- CPU, memory, disk resources
- Network configuration
- Cloud-Init user and packages
- SSH keys

See `terraform/variables.tf` and `terraform/terraform.tfvars.example` for details.
