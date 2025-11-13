# Inventory Management

Ansible Core's inventory system provides comprehensive host and group management capabilities supporting static and dynamic inventory sources, host pattern matching, variable scoping, and flexible target selection for automation tasks.

## Capabilities

### Inventory Manager

Central inventory management system that coordinates multiple inventory sources, maintains host and group relationships, and provides unified access to inventory data.

```python { .api }
class InventoryManager:
    """
    Main inventory manager coordinating multiple inventory sources.
    
    Parameters:
    - loader: DataLoader instance for file operations
    - sources: List of inventory source paths or URLs
    
    Attributes:
    - _loader: DataLoader for file operations
    - _sources: List of inventory sources
    - _hosts: Dictionary of all hosts
    - _groups: Dictionary of all groups
    - _pattern_cache: Cache for parsed host patterns
    """
    
    def __init__(self, loader, sources=None):
        """Initialize inventory manager with sources"""
    
    def parse_sources(self, cache=True):
        """
        Parse all inventory sources and populate host/group data.
        
        Parameters:
        - cache: Whether to cache parsing results
        """
    
    def get_hosts(self, pattern="all", ignore_limits=False, ignore_restrictions=False):
        """
        Get hosts matching the specified pattern.
        
        Parameters:
        - pattern: Host pattern string (default: "all")
        - ignore_limits: Ignore limit restrictions
        - ignore_restrictions: Ignore all restrictions
        
        Returns:
        list: List of Host objects matching pattern
        """
    
    def list_hosts(self, pattern="all"):
        """
        List hosts matching pattern.
        
        Parameters:
        - pattern: Host pattern string
        
        Returns:
        list: List of host names
        """
    
    def get_groups_dict(self):
        """
        Get dictionary representation of all groups.
        
        Returns:
        dict: Groups with their hosts and variables
        """
    
    def add_group(self, group):
        """
        Add group to inventory.
        
        Parameters:
        - group: Group name or Group object
        """
    
    def add_host(self, host, group=None, port=None):
        """
        Add host to inventory.
        
        Parameters:
        - host: Host name or Host object
        - group: Group to add host to
        - port: SSH port for host
        """
```

### Host Management

Individual host representation with connection parameters, variables, and group membership tracking.

```python { .api }
class Host:
    """
    Individual host representation with variables and connection info.
    
    Parameters:
    - name: Host name or IP address
    - port: SSH port (default: 22)
    
    Attributes:
    - name: Host identifier
    - address: Connection address (defaults to name)
    - port: SSH port number
    - vars: Host-specific variables
    - groups: List of groups containing this host
    """
    
    def __init__(self, name=None, port=None):
        """Initialize host with name and optional port"""
    
    def get_name(self):
        """
        Get host name.
        
        Returns:
        str: Host name
        """
    
    def set_variable(self, varname, value):
        """
        Set host variable.
        
        Parameters:
        - varname: Variable name
        - value: Variable value
        """
    
    def get_vars(self):
        """
        Get all host variables.
        
        Returns:
        dict: Host variables
        """
    
    def get_groups(self):
        """
        Get groups containing this host.
        
        Returns:
        list: Group objects
        """
    
    def add_group(self, group):
        """
        Add host to group.
        
        Parameters:
        - group: Group object
        """
```

### Group Management

Group representation supporting nested groups, group variables, and parent-child relationships for hierarchical inventory organization.

```python { .api }
class Group:
    """
    Host group representation with nested group support.
    
    Parameters:
    - name: Group name
    
    Attributes:
    - name: Group identifier
    - hosts: List of hosts in group
    - child_groups: List of child groups
    - parent_groups: List of parent groups
    - vars: Group-specific variables
    - priority: Group priority for variable precedence
    """
    
    def __init__(self, name=None):
        """Initialize group with name"""
    
    def add_host(self, host):
        """
        Add host to group.
        
        Parameters:
        - host: Host object
        """
    
    def remove_host(self, host):
        """
        Remove host from group.
        
        Parameters:
        - host: Host object
        """
    
    def get_hosts(self):
        """
        Get all hosts in group (including from child groups).
        
        Returns:
        list: Host objects
        """
    
    def add_child_group(self, group):
        """
        Add child group.
        
        Parameters:
        - group: Group object
        """
    
    def get_ancestors(self):
        """
        Get all ancestor groups.
        
        Returns:
        list: Ancestor Group objects
        """
    
    def set_variable(self, varname, value):
        """
        Set group variable.
        
        Parameters:
        - varname: Variable name
        - value: Variable value
        """
    
    def get_vars(self):
        """
        Get all group variables.
        
        Returns:
        dict: Group variables
        """
```

### Inventory Data Container

Core data structure maintaining the complete inventory state including hosts, groups, and their relationships.

```python { .api }
class InventoryData:
    """
    Inventory data container managing hosts and groups.
    
    Attributes:
    - groups: Dictionary of all groups
    - hosts: Dictionary of all hosts
    - _groups_dict_cache: Cached groups dictionary
    """
    
    def __init__(self):
        """Initialize empty inventory data"""
    
    def add_host(self, host, group=None):
        """
        Add host to inventory data.
        
        Parameters:
        - host: Host name or Host object
        - group: Group to add host to
        """
    
    def add_group(self, group):
        """
        Add group to inventory data.
        
        Parameters:
        - group: Group name or Group object
        """
    
    def get_host(self, hostname):
        """
        Get host by name.
        
        Parameters:
        - hostname: Host name
        
        Returns:
        Host: Host object or None
        """
    
    def get_group(self, groupname):
        """
        Get group by name.
        
        Parameters:
        - groupname: Group name
        
        Returns:
        Group: Group object or None
        """
```

### Host Pattern Processing

Pattern matching and parsing utilities for flexible host selection supporting ranges, wildcards, regular expressions, and boolean operations.

```python { .api }
def split_host_pattern(pattern):
    """
    Split host pattern into components for processing.
    
    Parameters:
    - pattern: Host pattern string
    
    Returns:
    list: Pattern components
    """

def detect_range(line):
    """
    Detect numeric or alphabetic ranges in host patterns.
    
    Parameters:
    - line: Pattern line to analyze
    
    Returns:
    tuple: (start, end, step) if range detected, None otherwise
    """

def expand_hostname_range(range_spec):
    """
    Expand hostname ranges into individual hostnames.
    
    Parameters:
    - range_spec: Range specification (e.g., "web[01:10]")
    
    Returns:
    list: Expanded hostnames
    """
```

## Inventory Sources

### Static Inventory

#### INI Format
```ini
[webservers]
web1.example.com
web2.example.com

[databases]
db1.example.com
db2.example.com

[webservers:vars]
http_port=80
nginx_version=1.18

[databases:vars]
mysql_port=3306
```

#### YAML Format
```yaml
all:
  children:
    webservers:
      hosts:
        web1.example.com:
        web2.example.com:
      vars:
        http_port: 80
        nginx_version: 1.18
    databases:
      hosts:
        db1.example.com:
        db2.example.com:
      vars:
        mysql_port: 3306
```

### Dynamic Inventory

Dynamic inventory plugins can generate inventory from external sources like cloud providers, CMDBs, or custom scripts.

```python
# Example dynamic inventory usage
inventory = InventoryManager(
    loader=loader,
    sources=['aws_ec2.yml', 'static_inventory']
)
```

## Host Patterns

### Pattern Syntax

- `all` or `*` - All hosts
- `group_name` - All hosts in group
- `host1:host2` - Multiple hosts/groups (union)
- `host1:!host2` - Exclude hosts/groups
- `host1:&group1` - Intersection of hosts and groups
- `web*.example.com` - Wildcard matching
- `~(web|db).*` - Regular expression matching
- `web[01:50]` - Numeric range expansion
- `web[a:f]` - Alphabetic range expansion

### Pattern Examples

```python
# Get all web servers
hosts = inventory.get_hosts('webservers')

# Get hosts in web or db groups
hosts = inventory.get_hosts('webservers:databases')

# Get web servers excluding maintenance
hosts = inventory.get_hosts('webservers:!maintenance')

# Get intersection of web servers and production
hosts = inventory.get_hosts('webservers:&production')

# Get hosts matching regex
hosts = inventory.get_hosts('~web[0-9]+\.prod\..*')
```

## Variable Precedence

Variables are resolved in order of precedence (highest to lowest):

1. Command line extra variables (`-e`)
2. Task variables
3. Block variables
4. Role variables
5. Play variables
6. Host facts
7. Host variables
8. Group variables (child groups override parent groups)
9. Default variables

## Usage Examples

### Basic Inventory Management

```python
from ansible.inventory.manager import InventoryManager
from ansible.parsing.dataloader import DataLoader

# Initialize components
loader = DataLoader()
inventory = InventoryManager(loader=loader, sources=['inventory'])

# Get hosts matching pattern
web_hosts = inventory.get_hosts('webservers')

# Add dynamic host
from ansible.inventory.host import Host
new_host = Host('dynamic.example.com')
new_host.set_variable('role', 'worker')
inventory.add_host(new_host, group='workers')

# List all groups
groups = inventory.get_groups_dict()
```

### Host and Group Operations

```python
# Create group with hosts
from ansible.inventory.group import Group
web_group = Group('webservers')

# Add hosts to group
host1 = Host('web1.example.com')
host2 = Host('web2.example.com')
web_group.add_host(host1)
web_group.add_host(host2)

# Set group variables
web_group.set_variable('http_port', 80)
web_group.set_variable('ssl_enabled', True)

# Create nested groups
prod_group = Group('production')
prod_group.add_child_group(web_group)
```