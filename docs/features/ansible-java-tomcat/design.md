# Feature Design: Terraform-Ansible Integration for Java/Tomcat Stack

## Metadata
- Author: Tessl Agent
- Created: 2025-11-28
- Status: Implemented
- Branch: `feature/ansible-java-tomcat`
- Related issues/PRs: N/A

## Goals and Motivation

**Problem:** After creating a VM with Terraform, there's no automated way to configure it with application software. Users must manually update Ansible inventory and run playbooks separately.

**Proposed Solution:** Integrate Terraform outputs with Ansible inventory generation, enabling automated end-to-end deployment of Java/Tomcat application servers.

**Benefits:**
- Single command deployment (`just deploy`)
- No manual inventory management
- Consistent, repeatable Java/Tomcat installations
- Clear separation between provisioning (Terraform) and configuration (Ansible)

## Requirements

### Functional Requirements
- FR-1: Terraform must export VM IP, name, and SSH user as outputs
- FR-2: A script must generate Ansible inventory from Terraform outputs
- FR-3: Ansible playbook must install OpenJDK 17
- FR-4: Ansible playbook must install and configure Apache Tomcat 10.1
- FR-5: Tomcat must run as a systemd service
- FR-6: Justfile must provide unified deployment workflow

### Non-Functional Requirements
- **Performance:** Deployment should complete within 10 minutes (excluding VM creation time)
- **Security:** Tomcat runs as unprivileged user; firewall opens only port 8080
- **Reliability:** Ansible playbook is idempotent; can be re-run safely
- **Maintainability:** Version numbers are configurable via environment variables

## Assumptions and Constraints

**Assumptions:**
- Target OS is Rocky Linux (uses DNF package manager)
- VM has internet access to download Tomcat
- QEMU guest agent reports IP address after boot
- SSH key-based authentication is configured via cloud-init

**Constraints:**
- IP discovery requires QEMU agent (30 second delay after VM creation)
- Tomcat download depends on Apache mirror availability

**Out of Scope:**
- Tomcat application deployment (WAR files)
- SSL/TLS configuration for Tomcat
- Tomcat Manager GUI setup
- Load balancer configuration

## Architecture and Design

### Components

**Component 1: Terraform Outputs (`terraform/outputs.tf`)**
- Purpose: Export VM metadata for Ansible consumption
- Responsibilities: Provide vm_ip, vm_name, vm_user, vm_id, vm_node
- Interactions: Read by generate_inventory.sh

**Component 2: Inventory Generator (`scripts/generate_inventory.sh`)**
- Purpose: Transform Terraform outputs to Ansible inventory
- Responsibilities: Query terraform output, validate values, write inventory.ini
- Interactions: Reads from Terraform state, writes to ansible/inventory.ini

**Component 3: Java/Tomcat Playbook (`ansible/java_tomcat.yml`)**
- Purpose: Install and configure Java 17 + Tomcat 10.1
- Responsibilities: Package installation, user creation, systemd service, firewall
- Interactions: Uses generated inventory, templates systemd service

**Component 4: Systemd Template (`ansible/templates/tomcat.service.j2`)**
- Purpose: Define Tomcat as a managed systemd service
- Responsibilities: Service lifecycle, JVM configuration, user context
- Interactions: Rendered by Ansible, managed by systemd

### Dependencies

| Dependency | Version | Usage Spec | Purpose |
|------------|--------:|-----------|---------|
| Terraform CLI | ≥ 1.3.0 | (planned) | Infrastructure provisioning |
| Ansible Core | 2.19.1 | `.tessl/usage-specs/tessl/pypi-ansible-core/` | Configuration management |
| OpenJDK | 17 | N/A (OS package) | Java runtime |
| Apache Tomcat | 10.1.31 | N/A | Application server |

### Diagrams

```
┌─────────────────────────────────────────────────────────────────┐
│                     Deployment Flow                              │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│   just deploy                                                    │
│        │                                                         │
│        ▼                                                         │
│   ┌──────────────┐                                              │
│   │ just tf-apply│ ─────────────────────┐                       │
│   └──────────────┘                      │                       │
│        │                                ▼                       │
│        │                         ┌─────────────┐                │
│        │                         │ Proxmox API │                │
│        │                         └─────────────┘                │
│        │                                │                       │
│        │                                ▼                       │
│        │                         ┌─────────────┐                │
│        │                         │ VM Created  │                │
│        │                         └─────────────┘                │
│        │                                │                       │
│        ▼                                ▼                       │
│   ┌──────────────┐              ┌─────────────┐                │
│   │ sleep 30     │              │ Cloud-Init  │                │
│   │ (wait for IP)│              │ (first boot)│                │
│   └──────────────┘              └─────────────┘                │
│        │                                │                       │
│        ▼                                ▼                       │
│   ┌──────────────────────┐      ┌─────────────┐                │
│   │ generate_inventory.sh│◀─────│ QEMU Agent  │                │
│   └──────────────────────┘      │ reports IP  │                │
│        │                        └─────────────┘                │
│        ▼                                                        │
│   ┌──────────────────────┐                                     │
│   │ terraform output     │                                     │
│   │ -raw vm_ip          │                                     │
│   └──────────────────────┘                                     │
│        │                                                        │
│        ▼                                                        │
│   ┌──────────────────────┐                                     │
│   │ ansible/inventory.ini│                                     │
│   │ [java_servers]       │                                     │
│   │ my-vm ansible_host=..│                                     │
│   └──────────────────────┘                                     │
│        │                                                        │
│        ▼                                                        │
│   ┌──────────────────────┐                                     │
│   │ ansible-playbook     │                                     │
│   │ java_tomcat.yml      │                                     │
│   └──────────────────────┘                                     │
│        │                                                        │
│        ├──────────────────────────────────────┐                │
│        ▼                                      ▼                │
│   ┌──────────────┐                    ┌──────────────┐        │
│   │ Install      │                    │ Install      │        │
│   │ OpenJDK 17   │                    │ Tomcat 10.1  │        │
│   └──────────────┘                    └──────────────┘        │
│        │                                      │                │
│        └──────────────────┬───────────────────┘                │
│                           ▼                                    │
│                    ┌──────────────┐                           │
│                    │ systemctl    │                           │
│                    │ start tomcat │                           │
│                    └──────────────┘                           │
│                           │                                    │
│                           ▼                                    │
│                    ┌──────────────┐                           │
│                    │ Healthcheck  │                           │
│                    │ :8080        │                           │
│                    └──────────────┘                           │
│                           │                                    │
│                           ▼                                    │
│                    ┌──────────────┐                           │
│                    │ ✓ COMPLETE   │                           │
│                    └──────────────┘                           │
│                                                                │
└─────────────────────────────────────────────────────────────────┘
```

### File Layout Changes

```
proxmox-iac/
├── terraform/
│   ├── main.tf                  # existing
│   ├── variables.tf             # existing
│   └── outputs.tf               # NEW - VM outputs for Ansible
├── ansible/
│   ├── inventory.ini            # MODIFIED - auto-generated
│   ├── post_install.yml         # existing
│   ├── java_tomcat.yml          # NEW - Java/Tomcat playbook
│   └── templates/               # NEW - Jinja2 templates
│       └── tomcat.service.j2    # NEW - systemd service
├── scripts/
│   ├── create_template.sh       # existing
│   └── generate_inventory.sh    # NEW - inventory generator
├── docs/
│   └── features/
│       └── ansible-java-tomcat/ # NEW - feature documentation
│           ├── design.md        # this document
│           └── todo.md          # TODO checklist
├── Justfile                     # MODIFIED - new recipes
└── KNOWLEDGE.md                 # MODIFIED - Java/Tomcat docs
```

## Implementation Stages

### Stage 1: Git Setup
**Description:** Create feature branch for isolated development

**Tasks:**
- Create branch `feature/ansible-java-tomcat`

**Exit Criteria:**
- [x] Branch created and checked out

**Status:** ✅ Complete

---

### Stage 2: Terraform Outputs
**Description:** Export VM metadata for Ansible integration

**Tasks:**
- Create `terraform/outputs.tf`
- Define outputs: vm_id, vm_name, vm_ip, vm_user, vm_node

**Exit Criteria:**
- [x] outputs.tf created
- [x] terraform fmt passes

**Status:** ✅ Complete

---

### Stage 3: Inventory Generator
**Description:** Script to transform Terraform outputs to Ansible inventory

**Tasks:**
- Create `scripts/generate_inventory.sh`
- Implement terraform output parsing
- Add group variables for Java/Tomcat versions
- Make script executable

**Exit Criteria:**
- [x] Script created and executable
- [x] Handles missing/pending IP gracefully

**Status:** ✅ Complete

---

### Stage 4: Ansible Playbook
**Description:** Playbook for Java 17 + Tomcat 10.1 installation

**Tasks:**
- Create `ansible/java_tomcat.yml`
- Create `ansible/templates/tomcat.service.j2`
- Implement tasks: Java install, user creation, Tomcat download/extract, systemd service, firewall, healthcheck

**Exit Criteria:**
- [x] Playbook created
- [x] Template created
- [x] All tasks implemented

**Status:** ✅ Complete

---

### Stage 5: Justfile Updates
**Description:** Add new recipes for integrated workflow

**Tasks:**
- Add `generate-inventory` recipe
- Add `ansible-java` recipe
- Add `deploy` recipe (unified workflow)
- Add `deploy-post` recipe (alternative workflow)
- Update help section

**Exit Criteria:**
- [x] All recipes added
- [x] Help updated

**Status:** ✅ Complete

---

### Stage 6: Documentation
**Description:** Update project documentation

**Tasks:**
- Update `KNOWLEDGE.md` with Java/Tomcat dependencies
- Update deployment workflow section
- Create feature design document
- Create feature TODO document

**Exit Criteria:**
- [x] KNOWLEDGE.md updated
- [x] Feature docs created

**Status:** ✅ Complete

## Risks and Mitigations

| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| QEMU agent not reporting IP | Medium | High | 30 second delay; error message with instructions |
| Apache mirror unavailable | Low | Medium | Use dlcdn.apache.org (CDN); retry logic in Ansible |
| Rocky Linux DNF repos offline | Low | High | Document alternative package sources |
| SSH connection timeout | Medium | Medium | SSH options: StrictHostKeyChecking=no, retries |

## Acceptance Criteria
- [x] AC-1: `just deploy` creates VM and installs Java/Tomcat
- [x] AC-2: Tomcat accessible at http://<vm_ip>:8080
- [x] AC-3: Tomcat runs as systemd service (survives reboot)
- [x] AC-4: Documentation updated
- [x] AC-5: Playbook is idempotent (can re-run safely)

## Testing

**Test Scenario 1: Full Deployment**
- Preconditions: Terraform initialized, secrets configured
- Steps:
  1. `just deploy`
  2. Wait for completion
  3. `curl http://<vm_ip>:8080`
- Expected: Tomcat default page returned

**Test Scenario 2: Inventory Generation Only**
- Preconditions: VM already exists
- Steps:
  1. `just generate-inventory`
  2. Check `ansible/inventory.ini`
- Expected: Inventory contains correct VM details

**Test Scenario 3: Re-run Playbook (Idempotency)**
- Preconditions: Java/Tomcat already installed
- Steps:
  1. `just ansible-java`
- Expected: No errors; "changed" count is minimal

**Commands:**
```bash
# Full deployment
just deploy

# Step-by-step
just tf-apply
just generate-inventory
just ansible-java

# Verification
curl http://<vm_ip>:8080
ssh rocky@<vm_ip> "systemctl status tomcat"
ssh rocky@<vm_ip> "java -version"
```

## Artifacts

**New files:**
- `terraform/outputs.tf`
- `scripts/generate_inventory.sh`
- `ansible/java_tomcat.yml`
- `ansible/templates/tomcat.service.j2`
- `docs/features/ansible-java-tomcat/design.md`
- `docs/features/ansible-java-tomcat/todo.md`

**Modified files:**
- `Justfile`
- `KNOWLEDGE.md`

## References
- Project Spec: `.tessl/project/spec.md`
- Knowledge Index: `KNOWLEDGE.md`
- Tessl Guide: `.tessl/project/TESSL_GUIDE.md`
- Ansible Core Usage Spec: `.tessl/usage-specs/tessl/pypi-ansible-core/docs/`
- Apache Tomcat 10.1 Docs: https://tomcat.apache.org/tomcat-10.1-doc/
- OpenJDK 17: https://openjdk.org/projects/jdk/17/

