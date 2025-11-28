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

### OpenJDK
- Version: 17
- Docs: https://openjdk.org/projects/jdk/17/
- Project usage: Java runtime for application servers

### Apache Tomcat
- Version: 10.1.31
- Docs: https://tomcat.apache.org/tomcat-10.1-doc/
- Project usage: Java application server (installed via Ansible)

## Processes

### Feature development process
See `.tessl/project/TESSL_GUIDE.md` — complete Tessl workflow guide.

### Deployment workflow

#### Quick deployment (recommended)
```bash
just tf-init        # First time only
just deploy         # Create VM + Install Java/Tomcat
```

#### Step-by-step deployment
1. `just tf-init` — Initialize Terraform (first time only)
2. `just tf-plan` — Review Terraform plan
3. `just tf-apply` — Create VM in Proxmox
4. `just generate-inventory` — Generate Ansible inventory from Terraform outputs
5. `just ansible-java` — Install Java 17 + Tomcat 10.1

#### Alternative workflows
- `just deploy` — Full deployment with Java/Tomcat
- `just deploy-post` — Full deployment with basic post-install only
- `just ansible-post` — Run basic post-configuration playbook

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
