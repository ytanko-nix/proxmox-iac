# Proxmox IaC — Quick Start Guide

This guide walks you through configuring and deploying a VM on Proxmox using Terraform and Cloud-Init. The example uses Rocky Linux, but the same approach works for any Cloud-Init-enabled template.

## Prerequisites

- **Terraform** ≥ 1.3.0 installed
- **Proxmox VE** access with API credentials
- **SSH key** (optional but recommended; default uses DHCP)
- **Ansible** (optional for post-install automation)
- **Just** command runner (optional; you can run bash directly)

## Step 1: Clone or Navigate to Project

```bash
cd ~/projects/proxmox-iac
```

## Step 2: Configure Terraform Variables

### Create `terraform.tfvars` from template

```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

### Edit `terraform/terraform.tfvars`

Open the file and update the following values:

```hcl
# Proxmox API
pm_api_url          = "https://your-proxmox-host:8006/api2/json"
pm_api_token_id     = "terraform@pam!iac"
pm_api_token_secret = "your-api-token-secret"
pm_tls_insecure     = true  # Set to false if using valid certificate

# Target
target_node = "node1"  # Your Proxmox node name
vm_name     = "my-vm"  # VM name in Proxmox
vm_hostname = null     # Optional: hostname (defaults to vm_name)
template    = "rocky9-cloudinit-template"  # Name of your Cloud-Init template

# Resources (customize as needed)
cpu_sockets           = 1
cpu_cores_per_socket  = 2
memory_mb             = 2048  # 2 GB
disk_gb               = 20
disk_storage          = "local-lvm"

# Network
network_model  = "virtio"
network_bridge = "vmbr0"
ip_config      = "ip=dhcp"  # Or use: "ip=192.168.1.100/24,gw=192.168.1.1"

# Cloud-Init
cloudinit_user        = "rocky"  # Default user created by cloud-init
ssh_public_key_path   = "~/.ssh/id_ed25519.pub"  # Leave empty to use cloudinit_ssh_keys
cloudinit_packages    = ["curl", "htop", "git"]  # Packages to install

# Misc
qemu_agent = true
tags       = ""  # Optional: comma-separated tags
```

### Key Configuration Parameters

| Parameter | Description | Example |
| --- | --- | --- |
| `pm_api_url` | Proxmox API endpoint URL | `https://proxmox.example.com:8006/api2/json` |
| `pm_api_token_id` | API token ID (format: `user@realm!name`) | `terraform@pam!iac` |
| `pm_api_token_secret` | API token secret (generate in Proxmox GUI) | Auto-generated |
| `target_node` | Proxmox node where VM will be created | `node1`, `Gemini`, etc. |
| `vm_name` | VM name in Proxmox | `my-vm`, `app-server`, etc. |
| `vm_hostname` | VM hostname (optional, defaults to vm_name) | `my-hostname` |
| `template` | Cloud-Init template VM name to clone from | `rocky9-cloudinit-template` |
| `cpu_sockets` | Number of CPU sockets | `1`, `2`, etc. |
| `cpu_cores_per_socket` | Cores per socket (total CPUs = sockets × cores) | `2` (1×2 = 2 total) |
| `memory_mb` | RAM in megabytes | `2048` (2 GB) |
| `disk_gb` | Primary disk size | `20`, `64`, etc. |
| `disk_storage` | Proxmox storage pool name | `local-lvm`, `local`, etc. |
| `network_bridge` | Virtual bridge to attach NIC | `vmbr0`, `vmbr1`, etc. |
| `cloudinit_user` | Default OS user created by Cloud-Init | `rocky`, `ubuntu`, etc. |
| `ssh_public_key_path` | Path to your SSH public key (optional) | `~/.ssh/id_ed25519.pub` |
| `ip_config` | IP configuration | `ip=dhcp` or `ip=192.168.x.x/24,gw=192.168.x.1` |

## Step 3: (Optional) Configure Cloud-Init

Cloud-Init configuration is primarily managed through Terraform variables (`cloudinit_user`, `ssh_public_key_path`, `cloudinit_packages`). The `cloud-init/cloud-init.yml` file serves as a reference template.

To customize further, you can modify the Cloud-Init settings in your `terraform.tfvars`:

```hcl
cloudinit_user     = "rocky"
cloudinit_packages = ["curl", "htop", "git", "vim"]
```

## Step 4: Initialize and Validate Terraform

```bash
# Initialize Terraform (downloads provider)
just tf-init
# OR without just:
cd terraform && terraform init && cd ..

# Validate configuration
just tf-validate
# OR:
cd terraform && terraform validate && cd ..

# (Optional) Format HCL files
just tf-fmt
# OR:
cd terraform && terraform fmt -recursive && cd ..
```

## Step 5: Review and Apply Terraform Plan

```bash
# Review what will be created
just tf-plan
# OR:
cd terraform && terraform plan && cd ..
```

Expected output shows:
- VM resource being created
- Network interface attached to bridge
- Disk allocated from storage pool
- Cloud-Init configuration applied

### Apply the Configuration

```bash
# Create the VM (auto-approve, no confirmation prompt)
just tf-apply
# OR:
cd terraform && terraform apply -auto-approve && cd ..
```

Expected output:
- VM created on Proxmox node
- Cloud-Init runs during first boot
- VM available at assigned IP

## Step 6: Verify VM Creation

In Proxmox GUI or CLI:

```bash
# SSH into your Proxmox host and check:
qm list                    # List VMs
qm status <vm-id>         # Check specific VM status
qm monitor <vm-id>        # Monitor VM activity

# Or check from your local machine:
ssh <cloudinit_user>@<vm-ip>     # SSH to VM after boot completes
```

Expected checks:
- ✓ VM running on specified node
- ✓ vCPU and RAM configured as specified
- ✓ Disk allocated as specified
- ✓ Network attached to specified bridge
- ✓ QEMU Guest Agent enabled
- ✓ SSH access as configured user

## Step 7: (Optional) Configure Ansible Post-Install

If you want to automate further configuration (Java, PostgreSQL, etc.):

1. **Update inventory** with VM IP/hostname:

```bash
# Edit ansible/inventory.ini
# Replace <vm_name> and <vm_ip> with actual values:
[proxmox_vms]
my-vm ansible_host=192.168.x.y ansible_user=rocky
```

2. **Run Ansible playbook**:

```bash
just ansible-post
# OR:
cd ansible && ansible-playbook -i inventory.ini post_install.yml && cd ..
```

## Troubleshooting

### `terraform init` fails with provider not found

**Solution:** Check internet connectivity and ensure Terraform can download providers.

### `terraform apply` fails with API error

**Solution:** Verify credentials:
- Proxmox API URL is correct (usually `https://hostname:8006/api2/json`)
- Token ID format: `user@realm!token-name` (e.g., `terraform@pam!iac`)
- Token secret is correct
- Node name (`target_node`) exists in Proxmox

### VM does not appear in Proxmox

**Solution:** Check Terraform state:
```bash
cd terraform && terraform state list && terraform state show proxmox_vm_qemu.otcs_vm && cd ..
```

### Cannot SSH to VM after creation

**Solution:**
- Verify VM has booted and obtained IP address: `qm status <vm-id>`
- Check Cloud-Init logs on VM: `cloud-init status`, `cloud-init logs`
- Ensure SSH key path is correct in `terraform.tfvars`
- If using password, verify via Proxmox console

### Cloud-Init did not run or errors

**Solution:** Check Cloud-Init execution on VM:
```bash
ssh otcs_user@<vm-ip>
sudo cloud-init status
sudo cloud-init query -a
cat /var/log/cloud-init-output.log
```

## Common Tasks

### Change VM Resources After Creation

Edit `terraform/terraform.tfvars` and run:
```bash
just tf-plan     # Review changes
just tf-apply    # Apply (may require VM restart)
```

### Add SSH Key After VM Creation

1. Edit `terraform/terraform.tfvars`:
```hcl
ssh_public_key_path = "~/.ssh/id_ed25519.pub"  # Update if not set
```

2. Apply:
```bash
just tf-plan
just tf-apply
```

### Destroy VM and Infrastructure

```bash
just tf-destroy
# OR:
cd terraform && terraform destroy -auto-approve && cd ..
```

**Warning:** This will delete the VM permanently.

### Save Terraform State Remotely

For production, store state in remote backend (S3, Terraform Cloud, etc.):

Create `terraform/backend.tf`:
```hcl
terraform {
  backend "s3" {
    bucket         = "my-terraform-state"
    key            = "proxmox/otcs/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
```

Then:
```bash
cd terraform
terraform init  # Will prompt to migrate state to S3
```

## Using Without Just

If you don't have `just` installed, run Terraform commands directly:

```bash
# Instead of: just tf-init
cd terraform && terraform init && cd ..

# Instead of: just tf-plan
cd terraform && terraform plan && cd ..

# Instead of: just tf-apply
cd terraform && terraform apply -auto-approve && cd ..

# Instead of: just tf-destroy
cd terraform && terraform destroy -auto-approve && cd ..
```

## Git Workflow

Track your configuration in version control:

```bash
# After configuring terraform.tfvars:
just git-commit MSG="Configure Proxmox API and VM resources"
# OR:
git add terraform/terraform.tfvars
git commit -m "Configure Proxmox API and VM resources"

# After successful apply:
git add terraform/terraform.tfstate*
git commit -m "Update Terraform state after VM creation"
```

**Note:** In production, store `terraform.tfstate` in remote backend, not Git.

## Architecture Overview

```
Local Machine
    ↓
Terraform (your machine)
    ↓
Proxmox API (https://proxmox:8006/api2/json)
    ↓
Proxmox Node
    ├─ VM created (name from vm_name variable)
    ├─ vCPU, RAM, disk as configured
    ├─ NIC attached to specified bridge
    └─ Cloud-Init runs on first boot
        ├─ Hostname: from vm_hostname or vm_name
        ├─ User: from cloudinit_user variable
        ├─ Packages: from cloudinit_packages variable
        └─ System updates
```

## Next Steps

1. **Deploy VM:** Run `just tf-apply`
2. **SSH in:** `ssh <cloudinit_user>@<vm-ip>`
3. **Run Ansible (optional):** Run post-install tasks with `just ansible-post`
4. **Monitor:** Check `/var/log/cloud-init-output.log` for issues
5. **Iterate:** Update config in `terraform/terraform.tfvars` and re-apply

## Support

- See `.tessl/project/spec.md` for architecture and design details
- See `docs/TODO.md` for remaining tasks
- Check `README.md` for full documentation
- View Terraform state: `cd terraform && terraform state list`
- View current variables: `cd terraform && terraform -var-file=terraform.tfvars plan`

## License

This IaC project is open source. Modify as needed for your environment.
