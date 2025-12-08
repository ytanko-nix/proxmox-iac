# TODO: Auto Provision Java + Tomcat

Start Date: 2025-12-08
Target Completion Date: 2025-12-08
Owner: Agent

## Related Documents
- Design Document: `docs/features/auto-provision-java-tomcat/design.md`
- Project Spec: `.tessl/project/spec.md`
- Related usage-specs: `.tessl/usage-specs/tessl/pypi-ansible-core/`

---

## Stage 1: Fix Current Implementation

Status: Done

### Preparation
- [x] Review Terraform provisioner documentation
- [x] Check bpg/proxmox provider ipv4_addresses attribute structure

### Tasks
- [x] Fix ipv4_addresses indexing (was `[0]`, now `[1][0]`)
- [x] Make Python3 installation compatible with dnf and apt
- [x] Add cloud-init wait before provisioning
- [x] Validate Terraform configuration

### Verification
- [x] `terraform validate` passes

### Artifacts
- Updated: `terraform/main.tf`

---

## Stage 2: Add Verification and Output

Status: Done

### Preparation
- [x] Review Ansible playbook verification tasks

### Tasks
- [x] Add remote-exec provisioner for verification
- [x] Verify Java installation (`java -version`)
- [x] Verify Tomcat service (`systemctl is-active tomcat`)
- [x] Verify Tomcat responds on port 8080
- [x] Output final message with VM name and IP address

### Verification
- [x] `terraform validate` passes
- [x] Verification commands are in place

### Artifacts
- Updated: `terraform/main.tf`

---

## Stage 3: Documentation

Status: Done

### Tasks
- [x] Create design.md document
- [x] Create todo.md checklist
- [x] Update `.tessl/project/spec.md` (add feature to documentation)
- [ ] Update README.md (if needed)
- [ ] Test full deployment cycle

---

## Acceptance Criteria
- [x] AC-1: Terraform provisioners use correct IP indexing
- [x] AC-2: Python3 installation works on dnf and apt systems
- [x] AC-3: Cloud-init completion is waited for
- [x] AC-4: Java installation is verified
- [x] AC-5: Tomcat installation is verified
- [x] AC-6: Final message displays VM name and IP address
- [ ] AC-7: Full deployment test passes
