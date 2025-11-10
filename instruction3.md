# Pre-Deployment Data Preparation Guide

This document outlines all the data, credentials, and information you need to gather **before** running the Terraform module to provision VMs on Proxmox.

## Required Data Checklist

### ✅ 1. Proxmox API Credentials

You need **one of the following** authentication methods:

#### Option A: API Token (Recommended)
- **`pm_api_token_id`**: Format `user@realm!token-name`
  - Example: `terraform@pam!iac`
  - Where to get: Proxmox Web UI → Datacenter → Permissions → API Tokens → Create Token
- **`pm_api_token_secret`**: The secret key generated when creating the token
  - ⚠️ **Keep this secret** - never commit to git
  - Copy immediately when created (cannot be retrieved later)

#### Option B: Username/Password (Alternative)
- **`pm_user`**: Proxmox username with realm
  - Example: `root@pam` or `admin@pam`
- **`pm_password`**: Password for the user
  - ⚠️ Less secure than API tokens

**Required:**
- **`pm_api_url`**: Proxmox API endpoint URL
  - Format: `https://YOUR_PROXMOX_HOST:8006/api2/json`
  - Example: `https://192.168.1.100:8006/api2/json` or `https://proxmox.example.com:8006/api2/json`
- **`pm_tls_insecure`**: Set to `true` if using self-signed certificates, `false` for valid certificates

**How to get API Token:**
1. Log into Proxmox Web UI
2. Navigate to: **Datacenter** → **Permissions** → **API Tokens**
3. Click **Add** → **API Token**
4. Configure:
   - **User**: Select user (e.g., `root@pam` or create dedicated user)
   - **Token ID**: Enter name (e.g., `terraform` or `iac`)
   - **Privilege Separation**: Enable if you want separate permissions
   - **Expiration**: Set expiration date (optional)
5. Click **Generate** and **copy the secret immediately** (you won't see it again)

---

### ✅ 2. Proxmox Infrastructure Information

- **`target_node`**: Name of the Proxmox node where VMs will be created
  - Example: `node1`, `pve`, `proxmox-node-01`
  - Where to find: Proxmox Web UI → Datacenter → Nodes (left sidebar)
  - Or run: `pvesh get /nodes` on Proxmox host

- **`template`**: Name of the Cloud-Init template VM to clone from
  - Example: `rocky9-cloudinit-template`, `ubuntu-22.04-cloudinit`, `debian-12-cloudinit`
  - ⚠️ **Must exist** in Proxmox before running Terraform
  - Where to find: Proxmox Web UI → Your Node → VMs → Look for template VMs
  - Template must have Cloud-Init enabled

- **`disk_storage`**: Proxmox storage pool name for VM disks
  - Example: `local-lvm`, `local`, `storage-pool-1`
  - Where to find: Proxmox Web UI → Datacenter → Storage
  - Or run: `pvesh get /storage` on Proxmox host

---

### ✅ 3. VM Configuration Details

- **`vm_name`**: Name for the VM in Proxmox
  - Example: `my-vm`, `app-server`, `k8s-worker-01`
  - Must be unique on the target node
  - Used as VM identifier in Proxmox

- **`vm_hostname`**: (Optional) Hostname for the VM
  - If not set, defaults to `vm_name`
  - Example: `my-hostname.local`, `app-server.example.com`
  - Used by Cloud-Init to set the system hostname

- **`cpu_sockets`**: Number of CPU sockets
  - Default: `1`
  - Example: `1`, `2`

- **`cpu_cores_per_socket`**: Number of CPU cores per socket
  - Default: `2`
  - Total CPUs = `cpu_sockets × cpu_cores_per_socket`
  - Example: `2` (with 1 socket = 2 total CPUs)

- **`memory_mb`**: RAM in megabytes
  - Default: `2048` (2 GB)
  - Example: `4096` (4 GB), `8192` (8 GB)

- **`disk_gb`**: Primary disk size in gigabytes
  - Default: `20`
  - Example: `50`, `100`, `200`

- **`qemu_agent`**: Enable QEMU Guest Agent (recommended)
  - Default: `true`
  - Requires QEMU Guest Agent installed in template

- **`tags`**: (Optional) Comma-separated tags for VM organization
  - Example: `"production,web-server"` or `""` (empty)

---

### ✅ 4. Network Configuration

- **`network_bridge`**: Virtual bridge to attach VM network interface
  - Default: `vmbr0`
  - Example: `vmbr0`, `vmbr1`
  - Where to find: Proxmox Web UI → Datacenter → Network
  - Or run: `cat /etc/network/interfaces` on Proxmox host

- **`network_model`**: Network interface model
  - Default: `virtio` (recommended for Linux)
  - Options: `virtio`, `e1000`, `rtl8139`

- **`ip_config`**: IP configuration for Cloud-Init
  - **DHCP** (default): `ip=dhcp`
  - **Static IP**: `ip=192.168.1.100/24,gw=192.168.1.1`
  - Format: `ip=IP_ADDRESS/CIDR,gw=GATEWAY`
  - Example: `ip=192.168.1.50/24,gw=192.168.1.1`

---

### ✅ 5. SSH Key Configuration

You need **one of the following**:

#### Option A: SSH Public Key File Path
- **`ssh_public_key_path`**: Path to your SSH public key file
  - Example: `~/.ssh/id_ed25519.pub`, `~/.ssh/id_rsa.pub`
  - Default: `""` (empty, uses cloudinit_ssh_keys instead)

#### Option B: SSH Public Key Content (Alternative)
- **`cloudinit_ssh_keys`**: List of SSH public key strings
  - Example: `["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI... user@host"]`
  - Default: `[]` (empty)

**How to get SSH public key:**
```bash
# Check if you have existing SSH keys
ls -la ~/.ssh/

# If you have id_ed25519.pub or id_rsa.pub, display it:
cat ~/.ssh/id_ed25519.pub

# If you don't have SSH keys, generate them:
ssh-keygen -t ed25519 -C "your_email@example.com"
# Or:
ssh-keygen -t rsa -b 4096 -C "your_email@example.com"
```

---

### ✅ 6. Cloud-Init Configuration

- **`cloudinit_user`**: Default user created by Cloud-Init
  - Default: `rocky` (for Rocky Linux templates)
  - Examples: `rocky`, `ubuntu`, `debian`, `admin`
  - Must match the user configured in your Cloud-Init template

- **`cloudinit_packages`**: List of packages to install via Cloud-Init
  - Default: `["curl", "htop", "git"]`
  - Example: `["curl", "htop", "git", "vim", "wget"]`
  - Packages must be available in the template's package repositories

---

## Quick Reference: terraform.tfvars Template

⚠️ **Security Note**: The example below shows the structure, but **DO NOT** store secrets in `terraform.tfvars` files that might be committed. Use environment variables or separate secrets files instead.

Here's a complete example with all required fields (for reference only):

```hcl
# ============================================
# PROXMOX API CREDENTIALS (Required)
# ============================================
pm_api_url          = "https://192.168.1.100:8006/api2/json"  # ⚠️ CHANGE THIS
pm_api_token_id     = "terraform@pam!iac"                      # ⚠️ CHANGE THIS
pm_api_token_secret = "YOUR_SECRET_TOKEN_HERE"                 # ⚠️ CHANGE THIS
pm_tls_insecure     = true  # Set to false if using valid SSL certificate

# Alternative: Use username/password instead of token
# pm_user     = "root@pam"
# pm_password = "your-password"

# ============================================
# PROXMOX INFRASTRUCTURE (Required)
# ============================================
target_node  = "node1"                              # ⚠️ CHANGE THIS
template     = "rocky9-cloudinit-template"          # ⚠️ CHANGE THIS (must exist)
disk_storage = "local-lvm"                          # ⚠️ CHANGE THIS

# ============================================
# VM CONFIGURATION (Required)
# ============================================
vm_name      = "my-vm"                              # ⚠️ CHANGE THIS
vm_hostname  = null                                 # Optional: defaults to vm_name

# Resources
cpu_sockets          = 1
cpu_cores_per_socket = 2
memory_mb           = 2048  # 2 GB
disk_gb             = 20
qemu_agent          = true
tags                = ""    # Optional: "production,web-server"

# ============================================
# NETWORK CONFIGURATION (Required)
# ============================================
network_model  = "virtio"
network_bridge = "vmbr0"                           # ⚠️ VERIFY THIS
ip_config      = "ip=dhcp"                         # Or: "ip=192.168.1.100/24,gw=192.168.1.1"

# ============================================
# SSH & CLOUD-INIT (Required)
# ============================================
cloudinit_user      = "rocky"                      # ⚠️ CHANGE THIS (match template)
ssh_public_key_path = "~/.ssh/id_ed25519.pub"      # ⚠️ CHANGE THIS (or use cloudinit_ssh_keys)
# cloudinit_ssh_keys = ["ssh-ed25519 AAAA..."]     # Alternative to ssh_public_key_path
cloudinit_packages  = ["curl", "htop", "git"]
```

---

## Pre-Flight Checklist

Before running `terraform apply`, verify you have:

- [ ] **Proxmox API URL** (`pm_api_url`)
- [ ] **Proxmox API Token ID** (`pm_api_token_id`) OR Username (`pm_user`)
- [ ] **Proxmox API Token Secret** (`pm_api_token_secret`) OR Password (`pm_password`)
- [ ] **Proxmox Node Name** (`target_node`) - verified it exists
- [ ] **Cloud-Init Template Name** (`template`) - verified it exists in Proxmox
- [ ] **Storage Pool Name** (`disk_storage`) - verified it exists
- [ ] **VM Name** (`vm_name`) - unique, not already in use
- [ ] **Network Bridge** (`network_bridge`) - verified it exists
- [ ] **SSH Public Key** - either file path or content
- [ ] **Cloud-Init User** (`cloudinit_user`) - matches template configuration
- [ ] Created `terraform/terraform.tfvars` file with all values filled in
- [ ] Verified API token has sufficient permissions (VM creation, storage access)

---

## How to Verify Your Data

### Test Proxmox API Connection

```bash
# Using API token
curl -k -H "Authorization: PVEAPIToken=YOUR_TOKEN_ID=YOUR_TOKEN_SECRET" \
  https://YOUR_PROXMOX_HOST:8006/api2/json/version

# Using username/password
curl -k -u "root@pam:your-password" \
  https://YOUR_PROXMOX_HOST:8006/api2/json/version
```

Expected response: JSON with Proxmox version information

### List Available Nodes

```bash
curl -k -H "Authorization: PVEAPIToken=YOUR_TOKEN_ID=YOUR_TOKEN_SECRET" \
  https://YOUR_PROXMOX_HOST:8006/api2/json/nodes
```

### List Available Templates

```bash
# SSH into Proxmox host
ssh root@YOUR_PROXMOX_HOST

# List all VMs (templates usually have "template" in name)
qm list | grep template
```

### List Available Storage

```bash
curl -k -H "Authorization: PVEAPIToken=YOUR_TOKEN_ID=YOUR_TOKEN_SECRET" \
  https://YOUR_PROXMOX_HOST:8006/api2/json/storage
```

### Verify Network Bridges

```bash
# SSH into Proxmox host
ssh root@YOUR_PROXMOX_HOST

# List network bridges
cat /etc/network/interfaces | grep -A 5 "vmbr"
```

---

## Security Best Practices

### 🔐 Secret Management Methods (Ranked by Security)

#### ⭐ Method 1: Environment Variables (Recommended for Local Development)

**Best for:** Local development, CI/CD pipelines, single-user setups

Set environment variables before running Terraform:

```bash
# Set environment variables (Terraform automatically reads TF_VAR_* prefix)
export TF_VAR_pm_api_url="https://your-proxmox-host:8006/api2/json"
export TF_VAR_pm_api_token_id="terraform@pam!iac"
export TF_VAR_pm_api_token_secret="your-secret-token"
export TF_VAR_target_node="node1"
export TF_VAR_vm_name="my-vm"
export TF_VAR_template="rocky9-cloudinit-template"

# Then run Terraform (no need for terraform.tfvars)
terraform plan
terraform apply
```

**Pros:**
- Secrets never stored in files
- Easy to use in CI/CD
- No risk of committing to git
- Works with all Terraform versions

**Cons:**
- Must set for each shell session
- Can be visible in process lists
- Not ideal for team collaboration

**Security Note:** Use a `.env` file with your shell (e.g., `source .env`) but **never commit `.env` files**.

---

#### ⭐⭐ Method 2: Separate Secrets File (Good for Teams)

**Best for:** Team environments, when you need version control for non-sensitive config

Create two files:

1. **`terraform.tfvars`** (non-sensitive config - can be committed):
```hcl
# Non-sensitive configuration
target_node  = "node1"
vm_name      = "my-vm"
template     = "rocky9-cloudinit-template"
cpu_sockets  = 1
memory_mb    = 2048
disk_gb      = 20
```

2. **`terraform.tfvars.secrets`** (sensitive - NEVER commit):
```hcl
# Sensitive credentials - DO NOT COMMIT
pm_api_url          = "https://your-proxmox-host:8006/api2/json"
pm_api_token_id     = "terraform@pam!iac"
pm_api_token_secret = "your-secret-token"
```

**Usage:**
```bash
# Apply with both files
terraform apply -var-file=terraform.tfvars -var-file=terraform.tfvars.secrets
```

**Add to `.gitignore`:**
```
terraform/terraform.tfvars.secrets
terraform/*.secrets
terraform/*.secret
```

**Pros:**
- Separates sensitive from non-sensitive config
- Can version control non-sensitive parts
- Clear separation of concerns

**Cons:**
- Still stores secrets in files
- Requires careful `.gitignore` management

---

#### ⭐⭐⭐ Method 3: Secret Management Systems (Best for Production)

**Best for:** Production environments, large teams, compliance requirements

**Options:**
- **HashiCorp Vault**: `vault read -field=secret proxmox/terraform`
- **AWS Secrets Manager**: Use `aws_secretsmanager_secret_version` data source
- **Azure Key Vault**: Use `azurerm_key_vault_secret` data source
- **Terraform Cloud/Enterprise**: Built-in variable management

**Example with HashiCorp Vault:**
```hcl
# terraform/secrets.tf
data "vault_generic_secret" "proxmox" {
  path = "secret/proxmox/terraform"
}

# Use in provider configuration
provider "proxmox" {
  pm_api_url          = data.vault_generic_secret.proxmox.data["api_url"]
  pm_api_token_id     = data.vault_generic_secret.proxmox.data["token_id"]
  pm_api_token_secret = data.vault_generic_secret.proxmox.data["token_secret"]
}
```

**Pros:**
- Centralized secret management
- Encryption at rest
- Access control and audit logs
- Automatic rotation support
- Compliance-ready

**Cons:**
- Requires additional infrastructure
- More complex setup
- Learning curve

---

#### ⚠️ Method 4: terraform.tfvars (NOT Recommended - Use Only for Testing)

**Only acceptable for:** Local testing, disposable environments

**Critical Requirements:**
- ✅ **MUST** be in `.gitignore`
- ✅ **NEVER** commit to version control
- ✅ Use only for non-production environments
- ✅ Delete after testing

```hcl
# terraform/terraform.tfvars - ONLY FOR TESTING
pm_api_url          = "https://test-proxmox:8006/api2/json"
pm_api_token_id     = "terraform@pam!test"
pm_api_token_secret = "test-token-only"
```

---

### 🔒 Additional Security Practices

1. **Never commit secrets to git**
   - ✅ Add `terraform/terraform.tfvars` to `.gitignore` (if using Method 4)
   - ✅ Add `terraform/*.secrets` to `.gitignore` (if using Method 2)
   - ✅ Use `.gitignore` patterns: `*.tfvars`, `*.secret`, `.env`
   - ✅ Verify with: `git status` before committing

2. **Use API tokens instead of passwords**
   - More secure and revocable
   - Can set expiration dates
   - Better audit trail
   - No password reuse risk

3. **Use least-privilege tokens**
   - Create dedicated user for Terraform (e.g., `terraform@pam`)
   - Grant only necessary permissions:
     - VM creation/modification
     - Storage access
     - Network configuration
   - **Do NOT** grant: User management, Datacenter admin, etc.

4. **Secure Terraform State Files**
   - ⚠️ **State files contain sensitive data** (API tokens, IPs, etc.)
   - Use remote backend with encryption:
     ```hcl
     terraform {
       backend "s3" {
         bucket         = "my-terraform-state"
         key            = "proxmox/terraform.tfstate"
         region         = "us-east-1"
         encrypt        = true
         dynamodb_table = "terraform-locks"
       }
     }
     ```
   - Enable state file encryption
   - Restrict access with IAM/policies
   - **Never commit** `.tfstate` files to git

5. **Rotate credentials regularly**
   - Set token expiration dates (30-90 days)
   - Rotate secrets periodically (quarterly minimum)
   - Document rotation procedures
   - Test rotation process before expiration

6. **Use valid SSL certificates**
   - Set `pm_tls_insecure = false` in production
   - Avoid self-signed certificates
   - Use proper CA-signed certificates
   - Consider internal CA for private networks

7. **Mark sensitive variables**
   - ✅ Already done: `pm_password` and `pm_api_token_secret` marked `sensitive = true`
   - Terraform will hide these values in output
   - Consider marking `pm_api_token_id` as sensitive too (contains user info)

8. **Use separate workspaces/environments**
   - Different credentials for dev/staging/prod
   - Prevents accidental cross-environment changes
   - Easier credential rotation

9. **Monitor and audit**
   - Enable Proxmox audit logs
   - Monitor API token usage
   - Set up alerts for unusual activity
   - Regular security reviews

10. **Use dynamic credentials when possible**
    - Short-lived tokens (if supported)
    - OAuth2/OpenID Connect (if available)
    - Avoid long-lived static credentials

---

## Common Mistakes to Avoid

### Configuration Mistakes
1. ❌ **Wrong template name** - Template must exist and have Cloud-Init enabled
2. ❌ **Wrong node name** - Node name is case-sensitive
3. ❌ **Missing SSH key** - VM will be created but you won't be able to SSH in
4. ❌ **Wrong storage name** - Storage pool must exist and have available space
5. ❌ **Invalid IP configuration** - Check gateway and subnet match your network
6. ❌ **API token format** - Must be `user@realm!token-name` format
7. ❌ **VM name conflicts** - VM name must be unique on the node

### Security Mistakes (CRITICAL)
1. ❌ **Committing secrets to git** - `terraform.tfvars` with secrets committed
   - ✅ **Fix**: Add to `.gitignore`, use environment variables or secret managers
   - ✅ **Verify**: Run `git check-ignore terraform/terraform.tfvars` before committing

2. ❌ **Storing secrets in plain text files** - Without proper protection
   - ✅ **Fix**: Use environment variables, encrypted files, or secret managers
   - ✅ **Fix**: Set file permissions: `chmod 600 terraform.tfvars.secrets`

3. ❌ **Using root@pam credentials** - Too powerful, no audit trail
   - ✅ **Fix**: Create dedicated `terraform@pam` user with minimal permissions

4. ❌ **Sharing credentials via email/chat** - Insecure transmission
   - ✅ **Fix**: Use secure secret sharing tools (1Password, Bitwarden, Vault)

5. ❌ **No credential rotation** - Using same tokens for months/years
   - ✅ **Fix**: Set expiration dates, rotate quarterly

6. ❌ **Committing state files** - State files contain sensitive data
   - ✅ **Fix**: Add `*.tfstate*` to `.gitignore`, use remote backend

7. ❌ **Using `pm_tls_insecure = true` in production** - Man-in-the-middle risk
   - ✅ **Fix**: Use valid SSL certificates, set to `false` in production

8. ❌ **Overly permissive API tokens** - Granting unnecessary permissions
   - ✅ **Fix**: Follow principle of least privilege, grant only what's needed

---

## Next Steps

### Recommended Approach: Using Environment Variables

1. **Set environment variables** (most secure):
   ```bash
   export TF_VAR_pm_api_url="https://your-proxmox-host:8006/api2/json"
   export TF_VAR_pm_api_token_id="terraform@pam!iac"
   export TF_VAR_pm_api_token_secret="your-secret-token"
   export TF_VAR_target_node="node1"
   export TF_VAR_vm_name="my-vm"
   export TF_VAR_template="rocky9-cloudinit-template"
   # ... set other required variables
   ```

2. **Initialize Terraform**: `just tf-init` or `cd terraform && terraform init`

3. **Validate configuration**: `just tf-validate` or `cd terraform && terraform validate`

4. **Review plan**: `just tf-plan` or `cd terraform && terraform plan`

5. **Apply**: `just tf-apply` or `cd terraform && terraform apply`

### Alternative: Using terraform.tfvars (Testing Only)

⚠️ **Only for local testing - NOT for production!**

1. **Copy example file**: `cp terraform/terraform.tfvars.example terraform/terraform.tfvars`

2. **Verify `.gitignore`** includes `terraform/terraform.tfvars`:
   ```bash
   git check-ignore terraform/terraform.tfvars
   # Should output: terraform/terraform.tfvars
   ```

3. **Edit `terraform/terraform.tfvars`** with your values

4. **Set secure file permissions**:
   ```bash
   chmod 600 terraform/terraform.tfvars
   ```

5. **Initialize and apply** as above

### Before First Commit

**CRITICAL**: Verify no secrets will be committed:

```bash
# Check what files are tracked/untracked
git status

# Verify sensitive files are ignored
git check-ignore terraform/terraform.tfvars terraform/*.secrets terraform/*.tfstate

# Review what will be committed
git diff --cached

# If using terraform.tfvars, double-check it's not staged
git status terraform/terraform.tfvars
```

For detailed deployment instructions, see `QUICKSTART.md`.

