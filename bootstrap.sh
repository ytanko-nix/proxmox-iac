#!/bin/bash
set -eu

PROJECT_DIR=~/projects/proxmox-iac
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"
git init -b main
mkdir -p terraform cloud-init ansible docs scripts

# .gitignore
cat > .gitignore << 'GITIGNORE_EOF'
.terraform/
*.tfstate
*.tfstate.*.backup
*.tfstate.backup
crash.log
*.log
.terraform.lock.hcl
.terragrunt-cache/
.venv/
.vscode/
.idea/
.DS_Store
GITIGNORE_EOF

# README.md
cat > README.md << 'README_EOF'
# 🧱 Proxmox VM Automation — Terraform + Cloud-Init

## 1. Огляд

Цей IaC-проєкт призначений для **автоматичного створення та первинної конфігурації** віртуальної машини (ВМ) на платформі Proxmox Virtual Environment.

ВМ створюється на базі операційної системи **Rocky Linux 9.5** на вузлі **Gemini** [1, 2].
Основна мета ВМ: надання ізольованого середовища розробки для Open Text Content Server (OTCS) версії 25.3, яке вимагає підвищених обсягів ресурсів (8 CPU, 16 GB RAM) та специфічної конфігурації мережі [3, 4].

## 2. Архітектура рішення

Проєкт використовує модульний підхід IaC для забезпечення відтворюваності та легкості управління конфігурацією ВМ.

**Компоненти:**

| Компонент | Роль |
| :--- | :--- |
| **Terraform** | Інструмент для опису та розгортання інфраструктури. Використовує Proxmox API для створення, конфігурування ресурсів (CPU, RAM, диск) та приєднання ISO-образу. |
| **Cloud-Init** | Вбудований механізм Proxmox для **первинної конфігурації** системи під час першого завантаження (встановлення імені хоста, створення користувача (`otcs_user`), налаштування мережи та виконання початкових скриптів) [5]. |
| **Ansible (опціонально)** | Буде використано для **пост-конфігурації** після того, як ВМ буде доступна по мережі. Сюди входять складні дії, які були виконані вручну, як-от: встановлення Java 21, PostgreSQL 15, Tomcat 10.1, додаткових бібліотек (`XVFB`), та налаштування конфігураційних файлів для Content Server [6-9]. |

**Схема розгортання:**

```mermaid
graph LR
  A[Terraform] --> B(Proxmox API)
  B --> C[VM Instance (Rocky 9.5)]
  subgraph Proxmox Host (Gemini)
    C
  end
  C --> D[Cloud-Init Initialization]
  D --> E[VM Created & Configured (otcs-253-nx)]
  E -- SSH/Ansible --> F[Post-Configuration: DB, Java, Tomcat, CS]
```

## 3. Використання

Для розгортання ВМ виконайте наступний робочий процес:

1. Налаштування змінних: Створіть файл terraform/terraform.tfvars і заповніть його значеннями, включаючи API-ключі Proxmox та специфікації ВМ.
2. Ініціалізація Terraform: `just tf-init`
3. Перевірка: `just tf-validate`
4. План: `just tf-plan`
5. Створення ВМ: `just tf-apply`
6. Пост-конфігурація (опціонально): `just ansible-post`

## 4. Змінні Terraform

| Змінна | Опис | Приклад (на основі джерел) |
| :--- | :--- | :--- |
| pm_api_url | URL API Proxmox | https://andromeda.galaxy.globalense.net:8006/api2/json |
| pm_user | Користувач Proxmox (для доступу до API) | root@pam |
| pm_api_token_id | ID токена API | terraform@pam!iac |
| pm_api_token_secret | Секрет токена API | (змінна) |
| target_node | Вузол, на якому буде створено ВМ | Gemini |
| vm_name | Ім'я ВМ | otcs-253-nx |
| template | Cloud-Init шаблон для клонування | rocky9-cloudinit-template |
| cpu_sockets | Кількість сокетів | 2 |
| cpu_cores_per_socket | Ядер на сокет | 4 |
| memory_mb | Обсяг пам'яті (MB) | 16384 (16 GB) |
| disk_gb | Обсяг диска (GB) | 64 |
| network_bridge | Мережевий міст | vmbr1 |
| cloudinit_user | Користувач системи | otcs_user |
| ssh_public_key_path | Шлях до публічного SSH-ключа | ~/.ssh/id_ed25519.pub |

## 5. Cloud-Init шаблон

```yaml
#cloud-config
hostname: otcs-253-nx
manage_etc_hosts: true
users:
  - name: otcs_user
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
package_update: true
packages:
  - curl
  - htop
  - git
runcmd:
  - dnf -y update
  - echo "Cloud-Init completed on $(date)" | tee /var/log/cloud-init-done.log
```

## 6. Приклад Terraform ресурсу

Див. `terraform/main.tf` для повної конфігурації.

README_EOF

# Terraform main.tf
mkdir -p terraform

cat > terraform/main.tf << 'TF_MAIN_EOF'
terraform {
  required_providers {
    proxmox = {
      source  = "Telmate/proxmox"
      version = "3.0.1"
    }
  }
  required_version = ">= 1.3.0"
}

provider "proxmox" {
  pm_api_url          = var.pm_api_url
  pm_user             = var.pm_user
  pm_password         = var.pm_password
  pm_api_token_id     = var.pm_api_token_id
  pm_api_token_secret = var.pm_api_token_secret
  pm_tls_insecure     = var.pm_tls_insecure
}

resource "proxmox_vm_qemu" "otcs_vm" {
  name        = var.vm_name
  target_node = var.target_node
  clone       = var.template
  full_clone  = true
  onboot      = true

  # Resources
  sockets = var.cpu_sockets
  cores   = var.cpu_cores_per_socket
  memory  = var.memory_mb
  cpu     = "host"

  scsihw   = "virtio-scsi-pci"
  bootdisk = "scsi0"
  agent    = var.qemu_agent ? 1 : 0
  tags     = var.tags

  disk {
    type    = "scsi"
    storage = var.disk_storage
    size    = "${var.disk_gb}G"
  }

  network {
    model  = var.network_model
    bridge = var.network_bridge
  }

  # Cloud-Init
  ciuser    = var.cloudinit_user
  sshkeys   = file(var.ssh_public_key_path)
  ipconfig0 = var.ip_config
}
TF_MAIN_EOF

# Terraform variables.tf
cat > terraform/variables.tf << 'TF_VARS_EOF'
variable "pm_api_url" {
  description = "Proxmox API URL"
  type        = string
}

variable "pm_user" {
  description = "Proxmox username (e.g., root@pam)"
  type        = string
  default     = null
}

variable "pm_password" {
  description = "Proxmox password (if not using API token)"
  type        = string
  sensitive   = true
  default     = null
}

variable "pm_api_token_id" {
  description = "Proxmox API token ID (recommended)"
  type        = string
  default     = null
}

variable "pm_api_token_secret" {
  description = "Proxmox API token secret"
  type        = string
  sensitive   = true
  default     = null
}

variable "pm_tls_insecure" {
  description = "Allow insecure TLS"
  type        = bool
  default     = true
}

variable "target_node" {
  description = "Proxmox node to place the VM"
  type        = string
  default     = "Gemini"
}

variable "vm_name" {
  description = "VM name"
  type        = string
  default     = "otcs-253-nx"
}

variable "template" {
  description = "Cloud-Init template to clone from"
  type        = string
  default     = "rocky9-cloudinit-template"
}

variable "cpu_sockets" {
  description = "Number of CPU sockets"
  type        = number
  default     = 2
}

variable "cpu_cores_per_socket" {
  description = "Number of cores per socket"
  type        = number
  default     = 4
}

variable "memory_mb" {
  description = "Memory in MB"
  type        = number
  default     = 16384
}

variable "disk_gb" {
  description = "Disk size in GB"
  type        = number
  default     = 64
}

variable "disk_storage" {
  description = "Proxmox storage to place the disk"
  type        = string
  default     = "local-lvm"
}

variable "network_model" {
  description = "Network interface model"
  type        = string
  default     = "virtio"
}

variable "network_bridge" {
  description = "Bridge to attach NIC"
  type        = string
  default     = "vmbr1"
}

variable "cloudinit_user" {
  description = "Default user created by cloud-init"
  type        = string
  default     = "otcs_user"
}

variable "ssh_public_key_path" {
  description = "Path to public SSH key"
  type        = string
  default     = "~/.ssh/id_ed25519.pub"
}

variable "ip_config" {
  description = "ipconfig0 value (e.g., ip=dhcp)"
  type        = string
  default     = "ip=dhcp"
}

variable "qemu_agent" {
  description = "Enable QEMU guest agent"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Comma-separated tags for the VM"
  type        = string
  default     = "otcs,rocky,terraform"
}
TF_VARS_EOF

# terraform.tfvars.example
cat > terraform/terraform.tfvars.example << 'TFVARS_EXAMPLE_EOF'
# Proxmox API
pm_api_url          = "https://andromeda.galaxy.globalense.net:8006/api2/json"
pm_api_token_id     = "terraform@pam!iac"
pm_api_token_secret = "REPLACE_ME"
pm_tls_insecure     = true

# Target
target_node = "Gemini"
vm_name     = "otcs-253-nx"
template    = "rocky9-cloudinit-template"

# Resources
cpu_sockets           = 2
cpu_cores_per_socket  = 4
memory_mb             = 16384
disk_gb               = 64
disk_storage          = "local-lvm"

# Network
network_model  = "virtio"
network_bridge = "vmbr1"
ip_config      = "ip=dhcp"

# Cloud-Init
cloudinit_user        = "otcs_user"
ssh_public_key_path   = "~/.ssh/id_ed25519.pub"

# Misc
qemu_agent = true
tags       = "otcs,rocky,terraform"
TFVARS_EXAMPLE_EOF

# Cloud-Init user-data
mkdir -p cloud-init

cat > cloud-init/cloud-init.yml << 'CLOUD_INIT_EOF'
#cloud-config
hostname: otcs-253-nx
manage_etc_hosts: true
users:
  - name: otcs_user
    sudo: ["ALL=(ALL) NOPASSWD:ALL"]
    shell: /bin/bash
package_update: true
packages:
  - curl
  - htop
  - git
runcmd:
  - echo "Running post-install steps..."
  - dnf -y update
  - echo "Cloud-Init completed on $(date)" | tee /var/log/cloud-init-done.log
CLOUD_INIT_EOF

# Docs
mkdir -p docs

cat > docs/ARCHITECTURE.md << 'ARCH_EOF'
# Proxmox VM IaC Architecture

## Flow

- Terraform -> Proxmox API -> VM clone from Cloud-Init template
- Cloud-Init -> initial config (hostname, user, packages, updates)
- Ansible -> post-install (Java, PostgreSQL, Tomcat, OTCS)

## Target

- Node: Gemini
- OS: Rocky Linux 9.5
- VM: otcs-253-nx
- Resources: 8 vCPU, 16GB RAM, 64GB disk
- Network: vmbr1
ARCH_EOF

cat > docs/DESIGN.md << 'DESIGN_EOF'
# DESIGN: Proxmox IaC (Terraform + Cloud-Init + Ansible)

## Goals
- Deterministic provisioning of a Rocky 9.5 VM on node "Gemini"
- VM spec: 8 vCPU (2 sockets x 4 cores), 16GB RAM, 64GB disk, vmbr1 network
- Cloud-Init user otcs_user with SSH access and initial updates
- Optional Ansible-driven post-install for OTCS stack

## Stages
1) Scaffolding & VCS: Repo, directories, Justfile, README, docs
2) Terraform Core: provider, VM resource, variables, tfvars example
3) Cloud-Init: user-data template (local & optional Proxmox snippet)
4) Ansible: base post-install playbook (updates, base packages)
5) Execution: tf init/plan/apply; Ansible run
6) Validation: SSH access, guest agent, resource sizing, network

## Assumptions
- Preferred: clone from a Rocky 9 Cloud-Init template in Proxmox
- Storage: disk on local-lvm
- Network: vmbr1 with DHCP in the target environment

## Risks / Open Questions
- Template availability: confirm rocky9-cloudinit-template exists
- Credentials: token vs user/pass policy
DESIGN_EOF

cat > docs/TODO.md << 'TODO_EOF'
# To-Do

## Stage 1: Scaffolding
- [x] Confirm image source (Cloud-Init template)
- [x] Project bootstrap & initial commit

## Stage 2: Terraform
- [ ] Fill terraform/terraform.tfvars with real values
- [ ] terraform init / validate / plan / apply
- [ ] Verify VM created on Gemini with expected resources

## Stage 3: Ansible
- [ ] Update inventory (IP/hostname)
- [ ] Run post-install playbook
- [ ] Expand roles for OTCS stack

## Stage 4: Validation
- [ ] SSH connectivity as otcs_user
- [ ] Packages present; guest agent running; disk/network OK
TODO_EOF

# Ansible
mkdir -p ansible

cat > ansible/post_install.yml << 'ANSIBLE_EOF'
- hosts: all
  become: true
  gather_facts: true
  tasks:
    - name: Ensure system is updated (Rocky)
      ansible.builtin.dnf:
        name: "*"
        state: latest
        update_only: true

    - name: Install base utilities
      ansible.builtin.dnf:
        name:
          - vim
          - curl
          - git
          - htop
        state: present
ANSIBLE_EOF

cat > ansible/inventory.ini << 'INV_EOF'
# Update with the VM's IP/hostname after provisioning
[otcs]
otcs-253-nx ansible_host=CHANGE_ME ansible_user=otcs_user
INV_EOF

# Initial git commit
git add .
git commit -m "Initial Proxmox IaC project structure with Terraform + Cloud-Init"
echo "✓ Bootstrap complete!"
