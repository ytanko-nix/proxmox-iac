# Proxmox VM Provisioning with Terraform and Ansible

This document outlines the steps to provision a Proxmox virtual machine and automatically install Java and Tomcat using Terraform and Ansible.

## Working Principle

The automation is orchestrated by Terraform, which manages the entire lifecycle of the virtual machine. Here's a step-by-step breakdown of what happens when you run `terraform apply`:

1.  **VM Creation**: Terraform communicates with the Proxmox API to clone the specified VM template, creating a new virtual machine with the defined hardware configuration (CPU, memory, disk).
2.  **Cloud-Init**: During the first boot, Cloud-Init runs inside the new VM. It configures the network, sets the hostname, and, most importantly, injects your SSH public key into the `authorized_keys` file for the specified user (`cloudinit_user`). This allows secure, passwordless access to the VM.
3.  **IP Address Retrieval**: Once the VM is running and the QEMU Guest Agent is active, Proxmox can determine the VM's IP address. Terraform retrieves this IP address and makes it available for the provisioners.
4.  **Provisioning Step 1 (Remote-Exec)**: Terraform establishes an SSH connection to the new VM using its IP address and the private SSH key you provided. It then runs a `remote-exec` provisioner which executes commands directly on the VM to:
    *   Update the package manager's cache (`apt-get update`).
    *   Install Python 3, which is a prerequisite for running Ansible modules on a target machine.
5.  **Provisioning Step 2 (Local-Exec)**: After the remote script successfully installs Python, Terraform runs the next provisioner, `local-exec`. This command is executed on your local machine (where you are running Terraform) and does the following:
    *   It calls `ansible-playbook`.
    *   It dynamically creates an in-memory inventory containing just the IP address of the new VM.
    *   It tells Ansible to use the same SSH private key to connect to the VM.
    *   It executes the `java_tomcat.yml` playbook, which handles the installation and configuration of OpenJDK and Apache Tomcat, sets up the `tomcat` user, and configures the firewall and `systemd` service.

By the time `terraform apply` finishes, you have a fully provisioned VM running a ready-to-use Tomcat web server.

## Local Setup

To run this setup locally, you need the following tools installed:

*   **Terraform**: For provisioning the Proxmox VM.
*   **Ansible**: For installing Java and Tomcat on the VM.
*   **SSH Client**: To connect to the VM (Terraform uses it for the `remote-exec` provisioner).

### 1. Clone the repository

```bash
git clone <your-repository-url>
cd proxmox-iac
```

### 2. Configure Terraform Variables

You need to provide your Proxmox API credentials and other VM configuration details. Create a `terraform.tfvars` file in the `terraform/` directory. You can use `terraform/terraform.tfvars.example` as a template.

**`terraform/terraform.tfvars` example:**

```terraform
pm_api_url          = "https://your-proxmox-host:8006/api2/json"
pm_api_token_id     = "your-api-token-id"
pm_api_token_secret = "your-api-token-secret"
target_node         = "your-proxmox-node-name"
vm_name             = "my-java-tomcat-vm"
template            = "your-cloud-init-template-name"
cloudinit_user      = "your-vm-user" # e.g., rocky, ubuntu
ssh_private_key_path = "~/.ssh/id_rsa" # Path to your SSH private key
```

**Important Notes:**
*   Replace placeholders like `your-proxmox-host`, `your-api-token-id`, etc., with your actual values.
*   Ensure the `ssh_private_key_path` points to the private key corresponding to the public key you inject into your cloud-init template or provide via `cloudinit_ssh_keys`. The user specified in `cloudinit_user` must be able to SSH into the VM using this key.

### 3. Initialize Terraform

Navigate to the `terraform/` directory and initialize Terraform.

```bash
cd terraform/
terraform init
```

### 4. Plan and Apply Terraform Configuration

Review the plan to see what Terraform will do, then apply the configuration to create the VM and run the Ansible playbook.

```bash
terraform plan
terraform apply
```

Confirm the apply operation by typing `yes` when prompted. Terraform will:
1.  Create the Proxmox VM.
2.  Use `remote-exec` to install Python 3 on the newly created VM via SSH.
3.  Use `local-exec` to run the `ansible/java_tomcat.yml` playbook on your local machine, connecting to the new VM via SSH using the provided private key.

## Server-Side Configuration (Proxmox Host & VM)

This section describes what needs to be configured on your Proxmox host and within your VM template.

### 1. Proxmox Host

*   **API Token**: Create a Proxmox API token with sufficient permissions (e.g., `VM.Allocate`, `VM.Audit`, `VM.Power` for VM creation and management).
*   **Network**: Ensure your Proxmox node has network connectivity and a bridge (e.g., `vmbr0`) for the VMs to connect to the network.
*   **Cloud-Init Template**: You need a Cloud-Init enabled VM template. This template should have:
    *   `qemu-guest-agent` installed and running.
    *   Cloud-Init configured to accept user data, including SSH public keys and username.
    *   A base operating system (e.g., Rocky Linux, Ubuntu Server) that supports `apt` or `dnf` package managers for Python installation.

### 2. VM Template (Cloud-Init Configuration)

Your Cloud-Init template should be prepared to allow SSH access for the Terraform provisioners.

*   **SSH Public Key**: Ensure the public SSH key corresponding to your `ssh_private_key_path` (specified in `terraform.tfvars`) is injected into the VM during its creation via Cloud-Init. This can be done by configuring the template to use a specific user (e.g., `rocky` or `ubuntu`) and adding the public key to that user's `authorized_keys`.
*   **QEMU Guest Agent**: Verify that `qemu-guest-agent` is installed and running inside your VM template. This is crucial for Terraform to reliably get the VM's IP address and execute `remote-exec` commands.
*   **Firewall**: If you have a firewall running on your VM template (e.g., `firewalld` or `ufw`), ensure that port 22 (SSH) is open for the `remote-exec` and Ansible connections. The Ansible playbook will attempt to open port 8080 for Tomcat if `firewalld` is active.

Once these steps are completed, running `terraform apply` will fully provision a VM with Java and Tomcat.
