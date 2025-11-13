# Error Handling and Exceptions

Ansible Core provides a comprehensive exception hierarchy that enables precise error handling and debugging throughout the automation process. All exceptions derive from `AnsibleError` and provide contextual information including source location, help text, and structured error reporting.

## Capabilities

### Base Exception System

The foundation exception class providing error message formatting, source context, and extensible error reporting for all Ansible operations.

```python { .api }
class AnsibleError(Exception):
    """
    Base class for all errors raised from Ansible code.
    
    Parameters:
    - message: Error message string
    - obj: Object that caused the error (for context)
    - show_content: Whether to show source content in error
    - help_text: Additional help information
    
    Attributes:
    - message: Formatted error message with cause information
    - _original_message: Original error message without cause
    - _help_text: Help text for resolving the error
    """
    
    def __init__(self, message="", obj=None, show_content=True, help_text=None):
        """Initialize base Ansible error"""

class ExitCode(enum.IntEnum):
    """
    Exit codes for Ansible CLI commands.
    """
    SUCCESS = 0
    GENERIC_ERROR = 1
    HOST_FAILED = 2
    HOST_UNREACHABLE = 4
    PARSER_ERROR = 4
    INVALID_CLI_OPTION = 5
    KEYBOARD_INTERRUPT = 99
    UNKNOWN_ERROR = 250
```

### Configuration Errors

Errors related to Ansible configuration including missing required options, invalid configuration values, and undefined configuration entries.

```python { .api }
class AnsibleOptionsError(AnsibleError):
    """
    Invalid options were passed.
    
    Used for CLI argument validation and configuration errors.
    """

class AnsibleRequiredOptionError(AnsibleOptionsError):
    """
    Bad or incomplete options passed.
    
    Raised when required CLI options or configuration values are missing.
    """

class AnsibleUndefinedConfigEntry(AnsibleError):
    """
    The requested config entry is not defined.
    
    Raised when attempting to access non-existent configuration keys.
    """
```

### Parser Errors

Errors encountered during YAML, JSON, and playbook parsing including syntax errors, field validation failures, and data structure problems.

```python { .api }
class AnsibleParserError(AnsibleError):
    """
    A playbook or data file could not be parsed.
    
    Raised for YAML syntax errors, invalid field values, and structural problems.
    """

class AnsibleFieldAttributeError(AnsibleParserError):
    """
    Errors caused during field attribute processing.
    
    Raised when task or play fields contain invalid values or structures.
    """

class AnsibleJSONParserError(AnsibleParserError):
    """
    JSON-specific parsing failure wrapping an exception raised by the JSON parser.
    
    Provides enhanced error reporting for JSON parsing issues.
    """
    
    @classmethod
    def handle_exception(cls, exception, origin):
        """
        Convert JSON parsing exceptions to Ansible errors.
        
        Parameters:
        - exception: Original JSON parsing exception
        - origin: Source location information
        
        Raises:
        AnsibleJSONParserError: Wrapped exception with context
        """
```

### Runtime Execution Errors

Errors that occur during playbook and task execution including module failures, connection issues, and general runtime problems.

```python { .api }
class AnsibleRuntimeError(AnsibleError):
    """
    Ansible had a problem while running a playbook.
    
    Base class for all runtime execution errors.
    """

class AnsibleModuleError(AnsibleRuntimeError):
    """
    A module failed somehow.
    
    Raised when modules return failure states or encounter execution errors.
    """

class AnsibleTaskError(AnsibleError):
    """
    Task execution failed; provides contextual information about the task.
    
    Enhanced error reporting for task-level failures with task context.
    """

class AnsibleInternalError(AnsibleError):
    """
    Internal safeguards tripped, something happened in the code that should never happen.
    
    Used for defensive programming and internal consistency checks.
    """
```

### Connection and Authentication Errors

Errors related to connecting to managed hosts including network failures, authentication problems, and transport issues.

```python { .api }
class AnsibleConnectionFailure(AnsibleRuntimeError):
    """
    The transport / connection_plugin had a fatal error.
    
    Provides result dictionary contribution for task results.
    
    Attributes:
    - result_contribution: Dictionary with unreachable=True
    - omit_failed_key: Returns True to omit 'failed' from results
    """

class AnsibleAuthenticationFailure(AnsibleConnectionFailure):
    """
    Invalid username/password/key.
    
    Specialized connection failure for authentication problems.
    """
```

### Template Processing Errors

Errors encountered during Jinja2 template processing including syntax errors, undefined variables, and template security violations.

```python { .api }
class AnsibleTemplateError(AnsibleRuntimeError):
    """
    A template related error.
    
    Base class for all template processing errors.
    """

class AnsibleTemplateSyntaxError(AnsibleTemplateError):
    """
    A syntax error was encountered while parsing a Jinja template or expression.
    
    Wraps Jinja2 syntax errors with Ansible context.
    """

class AnsibleUndefinedVariable(AnsibleTemplateError):
    """
    An undefined variable was encountered while processing a template or expression.
    
    Raised when templates reference undefined variables.
    """

class TemplateTrustCheckFailedError(AnsibleTemplateError):
    """
    Raised when processing was requested on an untrusted template or expression.
    
    Security control for template processing from untrusted sources.
    """

class AnsibleBrokenConditionalError(AnsibleTemplateError):
    """
    A broken conditional with non-boolean result was used.
    
    Raised when conditional expressions don't evaluate to boolean values.
    """

class AnsibleTemplatePluginError(AnsibleTemplateError):
    """
    An error sourced by a template plugin (lookup/filter/test).
    
    Errors from template plugins like filters, tests, and lookups.
    """
```

### Action Flow Control Exceptions

Special exceptions used for controlling action plugin execution flow including skip conditions and early returns.

```python { .api }
class AnsibleAction(AnsibleRuntimeError):
    """
    Base Exception for Action plugin flow control.
    
    Provides result dictionary contribution for action results.
    
    Parameters:
    - result: Dictionary of result data
    
    Attributes:
    - result_contribution: Result data as mapping
    - result: Mutable result dictionary for backward compatibility
    """

class AnsibleActionSkip(AnsibleAction):
    """
    An action runtime skip.
    
    Used to skip action execution with appropriate result marking.
    
    Result contribution includes:
    - skipped: True
    - msg: Error message
    """

class AnsibleActionFail(AnsibleAction):
    """
    An action runtime failure.
    
    Used to fail action execution with appropriate result marking.
    
    Result contribution includes:
    - failed: True  
    - msg: Error message
    """
```

### Plugin System Errors

Errors related to the plugin system including missing plugins, circular redirects, and plugin loading failures.

```python { .api }
class AnsiblePluginError(AnsibleError):
    """
    Base class for Ansible plugin-related errors that do not need AnsibleError contextual data.
    
    Parameters:
    - plugin_load_context: Context information about plugin loading
    """

class AnsiblePluginNotFound(AnsiblePluginError):
    """
    Indicates we did not find an Ansible plugin.
    
    Raised when requested plugins cannot be located or loaded.
    """

class AnsiblePluginRemovedError(AnsiblePluginError):
    """
    A requested plugin has been removed.
    
    Indicates deprecated plugins that have been removed from Ansible.
    """

class AnsiblePluginCircularRedirect(AnsiblePluginError):
    """
    A cycle was detected in plugin redirection.
    
    Prevents infinite loops in plugin alias chains.
    """

class AnsibleCollectionUnsupportedVersionError(AnsiblePluginError):
    """
    A collection is not supported by this version of Ansible.
    
    Version compatibility errors for collections.
    """
```

### File and Resource Errors

Errors related to file access, resource loading, and file system operations.

```python { .api }
class AnsibleFileNotFound(AnsibleRuntimeError):
    """
    A file missing failure.
    
    Enhanced file not found error with search path information.
    
    Parameters:
    - paths: List of paths searched for the file
    - file_name: Name of the missing file
    
    Provides detailed information about search locations.
    """
```

### Validation and Type Errors

Errors related to data validation, type checking, and variable storage constraints.

```python { .api }
class AnsibleTypeError(AnsibleRuntimeError, TypeError):
    """
    Ansible-augmented TypeError subclass.
    
    Enhanced type errors with Ansible context.
    """

class AnsibleVariableTypeError(AnsibleRuntimeError):
    """
    An error due to attempted storage of an unsupported variable type.
    
    Raised when variables contain unsupported data types.
    """
    
    @classmethod
    def from_value(cls, *, obj):
        """
        Create type error from unsupported value.
        
        Parameters:
        - obj: The unsupported value
        
        Returns:
        AnsibleVariableTypeError: Configured error instance
        """

class AnsibleConditionalError(AnsibleRuntimeError):
    """
    Errors related to failed conditional expression evaluation.
    
    Raised when conditional expressions cannot be evaluated.
    """
```

### User Interaction Errors

Errors related to user prompts and interactive input handling.

```python { .api }
class AnsiblePromptInterrupt(AnsibleError):
    """
    User interrupt.
    
    Raised when user interrupts interactive prompts.
    """

class AnsiblePromptNoninteractive(AnsibleError):
    """
    Unable to get user input.
    
    Raised when interactive input is required but not available.
    """
```

## Error Handling Patterns

### Exception Context
All Ansible exceptions support source context through the `obj` parameter, which can contain origin information for precise error location reporting.

### Result Contribution
Some exceptions implement `ContributesToTaskResult` mixin to provide structured result data for task execution reporting.

### Error Message Formatting
Exceptions automatically format error messages with cause information unless disabled via `_include_cause_message = False`.

### Help Text
Exceptions can provide help text for error resolution through the `_help_text` attribute or constructor parameter.