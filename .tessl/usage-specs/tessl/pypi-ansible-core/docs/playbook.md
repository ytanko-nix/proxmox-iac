# Playbook Engine

Ansible Core's playbook engine provides YAML-based automation workflow execution supporting plays, tasks, handlers, roles, blocks, includes, and imports with comprehensive control flow, error handling, and variable management.

## Capabilities

### Playbook Management

The main playbook container that loads, validates, and coordinates the execution of multiple plays with shared context and variable management.

```python { .api }
class Playbook:
    """
    Main playbook container managing plays and execution context.
    
    Attributes:
    - _entries: List of play entries
    - _basedir: Base directory for relative paths
    - _file_name: Playbook filename
    - _loader: DataLoader instance
    - _variable_manager: Variable manager instance
    """
    
    @staticmethod
    def load(filename, variable_manager=None, loader=None, vars=None):
        """
        Load playbook from YAML file.
        
        Parameters:
        - filename: Path to playbook file
        - variable_manager: Variable manager instance
        - loader: DataLoader instance
        - vars: Additional variables
        
        Returns:
        Playbook: Loaded playbook instance
        """
    
    def get_plays(self):
        """
        Get all plays in playbook.
        
        Returns:
        list: Play objects
        """
    
    def get_vars(self):
        """
        Get playbook-level variables.
        
        Returns:
        dict: Playbook variables
        """
```

### Play Management

Individual play representation containing tasks, handlers, and play-level configuration with host targeting and execution control.

```python { .api }
class Play:
    """
    Individual play representation with tasks and configuration.
    
    Attributes:
    - name: Play name
    - hosts: Target host pattern
    - tasks: List of task objects
    - handlers: List of handler objects
    - vars: Play variables
    - tags: Play tags
    - gather_facts: Whether to gather facts
    - remote_user: Remote user for connections
    - become: Privilege escalation settings
    """
    
    def __init__(self):
        """Initialize empty play"""
    
    @staticmethod
    def load(data, variable_manager=None, loader=None, basedir=None):
        """
        Load play from data structure.
        
        Parameters:
        - data: Play data dictionary
        - variable_manager: Variable manager
        - loader: DataLoader instance  
        - basedir: Base directory for paths
        
        Returns:
        Play: Loaded play instance
        """
    
    def get_tasks(self):
        """
        Get all tasks in play including role tasks.
        
        Returns:
        list: Task objects
        """
    
    def get_handlers(self):
        """
        Get all handlers in play including role handlers.
        
        Returns:
        list: Handler objects
        """
    
    def get_roles(self):
        """
        Get all roles in play.
        
        Returns:
        list: Role objects
        """
    
    def get_vars(self):
        """
        Get play variables.
        
        Returns:
        dict: Play-level variables
        """
```

### Task Management

Task representation with action, parameters, conditionals, loops, and execution control supporting all Ansible modules and plugins.

```python { .api }
class Task:
    """
    Task representation with action and execution parameters.
    
    Attributes:
    - action: Module or action name
    - args: Task arguments
    - name: Task name
    - when: Conditional expression
    - loop: Loop specification
    - tags: Task tags
    - register: Variable to register result
    - delegate_to: Delegation target
    - become: Privilege escalation
    - ignore_errors: Whether to ignore failures
    - changed_when: When to mark as changed
    - failed_when: When to mark as failed
    """
    
    def __init__(self):
        """Initialize empty task"""
    
    @staticmethod
    def load(data, block=None, role=None, task_include=None, variable_manager=None, loader=None):
        """
        Load task from data structure.
        
        Parameters:
        - data: Task data dictionary
        - block: Parent block object
        - role: Parent role object
        - task_include: Task include object
        - variable_manager: Variable manager
        - loader: DataLoader instance
        
        Returns:
        Task: Loaded task instance
        """
    
    def get_vars(self):
        """
        Get task variables.
        
        Returns:
        dict: Task-level variables
        """
    
    def evaluate_conditional(self, templar, all_vars):
        """
        Evaluate task conditional expression.
        
        Parameters:
        - templar: Templating engine
        - all_vars: Available variables
        
        Returns:
        bool: Whether conditional passes
        """
```

### Block Management

Task grouping container supporting error handling, rescue, and always sections with shared conditionals and variables.

```python { .api }
class Block:
    """
    Task block container with error handling support.
    
    Attributes:
    - block: List of main tasks
    - rescue: List of rescue tasks (on failure)
    - always: List of tasks that always run
    - when: Block conditional
    - tags: Block tags
    - vars: Block variables
    """
    
    def __init__(self, parent_block=None, role=None, task_include=None, use_handlers=True, implicit=False):
        """Initialize block container"""
    
    @staticmethod
    def load(data, play=None, parent_block=None, role=None, task_include=None, variable_manager=None, loader=None):
        """
        Load block from data structure.
        
        Parameters:
        - data: Block data dictionary
        - play: Parent play
        - parent_block: Parent block
        - role: Parent role
        - task_include: Task include
        - variable_manager: Variable manager
        - loader: DataLoader instance
        
        Returns:
        Block: Loaded block instance
        """
    
    def get_tasks(self):
        """
        Get all tasks in block sections.
        
        Returns:
        list: All task objects (block + rescue + always)
        """
    
    def has_tasks(self):
        """
        Check if block has any tasks.
        
        Returns:
        bool: True if block contains tasks
        """
```

### Handler Management

Event-driven task execution triggered by notify actions with deduplication and ordered execution.

```python { .api }
class Handler(Task):
    """
    Handler task triggered by notifications.
    
    Inherits from Task with additional handler-specific behavior.
    
    Attributes:
    - listen: List of notification names to listen for
    - _hash: Handler hash for deduplication
    """
    
    def __init__(self):
        """Initialize handler task"""
    
    @staticmethod
    def load(data, block=None, role=None, task_include=None, variable_manager=None, loader=None):
        """
        Load handler from data structure.
        
        Parameters:
        - data: Handler data dictionary
        - block: Parent block
        - role: Parent role  
        - task_include: Task include
        - variable_manager: Variable manager
        - loader: DataLoader instance
        
        Returns:
        Handler: Loaded handler instance
        """
```

### Role Management

Role definition and metadata management supporting role dependencies, parameters, and modular playbook organization.

```python { .api }
class Role:
    """
    Role definition with tasks, handlers, variables, and metadata.
    
    Attributes:
    - _role_name: Role name
    - _role_path: Path to role directory
    - _role_params: Role parameters
    - _default_vars: Default variables
    - _role_vars: Role variables
    - _dependencies: Role dependencies
    - _metadata: Role metadata
    """
    
    def __init__(self, play=None, from_files=None, from_include=False):
        """Initialize role"""
    
    @staticmethod
    def load(role_include, play, parent_role=None, from_files=None, from_include=False):
        """
        Load role from role include specification.
        
        Parameters:
        - role_include: Role include specification
        - play: Parent play
        - parent_role: Parent role for nested roles
        - from_files: Load from specific files
        - from_include: Whether loaded from include
        
        Returns:
        Role: Loaded role instance
        """
    
    def get_name(self):
        """
        Get role name.
        
        Returns:
        str: Role name
        """
    
    def get_tasks(self):
        """
        Get role tasks.
        
        Returns:
        list: Task objects
        """
    
    def get_handlers(self):
        """
        Get role handlers.
        
        Returns:
        list: Handler objects
        """
    
    def get_default_vars(self):
        """
        Get role default variables.
        
        Returns:
        dict: Default variables
        """
    
    def get_vars(self):
        """
        Get role variables.
        
        Returns:
        dict: Role variables
        """
    
    def get_dependencies(self):
        """
        Get role dependencies.
        
        Returns:
        list: Dependency role objects
        """
```

### Include and Import Management

Dynamic and static content inclusion supporting conditional includes, variable passing, and modular playbook composition.

```python { .api }
class TaskInclude(Task):
    """
    Task include for dynamic content inclusion.
    
    Supports conditional includes with variable passing.
    """
    
    @staticmethod
    def load(data, block=None, role=None, task_include=None, variable_manager=None, loader=None):
        """Load task include from data"""

class PlaybookInclude:
    """
    Playbook include for importing entire playbooks.
    
    Supports variable passing and conditional inclusion.
    """
    
    @staticmethod
    def load(data, basedir=None, variable_manager=None, loader=None):
        """Load playbook include from data"""
```

## Playbook Structure

### Basic Playbook Format

```yaml
---
- name: Web server setup
  hosts: webservers
  become: yes
  vars:
    http_port: 80
    server_name: "{{ inventory_hostname }}"
  
  tasks:
    - name: Install Apache
      package:
        name: apache2
        state: present
      notify: restart apache
    
    - name: Copy configuration
      template:
        src: apache.conf.j2
        dest: /etc/apache2/apache2.conf
      notify: restart apache
  
  handlers:
    - name: restart apache
      service:
        name: apache2
        state: restarted
```

### Advanced Features

```yaml
---
- name: Advanced playbook example
  hosts: all
  gather_facts: yes
  vars:
    app_version: "1.2.3"
  
  tasks:
    - name: Conditional task
      debug:
        msg: "Running on {{ ansible_os_family }}"
      when: ansible_os_family == "RedHat"
    
    - name: Loop example
      user:
        name: "{{ item }}"
        state: present
      loop:
        - alice
        - bob
        - charlie
    
    - name: Block with error handling
      block:
        - name: Risky operation
          command: /bin/might-fail
      rescue:
        - name: Handle failure
          debug:
            msg: "Operation failed, continuing"
      always:
        - name: Cleanup
          file:
            path: /tmp/cleanup
            state: absent
    
    - name: Include tasks conditionally
      include_tasks: database.yml
      when: setup_database | default(false)
    
    - name: Import role
      import_role:
        name: common
      vars:
        role_var: value
```

## Control Flow

### Conditionals

```yaml
# Simple conditional
- name: Task with when
  debug:
    msg: "Executed"
  when: ansible_os_family == "Debian"

# Complex conditional
- name: Multiple conditions
  debug:
    msg: "Complex condition"
  when:
    - ansible_distribution == "Ubuntu"
    - ansible_distribution_version is version('18.04', '>=')
    - inventory_hostname in groups['webservers']
```

### Loops

```yaml
# Simple loop
- name: Create users
  user:
    name: "{{ item }}"
  loop:
    - alice
    - bob

# Loop with dictionaries
- name: Create users with details
  user:
    name: "{{ item.name }}"
    groups: "{{ item.groups }}"
  loop:
    - name: alice
      groups: admin
    - name: bob
      groups: users

# Loop with conditionals
- name: Install packages on Debian
  package:
    name: "{{ item }}"
  loop:
    - nginx
    - mysql-server
  when: ansible_os_family == "Debian"
```

### Error Handling

```yaml
# Ignore errors
- name: Command that might fail
  command: /bin/might-fail
  ignore_errors: yes

# Custom failure conditions
- name: Check service
  command: systemctl is-active nginx
  register: nginx_status
  failed_when: nginx_status.rc not in [0, 3]

# Custom change conditions
- name: Touch file
  file:
    path: /tmp/myfile
    state: touch
  changed_when: false
```

## Usage Examples

### Basic Playbook Execution

```python
from ansible.playbook import Playbook
from ansible.inventory.manager import InventoryManager
from ansible.parsing.dataloader import DataLoader
from ansible.vars.manager import VariableManager

# Initialize components
loader = DataLoader()
inventory = InventoryManager(loader=loader, sources=['inventory'])
variable_manager = VariableManager(loader=loader, inventory=inventory)

# Load playbook
pb = Playbook.load('site.yml', variable_manager=variable_manager, loader=loader)

# Get plays
plays = pb.get_plays()
for play in plays:
    print(f"Play: {play.name}")
    tasks = play.get_tasks()
    for task in tasks:
        print(f"  Task: {task.name}")
```

### Task Manipulation

```python
from ansible.playbook.task import Task

# Create task programmatically
task_data = {
    'name': 'Install package',
    'package': {
        'name': 'nginx',
        'state': 'present'
    },
    'become': True,
    'tags': ['packages']
}

task = Task.load(task_data, variable_manager=variable_manager, loader=loader)

# Check task properties
print(f"Task name: {task.name}")
print(f"Task action: {task.action}")
print(f"Task args: {task.args}")
```