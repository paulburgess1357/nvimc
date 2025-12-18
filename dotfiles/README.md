# Project Configuration Templates

**Purpose**: Ready-to-use configuration files for linters, formatters, and language servers. Copy to your project root as needed.

## Python Projects

```bash
cp ~/.config/nvim/dotfiles/pyproject.toml ./
```

Files:
- `pyproject.toml` - Black, ruff, mypy, pylint config

## C++ Projects

For C++ projects, configuration files can be found in the test projects:
```bash
cp ~/.config/nvim/test/cpp_project/.clang* ./
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B build
ln -s build/compile_commands.json .
```

## Notes

All configuration templates are designed to work with the LSP servers and linters configured in this Neovim setup.
