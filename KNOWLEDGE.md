# Knowledge Index

This document indexes dependencies, processes, and technologies used in the proxmox-iac project.

## Core Dependencies

### Terraform CLI
- Version: ≥ 1.3.0 (confirm in `terraform/versions.tf`)
- Usage Spec: (planned) — after install see `.tessl/usage-specs/tessl/terraform-cli/docs/`
- Docs: https://terraform.io/docs
- Project usage: Proxmox infrastructure provisioning via code

### Terraform Provider: Telmate/proxmox
- Version: 3.0.1 (see `terraform/main.tf`/`versions.tf`)
- Usage Spec: (planned) — `.tessl/usage-specs/tessl/telmate-proxmox/docs/`
- Docs: https://registry.terraform.io/providers/Telmate/proxmox/latest/docs
- Project usage: Terraform provider for Proxmox API

### Ansible Core
- Version: 2.19.1
- Usage Spec: `.tessl/usage-specs/tessl/pypi-ansible-core/docs/`
- Docs: see installed usage-spec files (`index.md`, `cli.md`, `configuration.md`)
- Project usage: Post-configuration of VMs after Terraform

### Python Terraform
- Version: 0.14.0
- Usage Spec: `.tessl/usage-specs/tessl/pypi-python-terraform/docs/`
- Docs: see installed usage-spec files (`index.md`, `core-operations.md`, `command-interface.md`)
- Project usage: Python wrapper over Terraform CLI

### Just (task runner)
- Version: latest
- Usage Spec: (planned)
- Docs: https://just.systems/
- Project usage: Command automation (see `Justfile`)

### Cloud-Init
- Usage Spec: (planned) — `.tessl/usage-specs/tessl/cloud-init/docs/`
- Docs: https://cloudinit.readthedocs.io/
- Project usage: VM first-boot initialization and configuration

### Proxmox VE API
- Usage Spec: (planned) — `.tessl/usage-specs/tessl/proxmox-api/docs/`
- Docs: https://pve.proxmox.com/pve-docs/
- Project usage: Direct Proxmox API interactions

## Processes

### Feature development process
See `.tessl/project/TESSL_GUIDE.md` — complete Tessl workflow guide.

### Deployment workflow
1. `just tf-init` — Terraform init
2. `just tf-plan` — Terraform plan
3. `just tf-apply` — Terraform apply
4. `just ansible-post` — Ansible post-configuration

### Security policies
- Do not commit secrets
- Use `TF_VAR_*` env vars or git-ignored `secrets.tfvars`
- TLS: production uses `pm_tls_insecure = false` with valid certs
- API tokens: minimal permissions, rotation, store in env/secret manager
- Details: `.tessl/project/spec.md` (Security & Compliance)

## Updating the Knowledge Index

When adding a new dependency:
1. Search for a usage-spec: `tessl search <dependency>`
2. Install the spec: `tessl install <tile-id>`
3. Add an entry here (Core Dependencies)
4. Update `.tessl/framework/usage-specs.md`
5. Update `.tessl/project/spec.md` (References/Dependencies)
