# Core Terraform Operations

Essential terraform commands that form the core infrastructure lifecycle: initialization, planning, applying changes, and destruction. These operations are the foundation of terraform workflow automation.

## Capabilities

### Initialize Working Directory

Initializes a terraform working directory by downloading providers, modules, and configuring backends. This is typically the first command run in any terraform project.

```python { .api }
def init(self, dir_or_plan: Optional[str] = None, backend_config: Optional[Dict[str, str]] = None,
         reconfigure: Type[TerraformFlag] = IsFlagged, backend: bool = True, **kwargs) -> CommandOutput:
    """
    Initialize a Terraform working directory.

    Args:
        dir_or_plan: Path to terraform directory (defaults to working_dir)
        backend_config: Dictionary of backend configuration options
        reconfigure: Force reconfiguration of backend (default: IsFlagged)
        backend: Whether to use backend settings (default: True)
        **kwargs: Additional terraform options

    Returns:
        Tuple of (return_code, stdout, stderr)
    """
```

Usage examples:

```python
# Basic initialization
tf = Terraform(working_dir='/path/to/terraform')
return_code, stdout, stderr = tf.init()

# Initialize with backend configuration
return_code, stdout, stderr = tf.init(
    backend_config={
        'access_key': 'myaccesskey',
        'secret_key': 'mysecretkey',
        'bucket': 'mybucketname'
    }
)

# Initialize without backend
return_code, stdout, stderr = tf.init(backend=False)
```

### Plan Changes

Creates an execution plan showing what terraform will do when applied. This allows reviewing changes before applying them.

```python { .api }
def plan(self, dir_or_plan: Optional[str] = None, detailed_exitcode: Type[TerraformFlag] = IsFlagged,
         **kwargs) -> CommandOutput:
    """
    Create a Terraform execution plan.

    Args:
        dir_or_plan: Path to terraform directory or plan file
        detailed_exitcode: Return detailed exit codes (default: IsFlagged)
        **kwargs: Additional terraform options (var, var_file, target, etc.)

    Returns:
        Tuple of (return_code, stdout, stderr)

        Exit codes with detailed_exitcode=IsFlagged:
        - 0: No changes
        - 1: Error
        - 2: Changes present
    """
```

Usage examples:

```python
# Basic plan
return_code, stdout, stderr = tf.plan()

# Plan with variables
return_code, stdout, stderr = tf.plan(
    var={'environment': 'prod', 'instance_count': '3'}
)

# Plan targeting specific resources
return_code, stdout, stderr = tf.plan(
    target=['aws_instance.web', 'aws_security_group.web_sg']
)

# Plan with variable file
return_code, stdout, stderr = tf.plan(
    var_file='prod.tfvars'
)
```

### Apply Changes

Applies the terraform configuration, creating, updating, or deleting resources as specified in the configuration.

```python { .api }
def apply(self, dir_or_plan: Optional[str] = None, input: bool = False, skip_plan: bool = True,
          no_color: Type[TerraformFlag] = IsFlagged, **kwargs) -> CommandOutput:
    """
    Apply Terraform configuration changes.

    Args:
        dir_or_plan: Path to terraform directory or plan file
        input: Enable input prompts for missing variables (default: False)
        skip_plan: Skip planning phase and apply directly (default: True)
        no_color: Disable colored output (default: IsFlagged)
        **kwargs: Additional terraform options

    Returns:
        Tuple of (return_code, stdout, stderr)
    """
```

Usage examples:

```python
# Basic apply (auto-approved)
return_code, stdout, stderr = tf.apply()

# Apply with variables
return_code, stdout, stderr = tf.apply(
    var={'environment': 'staging', 'region': 'us-west-2'}
)

# Apply a specific plan file
return_code, stdout, stderr = tf.apply('saved-plan.tfplan')

# Apply targeting specific resources
return_code, stdout, stderr = tf.apply(
    target=['aws_instance.database']
)

# Apply with custom parallelism
return_code, stdout, stderr = tf.apply(parallelism=5)
```

### Destroy Infrastructure

Destroys all terraform-managed infrastructure or specific targeted resources.

```python { .api }
def destroy(self, dir_or_plan: Optional[str] = None, force: Type[TerraformFlag] = IsFlagged,
            **kwargs) -> CommandOutput:
    """
    Destroy Terraform-managed infrastructure.

    Args:
        dir_or_plan: Path to terraform directory
        force: Skip confirmation prompts (default: IsFlagged)
        **kwargs: Additional terraform options

    Returns:
        Tuple of (return_code, stdout, stderr)
    """
```

Usage examples:

```python
# Destroy all resources
return_code, stdout, stderr = tf.destroy()

# Destroy specific resources only
return_code, stdout, stderr = tf.destroy(
    target=['aws_instance.temp_server']
)

# Destroy with variables
return_code, stdout, stderr = tf.destroy(
    var={'environment': 'test'}
)
```

## Common Options

All core operations support these common terraform options:

- **var**: Dictionary of variables (`{'key': 'value'}`)
- **var_file**: Path to variable file or list of paths
- **target**: List of resource addresses to target
- **parallelism**: Number of concurrent operations
- **state**: Path to state file
- **no_color**: Disable colored output (use `IsFlagged`)
- **input**: Enable/disable input prompts (boolean)

## Error Handling

All operations raise `TerraformCommandError` on non-zero exit codes unless `raise_on_error=False` is specified:

```python
try:
    return_code, stdout, stderr = tf.apply()
except TerraformCommandError as e:
    print(f"Apply failed with code {e.returncode}")
    print(f"Error: {e.err}")
```