# Plugin System

Ansible Core's plugin system provides comprehensive extensibility through 17 plugin types that enable customization of connection methods, actions, callbacks, inventory sources, filters, tests, lookups, and more. The plugin architecture allows deep integration with existing systems and workflows.

## Capabilities

### Plugin Loading System

Central plugin loader managing plugin discovery, caching, and instantiation across all plugin types with collection support and configuration management.

```python { .api }
class PluginLoader:
    """
    Base plugin loader for managing plugin discovery and loading.
    
    Attributes:
    - _plugin_path_cache: Cache of plugin paths
    - _extra_dirs: Additional directories to search
    - _type: Plugin type name
    """
    
    def get(self, name, *args, **kwargs):
        """
        Get plugin instance by name.
        
        Parameters:
        - name: Plugin name
        - args: Plugin constructor arguments
        - kwargs: Plugin constructor keyword arguments
        
        Returns:
        object: Plugin instance
        """
    
    def all(self, *args, **kwargs):
        """
        Get all available plugins of this type.
        
        Returns:
        dict: Dictionary of plugin name to plugin instance
        """
    
    def find_plugin(self, name, mod_type='', ignore_deprecated=False, check_aliases=False):
        """
        Find plugin by name and return path.
        
        Parameters:
        - name: Plugin name
        - mod_type: Module type for module plugins
        - ignore_deprecated: Skip deprecated plugins
        - check_aliases: Check plugin aliases
        
        Returns:
        str: Path to plugin or None
        """

# Global plugin loaders
action_loader: PluginLoader       # Action plugins
callback_loader: PluginLoader     # Callback plugins  
connection_loader: PluginLoader   # Connection plugins
filter_loader: PluginLoader       # Filter plugins
inventory_loader: PluginLoader    # Inventory plugins
lookup_loader: PluginLoader       # Lookup plugins
module_loader: PluginLoader       # Module plugins
strategy_loader: PluginLoader     # Strategy plugins
test_loader: PluginLoader         # Test plugins
vars_loader: PluginLoader         # Vars plugins
```

### Action Plugins

Action plugins execute on the controller and coordinate task execution including module dispatch, file operations, and complex logic.

```python { .api }
class ActionBase:
    """
    Base class for action plugins.
    
    Attributes:
    - _task: Current task object
    - _connection: Connection to target host
    - _play_context: Play execution context
    - _loader: DataLoader instance
    - _templar: Template engine
    - _shared_loader_obj: Shared plugin loader
    """
    
    def __init__(self, task, connection, play_context, loader, templar, shared_loader_obj):
        """Initialize action plugin"""
    
    def run(self, tmp=None, task_vars=None):
        """
        Execute action plugin logic.
        
        Parameters:
        - tmp: Temporary directory path
        - task_vars: Task variables
        
        Returns:
        dict: Task result dictionary
        """
    
    def _execute_module(self, module_name=None, module_args=None, task_vars=None, wrap_async=False):
        """
        Execute module on target host.
        
        Parameters:
        - module_name: Module to execute
        - module_args: Module arguments
        - task_vars: Available variables
        - wrap_async: Whether to wrap in async
        
        Returns:
        dict: Module execution result
        """
    
    def _transfer_data(self, remote_path, data):
        """
        Transfer data to remote host.
        
        Parameters:
        - remote_path: Destination path
        - data: Data to transfer
        
        Returns:
        str: Remote path of transferred data
        """
```

### Connection Plugins

Connection plugins handle communication with target hosts supporting various transport methods and authentication mechanisms.

```python { .api }
class ConnectionBase:
    """
    Base class for connection plugins.
    
    Attributes:
    - _play_context: Play execution context
    - _new_stdin: Input stream
    - _connected: Connection state
    """
    
    def __init__(self, play_context, new_stdin, *args, **kwargs):
        """Initialize connection plugin"""
    
    def _connect(self):
        """
        Establish connection to target host.
        
        Returns:
        self: Connection instance
        """
    
    def exec_command(self, cmd, in_data=None, sudoable=True):
        """
        Execute command on target host.
        
        Parameters:
        - cmd: Command to execute
        - in_data: Input data for command
        - sudoable: Whether command can use sudo
        
        Returns:
        tuple: (return_code, stdout, stderr)
        """
    
    def put_file(self, in_path, out_path):
        """
        Transfer file to target host.
        
        Parameters:
        - in_path: Local source path
        - out_path: Remote destination path
        """
    
    def fetch_file(self, in_path, out_path):
        """
        Retrieve file from target host.
        
        Parameters:
        - in_path: Remote source path
        - out_path: Local destination path
        """
    
    def close(self):
        """Close connection to target host"""
```

### Callback Plugins

Callback plugins receive events during playbook execution enabling custom output formatting, logging, notifications, and integrations.

```python { .api }
class CallbackBase:
    """
    Base class for callback plugins.
    
    Attributes:
    - _display: Display object for output
    - _options: Plugin options
    """
    
    def __init__(self, display=None):
        """Initialize callback plugin"""
    
    def v2_playbook_on_start(self, playbook):
        """
        Called when playbook starts.
        
        Parameters:
        - playbook: Playbook object
        """
    
    def v2_playbook_on_play_start(self, play):
        """
        Called when play starts.
        
        Parameters:
        - play: Play object
        """
    
    def v2_runner_on_ok(self, result):
        """
        Called when task succeeds.
        
        Parameters:
        - result: Task result object
        """
    
    def v2_runner_on_failed(self, result, ignore_errors=False):
        """
        Called when task fails.
        
        Parameters:
        - result: Task result object
        - ignore_errors: Whether errors should be ignored
        """
    
    def v2_runner_on_unreachable(self, result):
        """
        Called when host is unreachable.
        
        Parameters:
        - result: Task result object
        """
    
    def v2_playbook_on_stats(self, stats):
        """
        Called when playbook completes with final statistics.
        
        Parameters:
        - stats: Execution statistics
        """
```

### Inventory Plugins

Inventory plugins generate dynamic inventory from external sources like cloud providers, databases, or APIs.

```python { .api }
class InventoryBase:
    """
    Base class for inventory plugins.
    
    Attributes:
    - inventory: Inventory data object
    - loader: DataLoader instance
    - cache: Inventory cache
    """
    
    def __init__(self):
        """Initialize inventory plugin"""
    
    def verify_file(self, path):
        """
        Verify that this plugin can handle the inventory source.
        
        Parameters:
        - path: Inventory source path
        
        Returns:
        bool: True if plugin can handle source
        """
    
    def parse(self, inventory, loader, path, cache=True):
        """
        Parse inventory source and populate inventory data.
        
        Parameters:
        - inventory: Inventory data object
        - loader: DataLoader instance
        - path: Inventory source path
        - cache: Whether to use caching
        """
    
    def get_option(self, option):
        """
        Get plugin configuration option.
        
        Parameters:
        - option: Option name
        
        Returns:
        object: Option value
        """
```

### Filter Plugins

Filter plugins provide Jinja2 filters for template processing enabling data transformation and formatting.

```python { .api }
class FilterModule:
    """
    Filter plugin module providing custom Jinja2 filters.
    """
    
    def filters(self):
        """
        Return dictionary of filter name to filter function.
        
        Returns:
        dict: Filter name to function mapping
        """

# Example filter functions
def to_yaml(data, indent=2):
    """
    Convert data to YAML format.
    
    Parameters:
    - data: Data to convert
    - indent: YAML indentation
    
    Returns:
    str: YAML representation
    """

def regex_replace(value, pattern, replacement):
    """
    Replace text using regular expressions.
    
    Parameters:
    - value: Input string
    - pattern: Regex pattern
    - replacement: Replacement string
    
    Returns:
    str: String with replacements
    """
```

### Test Plugins

Test plugins provide Jinja2 tests for conditional evaluation in templates and playbooks.

```python { .api }
class TestModule:
    """
    Test plugin module providing custom Jinja2 tests.
    """
    
    def tests(self):
        """
        Return dictionary of test name to test function.
        
        Returns:
        dict: Test name to function mapping
        """

# Example test functions  
def is_ip(value):
    """
    Test if value is valid IP address.
    
    Parameters:
    - value: Value to test
    
    Returns:
    bool: True if valid IP address
    """

def version_compare(value, version, operator):
    """
    Compare version strings.
    
    Parameters:
    - value: Version to compare
    - version: Comparison version
    - operator: Comparison operator
    
    Returns:
    bool: Comparison result
    """
```

### Lookup Plugins

Lookup plugins retrieve data from external sources during template processing enabling dynamic data integration.

```python { .api }
class LookupBase:
    """
    Base class for lookup plugins.
    """
    
    def run(self, terms, variables=None, **kwargs):
        """
        Execute lookup and return results.
        
        Parameters:
        - terms: Lookup terms/parameters
        - variables: Available variables
        - kwargs: Additional options
        
        Returns:
        list: Lookup results
        """

# Example lookup usage in templates
# {{ lookup('file', '/path/to/file') }}
# {{ lookup('env', 'HOME') }}
# {{ lookup('pipe', 'date') }}
```

### Strategy Plugins

Strategy plugins control task execution flow and parallelization enabling custom execution patterns and optimization.

```python { .api }
class StrategyBase:
    """
    Base class for strategy plugins.
    
    Attributes:
    - _inventory: Inventory object
    - _workers: Worker processes
    - _notified_handlers: Handler notification tracking
    """
    
    def __init__(self, tqm):
        """Initialize strategy plugin"""
    
    def run(self, iterator, play_context):
        """
        Execute strategy for play.
        
        Parameters:
        - iterator: Play iterator
        - play_context: Play execution context
        
        Returns:
        int: Execution result code
        """
    
    def get_hosts_left(self, iterator):
        """
        Get hosts that still have tasks to run.
        
        Parameters:
        - iterator: Play iterator
        
        Returns:
        list: Remaining hosts
        """
```

### Vars Plugins

Vars plugins provide variables from external sources enabling dynamic variable injection into plays and tasks.

```python { .api }
class VarsBase:
    """
    Base class for vars plugins.
    """
    
    def get_vars(self, loader, path, entities, cache=True):
        """
        Get variables for entities.
        
        Parameters:
        - loader: DataLoader instance
        - path: Source path
        - entities: Hosts or groups to get vars for
        - cache: Whether to use caching
        
        Returns:
        dict: Variables dictionary
        """
```

## Plugin Development

### Creating Custom Plugins

```python
# Example action plugin
from ansible.plugins.action import ActionBase

class ActionModule(ActionBase):
    def run(self, tmp=None, task_vars=None):
        super(ActionModule, self).run(tmp, task_vars)
        
        # Custom action logic
        result = {'changed': False}
        
        # Execute module if needed
        module_result = self._execute_module(
            module_name='command',
            module_args={'_raw_params': 'echo hello'},
            task_vars=task_vars
        )
        
        result.update(module_result)
        return result
```

### Plugin Configuration

```python
# Plugin with configuration options
from ansible.plugins.inventory import BaseInventoryPlugin

class InventoryModule(BaseInventoryPlugin):
    NAME = 'my_inventory'
    
    def verify_file(self, path):
        return path.endswith('.myinv')
    
    def parse(self, inventory, loader, path, cache=True):
        super(InventoryModule, self).parse(inventory, loader, path, cache)
        
        # Read configuration
        config = self._read_config_data(path)
        
        # Add hosts from config
        for host_data in config.get('hosts', []):
            self.inventory.add_host(host_data['name'])
```

## Available Plugin Types

### Core Plugin Types

1. **Action** - Task execution coordination
2. **Callback** - Event handling and output
3. **Connection** - Host communication transport
4. **Filter** - Jinja2 template filters
5. **Inventory** - Dynamic inventory sources
6. **Lookup** - External data retrieval
7. **Module** - Task implementation
8. **Strategy** - Execution flow control
9. **Test** - Jinja2 template tests
10. **Vars** - Variable sources

### Additional Plugin Types

11. **Become** - Privilege escalation methods
12. **Cache** - Fact caching backends
13. **CLI Conf** - Network device CLI configuration
14. **HTTP API** - HTTP API communication
15. **Net Conf** - NETCONF protocol support
16. **Shell** - Command shell interfaces
17. **Terminal** - Network device terminal handling

## Usage Examples

### Using Plugins in Playbooks

```yaml
# Using lookup plugins
- name: Read file content
  debug:
    msg: "{{ lookup('file', '/etc/hostname') }}"

# Using filters
- name: Format data
  debug:
    msg: "{{ my_dict | to_yaml }}"

# Using tests
- name: Check if IP
  debug:
    msg: "Valid IP"
  when: ansible_default_ipv4.address is ip

# Custom inventory plugin
# inventory.myinv
plugin: my_inventory
hosts:
  - name: server1
  - name: server2
```

### Programmatic Plugin Access

```python
from ansible.plugins.loader import filter_loader, lookup_loader

# Get filter plugin
yaml_filter = filter_loader.get('to_yaml')
result = yaml_filter({'key': 'value'})

# Get lookup plugin  
file_lookup = lookup_loader.get('file')
content = file_lookup.run(['/path/to/file'])
```