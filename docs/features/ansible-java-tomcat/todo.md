# Feature TODO: Terraform-Ansible Integration for Java/Tomcat Stack

## Metadata
- Feature: ansible-java-tomcat
- Branch: `feature/ansible-java-tomcat`
- Created: 2025-11-28
- Status: Complete

---

## Stage 1: Git Setup
**Goal:** Create isolated feature branch

- [x] Create branch `feature/ansible-java-tomcat`
- [x] Verify branch checkout

**Artifacts:** N/A (git state only)

**Status:** ✅ Complete

---

## Stage 2: Terraform Outputs
**Goal:** Export VM metadata for Ansible integration

- [x] Create `terraform/outputs.tf`
- [x] Define output: `vm_id`
- [x] Define output: `vm_name`
- [x] Define output: `vm_ip` (from QEMU agent)
- [x] Define output: `vm_user` (from cloud-init variable)
- [x] Define output: `vm_node`
- [x] Run `terraform fmt`

**Artifacts:**
- `terraform/outputs.tf`

**Status:** ✅ Complete

---

## Stage 3: Inventory Generator
**Goal:** Transform Terraform outputs to Ansible inventory

- [x] Create `scripts/generate_inventory.sh`
- [x] Implement terraform output parsing
- [x] Validate VM_IP is not empty or "pending"
- [x] Generate `[java_servers]` group
- [x] Add group variables:
  - [x] `java_version`
  - [x] `tomcat_version`
  - [x] `tomcat_user`
  - [x] `tomcat_group`
  - [x] `tomcat_install_dir`
  - [x] `tomcat_port`
- [x] Make script executable (`chmod +x`)
- [x] Add helpful output messages

**Artifacts:**
- `scripts/generate_inventory.sh`

**Status:** ✅ Complete

---

## Stage 4: Ansible Playbook
**Goal:** Install and configure Java 17 + Tomcat 10.1

### 4.1 Playbook Structure
- [x] Create `ansible/java_tomcat.yml`
- [x] Define hosts: `java_servers`
- [x] Set `become: true`
- [x] Define default variables

### 4.2 Java Installation Tasks
- [x] Install OpenJDK 17 (`java-17-openjdk`)
- [x] Install OpenJDK 17 devel (`java-17-openjdk-devel`)
- [x] Verify installation (`java -version`)
- [x] Display version output

### 4.3 Tomcat User Setup
- [x] Create `tomcat` group
- [x] Create `tomcat` user (system user, no shell)

### 4.4 Tomcat Installation Tasks
- [x] Create install directory (`/opt/tomcat`)
- [x] Download Tomcat 10.1.31 from Apache mirror
- [x] Extract archive with `--strip-components=1`
- [x] Set ownership recursively
- [x] Make bin scripts executable

### 4.5 Systemd Service
- [x] Create `ansible/templates/tomcat.service.j2`
- [x] Define service unit (Type=forking)
- [x] Configure environment variables (JAVA_HOME, CATALINA_*)
- [x] Set ExecStart/ExecStop
- [x] Configure restart behavior
- [x] Create task to deploy template
- [x] Add handler for systemd reload
- [x] Enable and start service

### 4.6 Firewall Configuration
- [x] Check if firewalld is running
- [x] Open port 8080 (conditional)

### 4.7 Healthcheck
- [x] Wait for Tomcat to respond on :8080
- [x] Display success message with URL

**Artifacts:**
- `ansible/java_tomcat.yml`
- `ansible/templates/tomcat.service.j2`

**Status:** ✅ Complete

---

## Stage 5: Justfile Updates
**Goal:** Add recipes for integrated workflow

- [x] Add `ansible-java` recipe
- [x] Add `generate-inventory` recipe
- [x] Add `deploy` recipe (full workflow with Java/Tomcat)
- [x] Add `deploy-post` recipe (full workflow with post-install)
- [x] Update help section with new commands

**Artifacts:**
- `Justfile` (modified)

**Status:** ✅ Complete

---

## Stage 6: Documentation
**Goal:** Update project documentation

### 6.1 KNOWLEDGE.md
- [x] Add OpenJDK 17 dependency
- [x] Add Apache Tomcat 10.1.31 dependency
- [x] Update deployment workflow section
- [x] Add quick deployment commands

### 6.2 Feature Documentation
- [x] Create `docs/features/ansible-java-tomcat/design.md`
- [x] Create `docs/features/ansible-java-tomcat/todo.md`

**Artifacts:**
- `KNOWLEDGE.md` (modified)
- `docs/features/ansible-java-tomcat/design.md`
- `docs/features/ansible-java-tomcat/todo.md`

**Status:** ✅ Complete

---

## Stage 7: Validation (Pending)
**Goal:** Verify implementation works end-to-end

- [ ] Run `just tf-init` (if not already done)
- [ ] Run `just tf-plan` — verify outputs are defined
- [ ] Run `just tf-apply` — create VM
- [ ] Run `just generate-inventory` — verify inventory generated
- [ ] Run `just ansible-java` — install Java/Tomcat
- [ ] Verify `curl http://<vm_ip>:8080` returns Tomcat page
- [ ] Verify `systemctl status tomcat` shows active
- [ ] Test idempotency: re-run `just ansible-java`

**Status:** ⏳ Pending (requires live Proxmox environment)

---

## Stage 8: Commit & Merge (Pending)
**Goal:** Finalize and merge to main

- [ ] Review all changes: `git diff`
- [ ] Stage changes: `git add .`
- [ ] Commit: `git commit -m "feat: add Terraform-Ansible integration for Java/Tomcat"`
- [ ] Push branch: `git push -u origin feature/ansible-java-tomcat`
- [ ] Create PR (if applicable)
- [ ] Merge to main

**Status:** ⏳ Pending

---

## Summary

| Stage | Status |
|-------|--------|
| 1. Git Setup | ✅ Complete |
| 2. Terraform Outputs | ✅ Complete |
| 3. Inventory Generator | ✅ Complete |
| 4. Ansible Playbook | ✅ Complete |
| 5. Justfile Updates | ✅ Complete |
| 6. Documentation | ✅ Complete |
| 7. Validation | ⏳ Pending |
| 8. Commit & Merge | ⏳ Pending |

**Overall Progress:** 6/8 stages complete (75%)

---

## Quick Reference

### New Files Created
```
terraform/outputs.tf
scripts/generate_inventory.sh
ansible/java_tomcat.yml
ansible/templates/tomcat.service.j2
docs/features/ansible-java-tomcat/design.md
docs/features/ansible-java-tomcat/todo.md
```

### Modified Files
```
Justfile
KNOWLEDGE.md
```

### Commands
```bash
# Full deployment
just deploy

# Step by step
just tf-apply
just generate-inventory
just ansible-java

# Verify
curl http://<vm_ip>:8080
```

