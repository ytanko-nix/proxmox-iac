# DESIGN: Proxmox IaC (Terraform + Cloud-Init + Ansible)

## Goals

- Deterministic provisioning of VMs on Proxmox using Cloud-Init templates
- Flexible configuration via Terraform variables
- Support for various operating systems (Rocky Linux, Ubuntu, etc.)
- Optional Ansible-driven post-install automation
- Reproducible and version-controlled infrastructure

## Stages

1. **Scaffolding & VCS**: Repo, directories, Justfile, README, docs
2. **Terraform Core**: provider, VM resource, variables, tfvars example
3. **Cloud-Init**: Configuration via Terraform variables (hostname, user, packages)
4. **Ansible**: Base post-install playbook (updates, base packages) - expandable
5. **Execution**: tf init/plan/apply; optional Ansible run
6. **Validation**: SSH access, guest agent, resource sizing, network

## Assumptions

- Cloud-Init template exists in Proxmox (user must create/populate)
- Storage pool exists (default: `local-lvm`)
- Network bridge exists (default: `vmbr0`)
- DHCP available or static IP configuration provided

## Configuration Points

All aspects are configurable:
- **Target node**: Any Proxmox node
- **VM resources**: CPU, RAM, disk via variables
- **Network**: Bridge selection, IP configuration (DHCP or static)
- **Cloud-Init**: User, packages, SSH keys
- **Tags**: Optional VM tagging for organization

## Risks / Open Questions

- Template availability: User must ensure Cloud-Init template exists
- Credentials: Token vs user/pass authentication
- Network: DHCP vs static IP requirements
