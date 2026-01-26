# Project Configuration Templates

Ready-to-use configuration files for linters, formatters, and language servers.

## Python

```bash
cp ~/.config/nvim-custom/dotfiles/pyproject.toml ./
```

Contains config for: Black, ruff, mypy, pylint

## C++

```bash
cp ~/.config/nvim-custom/test/cpp_project/.clang* ./
cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -B build
ln -s build/compile_commands.json .
```

## Notes

All templates are designed to work with the LSP servers and linters in this Neovim config.
