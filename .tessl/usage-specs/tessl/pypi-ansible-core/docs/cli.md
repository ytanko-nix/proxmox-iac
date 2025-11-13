# Command Line Interface

Ansible Core provides nine comprehensive command-line tools for different automation tasks. Each CLI tool follows consistent patterns for argument parsing, configuration, and output formatting while providing specialized functionality for specific automation scenarios.

## Capabilities

### Ad-hoc Command Execution

Execute single tasks across multiple hosts without requiring playbooks, supporting all Ansible modules with pattern-based host selection and parallel execution.

```python { .api }
def main():
    """
    Entry point for ansible ad-hoc command execution.
    
    Usage: ansible <host-pattern> -m <module> -a <arguments>
    
    Returns:
    int: Exit code (0 for success, non-zero for failure)
    """
```

Examples:
```bash
# Ping all hosts
ansible all -m ping

# Execute shell commands
ansible webservers -m shell -a "uptime"

# Copy files
ansible databases -m copy -a "src=/tmp/file dest=/tmp/file"
```

### Playbook Execution

Execute YAML playbooks with comprehensive options for inventory selection, variable override, limit patterns, tags, verbosity control, and execution strategies.

```python { .api }
def main():
    """
    Entry point for ansible-playbook execution.
    
    Usage: ansible-playbook [options] playbook.yml
    
    Returns:
    int: Exit code (0 for success, non-zero for failure)
    """
```

Examples:
```bash
# Basic playbook execution
ansible-playbook site.yml

# With inventory and variables
ansible-playbook -i inventory site.yml -e "version=1.2.3"

# Limit to specific hosts
ansible-playbook site.yml --limit webservers

# Run specific tags
ansible-playbook site.yml --tags deploy,config
```

### Configuration Management

View, edit, and manage Ansible configuration settings with support for different configuration sources and comprehensive configuration validation.

```python { .api }
def main():
    """
    Entry point for ansible-config management.
    
    Usage: ansible-config [view|edit|dump|list] [options]
    
    Returns:
    int: Exit code (0 for success, non-zero for failure)
    """
```

Examples:
```bash
# View current configuration
ansible-config view

# List all configuration options
ansible-config list

# Dump all settings with sources
ansible-config dump
```

### Interactive Console

Interactive REPL environment for Ansible with command completion, history, and direct access to inventory and modules for exploratory automation.

```python { .api }
def main():
    """
    Entry point for ansible-console interactive environment.
    
    Usage: ansible-console [host-pattern]
    
    Returns:
    int: Exit code (0 for success, non-zero for failure)
    """
```

Examples:
```bash
# Start console with all hosts
ansible-console

# Start console with specific pattern
ansible-console webservers

# Interactive commands within console
root@all (3)[f:5]$ ping
root@all (3)[f:5]$ setup
```

### Documentation Viewer

Built-in documentation system providing comprehensive module, plugin, and keyword documentation with search capabilities and multiple output formats.

```python { .api }
def main():
    """
    Entry point for ansible-doc documentation viewer.
    
    Usage: ansible-doc [options] [plugin]
    
    Returns:
    int: Exit code (0 for success, non-zero for failure)
    """
```

Examples:
```bash
# List all modules
ansible-doc -l

# View module documentation
ansible-doc copy

# View plugin documentation
ansible-doc -t connection ssh

# Search documentation
ansible-doc -F keyword copy
```

### Galaxy Collection Management

Ansible Galaxy integration for downloading, installing, and managing collections and roles with dependency resolution and version management.

```python { .api }
def main():
    """
    Entry point for ansible-galaxy collection management.
    
    Usage: ansible-galaxy [collection|role] [action] [options]
    
    Returns:
    int: Exit code (0 for success, non-zero for failure)
    """
```

Examples:
```bash
# Install collection
ansible-galaxy collection install community.general

# Install from requirements
ansible-galaxy collection install -r requirements.yml

# Create collection skeleton
ansible-galaxy collection init my_namespace.my_collection

# List installed collections
ansible-galaxy collection list
```

### Inventory Management

Inventory inspection and management tools supporting multiple inventory sources with host and group listing capabilities and graph visualization.

```python { .api }
def main():
    """
    Entry point for ansible-inventory management.
    
    Usage: ansible-inventory [options] [host|group]
    
    Returns:
    int: Exit code (0 for success, non-zero for failure)
    """
```

Examples:
```bash
# List all inventory
ansible-inventory --list

# Show inventory graph
ansible-inventory --graph

# Export to YAML
ansible-inventory --list --yaml

# Show specific host
ansible-inventory --host webserver1
```

### Pull-based Automation

Git-based automation for distributed deployments where managed nodes pull configurations from version control systems rather than being pushed from a control node.

```python { .api }
def main():
    """
    Entry point for ansible-pull automation.
    
    Usage: ansible-pull -U <repository> [options] [playbook]
    
    Returns:
    int: Exit code (0 for success, non-zero for failure)
    """
```

Examples:
```bash
# Pull and run playbook
ansible-pull -U https://github.com/example/playbooks.git site.yml

# With specific branch and interval
ansible-pull -U repo.git -C production --sleep 300 site.yml

# With vault password
ansible-pull -U repo.git --vault-password-file /path/to/vault site.yml
```

### Secrets Management

Ansible Vault integration for encrypting sensitive data including variables, files, and entire playbooks with multiple encryption methods and key management.

```python { .api }
def main():
    """
    Entry point for ansible-vault secrets management.
    
    Usage: ansible-vault [create|edit|encrypt|decrypt|view] [options] file
    
    Returns:
    int: Exit code (0 for success, non-zero for failure)  
    """
```

Examples:
```bash
# Create encrypted file
ansible-vault create secrets.yml

# Encrypt existing file
ansible-vault encrypt vars.yml

# Edit encrypted file
ansible-vault edit secrets.yml

# View encrypted file
ansible-vault view secrets.yml

# Decrypt file
ansible-vault decrypt secrets.yml
```

## Base CLI Framework

### CLI Base Class

```python { .api }
class CLI:
    """
    Base class for all Ansible CLI tools providing common functionality.
    
    Attributes:
    - args: Parsed command line arguments
    - options: CLI options configuration
    - parser: Argument parser instance
    """
    
    def __init__(self, args=None):
        """Initialize CLI base class"""
    
    def parse(self):
        """Parse command line arguments"""
    
    def run(self):
        """Execute CLI command logic"""
```

### Helper Functions

```python { .api }
def opt_help(option):
    """
    Generate help text for CLI options.
    
    Parameters:
    - option: CLI option configuration
    
    Returns:
    str: Formatted help text
    """

class SortingHelpFormatter:
    """Custom help formatter for consistent CLI output"""
```

## CLI Configuration

All CLI tools support common options:

- **Inventory**: `-i, --inventory` - Specify inventory sources
- **Verbosity**: `-v, -vv, -vvv, -vvvv` - Control output verbosity
- **Connection**: `-c, --connection` - Connection type (ssh, local, etc.)
- **User**: `-u, --user` - Remote user for connections
- **Become**: `-b, --become` - Privilege escalation
- **Variables**: `-e, --extra-vars` - Additional variables
- **Limits**: `-l, --limit` - Host pattern restrictions
- **Tags**: `-t, --tags` - Run specific tags
- **Skip Tags**: `--skip-tags` - Skip specific tags