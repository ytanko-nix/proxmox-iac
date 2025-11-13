# Command Interface & Utilities

Generic command execution interface and utility functions for building terraform commands, managing execution, and retrieving outputs. This provides the foundation for all terraform operations and enables access to any terraform command.

## Capabilities

### Generic Command Execution

Execute any terraform command with full control over arguments, options, and execution behavior.

```python { .api }
def cmd(self, cmd: str, *args, capture_output: Union[bool, str] = True,
        raise_on_error: bool = True, synchronous: bool = True, **kwargs) -> CommandOutput:
    """
    Execute arbitrary terraform command.

    Args:
        cmd: Command and sub-command of terraform, separated by space
        *args: Positional arguments for the command
        capture_output: Output capture mode:
            - True: Capture stdout/stderr and return as strings
            - False: Print output to terminal in real-time, return None
            - "framework": No capture, return None for both streams
        raise_on_error: Raise TerraformCommandError on non-zero exit (default: True)
        synchronous: Wait for command completion (default: True)
        **kwargs: Command options converted to terraform flags

    Returns:
        Tuple of (return_code, stdout, stderr)

    Raises:
        TerraformCommandError: If command fails and raise_on_error=True
    """
```

Usage examples:

```python
# Execute import command
return_code, stdout, stderr = tf.cmd('import', 'aws_instance.example', 'i-1234567890abcdef0')

# Execute refresh command
return_code, stdout, stderr = tf.cmd('refresh', var={'environment': 'prod'})

# Execute validate command
return_code, stdout, stderr = tf.cmd('validate')

# Execute state operations
return_code, stdout, stderr = tf.cmd('state', 'list')
return_code, stdout, stderr = tf.cmd('state', 'show', 'aws_instance.example')

# Real-time output for long-running commands
return_code, stdout, stderr = tf.cmd('apply', capture_output=False)

# Non-blocking execution
return_code, stdout, stderr = tf.cmd('apply', synchronous=False)
```

### Command String Generation

Build terraform command strings without executing them, useful for debugging or custom execution workflows.

```python { .api }
def generate_cmd_string(self, cmd: str, *args, **kwargs) -> List[str]:
    """
    Generate terraform command arguments list without execution.

    Args:
        cmd: Command and sub-command of terraform, separated by space
        *args: Positional arguments for the command
        **kwargs: Command options converted to terraform flags

    Returns:
        List of command arguments suitable for subprocess execution
    """
```

Usage examples:

```python
# Generate apply command with options
cmd_args = tf.generate_cmd_string('apply',
                                  var={'env': 'prod'},
                                  no_color=IsFlagged,
                                  target=['aws_instance.web'])
print(' '.join(cmd_args))
# Output: terraform apply -var=env=prod -no-color -target=aws_instance.web

# Generate import command
cmd_args = tf.generate_cmd_string('import', 'aws_instance.example', 'i-1234567890abcdef0')
print(' '.join(cmd_args))
# Output: terraform import aws_instance.example i-1234567890abcdef0

# Generate plan command with variable file
cmd_args = tf.generate_cmd_string('plan', var_file='production.tfvars', out='prod.tfplan')
print(' '.join(cmd_args))
# Output: terraform plan -var-file=production.tfvars -out=prod.tfplan
```

### Output Retrieval

Retrieve terraform outputs with automatic JSON parsing and flexible return formats.

```python { .api }
def output(self, *args, capture_output: bool = True, **kwargs) -> Union[None, str, Dict[str, str], Dict[str, Dict[str, str]]]:
    """
    Retrieve terraform output values with JSON parsing.

    Args:
        *args: Optional output name. If provided, returns single output value.
        capture_output: Must be True for this method (default: True)
        full_value: If True and output name provided, return full output metadata
        **kwargs: Additional terraform output options

    Returns:
        - None: If command failed
        - str: Output value if name provided and full_value=False
        - Dict: Output metadata if name provided and full_value=True
        - Dict[str, Dict]: All outputs with metadata if no name provided

    Note: This method automatically adds -json flag and parses the result.
    """
```

Usage examples:

```python
# Get all outputs
outputs = tf.output()
if outputs:
    for name, output_data in outputs.items():
        print(f"{name}: {output_data['value']}")

# Get specific output value
database_url = tf.output('database_url')
print(f"Database URL: {database_url}")

# Get output with metadata
output_info = tf.output('database_url', full_value=True)
if output_info:
    print(f"Value: {output_info['value']}")
    print(f"Type: {output_info['type']}")
    print(f"Sensitive: {output_info['sensitive']}")
```

### Dynamic Method Access

Access any terraform command as a method through Python's `__getattr__` mechanism.

```python { .api }
def __getattr__(self, item: str) -> Callable:
    """
    Dynamically create methods for terraform commands.

    Terraform commands become Python methods:
    - Command names ending in '_cmd' are handled (import_cmd, etc.)
    - All other names are passed through as terraform commands

    Returns:
        Callable that executes the terraform command
    """
```

Usage examples:

```python
# These are equivalent:
return_code, stdout, stderr = tf.cmd('import', 'aws_instance.example', 'i-1234567890abcdef0')
return_code, stdout, stderr = tf.import_cmd('aws_instance.example', 'i-1234567890abcdef0')

# Other command examples
return_code, stdout, stderr = tf.validate_cmd()
return_code, stdout, stderr = tf.refresh_cmd()
return_code, stdout, stderr = tf.fmt_cmd(diff=True)
return_code, stdout, stderr = tf.graph_cmd()
return_code, stdout, stderr = tf.show_cmd()
```

## Option Conversion Rules

The library automatically converts Python-style options to terraform CLI flags:

### Naming Convention
- **Underscores to dashes**: `no_color` → `-no-color`
- **Method name handling**: Commands ending with `_cmd` have suffix removed

### Value Types
- **IsFlagged**: Adds flag without value (`no_color=IsFlagged` → `-no-color`)
- **IsNotFlagged/None**: Skips the option entirely
- **Boolean**: Converts to string (`refresh=True` → `-refresh=true`)
- **String/Number**: Adds as key-value pair (`parallelism=5` → `-parallelism=5`)
- **List**: Adds multiple flags (`target=['a', 'b']` → `-target=a -target=b`)
- **Dictionary for var**: Creates temporary variable file or individual flags
- **Dictionary for backend-config**: Individual backend config flags

### Examples
```python
# Python options
tf.plan(
    no_color=IsFlagged,
    detailed_exitcode=IsFlagged,
    refresh=True,
    var={'environment': 'prod', 'count': '3'},
    target=['aws_instance.web'],
    parallelism=5
)

# Equivalent terraform command:
# terraform plan -no-color -detailed-exitcode -refresh=true -var-file=temp_vars.tfvars.json -target=aws_instance.web -parallelism=5
```

## Error Handling and Execution Control

### Capture Modes
```python
# Capture output (default)
return_code, stdout, stderr = tf.cmd('plan')

# Real-time output to terminal
return_code, stdout, stderr = tf.cmd('apply', capture_output=False)
# stdout and stderr will be None, output goes to terminal

# Framework mode (no capture or display)
return_code, stdout, stderr = tf.cmd('validate', capture_output="framework")
```

### Error Control
```python
# Default: raise exception on error
try:
    return_code, stdout, stderr = tf.cmd('apply')
except TerraformCommandError as e:
    print(f"Command failed: {e.cmd}")
    print(f"Return code: {e.returncode}")
    print(f"Error output: {e.err}")

# Don't raise exception, handle manually
return_code, stdout, stderr = tf.cmd('plan', raise_on_error=False)
if return_code != 0:
    print(f"Plan failed with code {return_code}")
    print(f"Error: {stderr}")
```

### Asynchronous Execution
```python
# Start command without waiting
return_code, stdout, stderr = tf.cmd('apply', synchronous=False)
# All return values will be None
# Command continues running in background
```