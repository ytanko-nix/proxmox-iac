# Configuration Management

Ansible Core's configuration system provides centralized management of all settings through multiple sources including configuration files, environment variables, and command-line options with comprehensive validation and runtime access.

## Capabilities

### Configuration Manager

Central configuration system coordinating multiple configuration sources with precedence handling, validation, and runtime access to all Ansible settings.

```python { .api }
class ConfigManager:
    """
    Central configuration manager handling multiple sources and precedence.
    
    Attributes:
    - _base_defs: Base configuration definitions
    - _config_file: Current configuration file path
    - _changed_keys: Keys that have been modified
    """
    
    def __init__(self, conf_file=None, defs_file=None):
        """Initialize configuration manager"""
    
    def get_config_value(self, config_key, origin=None):
        """
        Get configuration value by key.
        
        Parameters:
        - config_key: Configuration key name
        - origin: Configuration origin (file, env, cli)
        
        Returns:
        object: Configuration value
        """
    
    def get_config_value_and_origin(self, config_key):
        """
        Get configuration value and its origin.
        
        Parameters:
        - config_key: Configuration key name
        
        Returns:
        tuple: (value, origin)
        """
    
    def update_config_data(self, defs=None, configfile=None):
        """
        Update configuration data from sources.
        
        Parameters:
        - defs: Configuration definitions
        - configfile: Configuration file path
        """
    
    def get_config_keys(self):
        """
        Get all available configuration keys.
        
        Returns:
        list: Configuration key names
        """

# Global configuration instance
config: ConfigManager  # Global configuration manager
```

### Configuration Constants

Core configuration constants and default values used throughout Ansible Core for consistent behavior and customization points.

```python { .api }
# Global configuration access
config: ConfigManager  # Global configuration manager instance

# Color codes for output formatting
COLOR_CODES: dict = {
    'black': '0;30',
    'blue': '0;34', 
    'green': '0;32',
    'cyan': '0;36',
    'red': '0;31',
    'purple': '0;35',
    'yellow': '0;33',
    'white': '1;37',
    'normal': '0'
}

# Boolean true values
BOOL_TRUE: list  # Values considered True in configuration

# Plugin configuration
CONFIGURABLE_PLUGINS: tuple = (
    'become', 'cache', 'callback', 'cliconf', 'connection', 
    'httpapi', 'inventory', 'lookup', 'netconf', 'shell', 'vars'
)

DOCUMENTABLE_PLUGINS: tuple = CONFIGURABLE_PLUGINS + (
    'module', 'strategy', 'test', 'filter'
)

# File extensions and patterns
REJECT_EXTS: list  # File extensions to ignore
DOC_EXTENSIONS: tuple  # Documentation file extensions
IGNORE_FILES: tuple  # Files to ignore during module search

# Default values
DEFAULT_PASSWORD_CHARS: str  # Characters for auto-generated passwords
DEFAULT_REMOTE_PASS: None    # Default remote password
DEFAULT_BECOME_PASS: None    # Default become password
DEFAULT_SUBSET: None         # Default host subset
```

### Configuration Definitions

```python { .api }
class Setting:
    """
    Configuration setting definition with validation and metadata.
    
    Attributes:
    - name: Setting name
    - default: Default value
    - description: Setting description
    - type: Expected value type
    - choices: Valid choices (if applicable)
    """
    
    def __init__(self, name, default=None, description='', type=str, choices=None):
        """Initialize configuration setting"""
    
    def validate(self, value):
        """
        Validate configuration value.
        
        Parameters:
        - value: Value to validate
        
        Returns:
        object: Validated value
        
        Raises:
        AnsibleOptionsError: If validation fails
        """
```

## Configuration Sources

### Configuration File Precedence

Ansible reads configuration from multiple sources in order of precedence (highest to lowest):

1. **Command line options** (`-v`, `--inventory`, etc.)
2. **Environment variables** (`ANSIBLE_*`)
3. **ansible.cfg in current directory**
4. **~/.ansible.cfg** (user configuration)
5. **/etc/ansible/ansible.cfg** (system configuration)
6. **Built-in defaults**

### Configuration File Format

```ini
[defaults]
# Basic configuration
inventory = ./inventory
remote_user = ansible
host_key_checking = False
retry_files_enabled = False
gathering = implicit
fact_caching = memory

# Output and logging
stdout_callback = yaml
log_path = /var/log/ansible.log
display_skipped_hosts = False
display_ok_hosts = True

# Connection settings
timeout = 30
forks = 5
transport = ssh

# Privilege escalation
become = True
become_method = sudo
become_user = root
become_ask_pass = False

[inventory]
# Inventory plugin settings
enable_plugins = host_list, script, auto, yaml, ini, toml

[ssh_connection]
# SSH-specific settings
ssh_args = -o ControlMaster=auto -o ControlPersist=60s
pipelining = True
control_path = ~/.ansible/cp/%%h-%%p-%%r

[colors]
# Output coloring
highlight = white
verbose = blue
warn = bright purple
error = red
debug = dark gray
deprecate = purple
skip = cyan
unreachable = red
ok = green
changed = yellow
diff_add = green
diff_remove = red
diff_lines = cyan
```

### Environment Variables

```bash
# Core settings
export ANSIBLE_CONFIG=/path/to/ansible.cfg
export ANSIBLE_INVENTORY=/path/to/inventory
export ANSIBLE_REMOTE_USER=ansible
export ANSIBLE_BECOME=true
export ANSIBLE_BECOME_USER=root

# Connection settings
export ANSIBLE_HOST_KEY_CHECKING=false
export ANSIBLE_SSH_ARGS='-o ControlMaster=auto'
export ANSIBLE_TIMEOUT=30
export ANSIBLE_FORKS=10

# Output and logging
export ANSIBLE_STDOUT_CALLBACK=yaml
export ANSIBLE_LOG_PATH=/var/log/ansible.log
export ANSIBLE_DISPLAY_SKIPPED_HOSTS=false

# Vault settings
export ANSIBLE_VAULT_PASSWORD_FILE=/path/to/vault-pass
export ANSIBLE_VAULT_IDENTITY_LIST=default@/path/to/pass

# Plugin paths
export ANSIBLE_LIBRARY=/path/to/modules
export ANSIBLE_ACTION_PLUGINS=/path/to/action_plugins
export ANSIBLE_CALLBACK_PLUGINS=/path/to/callback_plugins
```

## Common Configuration Settings

### Connection Settings

```python { .api }
# Access configuration values
remote_user = config.get_config_value('DEFAULT_REMOTE_USER')
timeout = config.get_config_value('DEFAULT_TIMEOUT')
forks = config.get_config_value('DEFAULT_FORKS')
host_key_checking = config.get_config_value('HOST_KEY_CHECKING')
```

Key connection settings:
- `DEFAULT_REMOTE_USER` - Default SSH user
- `DEFAULT_TIMEOUT` - Connection timeout in seconds
- `DEFAULT_FORKS` - Number of parallel processes
- `HOST_KEY_CHECKING` - SSH host key verification
- `DEFAULT_TRANSPORT` - Connection transport method

### Privilege Escalation Settings

```python { .api }
# Become settings
become = config.get_config_value('DEFAULT_BECOME')
become_method = config.get_config_value('DEFAULT_BECOME_METHOD')
become_user = config.get_config_value('DEFAULT_BECOME_USER')
```

Key become settings:
- `DEFAULT_BECOME` - Enable privilege escalation
- `DEFAULT_BECOME_METHOD` - Escalation method (sudo, su, etc.)
- `DEFAULT_BECOME_USER` - Target user for escalation
- `DEFAULT_BECOME_ASK_PASS` - Prompt for become password

### Output and Logging Settings

```python { .api }
# Output settings
stdout_callback = config.get_config_value('STDOUT_CALLBACK')
log_path = config.get_config_value('DEFAULT_LOG_PATH')
display_skipped = config.get_config_value('DISPLAY_SKIPPED_HOSTS')
```

Key output settings:
- `STDOUT_CALLBACK` - Output format plugin
- `DEFAULT_LOG_PATH` - Log file location
- `DISPLAY_SKIPPED_HOSTS` - Show skipped tasks
- `DEFAULT_VERBOSITY` - Default verbosity level

### Plugin Settings

```python { .api }
# Plugin configuration
callback_plugins = config.get_config_value('DEFAULT_CALLBACK_PLUGIN_PATH')
action_plugins = config.get_config_value('DEFAULT_ACTION_PLUGIN_PATH')
library_path = config.get_config_value('DEFAULT_MODULE_PATH')
```

Key plugin settings:
- Plugin search paths for each plugin type
- Plugin whitelist/blacklist configuration
- Collection search paths
- Plugin-specific configuration options

## Configuration Validation

### Setting Types and Validation

```python
# Example configuration validation
from ansible.config.manager import ConfigManager

config = ConfigManager()

# Get with validation
try:
    forks = config.get_config_value('DEFAULT_FORKS')
    if not isinstance(forks, int) or forks < 1:
        raise ValueError("Forks must be positive integer")
except Exception as e:
    print(f"Configuration error: {e}")
```

### Custom Configuration

```python
# Programmatic configuration
from ansible.constants import set_constant

# Set custom constant
set_constant('CUSTOM_TIMEOUT', 60)

# Update configuration at runtime
config.update_config_data()
```

## Usage Examples

### Reading Configuration

```python
from ansible.constants import config

# Get basic settings
inventory_path = config.get_config_value('DEFAULT_HOST_LIST')
remote_user = config.get_config_value('DEFAULT_REMOTE_USER')
become_enabled = config.get_config_value('DEFAULT_BECOME')

# Get setting with origin
value, origin = config.get_config_value_and_origin('DEFAULT_FORKS')
print(f"Forks: {value} (from {origin})")

# List all available settings
all_keys = config.get_config_keys()
for key in sorted(all_keys):
    value = config.get_config_value(key)
    print(f"{key}: {value}")
```

### Configuration in Plugins

```python
# Using configuration in custom plugins
from ansible.plugins.action import ActionBase
from ansible.constants import config

class ActionModule(ActionBase):
    def run(self, tmp=None, task_vars=None):
        # Access configuration
        timeout = config.get_config_value('DEFAULT_TIMEOUT')
        remote_user = config.get_config_value('DEFAULT_REMOTE_USER')
        
        # Use configuration in plugin logic
        result = {'changed': False}
        return result
```

### Dynamic Configuration

```python
# Configuration testing and debugging
import os
from ansible.config.manager import ConfigManager

# Test different configuration sources
os.environ['ANSIBLE_FORKS'] = '20'

config = ConfigManager()
forks_value, forks_origin = config.get_config_value_and_origin('DEFAULT_FORKS')
print(f"Forks: {forks_value} from {forks_origin}")  # Should show environment

# Reset and test file configuration
del os.environ['ANSIBLE_FORKS']
config.update_config_data()
```