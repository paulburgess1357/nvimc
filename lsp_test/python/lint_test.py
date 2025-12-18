"""File with intentional issues to test linting and LSP diagnostics.

This file contains various code issues that should be caught by:
- pyright (type errors)
- ruff/flake8 (style issues) - if configured
"""

from typing import Optional
import os  # pyright: unused import warning


# Type errors for pyright to catch
def type_error_example() -> str:
    x: int = "not an int"  # Type error: str assigned to int
    return x  # Type error: returning int instead of str


def optional_none_access(value: Optional[str]) -> int:
    # Potential None access - pyright should warn
    return len(value)  # Should use: len(value) if value else 0


def wrong_argument_type() -> None:
    def expects_int(x: int) -> int:
        return x * 2

    result = expects_int("string")  # Type error: str instead of int
    print(result)


# Unreachable code
def unreachable_code() -> int:
    return 42
    print("This is unreachable")  # Should be flagged


# Unused variables (style issue)
def unused_variables() -> None:
    unused_var = 100  # Unused variable
    x = 1
    y = 2
    result = x + y
    print(result)


# Missing return statement in some paths
def inconsistent_return(flag: bool) -> Optional[int]:
    if flag:
        return 42
    # Missing return - should return None explicitly or always return


# Redefined variable with different type
def redefined_variable() -> None:
    value = 10
    value = "now a string"  # Redefined with different type
    value = [1, 2, 3]  # Redefined again
    print(value)


# Comparison issues
def comparison_issues() -> None:
    x = None
    if x == None:  # Should use 'is None'
        print("x is None")

    items: list[int] = []
    if items == []:  # Should use 'if not items:'
        print("empty")


# Class with issues
class ProblematicClass:
    def __init__(self) -> None:
        self.value = 0

    def method_missing_self(x: int) -> int:  # Missing self parameter
        return x * 2

    def shadowing_builtin(self, list: list[int]) -> None:  # Shadows builtin
        for id in list:  # Shadows builtin 'id'
            print(id)


# TODO: This should be highlighted by todo-comments
# FIXME: This too
# HACK: And this one
# NOTE: This is informational
def todo_test() -> None:
    """Function with todo comments for testing todo-comments plugin."""
    pass


# Test that main.py references work
if __name__ == "__main__":
    from main import create_sample_scene

    renderer, entities = create_sample_scene()
    print(f"Created {len(entities)} entities")
