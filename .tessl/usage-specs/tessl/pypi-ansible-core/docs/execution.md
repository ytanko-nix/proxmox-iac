# Execution Engine

Ansible Core's execution engine provides comprehensive task orchestration managing task queues, parallel execution, result collection, callback processing, and strategy selection for efficient automation execution across multiple hosts with result aggregation and error handling.

## Capabilities

### Task Queue Management

Central orchestration system managing task execution across multiple hosts with parallel processing, callback coordination, and comprehensive result collection.

```python { .api }
class TaskQueueManager:
    """
    Central task queue manager orchestrating playbook execution.
    
    Coordinates task execution across hosts, manages callbacks, and
    handles result collection with configurable parallelism and strategies.
    
    Attributes:
    - _inventory: Inventory manager
    - _variable_manager: Variable manager
    - _loader: DataLoader instance
    - _passwords: Authentication passwords
    - _stdout_callback: Primary output callback
    - _run_additional_callbacks: Whether to run additional callbacks
    - _run_tree: Whether to use run tree
    - _forks: Number of parallel processes
    """
    
    def __init__(self, inventory, variable_manager, loader, passwords=None,
                 stdout_callback=None, run_additional_callbacks=True, run_tree=False, forks=None):
        """
        Initialize task queue manager.
        
        Parameters:
        - inventory: InventoryManager instance
        - variable_manager: VariableManager instance
        - loader: DataLoader instance
        - passwords: Dictionary of passwords
        - stdout_callback: Primary output callback name
        - run_additional_callbacks: Enable additional callbacks
        - run_tree: Enable run tree output
        - forks: Number of parallel forks
        """
    
    def run(self, play):
        """
        Execute play with task queue management.
        
        Parameters:
        - play: Play object to execute
        
        Returns:
        int: Exit code (0 for success)
        """
    
    def cleanup(self):
        """Clean up task queue manager resources"""
    
    def send_callback(self, method_name, *args, **kwargs):
        """
        Send callback to all registered callbacks.
        
        Parameters:
        - method_name: Callback method name
        - args: Method arguments
        - kwargs: Method keyword arguments
        """
    
    def load_callbacks(self):
        """Load and initialize callback plugins"""
    
    def set_default_callbacks(self):
        """Set default callback configuration"""
```

### Playbook Execution

High-level playbook executor coordinating multiple plays with shared context, variable management, and comprehensive result tracking.

```python { .api }
class PlaybookExecutor:
    """
    High-level playbook executor managing multiple plays.
    
    Coordinates execution of all plays in a playbook with shared
    variable context and comprehensive result tracking.
    
    Attributes:
    - _playbooks: List of playbooks to execute
    - _inventory: Inventory manager
    - _variable_manager: Variable manager
    - _loader: DataLoader instance
    - _passwords: Authentication passwords
    """
    
    def __init__(self, playbooks, inventory, variable_manager, loader, passwords):
        """
        Initialize playbook executor.
        
        Parameters:
        - playbooks: List of playbook file paths
        - inventory: InventoryManager instance
        - variable_manager: VariableManager instance
        - loader: DataLoader instance
        - passwords: Dictionary of passwords
        """
    
    def run(self):
        """
        Execute all playbooks.
        
        Returns:
        int: Overall exit code
        """
    
    def _get_serialized_batches(self, play):
        """
        Get serialized host batches for play.
        
        Parameters:
        - play: Play object
        
        Returns:
        list: List of host batches
        """
```

### Task Execution

Individual task executor handling module dispatch, connection management, result processing, and error handling for single task execution.

```python { .api }
class TaskExecutor:
    """
    Execute individual tasks on specific hosts.
    
    Handles module execution, connection management, variable
    resolution, and result processing for single tasks.
    
    Attributes:
    - _host: Target host
    - _task: Task to execute
    - _job_vars: Task variables
    - _play_context: Play execution context
    - _new_stdin: Input stream
    - _loader: DataLoader instance
    - _shared_loader_obj: Shared plugin loader
    """
    
    def __init__(self, host, task, job_vars, play_context, new_stdin, loader, shared_loader_obj):
        """
        Initialize task executor.
        
        Parameters:
        - host: Target host object
        - task: Task object to execute
        - job_vars: Task execution variables
        - play_context: Play execution context
        - new_stdin: Input stream
        - loader: DataLoader instance
        - shared_loader_obj: Shared plugin loader
        """
    
    def run(self):
        """
        Execute task on target host.
        
        Returns:
        dict: Task execution result
        """
    
    def _get_connection(self):
        """
        Get connection to target host.
        
        Returns:
        Connection: Connection plugin instance
        """
    
    def _get_action_handler(self, connection, templar):
        """
        Get action handler for task.
        
        Parameters:
        - connection: Host connection
        - templar: Template engine
        
        Returns:
        ActionBase: Action plugin instance
        """
    
    def _execute_action(self, action, tmp, task_vars):
        """
        Execute action plugin.
        
        Parameters:
        - action: Action plugin instance
        - tmp: Temporary directory
        - task_vars: Task variables
        
        Returns:
        dict: Action result
        """
```

### Result Processing

Result collection and processing system managing task results, callback notifications, and statistics aggregation across all hosts.

```python { .api }
class TaskResult:
    """
    Container for task execution results.
    
    Encapsulates all information about task execution including
    host, task, result data, and execution metadata.
    
    Attributes:
    - _host: Host that executed the task
    - _task: Task that was executed
    - _return_data: Task execution result data
    - task_name: Name of executed task
    """
    
    def __init__(self, host, task, return_data, task_fields=None):
        """
        Initialize task result.
        
        Parameters:
        - host: Host object
        - task: Task object
        - return_data: Task result data
        - task_fields: Additional task fields
        """
    
    def is_changed(self):
        """
        Check if task made changes.
        
        Returns:
        bool: True if task changed something
        """
    
    def is_skipped(self):
        """
        Check if task was skipped.
        
        Returns:
        bool: True if task was skipped
        """
    
    def is_failed(self):
        """
        Check if task failed.
        
        Returns:
        bool: True if task failed
        """
    
    def is_unreachable(self):
        """
        Check if host was unreachable.
        
        Returns:
        bool: True if host unreachable
        """
    
    def needs_debugger(self):
        """
        Check if result needs debugger.
        
        Returns:
        bool: True if debugger needed
        """
    
    def clean_copy(self):
        """
        Create clean copy of result without sensitive data.
        
        Returns:
        TaskResult: Sanitized result copy
        """

class PlayStats:
    """
    Statistics tracking for playbook execution.
    
    Tracks execution statistics across all hosts including
    success, failure, change, and skip counts.
    """
    
    def __init__(self):
        """Initialize statistics tracking"""
    
    def increment(self, what, host):
        """
        Increment statistic counter.
        
        Parameters:
        - what: Statistic type ('ok', 'failures', 'changed', 'skipped', 'unreachable')
        - host: Host name
        """
    
    def summarize(self, host):
        """
        Get summary statistics for host.
        
        Parameters:
        - host: Host name
        
        Returns:
        dict: Host statistics
        """
    
    def custom(self, what, host, field):
        """
        Track custom statistic.
        
        Parameters:
        - what: Custom statistic name
        - host: Host name  
        - field: Field value
        """
```

### Strategy Plugins Integration

Integration with strategy plugins for customizable execution patterns including linear, free, debug, and custom strategies.

```python { .api }
class StrategyModule:
    """
    Base class for execution strategy plugins.
    
    Defines the interface for custom execution strategies that
    control how tasks are executed across hosts.
    """
    
    def __init__(self, tqm):
        """
        Initialize strategy.
        
        Parameters:
        - tqm: TaskQueueManager instance
        """
    
    def run(self, iterator, play_context, result=0):
        """
        Execute strategy for play.
        
        Parameters:
        - iterator: Play iterator
        - play_context: Play execution context
        - result: Current result code
        
        Returns:
        int: Final result code
        """
    
    def get_hosts_left(self, iterator):
        """
        Get hosts that still have tasks to execute.
        
        Parameters:
        - iterator: Play iterator
        
        Returns:
        list: Remaining host objects
        """

# Built-in strategy plugins
linear_strategy: StrategyModule    # Execute tasks linearly across hosts
free_strategy: StrategyModule      # Execute tasks as fast as possible
debug_strategy: StrategyModule     # Interactive debugging strategy
```

### Play Context Management

Execution context management providing configuration, connection parameters, and runtime settings for play execution.

```python { .api }
class PlayContext:
    """
    Execution context for plays providing connection and runtime configuration.
    
    Encapsulates all configuration needed for task execution including
    connection parameters, privilege escalation, and runtime options.
    
    Attributes:
    - check_mode: Whether in check mode
    - diff: Whether to show diffs
    - force_handlers: Whether to force handler execution
    - remote_addr: Target host address
    - remote_user: Remote username
    - port: Connection port
    - password: Connection password
    - private_key_file: SSH private key
    - timeout: Connection timeout
    - become: Whether to use privilege escalation
    - become_method: Privilege escalation method
    - become_user: Target user for escalation
    - become_pass: Become password
    - verbosity: Output verbosity level
    """
    
    def __init__(self, play=None, options=None, passwords=None, connection_lockfd=None):
        """
        Initialize play context.
        
        Parameters:
        - play: Play object
        - options: CLI options
        - passwords: Password dictionary
        - connection_lockfd: Connection lock file descriptor
        """
    
    def copy(self, host=None):
        """
        Create copy of play context.
        
        Parameters:
        - host: Host to customize context for
        
        Returns:
        PlayContext: Copied context
        """
    
    def set_attributes_from_plugin(self, plugin):
        """
        Set attributes from connection plugin.
        
        Parameters:
        - plugin: Connection plugin instance
        """
    
    def set_attributes_from_cli(self, options):
        """
        Set attributes from CLI options.
        
        Parameters:
        - options: CLI option namespace
        """
    
    def make_become_cmd(self, cmd, executable='/bin/sh'):
        """
        Create become command wrapper.
        
        Parameters:
        - cmd: Command to wrap
        - executable: Shell executable
        
        Returns:
        str: Wrapped command
        """
```

### Worker Process Management

Worker process coordination for parallel task execution with inter-process communication and resource management.

```python { .api }
class WorkerProcess:
    """
    Worker process for parallel task execution.
    
    Handles individual task execution in separate processes
    with result communication back to main process.
    """
    
    def __init__(self, rslt_q, task_vars, host, task, play_context, loader, variable_manager, shared_loader_obj):
        """Initialize worker process"""
    
    def run(self):
        """Execute task in worker process"""
    
    def _hard_exit(self, exit_code):
        """Force process exit"""

def _become_prompt_regex(become_method):
    """
    Get regex for become prompts.
    
    Parameters:
    - become_method: Become method name
    
    Returns:
    str: Regex pattern for prompts
    """
```

## Execution Flow

### Playbook Execution Sequence

1. **Playbook Loading**: Parse YAML and create play objects
2. **Inventory Processing**: Load and process inventory sources
3. **Variable Resolution**: Gather and merge variables from all sources
4. **Play Iteration**: Execute each play in sequence
5. **Host Batching**: Group hosts according to serial settings
6. **Task Execution**: Execute tasks according to strategy
7. **Result Collection**: Gather and process task results
8. **Handler Notification**: Track and execute handlers
9. **Statistics Reporting**: Generate final execution statistics

### Task Execution Pipeline

1. **Task Preparation**: Resolve variables and templates
2. **Connection Establishment**: Connect to target host
3. **Action Plugin Loading**: Load appropriate action plugin
4. **Module Transfer**: Transfer and execute module code
5. **Result Processing**: Process and validate results
6. **Callback Notification**: Send results to callbacks
7. **Cleanup**: Clean up temporary resources

## Usage Examples

### Basic Execution Setup

```python
from ansible.executor.task_queue_manager import TaskQueueManager
from ansible.executor.playbook_executor import PlaybookExecutor
from ansible.inventory.manager import InventoryManager
from ansible.parsing.dataloader import DataLoader
from ansible.vars.manager import VariableManager
from ansible.playbook import Playbook

# Initialize core components  
loader = DataLoader()
inventory = InventoryManager(loader=loader, sources=['inventory'])
variable_manager = VariableManager(loader=loader, inventory=inventory)

# Set up passwords
passwords = {
    'conn_pass': None,
    'become_pass': None
}

# Execute single play
pb = Playbook.load('site.yml', variable_manager=variable_manager, loader=loader)
plays = pb.get_plays()

tqm = TaskQueueManager(
    inventory=inventory,
    variable_manager=variable_manager,
    loader=loader,
    passwords=passwords,
    stdout_callback='default'
)

result = 0
try:
    for play in plays:
        result = tqm.run(play)
        if result != 0:
            break
finally:
    tqm.cleanup()

print(f"Playbook execution result: {result}")
```

### Advanced Execution with Custom Callbacks

```python
from ansible.executor.task_queue_manager import TaskQueueManager
from ansible.plugins.callback import CallbackBase

class CustomCallback(CallbackBase):
    """Custom callback for execution monitoring"""
    
    def __init__(self):
        super().__init__()
        self.host_stats = {}
    
    def v2_runner_on_ok(self, result):
        host = result._host.get_name()
        self.host_stats.setdefault(host, {'ok': 0, 'failed': 0})
        self.host_stats[host]['ok'] += 1
        print(f"✓ {host}: {result._task.get_name()}")
    
    def v2_runner_on_failed(self, result, ignore_errors=False):
        host = result._host.get_name()
        self.host_stats.setdefault(host, {'ok': 0, 'failed': 0})
        self.host_stats[host]['failed'] += 1
        print(f"✗ {host}: {result._task.get_name()} - {result._result.get('msg', 'Failed')}")
    
    def v2_playbook_on_stats(self, stats):
        print("\nExecution Summary:")
        for host, host_stats in self.host_stats.items():
            print(f"  {host}: {host_stats['ok']} ok, {host_stats['failed']} failed")

# Use custom callback
custom_callback = CustomCallback()

tqm = TaskQueueManager(
    inventory=inventory,
    variable_manager=variable_manager,
    loader=loader,
    passwords=passwords,
    stdout_callback=custom_callback
)
```

### Task-Level Execution

```python
from ansible.executor.task_executor import TaskExecutor
from ansible.playbook.task import Task
from ansible.executor.play_context import PlayContext

# Create task
task_data = {
    'name': 'Test task',
    'debug': {'msg': 'Hello from task executor'}
}
task = Task.load(task_data, variable_manager=variable_manager, loader=loader)

# Set up execution context
play_context = PlayContext()
play_context.remote_user = 'ansible'

# Get target host
host = inventory.get_host('localhost')

# Execute task
task_executor = TaskExecutor(
    host=host,
    task=task,
    job_vars=variable_manager.get_vars(host=host),
    play_context=play_context,
    new_stdin=None,
    loader=loader,
    shared_loader_obj=None
)

result = task_executor.run()
print(f"Task result: {result}")
```

### Parallel Execution Control

```python
# Configure parallel execution
tqm = TaskQueueManager(
    inventory=inventory,
    variable_manager=variable_manager,
    loader=loader,
    passwords=passwords,
    forks=10,  # 10 parallel processes
    stdout_callback='minimal'
)

# Monitor execution with statistics
from ansible.executor import stats

play_stats = stats.PlayStats()

# Custom strategy with statistics
class MonitoredStrategy:
    def __init__(self, tqm):
        self.tqm = tqm
        self.stats = play_stats
    
    def execute_task(self, host, task):
        # Execute task and track statistics
        result = self.tqm.execute_task(host, task)
        
        if result.is_changed():
            self.stats.increment('changed', host.name)
        elif result.is_failed():
            self.stats.increment('failures', host.name)
        elif result.is_skipped():
            self.stats.increment('skipped', host.name)
        else:
            self.stats.increment('ok', host.name)
        
        return result
```

### Error Handling and Recovery

```python
from ansible.errors import AnsibleError, AnsibleConnectionFailure

def robust_execution(playbook_path):
    """Execute playbook with comprehensive error handling"""
    
    try:
        # Initialize execution components
        loader = DataLoader()
        inventory = InventoryManager(loader=loader, sources=['inventory'])
        variable_manager = VariableManager(loader=loader, inventory=inventory)
        
        # Execute playbook
        pbex = PlaybookExecutor(
            playbooks=[playbook_path],
            inventory=inventory,
            variable_manager=variable_manager,
            loader=loader,
            passwords={}
        )
        
        result = pbex.run()
        return result
        
    except AnsibleConnectionFailure as e:
        print(f"Connection failed: {e}")
        return 4  # HOST_UNREACHABLE
        
    except AnsibleError as e:
        print(f"Ansible error: {e}")
        return 1  # GENERIC_ERROR
        
    except Exception as e:
        print(f"Unexpected error: {e}")
        return 250  # UNKNOWN_ERROR
    
    finally:
        # Cleanup resources
        if 'tqm' in locals():
            tqm.cleanup()

# Execute with error handling
exit_code = robust_execution('site.yml')
exit(exit_code)
```