# Proxmox VM Automation — Project Specification

## Metadata

- **Project Name**: Proxmox VM Automation — Terraform + Cloud-Init + Ansible
- **Repository**: proxmox-iac
- **Baseline Branch**: `main`
- **Purpose**: Automated provisioning and initial configuration of virtual machines on Proxmox Virtual Environment using Infrastructure as Code (IaC) principles
- **Spec Version**: 1.0.0
- **Last Updated**: 2025-11-13

## Overview

This project provides a modular, reproducible approach to VM provisioning on Proxmox VE. It uses a three-tier automation strategy that separates infrastructure provisioning, initial system configuration, and post-deployment customization.

### Goals and Motivation

**Primary Goals:**
- Deterministic provisioning of VMs on Proxmox using Cloud-Init templates
- Flexible configuration via Terraform variables
- Support for various operating systems (Rocky Linux, Ubuntu, etc.)
- Optional Ansible-driven post-install automation
- Reproducible and version-controlled infrastructure

**Benefits:**
- Infrastructure as Code (IaC) principles enable version control and reproducibility
- Separation of concerns across provisioning, initial configuration, and post-deployment
- Template-based approach accelerates VM deployment
- Modular design supports diverse workload requirements

### Architecture

The project implements a layered automation approach:

| Component | Role | Execution Phase |
|:----------|:-----|:----------------|
| **Terraform** | Infrastructure provisioning via Proxmox API (CPU, RAM, disk, network) | Pre-deployment |
| **Cloud-Init** | Initial system configuration during first boot (hostname, user creation, package installation) | VM first boot |
| **Ansible** (optional) | Post-configuration automation (application stack, services) | Post-deployment |

**Deployment Flow:**

```
Terraform → Proxmox API → VM Instance (created)
                              ↓
                         Cloud-Init (first boot)
                              ↓
                         VM Ready & Accessible
                              ↓
                         Ansible (optional post-config)
```

#### Component Details

**Terraform:**
- Provisions infrastructure via Proxmox API
- Manages VM resources: CPU, memory, disk, network
- Clones from Cloud-Init template
- Injects Cloud-Init configuration parameters

**Cloud-Init:**
- Executes on first VM boot
- Sets hostname
- Creates default user with SSH keys
- Installs packages
- Runs system updates
- Configuration passed via Terraform variables (not separate YAML files)

**Ansible (Optional):**
- Handles post-deployment automation
- Installs application stacks (e.g., Java 17 + Tomcat 10.1)
- Configures services and daemons
- Applies security hardening
- Expandable with custom roles and playbooks
- Auto-generated inventory from Terraform outputs

### Configuration Approach

All VM specifications are configurable via Terraform variables:
- **Node selection**: Target Proxmox node
- **VM identity**: Name and hostname
- **Resources**: CPU, memory, disk sizing
- **Network**: Bridge selection, IP configuration (DHCP or static)
- **Cloud-Init**: User, packages, SSH keys
- **Tags**: Optional VM tagging for organization

See `terraform/variables.tf` and `terraform/terraform.tfvars.example` for complete variable definitions.

### Design Assumptions and Constraints

**Assumptions:**
- Cloud-Init template exists in Proxmox (user must create/populate in advance)
- Storage pool exists and is accessible (default: `local-lvm`)
- Network bridge exists (default: `vmbr0`)
- DHCP service available (or static IP configuration will be provided)
- Proxmox API access is configured with appropriate permissions

**Constraints:**
- Template must have Cloud-Init support pre-configured
- API tokens or credentials must have VM.Allocate, VM.Clone, VM.Config.All, Datastore.AllocateSpace permissions
- Network configuration depends on existing infrastructure

**Out of Scope:**
- Cloud-Init template creation (user responsibility)
- Proxmox cluster setup and configuration
- Network infrastructure provisioning
- Storage pool configuration

## Repository Structure

```
proxmox-iac/
├── .tessl/                      # Tessl framework and specifications
│   ├── framework/
│   │   └── usage-specs.md       # Usage specifications for dependencies
│   └── project/
│       └── spec.md              # This file
├── terraform/                   # Terraform configuration
│   ├── main.tf                  # Provider and VM resource definitions
│   ├── variables.tf             # Input variable declarations
│   ├── outputs.tf               # Outputs for Ansible integration
│   └── terraform.tfvars.example # Non-sensitive configuration template
├── cloud-init/                  # Cloud-Init templates
│   └── cloud-init.yml           # Reference cloud-init configuration
├── ansible/                     # Ansible post-configuration
│   ├── inventory.ini            # Auto-generated inventory
│   ├── post_install.yml         # Post-installation playbook
│   ├── java_tomcat.yml          # Java 17 + Tomcat 10.1 playbook
│   └── templates/               # Jinja2 templates
│       └── tomcat.service.j2    # Tomcat systemd service
├── scripts/                     # Utility scripts
│   ├── create_template.sh       # Cloud-Init template creation
│   └── generate_inventory.sh    # Generate Ansible inventory from Terraform
├── docs/                        # Project documentation
│   ├── ARCHITECTURE.md          # Architecture details
│   ├── DESIGN.md                # Design decisions
│   ├── TODO.md                  # Planned improvements
│   └── features/                # Feature-specific documentation
│       └── ansible-java-tomcat/ # Java/Tomcat integration feature
│           ├── design.md        # Feature design document
│           └── todo.md          # Feature TODO checklist
├── Justfile                     # Command automation recipes
├── README.md                    # Project overview and quick start
├── AGENTS.md                    # Agent configuration (Tessl)
├── RULES.md                     # Agent rules (Tessl)
└── KNOWLEDGE.md                 # Knowledge index for dependencies
```

## Dependencies

### Core Requirements

| Dependency | Version | Purpose | Documentation |
|:-----------|:--------|:--------|:--------------|
| **Terraform CLI** | ≥ 1.3.0 | Infrastructure provisioning | [terraform.io](https://terraform.io) |
| **Telmate/proxmox** (provider) | 3.0.1 | Terraform provider for Proxmox VE | [registry.terraform.io](https://registry.terraform.io/providers/Telmate/proxmox/3.0.1) |
| **Proxmox VE** | Latest stable | Virtualization platform with API access | [proxmox.com](https://www.proxmox.com) |
| **Cloud-Init Template** | Platform-specific | Pre-configured VM template with Cloud-Init support | Must exist on Proxmox host |

### Optional Dependencies

| Dependency | Version | Purpose | Documentation |
|:-----------|:--------|:--------|:--------------|
| **ansible-core** | 2.19.1 | Post-configuration automation | [Usage spec](.tessl/usage-specs/tessl/pypi-ansible-core/docs/index.md) |
| **python-terraform** | 0.14.0 | Python wrapper for Terraform CLI | [Usage spec](.tessl/usage-specs/tessl/pypi-python-terraform/docs/index.md) |
| **Just** | Latest | Command runner for automation recipes | [casey.github.io/just](https://casey.github.io/just/) |

### Infrastructure Requirements

- **Proxmox VE** with API access enabled
- **Cloud-Init template VM** (e.g., `rocky9-cloudinit-template`) must be created in advance
- **Storage pool** (default: `local-lvm`)
- **Network bridge** (default: `vmbr0`)
- **DHCP service** (optional, for dynamic IP assignment)

### Security Notes

- **TLS Verification**: `pm_tls_insecure` defaults to `true` for development. Set to `false` in production with proper certificates.
- **API Tokens**: Prefer API tokens over username/password authentication.
- **Permissions**: Ensure API tokens have minimal required permissions for VM provisioning.

## Configuration

### Terraform Variables

All VM specifications are configurable via Terraform variables defined in `terraform/variables.tf`. Key variables include:

#### API Connection

| Variable | Type | Required | Default | Description |
|:---------|:-----|:---------|:--------|:------------|
| `pm_api_url` | string | Yes | — | Proxmox API URL (e.g., `https://proxmox.example.com:8006/api2/json`) |
| `pm_user` | string | No | `null` | Proxmox username (e.g., `root@pam`) |
| `pm_password` | string | No | `null` | Proxmox password (sensitive) |
| `pm_api_token_id` | string | No | `null` | API token ID (recommended) |
| `pm_api_token_secret` | string | No | `null` | API token secret (sensitive) |
| `pm_tls_insecure` | bool | No | `true` | Allow insecure TLS |

#### VM Target & Template

| Variable | Type | Required | Default | Description |
|:---------|:-----|:---------|:--------|:------------|
| `target_node` | string | Yes | — | Proxmox node name (e.g., `node1`, `Gemini`) |
| `template` | string | Yes | — | Cloud-Init template to clone from |
| `vm_name` | string | Yes | — | VM name in Proxmox |
| `vm_hostname` | string | No | `null` | VM hostname (defaults to `vm_name`) |

#### Resources

| Variable | Type | Required | Default | Description |
|:---------|:-----|:---------|:--------|:------------|
| `cpu_sockets` | number | No | `1` | Number of CPU sockets |
| `cpu_cores_per_socket` | number | No | `2` | Cores per socket |
| `memory_mb` | number | No | `2048` | Memory in MB |
| `disk_gb` | number | No | `20` | Disk size in GB |
| `disk_storage` | string | No | `local-lvm` | Proxmox storage pool |

#### Network

| Variable | Type | Required | Default | Description |
|:---------|:-----|:---------|:--------|:------------|
| `network_model` | string | No | `virtio` | Network interface model |
| `network_bridge` | string | No | `vmbr0` | Network bridge |
| `ip_config` | string | No | `ip=dhcp` | IP configuration (e.g., `ip=192.168.1.100/24,gw=192.168.1.1`) |

#### Cloud-Init

| Variable | Type | Required | Default | Description |
|:---------|:-----|:---------|:--------|:------------|
| `cloudinit_user` | string | No | `rocky` | Default user created by Cloud-Init |
| `ssh_public_key_path` | string | No | `""` | Path to SSH public key file |
| `cloudinit_ssh_keys` | list(string) | No | `[]` | List of SSH public keys (alternative to `ssh_public_key_path`) |
| `cloudinit_packages` | list(string) | No | `["curl", "htop", "git"]` | Packages to install via Cloud-Init |

#### Other

| Variable | Type | Required | Default | Description |
|:---------|:-----|:---------|:--------|:------------|
| `qemu_agent` | bool | No | `true` | Enable QEMU guest agent |
| `tags` | string | No | `""` | Comma-separated VM tags |

### Secrets Management

**⚠️ NEVER commit secrets to version control.**

Provide sensitive values using one of these methods:

1. **Environment Variables** (recommended):
   ```bash
   export TF_VAR_pm_api_url="https://proxmox.example.com:8006/api2/json"
   export TF_VAR_pm_api_token_id="terraform@pam!iac"
   export TF_VAR_pm_api_token_secret="your-secret-here"
   ```

2. **Separate `secrets.tfvars` file** (ensure it's git-ignored):
   ```hcl
   pm_api_url          = "https://proxmox.example.com:8006/api2/json"
   pm_api_token_id     = "terraform@pam!iac"
   pm_api_token_secret = "your-secret-here"
   ```
   Apply with: `terraform apply -var-file="secrets.tfvars"`

3. **External Secret Manager** (production):
   - HashiCorp Vault
   - AWS Secrets Manager
   - Azure Key Vault
   - etc.

See `terraform/terraform.tfvars.example` for non-sensitive configuration reference.

## Workflows

### Available Commands

The project uses [Just](https://casey.github.io/just/) for command automation. All recipes are defined in `Justfile`.

#### Terraform Commands

| Command | Description |
|:--------|:------------|
| `just tf-init` | Initialize Terraform (download providers, setup backend) |
| `just tf-fmt` | Format Terraform files according to canonical style |
| `just tf-validate` | Validate Terraform configuration syntax |
| `just tf-plan` | Show execution plan (preview changes) |
| `just tf-apply` | Apply infrastructure changes (auto-approve) |
| `just tf-destroy` | Destroy all managed infrastructure (auto-approve) |
| `just tf-clean` | Clean local Terraform state files and cache |

#### Ansible Commands

| Command | Description |
|:--------|:------------|
| `just ansible-post` | Run post-installation playbook |
| `just ansible-java` | Install Java 17 + Tomcat 10.1 |
| `just generate-inventory` | Generate inventory from Terraform outputs |

#### Workflow Commands

| Command | Description |
|:--------|:------------|
| `just deploy` | Full deployment: tf-apply → generate-inventory → ansible-java |
| `just deploy-post` | Full deployment: tf-apply → generate-inventory → ansible-post |

#### Utilities

| Command | Description |
|:--------|:------------|
| `just upload-ci-snippet` | Upload cloud-init snippet to Proxmox snippets directory |
| `just git-commit MSG="message"` | Commit all changes with specified message |
| `just help` | Display help with all available recipes |

### End-to-End Provisioning Workflow

**Prerequisites:**
- Ensure Cloud-Init template exists on Proxmox
- Configure `terraform/terraform.tfvars` or set environment variables
- Ensure SSH key is available

**Steps:**

1. **Initialize Terraform:**
   ```bash
   just tf-init
   ```

2. **Validate Configuration:**
   ```bash
   just tf-validate
   ```

3. **Review Execution Plan:**
   ```bash
   just tf-plan
   ```

4. **Create VM:**
   ```bash
   just tf-apply
   ```
   Wait for VM to boot and Cloud-Init to complete.

5. **Verify VM Access:**
   ```bash
   ssh <cloudinit_user>@<vm_ip>
   ```

6. **(Optional) Run Post-Configuration:**
   - Update `ansible/inventory.ini` with VM IP/hostname
   - Run playbook:
     ```bash
     just ansible-post
     ```

7. **Validate VM State:**
   - Check packages are installed
   - Verify QEMU guest agent is running (if enabled)
   - Confirm disk size and network configuration

## Cloud-Init Integration

### Configuration Approach

Cloud-Init configuration is passed to VMs via Terraform variables (`ciuser`, `sshkeys`, `ipconfig0`). The `cloud-init/cloud-init.yml` file serves as a **reference template** only and is not directly used during provisioning.

### How It Works

1. **Terraform** passes Cloud-Init parameters to Proxmox API
2. **Proxmox** injects Cloud-Init ISO into VM during cloning
3. **Cloud-Init** runs on first boot to:
   - Set hostname
   - Create default user
   - Install SSH keys
   - Install packages
   - Run update commands

### Customization

To customize Cloud-Init behavior, modify Terraform variables:
- `cloudinit_user` — Default user
- `ssh_public_key_path` or `cloudinit_ssh_keys` — SSH access
- `cloudinit_packages` — Packages to install
- `ip_config` — Network configuration

## Ansible Integration (Optional)

### Purpose

Ansible handles complex post-deployment configuration that goes beyond Cloud-Init's capabilities, such as:
- Installing application stacks
- Configuring services and daemons
- Setting up monitoring agents
- Applying security hardening

### Configuration Files

- **`ansible/inventory.ini`** — Inventory template (must be updated with VM IP/hostname after provisioning)
- **`ansible/post_install.yml`** — Base post-installation playbook

### Usage

1. **Update Inventory:**
   After VM is provisioned, update `ansible/inventory.ini`:
   ```ini
   [proxmox_vms]
   my-vm ansible_host=192.168.1.100 ansible_user=rocky
   ```

2. **Run Playbook:**
   ```bash
   just ansible-post
   ```

### Extensibility

The base playbook can be extended with additional roles and tasks:
- Create custom roles in `ansible/roles/`
- Add playbooks for specific use cases (e.g., `webserver.yml`, `database.yml`)
- Integrate with Ansible Galaxy roles

## Knowledge Management

### Tessl Knowledge Index

The project uses Tessl's Knowledge Index system to manage dependency documentation. See [KNOWLEDGE.md](../../KNOWLEDGE.md) for the complete index.

For practical guidance on using Tessl in this repository, see [TESSL_GUIDE.md](./TESSL_GUIDE.md).

**Current documented dependencies:**
- **ansible-core@2.19.1** — [docs](.tessl/usage-specs/tessl/pypi-ansible-core/docs/index.md)
- **python-terraform@0.14.0** — [docs](.tessl/usage-specs/tessl/pypi-python-terraform/docs/index.md)

### Usage Specifications

Consult [Usage Specs Framework](.tessl/framework/usage-specs.md) for guidance on:
- Reading the Knowledge Index before starting work
- Spawning research subagents for large documentation sets
- Searching and installing specs from Tessl Spec Registry

### Recommended Additions

The following dependencies should be documented in the Knowledge Index for improved coverage:
- **Terraform CLI** (≥ 1.3.0)
- **Telmate/proxmox provider** (v3.0.1)
- **Just command runner**
- **Cloud-Init**
- **Proxmox VE API**

Use `tessl registry search` and `tessl registry install` to add these specs.

## Security & Compliance

### Credential Management

**✅ Best Practices:**
- Use environment variables (`TF_VAR_*`) for sensitive values
- Use separate `secrets.tfvars` file (ensure it's git-ignored)
- Consider external secret managers for production environments
- Rotate API tokens and passwords regularly

**❌ Never:**
- Commit secrets to version control
- Share credentials via insecure channels
- Use production credentials in development

### TLS Configuration

- **Default**: `pm_tls_insecure = true` (development convenience)
- **Security Risk**: Disables TLS certificate verification
- **Production Recommendation**: Set to `false` and use valid certificates

### SSH Keys

- **Store**: Public keys only in configuration files
- **Never Commit**: Private keys
- **Best Practice**: Use separate SSH keys per environment

### Access Control

- **API Tokens**: Use tokens with minimal required permissions
- **Required Permissions**: VM.Allocate, VM.Clone, VM.Config.All, Datastore.AllocateSpace
- **Audit**: Regularly review and audit token usage

## Development Conventions

### Branching Strategy

- **Default Branch**: `main`
- **Feature Branches**: Create feature branches for significant changes
- **Commit Messages**: Use conventional commit format (e.g., `feat:`, `fix:`, `docs:`)

### Code Standards

- **Terraform**: Use `just tf-fmt` to format code before committing
- **Validation**: Run `just tf-validate` before pushing changes
- **Testing**: Always run `just tf-plan` to preview changes

### Documentation

- Keep README.md up to date with user-facing changes
- Update architecture and design docs for significant changes
- Maintain TODO.md with planned improvements (see [docs/TODO.md](../../docs/TODO.md))

### Maintenance Practices

- **Dependency Updates**: Regularly update provider versions
- **Cloud-Init Templates**: Review and update templates quarterly
- **Security Audits**: Audit secrets management and access controls regularly
- **Backups**: Ensure Terraform state is backed up (consider remote backend)

## Implemented Features

### Auto Provision Java + Tomcat

**Status**: Implemented (2025-12-08)
**Documentation**: [docs/features/auto-provision-java-tomcat/](../../docs/features/auto-provision-java-tomcat/)

**Description**: После создания VM через Terraform автоматически:
1. Ожидает готовности VM (SSH доступность, cloud-init completion)
2. Устанавливает Python3 (зависимость для Ansible)
3. Запускает Ansible playbook для установки Java 17 + Tomcat 10.1
4. Верифицирует установку (java -version, systemctl status tomcat, HTTP check)
5. Выводит сообщение: "Java и Tomcat установлены на машину [имя] с адресом [IP]"

**Используемые компоненты**:
- Terraform provisioners (remote-exec, local-exec)
- Ansible playbook: `ansible/java_tomcat.yml`
- bpg/proxmox provider `ipv4_addresses` attribute

**Запуск**:
```bash
just tf-apply
# или
terraform apply
```

## Planned Improvements

See [docs/TODO.md](../../docs/TODO.md) for current task list.

**Future enhancements:**
- Install missing usage-spec tiles for better documentation coverage
- Add CI/CD pipeline for automated validation and testing
- Implement remote Terraform backend (S3, GCS, Terraform Cloud)
- Create additional Cloud-Init templates for different OS distributions
- Expand Ansible roles for common application stacks
- Add VM snapshot management
- Implement automated backup workflows

## References

### Internal Documentation

- [README.md](../../README.md) — Project overview and quick start guide
- [docs/TODO.md](../../docs/TODO.md) — Planned improvements
- [KNOWLEDGE.md](../../KNOWLEDGE.md) — Dependency knowledge index
- [.tessl/framework/usage-specs.md](../framework/usage-specs.md) — Usage specifications framework
- [TESSL_GUIDE.md](./TESSL_GUIDE.md) — Tessl usage guide for feature development

**Note:** Architecture and design documentation has been consolidated into this specification document.

### External Resources

- [Terraform Documentation](https://terraform.io/docs)
- [Telmate/proxmox Provider](https://registry.terraform.io/providers/Telmate/proxmox/latest/docs)
- [Proxmox VE Documentation](https://pve.proxmox.com/pve-docs/)
- [Cloud-Init Documentation](https://cloudinit.readthedocs.io/)
- [Ansible Documentation](https://docs.ansible.com/)
- [Just Manual](https://just.systems/)

---

**Specification Maintained By**: Tessl Agent  
**Last Review**: 2025-11-13
