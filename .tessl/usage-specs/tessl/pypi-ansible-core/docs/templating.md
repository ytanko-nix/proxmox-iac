# Template Engine

Ansible Core's template engine provides comprehensive Jinja2-based variable substitution, conditional logic, loops, and expression evaluation with Ansible-specific filters, tests, functions, and security controls optimized for automation workflows.

## Capabilities

### Template Engine Core

The main templating engine coordinating Jinja2 processing with Ansible-specific enhancements, variable resolution, and security controls.

```python { .api }
class Templar:
    """
    Main templating engine with Jinja2 integration and Ansible enhancements.
    
    Attributes:
    - _loader: DataLoader instance
    - _variables: Available variables
    - environment: Jinja2 environment
    - _fail_on_undefined: Whether to fail on undefined variables
    - _finalized: Whether templating is finalized
    """
    
    def __init__(self, loader, variables=None):
        """
        Initialize templating engine.
        
        Parameters:
        - loader: DataLoader instance
        - variables: Available variables dictionary
        """
    
    def template(self, variable, convert_bare=False, preserve_trailing_newlines=True, 
                 escape_backslashes=True, fail_on_undefined=None, overrides=None, 
                 convert_data=True, static_vars=None, cache=True, disable_lookups=False):
        """
        Template a variable with current context.
        
        Parameters:
        - variable: Variable to template (string, dict, list, etc.)
        - convert_bare: Convert bare variables
        - preserve_trailing_newlines: Keep trailing newlines
        - escape_backslashes: Escape backslash characters
        - fail_on_undefined: Fail on undefined variables
        - overrides: Variable overrides
        - convert_data: Convert templated data
        - static_vars: Static variables list
        - cache: Use template caching
        - disable_lookups: Disable lookup plugins
        
        Returns:
        object: Templated result
        """
    
    def is_template(self, data):
        """
        Check if data contains template expressions.
        
        Parameters:
        - data: Data to check
        
        Returns:
        bool: True if data contains templates
        """
    
    def set_available_variables(self, variables):
        """
        Set available variables for templating.
        
        Parameters:
        - variables: Variables dictionary
        """
    
    def get_available_variables(self):
        """
        Get currently available variables.
        
        Returns:
        dict: Available variables
        """
```

### Jinja2 Environment

Customized Jinja2 environment with Ansible-specific filters, tests, globals, and configuration optimized for automation use cases.

```python { .api }
class AnsibleEnvironment:
    """
    Ansible-customized Jinja2 environment with enhanced functionality.
    
    Provides Ansible-specific filters, tests, and globals while maintaining
    Jinja2 compatibility and adding security controls.
    """
    
    def __init__(self, *args, **kwargs):
        """Initialize Ansible Jinja2 environment"""
    
    def get_template(self, name, parent=None, globals=None):
        """
        Get template by name with Ansible enhancements.
        
        Parameters:
        - name: Template name
        - parent: Parent template
        - globals: Template globals
        
        Returns:
        Template: Jinja2 template object
        """

class AnsibleContext:
    """
    Template context with Ansible-specific variable resolution and scoping.
    
    Manages variable inheritance, scoping, and resolution order for
    templates while providing access to Ansible-specific data.
    """
```

### Template Filters

Ansible-specific Jinja2 filters for data transformation, formatting, and manipulation commonly needed in automation workflows.

```python { .api }
# String and text filters
def to_yaml(data, indent=2, default_flow_style=False):
    """
    Convert data to YAML format.
    
    Parameters:
    - data: Data to convert
    - indent: YAML indentation
    - default_flow_style: Use flow style
    
    Returns:
    str: YAML representation
    """

def to_json(data, indent=None, sort_keys=False):
    """
    Convert data to JSON format.
    
    Parameters:
    - data: Data to convert  
    - indent: JSON indentation
    - sort_keys: Sort dictionary keys
    
    Returns:
    str: JSON representation
    """

def regex_replace(value, pattern, replacement, ignorecase=False, multiline=False):
    """
    Replace text using regular expressions.
    
    Parameters:
    - value: Input string
    - pattern: Regex pattern
    - replacement: Replacement string
    - ignorecase: Case insensitive matching
    - multiline: Multiline mode
    
    Returns:
    str: String with replacements
    """

def regex_search(value, pattern, groups=None, ignorecase=False, multiline=False):
    """
    Search for regex pattern in string.
    
    Parameters:
    - value: Input string
    - pattern: Regex pattern
    - groups: Groups to extract
    - ignorecase: Case insensitive matching
    - multiline: Multiline mode
    
    Returns:
    str|list: Match result or groups
    """

def b64encode(data):
    """
    Base64 encode data.
    
    Parameters:
    - data: Data to encode
    
    Returns:
    str: Base64 encoded string
    """

def b64decode(data):
    """
    Base64 decode data.
    
    Parameters:
    - data: Data to decode
    
    Returns:
    str: Decoded string
    """

# List and dictionary filters
def map(attribute, iterable):
    """
    Extract attribute from list of objects.
    
    Parameters:
    - attribute: Attribute name to extract
    - iterable: List of objects
    
    Returns:
    list: Extracted values
    """

def select(test, iterable):
    """
    Filter list items by test condition.
    
    Parameters:
    - test: Test condition
    - iterable: List to filter
    
    Returns:
    list: Filtered items
    """

def reject(test, iterable):
    """
    Reject list items by test condition.
    
    Parameters:
    - test: Test condition
    - iterable: List to filter
    
    Returns:
    list: Remaining items
    """

def combine(*dicts, recursive=False, list_merge='replace'):
    """
    Combine multiple dictionaries.
    
    Parameters:
    - dicts: Dictionaries to combine
    - recursive: Recursive merging
    - list_merge: List merge strategy
    
    Returns:
    dict: Combined dictionary
    """

# Network and system filters
def ipaddr(value, query=''):
    """
    IP address manipulation and validation.
    
    Parameters:
    - value: IP address or network
    - query: Query type (network, host, etc.)
    
    Returns:
    str: Processed IP address
    """

def hash(data, hashtype='sha1'):
    """
    Generate hash of data.
    
    Parameters:
    - data: Data to hash
    - hashtype: Hash algorithm
    
    Returns:
    str: Hash digest
    """

def password_hash(password, hashtype='sha512', salt=None):
    """
    Generate password hash.
    
    Parameters:
    - password: Password to hash
    - hashtype: Hash algorithm
    - salt: Salt value
    
    Returns:
    str: Password hash
    """
```

### Template Tests

Ansible-specific Jinja2 tests for conditional evaluation and data validation in templates and playbooks.

```python { .api }
# Type and value tests
def is_string(value):
    """Test if value is string"""

def is_number(value):
    """Test if value is number"""

def is_boolean(value):
    """Test if value is boolean"""

def is_list(value):
    """Test if value is list"""

def is_dict(value):
    """Test if value is dictionary"""

# Network tests
def is_ip(value):
    """
    Test if value is valid IP address.
    
    Parameters:
    - value: Value to test
    
    Returns:
    bool: True if valid IP address
    """

def is_ipv4(value):
    """Test if value is IPv4 address"""

def is_ipv6(value):
    """Test if value is IPv6 address"""

def is_mac(value):
    """Test if value is MAC address"""

# Version tests
def version_compare(value, version, operator='==', strict=False):
    """
    Compare version strings.
    
    Parameters:
    - value: Version to compare
    - version: Comparison version
    - operator: Comparison operator
    - strict: Strict version parsing
    
    Returns:
    bool: Comparison result
    """

def version(value, version, operator='=='):
    """Alias for version_compare"""

# File and path tests
def is_file(path):
    """Test if path is regular file"""

def is_dir(path):
    """Test if path is directory"""

def is_link(path):
    """Test if path is symbolic link"""

def exists(path):
    """Test if path exists"""

# Content tests
def match(value, pattern, ignorecase=False, multiline=False):
    """Test if value matches regex pattern"""

def search(value, pattern, ignorecase=False, multiline=False):
    """Test if pattern found in value"""

def regex(value, pattern, ignorecase=False, multiline=False):
    """Test regex pattern against value"""
```

### Template Functions and Globals

Global functions and variables available in all template contexts providing access to Ansible-specific functionality.

```python { .api }
# Template functions
def range(start, stop=None, step=1):
    """Generate range of numbers"""

def lipsum(n=5, html=True, min=20, max=100):
    """Generate lorem ipsum text"""

def dict(items):
    """Create dictionary from items"""

def list(items):
    """Convert items to list"""

# Ansible-specific globals
hostvars: dict       # All host variables
group_names: list    # Groups current host belongs to
groups: dict         # All groups and their hosts
inventory_hostname: str  # Current hostname
ansible_hostname: str    # Discovered hostname
ansible_facts: dict      # Gathered facts
play_hosts: list         # Hosts in current play
ansible_play_hosts: list    # All play hosts
ansible_play_batch: list   # Current batch of hosts
```

## Template Usage

### Variable Interpolation

```yaml
# Basic variable substitution
- name: "Install {{ package_name }}"
  package:
    name: "{{ package_name }}"
    state: present

# Complex expressions
- name: "Setup {{ inventory_hostname }}"
  template:
    src: config.j2
    dest: "/etc/{{ service_name }}/{{ inventory_hostname }}.conf"
  vars:
    config_file: "{{ service_name }}-{{ ansible_hostname }}.conf"
```

### Conditional Templates

```yaml
# Conditional content
- name: Configure service
  template:
    src: service.conf.j2
    dest: /etc/service.conf
  notify: restart service

# Template with conditionals
# service.conf.j2:
# {% if ssl_enabled %}
# ssl_certificate {{ ssl_cert_path }}
# ssl_certificate_key {{ ssl_key_path }}
# {% endif %}
# 
# {% for port in service_ports %}
# listen {{ port }}
# {% endfor %}
```

### Filters in Templates

```yaml
# Using filters
- name: Display formatted data
  debug:
    msg: |
      YAML: {{ my_dict | to_yaml }}
      JSON: {{ my_dict | to_json }}
      Base64: {{ secret_value | b64encode }}

# List processing
- name: Process user list
  debug:
    msg: "User {{ item }} has home {{ item | regex_replace('^(.+)$', '/home/\\1') }}"
  loop: "{{ users | map('extract', hostvars, 'username') | list }}"
```

### Tests in Conditionals

```yaml
# Using tests
- name: Check conditions
  debug:
    msg: "Processing {{ item }}"
  loop: "{{ server_list }}"
  when:
    - item is string
    - item is match('^web.*')
    - inventory_hostname is version('2.0', '>=')

# Network tests
- name: Configure network
  template:
    src: network.j2
    dest: /etc/network/interfaces
  when: ansible_default_ipv4.address is ip
```

### Complex Template Examples

```jinja2
{# config.j2 template #}
# Generated by Ansible on {{ ansible_date_time.date }}
# Host: {{ inventory_hostname }}

{% set server_config = {
    'web': {'port': 80, 'workers': 4},
    'api': {'port': 8080, 'workers': 2},
    'db': {'port': 5432, 'workers': 1}
} %}

{% for service_type in groups %}
{% if service_type in server_config %}
[{{ service_type }}]
{% for host in groups[service_type] %}
{{ host }} = {{ hostvars[host]['ansible_default_ipv4']['address'] }}:{{ server_config[service_type]['port'] }}
{% endfor %}
workers = {{ server_config[service_type]['workers'] }}

{% endif %}
{% endfor %}

# SSL Configuration
{% if ssl_enabled | default(false) %}
ssl_cert = {{ ssl_cert_path | default('/etc/ssl/certs/server.crt') }}
ssl_key = {{ ssl_key_path | default('/etc/ssl/private/server.key') }}
{% endif %}

# Environment-specific settings
{% if environment == 'production' %}
debug = false
log_level = warn
{% else %}
debug = true
log_level = debug
{% endif %}
```

## Template Security

### Trusted Templates

```python
# Template trust checking
from ansible.template import Templar
from ansible.errors import TemplateTrustCheckFailedError

templar = Templar(loader=loader, variables=variables)

try:
    # This will check template trust
    result = templar.template(untrusted_template)
except TemplateTrustCheckFailedError:
    print("Template from untrusted source rejected")
```

### Safe Template Processing

```python
# Safe templating with error handling
from ansible.template import Templar
from ansible.errors import AnsibleTemplateError

templar = Templar(loader=loader, variables=variables)

try:
    result = templar.template("{{ undefined_var }}", fail_on_undefined=True)
except AnsibleTemplateError as e:
    print(f"Template error: {e}")
```

## Usage Examples

### Basic Templating

```python
from ansible.template import Templar
from ansible.parsing.dataloader import DataLoader

# Initialize components
loader = DataLoader()
variables = {
    'service_name': 'nginx',
    'port': 80,
    'ssl_enabled': True
}

# Create templater
templar = Templar(loader=loader, variables=variables)

# Template strings
result = templar.template("Service {{ service_name }} on port {{ port }}")
print(result)  # "Service nginx on port 80"

# Template with conditionals
template = "{% if ssl_enabled %}HTTPS{% else %}HTTP{% endif %} enabled"
result = templar.template(template)
print(result)  # "HTTPS enabled"
```

### Advanced Templating

```python
# Template complex data structures
data = {
    'config': {
        'servers': [
            {'name': 'web1', 'ip': '192.168.1.10'},
            {'name': 'web2', 'ip': '192.168.1.11'}
        ]
    },
    'template_var': '{{ config.servers | map(attribute="name") | join(",") }}'
}

result = templar.template(data)
print(result['template_var'])  # "web1,web2"

# Check if data needs templating
needs_template = templar.is_template("{{ service_name }}")
print(needs_template)  # True

no_template = templar.is_template("static_string")
print(no_template)  # False
```