# Feature Design: Auto Provision Java + Tomcat

## Metadata
- Author: Agent
- Created: 2025-12-08
- Status: Draft
- Related issues/PRs: N/A

## Goals and Motivation
Problem: After creating a VM via Terraform, we need to automatically install Java and Tomcat, wait for the machine to be ready, and display a confirmation message to the user with machine information.

Proposed Solution: Use Terraform provisioners to:
1. Wait for VM readiness (SSH availability)
2. Run Ansible playbook to install Java 17 + Tomcat 10.1
3. Verify successful installation
4. Output message with VM name and IP address

Benefits:
- Fully automated deployment process
- Installation verification
- Informative output for the user

## Requirements

### Functional Requirements
- FR-1: After VM creation, automatically wait for its readiness (SSH availability)
- FR-2: Install Python3 (dependency for Ansible)
- FR-3: Run Ansible playbook to install Java 17 and Tomcat 10.1
- FR-4: Verify Java presence on the machine
- FR-5: Verify Tomcat presence on the machine
- FR-6: Output message: "Java and Tomcat installed on [name] ([IP])"

### Non-Functional Requirements
- Performance: Installation should complete within 10 minutes
- Security: SSH keys should not appear in logs
- Reliability: Clear error message on installation failure
- Maintainability: Java/Tomcat versions should be configurable

## Assumptions and Constraints

Assumptions:
- VM template has Cloud-Init and supports SSH
- Network is configured (DHCP or static IP)
- SSH private key is available locally

Constraints:
- Terraform provisioners only execute on resource creation
- Ansible requires Python on the target machine

Out of Scope:
- Application configuration inside Tomcat
- SSL/TLS setup for Tomcat

## Architecture and Design

### Components

Component 1: Terraform Provisioners
- Purpose: Orchestrate post-deployment automation
- Responsibilities: Wait for VM, run Ansible
- Interactions: SSH to VM, invoke ansible-playbook

Component 2: Ansible Playbook (java_tomcat.yml)
- Purpose: Install and configure Java + Tomcat
- Responsibilities: Package installation, systemd setup, firewall
- Interactions: SSH to VM, dnf/apt

Component 3: Verification & Output
- Purpose: Verify success and inform the user
- Responsibilities: Check java -version, curl Tomcat, output message
- Interactions: SSH to VM, stdout

### Dependencies

| Dependency | Version | Usage Spec | Purpose |
|------------|--------:|-----------:|---------|
| Terraform CLI | ≥ 1.3.0 | — | Infrastructure provisioning |
| bpg/proxmox | ~> 0.87.0 | — | Proxmox provider |
| Ansible Core | 2.19.1 | `.tessl/usage-specs/tessl/pypi-ansible-core/` | Post-configuration |

### Flow Diagram

```
Terraform Apply
    ↓
proxmox_virtual_environment_vm created
    ↓
remote-exec provisioner:
    - Wait for SSH
    - Install Python3
    ↓
local-exec provisioner:
    - Run ansible-playbook java_tomcat.yml
        ↓
    Ansible tasks:
        - Install Java 17
        - Install Tomcat 10.1
        - Configure systemd
        - Health check (curl localhost:8080)
        ↓
    Verification:
        - java -version
        - systemctl status tomcat
        ↓
    Output message:
        "Java и Tomcat установлены на [name] ([IP])"
```

## Implementation Stages

### Stage 1: Verify and Fix Current Implementation
Description: Verify current provisioners functionality

Tasks:
- Check provisioners syntax in main.tf
- Verify paths and variables correctness
- Ensure ipv4_addresses is accessed correctly

Exit Criteria:
- [ ] terraform validate passes successfully
- [ ] Provisioners use correct resource attributes

### Stage 2: Add Verification and Output
Description: Add installation verification and output message

Tasks:
- Add java -version verification after Ansible
- Add Tomcat verification (curl or systemctl)
- Add final output with VM name and IP

Exit Criteria:
- [ ] Java verified on target machine
- [ ] Tomcat verified on target machine
- [ ] Message with name and IP is displayed

### Stage 3: Documentation
Description: Update documentation

Tasks:
- Update .tessl/project/spec.md
- Create todo.md for the feature
- Update README if needed

Exit Criteria:
- [ ] Documentation is up to date
- [ ] Feature is documented in spec.md

## Acceptance Criteria
- [ ] AC-1: VM is created via terraform apply
- [ ] AC-2: Java 17 is automatically installed
- [ ] AC-3: Tomcat 10.1 is automatically installed
- [ ] AC-4: Installation is verified (java -version, Tomcat health)
- [ ] AC-5: Message "Java and Tomcat installed on [name] ([IP])" is displayed

## Testing

Test Scenario 1: Full Deployment
- Preconditions: Template существует, SSH ключи настроены
- Steps:
  1. terraform apply
  2. Дождаться завершения
- Expected: VM создана, Java+Tomcat установлены, сообщение выведено

Verification Commands:
```bash
# На VM
java -version
systemctl status tomcat
curl http://localhost:8080

# Локально
terraform output vm_ip
terraform output vm_name
```

## References
- Project Spec: `.tessl/project/spec.md`
- Ansible Playbook: `ansible/java_tomcat.yml`
- Terraform Main: `terraform/main.tf`
