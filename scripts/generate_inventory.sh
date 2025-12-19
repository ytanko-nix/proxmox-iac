#!/bin/bash
# Generate Ansible inventory from Terraform outputs
# Usage: ./scripts/generate_inventory.sh

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
TERRAFORM_DIR="$PROJECT_ROOT/terraform"
ANSIBLE_DIR="$PROJECT_ROOT/ansible"
INVENTORY_FILE="$ANSIBLE_DIR/inventory.ini"

# Configuration (can be overridden via environment)
JAVA_VERSION="${JAVA_VERSION:-17}"
TOMCAT_VERSION="${TOMCAT_VERSION:-10.1.31}"

echo "Generating Ansible inventory from Terraform outputs..."

# Change to terraform directory
cd "$TERRAFORM_DIR"

# Check if terraform state exists
if [[ ! -f "terraform.tfstate" ]]; then
    echo "Error: terraform.tfstate not found. Run 'just tf-apply' first."
    exit 1
fi

# Get outputs from Terraform
VM_NAME=$(terraform output -raw vm_name 2>/dev/null || echo "")
VM_IP=$(terraform output -raw vm_ip 2>/dev/null || echo "")
VM_USER=$(terraform output -raw vm_user 2>/dev/null || echo "")
VM_OS_FAMILY=$(terraform output -raw vm_os_family 2>/dev/null || echo "")
VM_TEMPLATE=$(terraform output -raw vm_template 2>/dev/null || echo "")

if [[ "$VM_OS_FAMILY" == "windows" ]]; then
    echo "Error: The created VM is Windows (vm_os_family=windows)."
    echo "This script generates an SSH-based Ansible inventory for Linux VMs and is not applicable to Windows."
    echo ""
    echo "VM Details:"
    echo "  Name:     ${VM_NAME:-<empty>}"
    echo "  IP:       ${VM_IP:-<empty>}"
    echo "  Template: ${VM_TEMPLATE:-<empty>}"
    echo ""
    echo "Hint: For Windows automation, consider using WinRM and an Ansible Windows inventory/group instead."
    exit 1
fi

# Validate outputs
if [[ -z "$VM_NAME" || -z "$VM_IP" || -z "$VM_USER" ]]; then
    echo "Error: Could not get VM details from Terraform outputs."
    echo "  VM_NAME: ${VM_NAME:-<empty>}"
    echo "  VM_IP: ${VM_IP:-<empty>}"
    echo "  VM_USER: ${VM_USER:-<empty>}"
    echo "  VM_OS_FAMILY: ${VM_OS_FAMILY:-<empty>}"
    exit 1
fi

if [[ "$VM_IP" == "pending" ]]; then
    echo "Error: VM IP is still pending. Wait for QEMU agent to report the IP."
    echo "You can check with: cd terraform && terraform output vm_ip"
    exit 1
fi

# Generate inventory file
cat > "$INVENTORY_FILE" << EOF
# Auto-generated Ansible inventory
# Generated: $(date -Iseconds)
# Source: Terraform outputs

[java_servers]
${VM_NAME} ansible_host=${VM_IP} ansible_user=${VM_USER}

[java_servers:vars]
ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'
java_version=${JAVA_VERSION}
tomcat_version=${TOMCAT_VERSION}
tomcat_user=tomcat
tomcat_group=tomcat
tomcat_install_dir=/opt/tomcat
tomcat_port=8080

[proxmox_vms:children]
java_servers
EOF

echo "Inventory generated: $INVENTORY_FILE"
echo ""
echo "VM Details:"
echo "  Name: $VM_NAME"
echo "  IP:   $VM_IP"
echo "  User: $VM_USER"
echo ""
echo "Java/Tomcat Configuration:"
echo "  Java Version:   $JAVA_VERSION"
echo "  Tomcat Version: $TOMCAT_VERSION"
echo ""
echo "Next step: just ansible-java"

