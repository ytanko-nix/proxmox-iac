# State Management

Operations for reading and managing terraform state files, including parsing state data and accessing resource information. Terraform state files contain the current state of your infrastructure and are critical for terraform's operation.

## Capabilities

### State File Reading

Read and parse terraform state files into accessible Python objects.

```python { .api }
def read_state_file(self, file_path: Optional[str] = None) -> None:
    """
    Read and parse terraform state file.

    Args:
        file_path: Path to state file relative to working directory.
                  If None, uses instance state setting or discovers automatically.

    Side Effects:
        Updates self.tfstate property with parsed state data

    State file discovery order:
        1. Provided file_path parameter
        2. Instance self.state setting
        3. .terraform/terraform.tfstate (for remote backends)
        4. terraform.tfstate (for local backends)
    """
```

Usage examples:

```python
# Read default state file
tf.read_state_file()

# Read specific state file
tf.read_state_file('prod.tfstate')

# Access state data after reading
if tf.tfstate:
    print(f"Terraform version: {tf.tfstate.terraform_version}")
    print(f"Serial: {tf.tfstate.serial}")
```

### Tfstate Class

The `Tfstate` class provides structured access to terraform state file data.

```python { .api }
class Tfstate:
    def __init__(self, data: Optional[Dict[str, str]] = None):
        """
        Initialize state object.

        Args:
            data: Parsed JSON data from state file
        """

    @staticmethod
    def load_file(file_path: str) -> Tfstate:
        """
        Load state file from disk.

        Args:
            file_path: Path to terraform state file

        Returns:
            Tfstate object with parsed data, or empty Tfstate if file doesn't exist
        """

    # Properties (dynamically set from state file data)
    tfstate_file: Optional[str]  # Path to loaded state file
    native_data: Optional[Dict[str, str]]  # Raw parsed JSON data
    # ... all other terraform state file fields are available as attributes
```

Usage examples:

```python
from python_terraform import Tfstate

# Load state file directly
state = Tfstate.load_file('/path/to/terraform.tfstate')

# Check if state file exists and has data
if state.native_data:
    print("State file loaded successfully")

    # Access state file fields (these vary based on terraform version)
    if hasattr(state, 'version'):
        print(f"State format version: {state.version}")
    if hasattr(state, 'terraform_version'):
        print(f"Terraform version: {state.terraform_version}")
    if hasattr(state, 'serial'):
        print(f"Serial: {state.serial}")
    if hasattr(state, 'lineage'):
        print(f"Lineage: {state.lineage}")

    # Access resources (structure depends on terraform version)
    if hasattr(state, 'resources'):
        print(f"Number of resources: {len(state.resources)}")
        for resource in state.resources:
            print(f"Resource: {resource.get('type', 'unknown')} - {resource.get('name', 'unknown')}")
else:
    print("State file not found or empty")
```

### Automatic State Loading

The Terraform class automatically loads state files after successful operations.

```python
# State is automatically loaded after successful operations
tf = Terraform(working_dir='/path/to/project')
tf.apply()

# State is now available
if tf.tfstate and tf.tfstate.native_data:
    # Access state data
    print("Resources in state:")
    if hasattr(tf.tfstate, 'resources'):
        for resource in tf.tfstate.resources:
            resource_type = resource.get('type', 'unknown')
            resource_name = resource.get('name', 'unknown')
            print(f"  {resource_type}.{resource_name}")
```

## State File Formats

Terraform state files are JSON documents with version-specific schemas. The library handles different state file formats automatically:

### State File Structure (varies by version)
```json
{
  "version": 4,
  "terraform_version": "1.0.0",
  "serial": 1,
  "lineage": "uuid-here",
  "outputs": {},
  "resources": []
}
```

### Common State File Fields

The exact fields available depend on your terraform version, but common fields include:

- **version**: State file format version
- **terraform_version**: Version of terraform that created the state
- **serial**: Incremental counter for state changes
- **lineage**: UUID that identifies the state lineage
- **outputs**: Terraform outputs
- **resources**: List of managed resources
- **modules**: Module information (older versions)

## Working with State Data

### Accessing Resource Information

```python
def get_resource_by_address(tf, resource_address):
    """Find a resource by its terraform address."""
    if not tf.tfstate or not tf.tfstate.native_data:
        return None

    if hasattr(tf.tfstate, 'resources'):
        for resource in tf.tfstate.resources:
            if resource.get('type') and resource.get('name'):
                address = f"{resource['type']}.{resource['name']}"
                if address == resource_address:
                    return resource
    return None

# Usage
tf.apply()
web_instance = get_resource_by_address(tf, 'aws_instance.web')
if web_instance:
    print(f"Instance ID: {web_instance.get('instances', [{}])[0].get('attributes', {}).get('id')}")
```

### Accessing Outputs

```python
def get_state_outputs(tf):
    """Extract outputs from state file."""
    if not tf.tfstate or not hasattr(tf.tfstate, 'outputs'):
        return {}

    outputs = {}
    for name, output_data in tf.tfstate.outputs.items():
        outputs[name] = output_data.get('value')
    return outputs

# Usage
tf.apply()
outputs = get_state_outputs(tf)
for name, value in outputs.items():
    print(f"{name}: {value}")
```

### State File Backup and Recovery

```python
import shutil
from datetime import datetime

def backup_state_file(tf):
    """Create a backup of the current state file."""
    if tf.tfstate and tf.tfstate.tfstate_file:
        timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
        backup_path = f"{tf.tfstate.tfstate_file}.backup.{timestamp}"
        shutil.copy2(tf.tfstate.tfstate_file, backup_path)
        print(f"State backed up to: {backup_path}")
        return backup_path
    return None

# Usage
backup_path = backup_state_file(tf)
try:
    tf.apply()
except TerraformCommandError:
    print("Apply failed, state backup available at:", backup_path)
```

## Error Handling

State file operations can fail for various reasons:

```python
from python_terraform import Tfstate, TerraformCommandError

# Handle missing state files
try:
    tf.read_state_file('nonexistent.tfstate')
except FileNotFoundError:
    print("State file not found")

# Handle corrupted state files
state = Tfstate.load_file('potentially-corrupted.tfstate')
if not state.native_data:
    print("State file is empty or corrupted")

# Handle state loading after failed operations
try:
    tf.apply()
except TerraformCommandError:
    # State may not be updated if apply failed
    print("Apply failed, state may be inconsistent")
    tf.read_state_file()  # Explicitly reload state
```

## Best Practices

### State File Safety
- Always backup state files before major operations
- Use remote backends for team environments
- Never manually edit state files
- Use terraform state commands for state manipulation

### Integration with Operations
```python
# The library automatically manages state loading
tf = Terraform(working_dir='/path/to/project')

# State is loaded after successful operations
ret, out, err = tf.apply()
if ret == 0:
    # tf.tfstate now contains current state
    print("Apply successful, state updated")
else:
    # State may not be updated
    print("Apply failed, state unchanged")
```