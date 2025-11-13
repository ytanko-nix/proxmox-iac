# Python Terraform

A Python wrapper for HashiCorp's Terraform command-line tool that enables developers to execute Terraform commands programmatically within Python applications. This library provides a comprehensive interface that mirrors Terraform's CLI functionality, supporting all standard commands with proper argument handling and Python-friendly option conversion.

## Package Information

- **Package Name**: python-terraform
- **Language**: Python
- **Installation**: `pip install python-terraform`
- **Repository**: https://github.com/beelit94/python-terraform

## Core Imports

```python
from python_terraform import Terraform, IsFlagged, IsNotFlagged
```

For all exports including state management and error handling:

```python
from python_terraform import (
    Terraform,
    Tfstate,
    TerraformCommandError,
    VariableFiles,
    IsFlagged,
    IsNotFlagged
)
```

## Basic Usage

```python
from python_terraform import Terraform, IsFlagged

# Initialize terraform wrapper
tf = Terraform(working_dir='/path/to/terraform/project')

# Initialize terraform project
return_code, stdout, stderr = tf.init()

# Plan the changes
return_code, stdout, stderr = tf.plan()

# Apply the changes
return_code, stdout, stderr = tf.apply()

# Check outputs
outputs = tf.output()
print(outputs)

# Destroy infrastructure when done
return_code, stdout, stderr = tf.destroy()

# Using as context manager (automatically cleans up temp files)
with Terraform(working_dir='/path/to/terraform/project') as tf:
    tf.init()
    tf.apply()
```

## Architecture

The library follows a straightforward design centered around the main `Terraform` class:

- **Terraform**: Main wrapper class that provides methods for all terraform commands
- **Command Execution**: All terraform commands return a tuple of (return_code, stdout, stderr)
- **Option Handling**: Converts Python-style options (underscores) to terraform CLI flags (dashes)
- **Flag System**: Uses `IsFlagged`/`IsNotFlagged` sentinel values for boolean command-line flags
- **State Management**: Automatically reads and parses terraform state files after successful operations
- **Variable Files**: Manages temporary `.tfvars.json` files for complex variable passing

## Capabilities

### Core Terraform Operations

Essential terraform commands including init, plan, apply, and destroy. These form the core infrastructure lifecycle management functionality.

```python { .api }
def init(self, dir_or_plan: Optional[str] = None, backend_config: Optional[Dict[str, str]] = None,
         reconfigure: Type[TerraformFlag] = IsFlagged, backend: bool = True, **kwargs) -> CommandOutput
def plan(self, dir_or_plan: Optional[str] = None, detailed_exitcode: Type[TerraformFlag] = IsFlagged,
         **kwargs) -> CommandOutput
def apply(self, dir_or_plan: Optional[str] = None, input: bool = False, skip_plan: bool = True,
          no_color: Type[TerraformFlag] = IsFlagged, **kwargs) -> CommandOutput
def destroy(self, dir_or_plan: Optional[str] = None, force: Type[TerraformFlag] = IsFlagged,
            **kwargs) -> CommandOutput
```

[Core Operations](./core-operations.md)

### Workspace Management

Terraform workspace operations for managing multiple environments and configurations within the same terraform project.

```python { .api }
def set_workspace(self, workspace: str, *args, **kwargs) -> CommandOutput
def create_workspace(self, workspace: str, *args, **kwargs) -> CommandOutput
def delete_workspace(self, workspace: str, *args, **kwargs) -> CommandOutput
def show_workspace(self, **kwargs) -> CommandOutput
```

[Workspace Management](./workspace-management.md)

### Command Interface & Utilities

Generic command execution interface and utility functions for building terraform commands and managing execution.

```python { .api }
def cmd(self, cmd: str, *args, capture_output: Union[bool, str] = True,
        raise_on_error: bool = True, synchronous: bool = True, **kwargs) -> CommandOutput
def generate_cmd_string(self, cmd: str, *args, **kwargs) -> List[str]
def output(self, *args, capture_output: bool = True, **kwargs) -> Union[None, str, Dict[str, str], Dict[str, Dict[str, str]]]
```

[Command Interface](./command-interface.md)

### State File Management

Operations for reading and managing terraform state files, including parsing state data and accessing resource information.

```python { .api }
def read_state_file(self, file_path: Optional[str] = None) -> None
```

State file parsing through the `Tfstate` class:

```python { .api }
@staticmethod
def load_file(file_path: str) -> Tfstate
```

[State Management](./state-management.md)

## Terraform Class

The main `Terraform` class constructor accepts several parameters for configuring default behavior:

```python { .api }
class Terraform:
    def __init__(
        self,
        working_dir: Optional[str] = None,
        targets: Optional[Sequence[str]] = None,
        state: Optional[str] = None,
        variables: Optional[Dict[str, str]] = None,
        parallelism: Optional[str] = None,
        var_file: Optional[str] = None,
        terraform_bin_path: Optional[str] = None,
        is_env_vars_included: bool = True,
    ):
        """
        Initialize Terraform wrapper.

        Args:
            working_dir: Working directory for terraform operations
            targets: Default target resources for apply/destroy/plan
            state: Path to state file relative to working directory
            variables: Default variables for terraform commands
            parallelism: Default parallelism value for operations
            var_file: Default variable file path(s)
            terraform_bin_path: Path to terraform binary (default: "terraform")
            is_env_vars_included: Include environment variables in command execution
        """

    def __exit__(self, exc_type, exc_value, traceback) -> None:
        """Context manager exit - cleans up temporary variable files"""
```

## Types

```python { .api }
# Command output tuple type
CommandOutput = Tuple[Optional[int], Optional[str], Optional[str]]

# Flag classes for terraform boolean options
class TerraformFlag:
    """Base class for terraform flag values"""

class IsFlagged(TerraformFlag):
    """Sentinel class indicating a flag should be enabled"""

class IsNotFlagged(TerraformFlag):
    """Sentinel class indicating a flag should be disabled"""

# Custom exception for terraform command failures
class TerraformCommandError(subprocess.CalledProcessError):
    def __init__(self, ret_code: int, cmd: str, out: Optional[str], err: Optional[str]): ...
    out: Optional[str]
    err: Optional[str]

# Variable file manager for complex variable passing
class VariableFiles:
    def __init__(self): ...
    def create(self, variables: Dict[str, str]) -> str:
        """Create temporary .tfvars.json file and return filename"""
    def clean_up(self) -> None:
        """Remove all created temporary files"""

# Module constants
COMMAND_WITH_SUBCOMMANDS = {"workspace"}  # Commands that require subcommand handling
```

## Error Handling

By default, terraform commands that return non-zero exit codes will raise a `TerraformCommandError` exception. This can be disabled by passing `raise_on_error=False` to any command method.

```python
try:
    return_code, stdout, stderr = tf.apply()
except TerraformCommandError as e:
    print(f"Terraform command failed with return code {e.returncode}")
    print(f"Error output: {e.err}")
```