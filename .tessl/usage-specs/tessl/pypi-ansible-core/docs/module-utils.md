# Module Utilities

Ansible Core's module utilities provide comprehensive shared libraries for module development including argument parsing, JSON handling, text conversion, network utilities, validation, platform abstraction, and common functionality used across all Ansible modules.

## Capabilities

### Basic Module Framework

Core module utilities providing the foundation for all Ansible module development with argument parsing, result formatting, and platform abstraction.

```python { .api }
class AnsibleModule:
    """
    Base class for all Ansible modules providing common functionality.
    
    Parameters:
    - argument_spec: Module argument specification
    - bypass_checks: Skip argument validation
    - no_log: Disable logging of arguments
    - check_invalid_arguments: Validate unknown arguments
    - mutually_exclusive: Mutually exclusive argument groups
    - required_together: Arguments required together
    - required_one_of: Require at least one of arguments
    - add_file_common_args: Add common file arguments
    - supports_check_mode: Module supports check mode
    
    Attributes:
    - params: Parsed module parameters
    - check_mode: Whether in check mode
    - diff_mode: Whether in diff mode
    """
    
    def __init__(self, argument_spec, bypass_checks=False, no_log=False,
                 check_invalid_arguments=None, mutually_exclusive=None,
                 required_together=None, required_one_of=None,
                 add_file_common_args=False, supports_check_mode=False):
        """Initialize module with argument specification"""
    
    def exit_json(self, **kwargs):
        """
        Exit module with success result.
        
        Parameters:
        - kwargs: Result data (changed, msg, etc.)
        """
    
    def fail_json(self, msg, **kwargs):
        """
        Exit module with failure result.
        
        Parameters:
        - msg: Failure message
        - kwargs: Additional result data
        """
    
    def run_command(self, args, check_rc=True, close_fds=True, executable=None,
                    data=None, binary_data=False, path_prefix=None, cwd=None,
                    use_unsafe_shell=False, prompt_regex=None, environ_update=None,
                    umask=None, encoding='utf-8', errors='surrogateescape'):
        """
        Execute command and return result.
        
        Parameters:
        - args: Command arguments
        - check_rc: Check return code
        - close_fds: Close file descriptors
        - executable: Shell executable
        - data: Input data
        - binary_data: Handle binary data
        - path_prefix: PATH prefix
        - cwd: Working directory
        - use_unsafe_shell: Allow shell injection
        - prompt_regex: Regex for prompts
        - environ_update: Environment updates
        - umask: Process umask
        - encoding: Text encoding
        - errors: Error handling
        
        Returns:
        tuple: (return_code, stdout, stderr)
        """
    
    def get_bin_path(self, arg, required=False, opt_dirs=None):
        """
        Find binary in PATH.
        
        Parameters:
        - arg: Binary name
        - required: Whether binary is required
        - opt_dirs: Additional directories to search
        
        Returns:
        str: Path to binary or None
        """
    
    def boolean(self, arg):
        """
        Convert argument to boolean.
        
        Parameters:
        - arg: Value to convert
        
        Returns:
        bool: Boolean value
        """
    
    def md5(self, filename):
        """
        Calculate MD5 hash of file.
        
        Parameters:
        - filename: File path
        
        Returns:
        str: MD5 hash
        """
    
    def sha1(self, filename):
        """
        Calculate SHA1 hash of file.
        
        Parameters:
        - filename: File path
        
        Returns:
        str: SHA1 hash
        """
    
    def backup_file(self, fn):
        """
        Create backup of file.
        
        Parameters:
        - fn: File path
        
        Returns:
        str: Backup file path
        """
    
    def cleanup(self, tmpfile):
        """
        Clean up temporary files.
        
        Parameters:
        - tmpfile: Temporary file path
        """
```

### Argument Specification and Validation

Comprehensive argument parsing and validation system supporting complex argument relationships, type checking, and input sanitization.

```python { .api }
def check_required_arguments(argument_spec, parameters):
    """
    Check that all required arguments are provided.
    
    Parameters:
    - argument_spec: Argument specification
    - parameters: Provided parameters
    
    Raises:
    AnsibleError: If required arguments missing
    """

def check_type_str(value):
    """
    Ensure value is string type.
    
    Parameters:
    - value: Value to check
    
    Returns:
    str: String value
    """

def check_type_list(value):
    """
    Ensure value is list type.
    
    Parameters:
    - value: Value to check
    
    Returns:
    list: List value
    """

def check_type_dict(value):
    """
    Ensure value is dictionary type.
    
    Parameters:
    - value: Value to check
    
    Returns:
    dict: Dictionary value
    """

def check_type_bool(value):
    """
    Convert value to boolean.
    
    Parameters:
    - value: Value to convert
    
    Returns:
    bool: Boolean value
    """

def check_type_int(value):
    """
    Convert value to integer.
    
    Parameters:
    - value: Value to convert
    
    Returns:
    int: Integer value
    """

def check_type_float(value):
    """
    Convert value to float.
    
    Parameters:
    - value: Value to convert
    
    Returns:
    float: Float value
    """

def check_type_path(value):
    """
    Validate and expand file path.
    
    Parameters:
    - value: Path to validate
    
    Returns:
    str: Validated path
    """
```

### Text Processing and Conversion

Text handling utilities for encoding conversion, string manipulation, and cross-platform text processing.

```python { .api }
def to_bytes(obj, encoding='utf-8', errors='surrogateescape', nonstring='simplerepr'):
    """
    Convert object to bytes.
    
    Parameters:
    - obj: Object to convert
    - encoding: Text encoding
    - errors: Error handling
    - nonstring: Non-string handling
    
    Returns:
    bytes: Byte representation
    """

def to_text(obj, encoding='utf-8', errors='surrogateescape', nonstring='simplerepr'):
    """
    Convert object to text string.
    
    Parameters:
    - obj: Object to convert
    - encoding: Text encoding
    - errors: Error handling
    - nonstring: Non-string handling
    
    Returns:
    str: Text representation
    """

def to_native(obj, encoding='utf-8', errors='surrogateescape', nonstring='simplerepr'):
    """
    Convert object to native string type.
    
    Parameters:
    - obj: Object to convert
    - encoding: Text encoding
    - errors: Error handling
    - nonstring: Non-string handling
    
    Returns:
    str: Native string
    """
```

### JSON Handling

JSON processing utilities with enhanced error handling and Ansible-specific serialization support.

```python { .api }
def load_json(data):
    """
    Load JSON data with error handling.
    
    Parameters:
    - data: JSON string
    
    Returns:
    object: Parsed JSON data
    
    Raises:
    ValueError: If JSON parsing fails
    """

def dump_json(obj, indent=None):
    """
    Dump object to JSON string.
    
    Parameters:
    - obj: Object to serialize
    - indent: JSON indentation
    
    Returns:
    str: JSON string
    """

class AnsibleJSONEncoder:
    """JSON encoder with Ansible-specific type handling"""
    
    def default(self, obj):
        """Handle Ansible-specific object types"""
```

### Network Utilities

Network-related utilities for IP address validation, network calculations, and network interface operations.

```python { .api }
def is_ip(address):
    """
    Check if string is valid IP address.
    
    Parameters:
    - address: Address to check
    
    Returns:
    bool: True if valid IP
    """

def is_ipv4(address):
    """Check if address is IPv4"""

def is_ipv6(address):
    """Check if address is IPv6"""

def get_network_address(ip, prefix):
    """
    Calculate network address from IP and prefix.
    
    Parameters:
    - ip: IP address
    - prefix: Network prefix
    
    Returns:
    str: Network address
    """

def get_network_size(prefix):
    """
    Get network size from prefix.
    
    Parameters:
    - prefix: Network prefix
    
    Returns:
    int: Number of addresses
    """
```

### File and Directory Operations

File system utilities for cross-platform file operations, permission handling, and path manipulation.

```python { .api }
def mkstemp(suffix="", prefix="tmp", dir=None):
    """
    Create temporary file.
    
    Parameters:
    - suffix: File suffix
    - prefix: File prefix
    - dir: Directory for temp file
    
    Returns:
    tuple: (file_descriptor, path)
    """

def mkdtemp(suffix="", prefix="tmp", dir=None):
    """
    Create temporary directory.
    
    Parameters:
    - suffix: Directory suffix
    - prefix: Directory prefix
    - dir: Parent directory
    
    Returns:
    str: Temporary directory path
    """

def cleanup_tmp_file(path):
    """
    Clean up temporary file.
    
    Parameters:
    - path: File path to clean up
    """

def set_mode_if_different(path, mode, changed):
    """
    Set file mode if different.
    
    Parameters:
    - path: File path
    - mode: Desired mode
    - changed: Whether file was changed
    
    Returns:
    bool: True if mode was changed
    """

def set_owner_if_different(path, owner, changed):
    """
    Set file owner if different.
    
    Parameters:
    - path: File path
    - owner: Desired owner
    - changed: Whether file was changed
    
    Returns:
    bool: True if owner was changed
    """

def set_group_if_different(path, group, changed):
    """
    Set file group if different.
    
    Parameters:
    - path: File path
    - group: Desired group
    - changed: Whether file was changed
    
    Returns:
    bool: True if group was changed
    """
```

### Dictionary Transformations

Dictionary manipulation utilities for merging, flattening, and transforming data structures commonly used in automation.

```python { .api }
def dict_merge(base_dict, other_dict):
    """
    Recursively merge dictionaries.
    
    Parameters:
    - base_dict: Base dictionary
    - other_dict: Dictionary to merge
    
    Returns:
    dict: Merged dictionary
    """

def flatten_dict(d, separator='.'):
    """
    Flatten nested dictionary.
    
    Parameters:
    - d: Dictionary to flatten
    - separator: Key separator
    
    Returns:
    dict: Flattened dictionary
    """

def camel_dict_to_snake_dict(camel_dict):
    """
    Convert camelCase keys to snake_case.
    
    Parameters:
    - camel_dict: Dictionary with camelCase keys
    
    Returns:
    dict: Dictionary with snake_case keys
    """

def snake_dict_to_camel_dict(snake_dict, capitalize_first=False):
    """
    Convert snake_case keys to camelCase.
    
    Parameters:
    - snake_dict: Dictionary with snake_case keys
    - capitalize_first: Capitalize first letter
    
    Returns:
    dict: Dictionary with camelCase keys
    """
```

### Process and System Utilities

System-level utilities for process management, signal handling, and platform-specific operations.

```python { .api }
def get_platform():
    """
    Get current platform name.
    
    Returns:
    str: Platform name (Linux, Darwin, Windows, etc.)
    """

def get_distribution():
    """
    Get Linux distribution information.
    
    Returns:
    tuple: (name, version, codename)
    """

def get_all_subclasses(cls):
    """
    Get all subclasses of a class.
    
    Parameters:
    - cls: Base class
    
    Returns:
    set: All subclasses
    """

def run_cmd(module, args, **kwargs):
    """
    Run command using module's run_command method.
    
    Parameters:
    - module: AnsibleModule instance
    - args: Command arguments
    - kwargs: Additional options
    
    Returns:
    tuple: (return_code, stdout, stderr)
    """
```

### Validation Utilities

Input validation and sanitization utilities for securing module inputs and ensuring data integrity.

```python { .api }
def check_required_if(parameters, argument_spec):
    """
    Check conditional requirements.
    
    Parameters:
    - parameters: Module parameters
    - argument_spec: Argument specification
    
    Raises:
    AnsibleError: If requirements not met
    """

def check_required_one_of(parameters, required_one_of):
    """
    Check that one of required arguments is provided.
    
    Parameters:
    - parameters: Module parameters
    - required_one_of: Required argument groups
    
    Raises:
    AnsibleError: If no required arguments provided
    """

def check_required_together(parameters, required_together):
    """
    Check that related arguments are provided together.
    
    Parameters:
    - parameters: Module parameters
    - required_together: Related argument groups
    
    Raises:
    AnsibleError: If related arguments not together
    """

def check_mutually_exclusive(parameters, mutually_exclusive):
    """
    Check that mutually exclusive arguments are not both provided.
    
    Parameters:
    - parameters: Module parameters
    - mutually_exclusive: Mutually exclusive groups
    
    Raises:
    AnsibleError: If exclusive arguments both provided
    """

def sanitize_keys(obj, no_log_strings):
    """
    Remove sensitive data from object.
    
    Parameters:
    - obj: Object to sanitize
    - no_log_strings: Sensitive strings to remove
    
    Returns:
    object: Sanitized object
    """
```

## Module Development Patterns

### Basic Module Structure

```python
#!/usr/bin/python
# -*- coding: utf-8 -*-

from ansible.module_utils.basic import AnsibleModule

DOCUMENTATION = '''
---
module: my_module
short_description: Example module
description:
    - This is an example module
options:
    name:
        description:
            - Name parameter
        required: true
        type: str
    state:
        description:
            - Desired state
        choices: ['present', 'absent']
        default: present
        type: str
'''

EXAMPLES = '''
- name: Ensure resource is present
  my_module:
    name: example
    state: present
'''

RETURN = '''
changed:
    description: Whether changes were made
    type: bool
    returned: always
message:
    description: Result message
    type: str
    returned: always
'''

def main():
    argument_spec = dict(
        name=dict(type='str', required=True),
        state=dict(type='str', default='present', choices=['present', 'absent'])
    )
    
    module = AnsibleModule(
        argument_spec=argument_spec,
        supports_check_mode=True
    )
    
    name = module.params['name']
    state = module.params['state']
    changed = False
    
    if module.check_mode:
        module.exit_json(changed=changed, msg="Check mode - no changes made")
    
    # Module logic here
    if state == 'present':
        # Create/update resource
        changed = True
        msg = f"Resource {name} created"
    else:
        # Remove resource
        changed = True
        msg = f"Resource {name} removed"
    
    module.exit_json(changed=changed, msg=msg)

if __name__ == '__main__':
    main()
```

### Advanced Module with Validation

```python
from ansible.module_utils.basic import AnsibleModule
from ansible.module_utils.common.validation import check_required_arguments

def validate_parameters(module):
    """Custom parameter validation"""
    params = module.params
    
    if params['state'] == 'present' and not params.get('config'):
        module.fail_json(msg="config required when state is present")
    
    if params.get('port') and not (1 <= params['port'] <= 65535):
        module.fail_json(msg="port must be between 1 and 65535")

def main():
    argument_spec = dict(
        name=dict(type='str', required=True),
        state=dict(type='str', default='present', choices=['present', 'absent']),
        config=dict(type='dict'),
        port=dict(type='int'),
        enable_ssl=dict(type='bool', default=False),
        ssl_cert=dict(type='path'),
        ssl_key=dict(type='path', no_log=True)
    )
    
    module = AnsibleModule(
        argument_spec=argument_spec,
        supports_check_mode=True,
        required_together=[('ssl_cert', 'ssl_key')],
        required_if=[('enable_ssl', True, ('ssl_cert', 'ssl_key'))]
    )
    
    # Custom validation
    validate_parameters(module)
    
    # Module implementation
    result = {'changed': False}
    
    try:
        # Execute module logic
        if module.params['state'] == 'present':
            # Implementation here
            result['changed'] = True
            result['msg'] = 'Resource created successfully'
        
        module.exit_json(**result)
    
    except Exception as e:
        module.fail_json(msg=f"Module failed: {str(e)}")

if __name__ == '__main__':
    main()
```

## Usage Examples

### Using Module Utils in Custom Modules

```python
from ansible.module_utils.basic import AnsibleModule
from ansible.module_utils.common.text.converters import to_text, to_bytes
from ansible.module_utils.common.validation import check_type_dict
from ansible.module_utils.common.dict_transformations import dict_merge
import json

def process_config(module, config_data):
    """Process configuration with utilities"""
    
    # Validate input
    config = check_type_dict(config_data)
    
    # Convert text encoding
    processed_config = {}
    for key, value in config.items():
        key_text = to_text(key)
        value_text = to_text(value) if isinstance(value, (str, bytes)) else value
        processed_config[key_text] = value_text
    
    # Merge with defaults
    defaults = {'timeout': 30, 'retries': 3}
    final_config = dict_merge(defaults, processed_config)
    
    return final_config

def run_external_command(module, cmd):
    """Execute external command safely"""
    
    rc, stdout, stderr = module.run_command(cmd, check_rc=False)
    
    if rc != 0:
        module.fail_json(
            msg=f"Command failed: {cmd}",
            rc=rc,
            stdout=stdout,
            stderr=stderr
        )
    
    return to_text(stdout).strip()
```

### Error Handling and Logging

```python
def safe_operation(module):
    """Example of safe operation with error handling"""
    
    try:
        # Risky operation
        result = perform_operation()
        
        # Sanitize sensitive data
        from ansible.module_utils.common.parameters import sanitize_keys
        safe_result = sanitize_keys(result, ['password', 'secret'])
        
        return safe_result
        
    except Exception as e:
        module.fail_json(
            msg=f"Operation failed: {str(e)}",
            exception=traceback.format_exc()
        )
```