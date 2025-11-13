# Tessl Framework Guide for proxmox-iac

## Introduction

Tessl is a framework for organizing knowledge about dependencies and for structuring feature development workflows in this IaC project. It provides:
- Usage Specifications (usage-specs): standardized docs for dependencies (how-to, API, best practices)
- Knowledge Index: a single catalog of project dependencies and processes
- A consistent process for designing and delivering features

Why here:
- We combine Terraform, Cloud-Init, Ansible, Python Terraform, Just, and the Proxmox API
- Tessl ensures repeatable workflows, quick lookup of dependency guidance, and disciplined docs

---

## When to use Tessl

Use Tessl whenever you:
1) Build a new feature
- Read usage-specs for all dependencies you will touch
- Write a design document from a template
- Break down work into stages with a TODO checklist

2) Add a new dependency
- Search a usage-spec: `tessl search <dependency>`
- Install it: `tessl install <tile-id>`
- Update the Knowledge Index

3) Need clarity on a tool/API
- Open the relevant usage-spec under `.tessl/usage-specs/tessl/<package>/docs/`
- Use examples and best practices to guide implementation

4) Troubleshoot issues
- Refer to usage-specs for common issues and debugging patterns
- Fall back to official docs where needed and record notes in the Knowledge Index

---

## Feature development process (Tessl-driven)

1) Clarify requirements (confidence ≥95%)
- Confirm functional and non-functional needs
- Capture constraints and assumptions
- Enumerate acceptance criteria, success metrics, and edge cases

2) Ensure usage-specs are available
```bash
# List installed specs
ls .tessl/usage-specs/tessl/

# Search for additional specs
tessl search terraform
tessl search "cloud init"
tessl search proxmox

# Install missing specs
tessl install tessl/terraform-cli
tessl install tessl/proxmox-api
```
- Update the Knowledge Index after installations

3) Write a design document
```bash
cp .tessl/project/templates/FEATURE_DESIGN_TEMPLATE.md docs/features/<feature>-design.md
```
- Fill out: goals, requirements, architecture, dependencies (link usage-specs), stages, risks, acceptance criteria

4) Create a stage-based TODO
```bash
cp .tessl/project/templates/FEATURE_TODO_TEMPLATE.md docs/features/<feature>-todo.md
```
- Each stage has: clear goal, tasks, checks, and artifacts

5) Keep docs in `docs/features/` for feature-specific artifacts; framework/process docs live under `.tessl/`

6) Implement stage-by-stage
- Execute tasks, mark completion, keep design synced
- Commit at the end of each stage

7) Finalization checklist
- Update `.tessl/project/spec.md` (Knowledge/References/Dependencies)
- Update `KNOWLEDGE.md`
- Update `.tessl/framework/usage-specs.md` (if you installed new specs)
- Update `README.md` if user-facing behavior changed
- Security review (secrets, tokens, TLS)
- Run validation/tests; request code review; merge

---

## Knowledge Index

- File: `KNOWLEDGE.md` (project root)
- Content: dependencies and their usage-specs, project workflows, security policies, and how to update the index

Workflow:
1) Open `KNOWLEDGE.md`
2) Follow links into `.tessl/usage-specs/tessl/<package>/docs/`
3) Start at `index.md`, then deep-dive into specific sections (e.g., `cli.md`, `configuration.md`, `core-operations.md`)

Adding new dependencies:
```bash
tessl search <dependency>
tessl install <tile-id>
```
Then update:
- `KNOWLEDGE.md`
- `.tessl/framework/usage-specs.md`
- `.tessl/project/spec.md` (Dependencies/References)

---

## Usage Specs

What they include:
- How-to guides, code examples
- Best practices and anti-patterns
- API references and types

Where they live:
- `.tessl/usage-specs/tessl/<package>/docs/`

Installed examples:
- Ansible Core: `.tessl/usage-specs/tessl/pypi-ansible-core/docs/`
- Python Terraform: `.tessl/usage-specs/tessl/pypi-python-terraform/docs/`

Installing missing usage-spec tiles:
```bash
tessl search terraform
tessl search "cloud init"
tessl search proxmox

tessl install tessl/terraform-cli
tessl install tessl/cloud-init
tessl install tessl/just
tessl install tessl/proxmox-api
```

After installation:
- Verify files under `.tessl/usage-specs/tessl/<package>/`
- Update `KNOWLEDGE.md`
- Update `.tessl/framework/usage-specs.md`
- Update `.tessl/project/spec.md`

---

## Integrating changes into the project

Update `.tessl/project/spec.md`
- Knowledge section: link to `KNOWLEDGE.md`, `.tessl/framework/usage-specs.md`, and this guide
- References section: add links to templates and feature docs if needed
- Dependencies: ensure links to usage-specs exist

Update `KNOWLEDGE.md` and `.tessl/framework/usage-specs.md` whenever you add new tiles.

---

## Alignment with Justfile

Common commands:
```bash
just tf-init       # Terraform init
just tf-fmt        # Terraform fmt
just tf-validate   # Terraform validate
just tf-plan       # Terraform plan
just tf-apply      # Terraform apply (auto-approve)
just tf-destroy    # Terraform destroy
just ansible-post  # Run Ansible post-install playbook
```
Usage-specs provide correct usage patterns and options for these tools.

---

## Security policies (must-do)

Secrets
- Never commit secrets
- Prefer environment variables (`TF_VAR_*`) or a git-ignored `secrets.tfvars`
- Use managed secret stores in production (Vault, AWS/Azure, etc.)

TLS
- Dev: `pm_tls_insecure = true`
- Prod: `pm_tls_insecure = false` + valid certs

API tokens
- Use tokens (not passwords), minimal permissions, rotation, keep in env/secret stores

Pre-commit check:
```bash
git diff --cached | grep -i "secret\|password\|token\|api_key" || true
```

---

## Templates and checklists

Templates (under `.tessl/project/templates/`):
- `FEATURE_DESIGN_TEMPLATE.md` — design doc template
- `FEATURE_TODO_TEMPLATE.md` — stage-based TODO template

How to use:
```bash
cp .tessl/project/templates/FEATURE_DESIGN_TEMPLATE.md docs/features/my-feature-design.md
cp .tessl/project/templates/FEATURE_TODO_TEMPLATE.md docs/features/my-feature-todo.md
```

Feature delivery checklist
- [ ] Requirements clarified (≥95% confidence)
- [ ] Usage-specs checked and installed when missing
- [ ] Design doc and TODO created from templates
- [ ] Stages implemented with validation
- [ ] `.tessl/project/spec.md` updated
- [ ] `KNOWLEDGE.md` updated
- [ ] `.tessl/framework/usage-specs.md` updated
- [ ] `README.md` updated (if applicable)
- [ ] Security policies reviewed
- [ ] Code review complete; merged

---

## Practical examples

Example 1: Introduce Cloud-Init templates
1. Clarify requirements (storage location, selection mechanism, required templates)
2. Install usage-spec if missing:
```bash
tessl search cloud-init
tessl install tessl/cloud-init
```
3. Read `.tessl/usage-specs/tessl/cloud-init/docs/`
4. Create design:
```bash
cp .tessl/project/templates/FEATURE_DESIGN_TEMPLATE.md docs/features/cloud-init-templates-design.md
```
5. Create TODO:
```bash
cp .tessl/project/templates/FEATURE_TODO_TEMPLATE.md docs/features/cloud-init-templates-todo.md
```
6. Implement and test (`just tf-plan`, `just tf-apply`)
7. Update `.tessl/project/spec.md`, `KNOWLEDGE.md`, `.tessl/framework/usage-specs.md`

Example 2: Proxmox API snapshots
1. Install usage-spec if needed:
```bash
tessl search proxmox api
tessl install tessl/proxmox-api
```
2. Read `.tessl/usage-specs/tessl/proxmox-api/docs/`
3. Implement snapshot helper (use API tokens from environment)
4. Add a Just recipe if needed
5. Document in `KNOWLEDGE.md`

---

## Troubleshooting

Usage-spec not found
- Try exact names and keywords: `tessl search terraform`, `tessl search "terraform cli"`
- If still missing, use official docs and record notes in `KNOWLEDGE.md`

Version conflicts
- Verify versions in `versions.tf`/tooling
- Look for a spec matching your version
- Record differences and mitigations in the design doc

Missing `.tessl/framework/usage-specs.md`
- Create it from this repository (see `.tessl/framework/usage-specs.md`)
- Run `tessl update`

Don’t remember installed specs
- List `.tessl/usage-specs/tessl/`
- Check `KNOWLEDGE.md`
- Review `.tessl/framework/usage-specs.md`

Just command issues
- Validate Justfile syntax: `just --list`
- Verify required tools are on PATH
- Check relative paths are correct

---

## References

Internal
- Project spec: `.tessl/project/spec.md`
- Knowledge Index: `KNOWLEDGE.md`
- Usage Specs overview: `.tessl/framework/usage-specs.md`
- Templates: `.tessl/project/templates/`

Installed usage-specs
- Ansible Core: `.tessl/usage-specs/tessl/pypi-ansible-core/docs/`
- Python Terraform: `.tessl/usage-specs/tessl/pypi-python-terraform/docs/`

External
- Terraform: https://terraform.io/docs
- Telmate/proxmox: https://registry.terraform.io/providers/Telmate/proxmox/latest/docs
- Proxmox VE: https://pve.proxmox.com/pve-docs/
- Cloud-Init: https://cloudinit.readthedocs.io/
- Ansible: https://docs.ansible.com/
- Just: https://just.systems/
