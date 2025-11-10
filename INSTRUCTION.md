# Proxmox IaC Setup Instructions

## Overview
This document provides step-by-step instructions to prepare and run the existing Terraform infrastructure-as-code module for Proxmox virtualization.

## Prerequisites

### Required Software
- Terraform (>= 1.0)
- Ansible (>= 2.9)
- Git
- Just (optional, for running commands from Justfile)

### Required Data & API Keys

#### 1. Proxmox Connection Details
You need the following information for your Proxmox server:

```bash
# Required variables for terraform.tfvars
proxmox_api_url = "https://YOUR_PROXMOX_IP:8006/api2/json"
proxmox_api_token_id = "YOUR_TOKEN_ID"
proxmox_api_token_secret = "YOUR_TOKEN_SECRET"
proxmox_node = "YOUR_NODE_NAME"
```

**How to get these:**
- **API URL**: Use your Proxmox server IP address
- **Token ID & Secret**: Create in Proxmox web UI under Datacenter → Permissions → API Tokens
- **Node Name**: Check in Proxmox web UI under Datacenter → Nodes

#### 2. SSH Key Configuration
```bash
# Required for cloud-init VMs
ssh_public_key = "YOUR_SSH_PUBLIC_KEY"
```

**How to get this:**
- Run `cat ~/.ssh/id_rsa.pub` or `cat ~/.ssh/id_ed25519.pub`
- If you don't have SSH keys, generate with: `ssh-keygen -t ed25519 -C "your_email@example.com"`

#### 3. Network Configuration
```bash
# Required network settings
vm_gateway = "YOUR_GATEWAY_IP"
vm_dns = "YOUR_DNS_SERVER"
vm_network_cidr = "YOUR_NETWORK_CIDR"
```

**Examples:**
- Gateway: `192.168.1.1`
- DNS: `8.8.8.8` or `1.1.1.1`
- Network CIDR: `192.168.1.0/24`

#### 4. VM Configuration
```bash
# VM-specific settings
vm_id_range_start = 100
vm_name_prefix = "k8s-"
vm_memory = 4096
vm_cores = 2
vm_disk_size = "20G"
```

## Setup Steps

### Step 1: Clone Repository
```bash
git clone <repository-url>
cd proxmox-iac
```

### Step 2: Create Configuration Files

#### Create terraform.tfvars
Copy the example file and fill in your values:
```bash
cp terraform/terraform.tfvars.example terraform/terraform.tfvars
```

Edit `terraform/terraform.tfvars` with your specific values:
```hcl
# Proxmox connection
proxmox_api_url = "https://192.168.1.100:8006/api2/json"
proxmox_api_token_id = "root@pam!terraform"
proxmox_api_token_secret = "your-secret-token-here"
proxmox_node = "pve"

# SSH configuration
ssh_public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... your_email@example.com"

# Network configuration
vm_gateway = "192.168.1.1"
vm_dns = "8.8.8.8"
vm_network_cidr = "192.168.1.0/24"

# VM settings
vm_count = 3
vm_id_range_start = 100
vm_name_prefix = "k8s-"
vm_memory = 4096
vm_cores = 2
vm_disk_size = "20G"
```

#### Update Ansible Inventory
Edit `ansible/inventory.ini`:
```ini
[proxmox_vms]
192.168.1.101 ansible_user=ubuntu
192.168.1.102 ansible_user=ubuntu
192.168.1.103 ansible_user=ubuntu

[proxmox_vms:vars]
ansible_ssh_private_key_file=~/.ssh/id_ed25519
```

### Step 3: Initialize Terraform
```bash
cd terraform
terraform init
```

### Step 4: Plan and Apply Infrastructure
```bash
# See what will be created
terraform plan

# Apply the configuration
terraform apply
```

### Step 5: Configure VMs with Ansible
After VMs are created:
```bash
# Run post-install configuration
ansible-playbook -i ansible/inventory.ini ansible/post_install.yml
```

## Verification

### Check VM Status
In Proxmox web UI:
1. Navigate to your node
2. Check that VMs are running
3. Verify cloud-init has completed

### Test SSH Access
```bash
# Test connection to first VM
ssh ubuntu@192.168.1.101
```

### Verify Ansible Connectivity
```bash
# Test Ansible connection
ansible all -i ansible/inventory.ini -m ping
```

## Troubleshooting

### Common Issues

#### 1. API Token Issues
- **Error**: `401 Unauthorized`
- **Solution**: Verify token ID and secret in Proxmox UI under Datacenter → Permissions → API Tokens

#### 2. Network Connectivity
- **Error**: VMs can't reach internet
- **Solution**: Check gateway and DNS settings in terraform.tfvars

#### 3. SSH Key Issues
- **Error**: `Permission denied (publickey)`
- **Solution**: Ensure SSH public key is correctly added to terraform.tfvars

#### 4. VM ID Conflicts
- **Error**: `VM ID already exists`
- **Solution**: Change `vm_id_range_start` to higher number

### Debug Commands
```bash
# Check Terraform state
terraform show

# Check Proxmox API connectivity
curl -k -H "Authorization: PVEAPIToken=YOUR_TOKEN_ID=YOUR_TOKEN_SECRET" https://YOUR_PROXMOX_IP:8006/api2/json/nodes

# Check VM cloud-init status
qm cloud-init dump VM_ID
```

## Security Notes

- Store API tokens securely - never commit them to git
- Use least-privilege tokens in production
- Consider using a secrets management system for production deployments
- Rotate API tokens regularly

## Next Steps

After successful deployment:
1. Configure additional services on VMs
2. Set up monitoring and logging
3. Implement backup strategies
4. Consider using Terraform workspaces for different environments
