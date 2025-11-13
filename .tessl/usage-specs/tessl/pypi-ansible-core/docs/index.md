# Ansible Core

Ansible Core is a comprehensive IT automation platform that handles configuration management, application deployment, cloud provisioning, ad-hoc task execution, network automation, and multi-node orchestration. It provides a radically simple approach to automation with agentless architecture leveraging SSH for remote management, human-readable YAML for describing infrastructure, and extensive plugin systems for customization.

## Package Information

- **Package Name**: ansible-core
- **Language**: Python
- **Installation**: `pip install ansible-core`
- **Requirements**: Python 3.11+
- **License**: GPL-3.0+

## Core Imports

```python
import ansible
from ansible.constants import config
from ansible.errors import (
    AnsibleError,
    AnsibleParserError,
    AnsibleRuntimeError,
    AnsibleConnectionFailure,
    AnsibleTemplateError
)
```

For CLI usage:
```python
from ansible.cli.playbook import main as playbook_main
from ansible.cli.adhoc import main as adhoc_main
```

For programmatic usage:
```python
from ansible.inventory.manager import InventoryManager
from ansible.playbook import Playbook
from ansible.executor.task_queue_manager import TaskQueueManager
from ansible.parsing.dataloader import DataLoader
from ansible.template import Templar
from ansible.vars.manager import VariableManager
```

## Basic Usage

### CLI Commands
Ansible-core provides 9 command-line tools for different automation tasks:

```bash
# Execute ad-hoc commands on hosts
ansible all -m ping

# Run playbooks
ansible-playbook site.yml

# Manage inventory
ansible-inventory --list

# View documentation
ansible-doc -l

# Manage collections
ansible-galaxy collection install community.general

# Configuration management
ansible-config view

# Interactive console
ansible-console

# Pull mode (git-based automation)
ansible-pull -U repo_url playbook.yml

# Secrets management
ansible-vault encrypt secrets.yml
```

### Programmatic Usage
```python
from ansible.inventory.manager import InventoryManager
from ansible.parsing.dataloader import DataLoader
from ansible.executor.task_queue_manager import TaskQueueManager
from ansible.playbook import Playbook
from ansible.vars.manager import VariableManager

# Initialize core components
loader = DataLoader()
inventory = InventoryManager(loader=loader, sources=['inventory'])
variable_manager = VariableManager(loader=loader, inventory=inventory)

# Load and execute a playbook
pb = Playbook.load('site.yml', variable_manager=variable_manager, loader=loader)
tqm = TaskQueueManager(inventory=inventory, variable_manager=variable_manager, loader=loader)

# Execute the playbook
result = tqm.run(pb.get_plays())
```

## Architecture

Ansible Core follows a modular architecture designed for extensibility and reliability:

- **CLI Layer**: 9 command-line interfaces providing user-facing functionality
- **Core Engine**: Configuration management, parsing, templating, and execution orchestration
- **Plugin System**: 17 plugin types enabling customization of connection, action, inventory, callback, and other behaviors
- **Inventory Management**: Dynamic host and group management with pattern matching
- **Playbook Engine**: YAML-based automation workflow parsing and execution
- **Execution Engine**: Task queue management, parallel execution, and result aggregation
- **Template Engine**: Jinja2-based variable substitution and expression evaluation
- **Module Utilities**: Shared libraries for module development across different platforms

This architecture enables Ansible's agentless design, where the control node orchestrates automation across managed nodes via SSH without requiring agents on target systems.

## Capabilities

### Command Line Interface

Nine CLI tools providing comprehensive automation functionality including ad-hoc command execution, playbook management, inventory operations, documentation access, collection management, configuration control, interactive console, pull-based automation, and secrets management.

```python { .api }
def main():
    """Entry point for ansible CLI commands"""

# CLI modules
from ansible.cli.adhoc import main as adhoc_main
from ansible.cli.config import main as config_main
from ansible.cli.console import main as console_main
from ansible.cli.doc import main as doc_main
from ansible.cli.galaxy import main as galaxy_main
from ansible.cli.inventory import main as inventory_main
from ansible.cli.playbook import main as playbook_main
from ansible.cli.pull import main as pull_main
from ansible.cli.vault import main as vault_main
```

[Command Line Interface](./cli.md)

### Error Handling and Exceptions

Comprehensive exception hierarchy providing detailed error information with source context, supporting error recovery patterns and detailed debugging information for automation failures.

```python { .api }
class AnsibleError(Exception):
    """Base exception for all Ansible errors"""

class AnsibleParserError(AnsibleError):
    """Playbook or data file parsing errors"""

class AnsibleRuntimeError(AnsibleError):
    """Runtime execution errors"""

class AnsibleConnectionFailure(AnsibleRuntimeError):
    """Connection and transport failures"""

class AnsibleTemplateError(AnsibleRuntimeError):
    """Template processing errors"""
```

[Error Handling](./errors.md)

### Inventory Management

Dynamic host and group management system supporting static and dynamic inventory sources, host pattern matching, group relationships, and variable scoping for target host selection and organization.

```python { .api }
class InventoryManager:
    def __init__(self, loader, sources=None, parse=True, cache=True):
        """Initialize inventory manager"""

class Host:
    def __init__(self, name, port=None, gen_uuid=True):
        """Individual host representation"""

class Group:
    def __init__(self, name):
        """Host group representation"""
```

[Inventory Management](./inventory.md)

### Playbook Engine

YAML-based automation workflow system supporting plays, tasks, handlers, roles, blocks, includes, and imports with conditional execution, loops, delegation, and comprehensive error handling for complex automation scenarios.

```python { .api }
class Playbook:
    @staticmethod
    def load(filename, variable_manager, loader):
        """Load playbook from file"""

class Play:
    def __init__(self):
        """Individual play representation"""

class Task:
    def __init__(self):
        """Task representation with action and parameters"""
```

[Playbook Engine](./playbook.md)

### Plugin System

Extensible plugin architecture with 17 plugin types including action, callback, connection, filter, inventory, lookup, module, strategy, test, and vars plugins enabling customization of every aspect of Ansible's behavior.

```python { .api }
from ansible.plugins.loader import action_loader, callback_loader, connection_loader

class ActionBase:
    """Base class for action plugins"""

class CallbackBase:  
    """Base class for callback plugins"""

class ConnectionBase:
    """Base class for connection plugins"""
```

[Plugin System](./plugins.md)

### Configuration Management

Centralized configuration system supporting multiple sources (config files, environment variables, command line), validation, and runtime access to all Ansible settings with comprehensive default values and documentation.

```python { .api }
from ansible.config.manager import ConfigManager
from ansible.constants import config

class ConfigManager:
    def get_config_value(self, config_key):
        """Get configuration value"""

# Global configuration access
config_value = config.get_config_value('DEFAULT_HOST_LIST')
```

[Configuration](./configuration.md)

### Template Engine

Jinja2-based template processing system with Ansible-specific filters, tests, and functions supporting variable substitution, conditional logic, loops, and expression evaluation with security controls and performance optimization.

```python { .api }
class Templar:
    def __init__(self, loader, variables):
        """Initialize templating engine"""
    
    def template(self, variable, **kwargs):
        """Template a variable with context"""
```

[Template Engine](./templating.md)

### Module Utilities

Comprehensive utility libraries for module development including argument parsing, JSON handling, text conversion, network utilities, validation, platform abstraction, and common functionality shared across modules.

```python { .api }
from ansible.module_utils.basic import AnsibleModule
from ansible.module_utils.common.validation import check_required_arguments
from ansible.module_utils.common.text.converters import to_text, to_bytes
```

[Module Utilities](./module-utils.md)

### Execution Engine

Task execution orchestration system managing task queues, parallel execution, result collection, callback processing, and strategy selection for efficient automation execution across multiple hosts with comprehensive result aggregation.

```python { .api }
class TaskQueueManager:
    def __init__(self, inventory, variable_manager, loader):
        """Initialize task queue manager"""
    
    def run(self, play):
        """Execute play tasks"""

class TaskExecutor:
    def __init__(self, host, task, variable_manager, loader):
        """Execute individual tasks"""
```

[Execution Engine](./execution.md)

## Types

### Common Data Structures

```python { .api }
# Context and CLI arguments
class CLIArgs:
    """Container for CLI arguments and options"""

# Version information  
__version__: str  # Current ansible-core version
__author__: str   # Author information

# Configuration constants
config: ConfigManager  # Global configuration manager
COLOR_CODES: dict      # ANSI color code mappings
BOOL_TRUE: list        # Boolean true value patterns
```

### Exception Hierarchy

```python { .api }
class ExitCode(enum.IntEnum):
    SUCCESS = 0
    GENERIC_ERROR = 1  
    HOST_FAILED = 2
    HOST_UNREACHABLE = 4
    PARSER_ERROR = 4
    INVALID_CLI_OPTION = 5
    KEYBOARD_INTERRUPT = 99
    UNKNOWN_ERROR = 250
```