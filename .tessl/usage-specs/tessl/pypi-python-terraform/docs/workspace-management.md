# Workspace Management

Terraform workspace operations for managing multiple environments and configurations within the same terraform project. Workspaces allow you to manage different states for the same configuration (e.g., dev, staging, prod environments).

## Capabilities

### Switch to Workspace

Switches the current terraform workspace to an existing workspace.

```python { .api }
def set_workspace(self, workspace: str, *args, **kwargs) -> CommandOutput:
    """
    Switch to an existing Terraform workspace.

    Args:
        workspace: Name of the workspace to switch to
        *args: Additional positional arguments
        **kwargs: Additional terraform options

    Returns:
        Tuple of (return_code, stdout, stderr)

    Raises:
        TerraformCommandError: If workspace doesn't exist or switch fails
    """
```

Usage example:

```python
# Switch to production workspace
return_code, stdout, stderr = tf.set_workspace('production')

# Switch to staging workspace
return_code, stdout, stderr = tf.set_workspace('staging')
```

### Create New Workspace

Creates a new terraform workspace and optionally switches to it.

```python { .api }
def create_workspace(self, workspace: str, *args, **kwargs) -> CommandOutput:
    """
    Create a new Terraform workspace.

    Args:
        workspace: Name of the workspace to create
        *args: Additional positional arguments
        **kwargs: Additional terraform options

    Returns:
        Tuple of (return_code, stdout, stderr)

    Raises:
        TerraformCommandError: If workspace already exists or creation fails
    """
```

Usage examples:

```python
# Create a new workspace for development
return_code, stdout, stderr = tf.create_workspace('development')

# Create a new workspace for a feature branch
return_code, stdout, stderr = tf.create_workspace('feature-auth-system')
```

### Delete Workspace

Deletes an existing terraform workspace. Cannot delete the current workspace - you must switch to another workspace first.

```python { .api }
def delete_workspace(self, workspace: str, *args, **kwargs) -> CommandOutput:
    """
    Delete a Terraform workspace.

    Args:
        workspace: Name of the workspace to delete
        *args: Additional positional arguments
        **kwargs: Additional terraform options

    Returns:
        Tuple of (return_code, stdout, stderr)

    Raises:
        TerraformCommandError: If workspace is current workspace, doesn't exist, or deletion fails
    """
```

Usage examples:

```python
# Delete an old feature workspace
return_code, stdout, stderr = tf.delete_workspace('feature-old-system')

# Delete a temporary testing workspace
return_code, stdout, stderr = tf.delete_workspace('temp-testing')
```

### Show Current Workspace

Shows the name of the currently active terraform workspace.

```python { .api }
def show_workspace(self, **kwargs) -> CommandOutput:
    """
    Show the current Terraform workspace name.

    Args:
        **kwargs: Additional terraform options

    Returns:
        Tuple of (return_code, stdout, stderr)
        stdout contains the workspace name
    """
```

Usage example:

```python
# Get current workspace name
return_code, stdout, stderr = tf.show_workspace()
if return_code == 0:
    current_workspace = stdout.strip()
    print(f"Current workspace: {current_workspace}")
```

## Workspace Workflow Examples

### Environment Management

```python
from python_terraform import Terraform

tf = Terraform(working_dir='/path/to/terraform/project')

# Initialize the project
tf.init()

# Create environments if they don't exist
environments = ['development', 'staging', 'production']
for env in environments:
    try:
        tf.create_workspace(env)
        print(f"Created workspace: {env}")
    except TerraformCommandError:
        print(f"Workspace {env} already exists")

# Deploy to each environment
for env in environments:
    print(f"Deploying to {env}")

    # Switch to environment workspace
    tf.set_workspace(env)

    # Apply with environment-specific variables
    tf.apply(var_file=f'{env}.tfvars')
```

### Feature Branch Workflow

```python
import subprocess

# Get current git branch
git_branch = subprocess.check_output(['git', 'rev-parse', '--abbrev-ref', 'HEAD']).decode().strip()
workspace_name = f'feature-{git_branch}'

# Create workspace for feature branch
try:
    tf.create_workspace(workspace_name)
    print(f"Created workspace for branch: {workspace_name}")
except TerraformCommandError:
    tf.set_workspace(workspace_name)
    print(f"Using existing workspace: {workspace_name}")

# Deploy feature branch infrastructure
tf.apply(var={'environment': 'feature', 'branch': git_branch})
```

### Workspace Cleanup

```python
# List and clean up old workspaces
# Note: This uses the generic cmd method since there's no built-in list method

# Get list of workspaces
return_code, stdout, stderr = tf.cmd('workspace', 'list')
workspaces = [ws.strip().lstrip('* ') for ws in stdout.splitlines() if ws.strip()]

# Delete old feature workspaces
for workspace in workspaces:
    if workspace.startswith('feature-') and workspace != current_workspace:
        print(f"Cleaning up old workspace: {workspace}")
        tf.delete_workspace(workspace)
```

## Error Handling

Workspace operations can fail for several reasons:

- **Workspace already exists** (create)
- **Workspace doesn't exist** (set, delete)
- **Attempting to delete current workspace** (delete)

```python
try:
    tf.create_workspace('my-environment')
except TerraformCommandError as e:
    if 'already exists' in e.err:
        print("Workspace already exists, switching to it")
        tf.set_workspace('my-environment')
    else:
        raise
```