# Usage Specifications

This document explains how to work with usage-spec tiles in the proxmox-iac project.

## What are Usage Specs

Usage specs are standardized documentation tiles for libraries, frameworks, and tools distributed via the Tessl registry. They include:
- How-to guides and code samples
- Best practices and common patterns/anti-patterns
- API references and types

## Where installed specs live

Installed specs are located in:
- `.tessl/usage-specs/tessl/<package>/docs/`

Examples already installed:
- Ansible Core: `.tessl/usage-specs/tessl/pypi-ansible-core/docs/`
- Python Terraform: `.tessl/usage-specs/tessl/pypi-python-terraform/docs/`

## How to use Usage Specs

### Quick access
1. Open `KNOWLEDGE.md` and find the dependency
2. Navigate to `.tessl/usage-specs/tessl/<package>/docs/`
3. Start with `index.md` then dive into specific sections (e.g., `cli.md`, `configuration.md`, `core-operations.md`)

### Search for new specs
```bash
# Search by name
tessl search terraform

# Search by keyword
tessl search "cloud init"
```

### Install specs
```bash
# Install a specific tile
tessl install <tile-id>

# Examples
tessl install tessl/terraform-cli
tessl install tessl/proxmox-api
```

After installation:
- The spec will appear in `.tessl/usage-specs/tessl/<package>/`
- Update `KNOWLEDGE.md`
- Return to this page if needed

### Integrate with development
1. For new features, ensure a usage-spec exists for each dependency
2. For questions, consult the usage-spec before official docs
3. If a spec is missing, install it and add an entry to `KNOWLEDGE.md`

## Maintenance

### Update specs
```bash
tessl update
```

### Planned installations
- [ ] Terraform CLI
- [ ] Telmate/proxmox provider
- [ ] Just task runner
- [ ] Cloud-Init
- [ ] Proxmox API
