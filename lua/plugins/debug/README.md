# Debug (DAP)

Debug Adapter Protocol support for Neovim.

## Plugins

- **nvim-dap** - Core DAP client
- **nvim-dap-ui** - Visual debugging interface
- **nvim-dap-virtual-text** - Inline variable values
- **persistent-breakpoints.nvim** - Save breakpoints across sessions

## Quick Start

1. Install adapter: `:MasonInstall cpptools` (or debugpy, delve, etc.)
2. Open source file
3. Set breakpoint: `<leader>db`
4. Start debugging: `<leader>dc`
5. Select executable when prompted

See [KEYBINDINGS.md](../../../KEYBINDINGS.md) for all debug keybindings (`<leader>d`).

## Install Adapters

| Language | Adapter | Install |
| -------- | ------- | ------- |
| C/C++ | cpptools | `:MasonInstall cpptools` |
| Python | debugpy | `:MasonInstall debugpy` |
| Go | delve | `:MasonInstall delve` |
| JavaScript/Node | js-debug-adapter | `:MasonInstall js-debug-adapter` |
| Ruby | rdbg | `:MasonInstall ruby-debug-ide` |
| Bash | bash-debug-adapter | `:MasonInstall bash-debug-adapter` |

Install all: `:MasonInstall cpptools debugpy delve js-debug-adapter ruby-debug-ide bash-debug-adapter`

## System Dependencies

**C/C++ (GDB):**
```bash
sudo apt install gdb
```

**Ruby:**
```bash
gem install debug
```
