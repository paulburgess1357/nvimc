# Debug (DAP)

Debug Adapter Protocol support for Neovim.

## Plugins

- **nvim-dap** - Core DAP client
- **nvim-dap-ui** - Visual debugging interface
- **nvim-dap-virtual-text** - Inline variable values

## Setup

### 1. Install Debug Adapters

Install adapters for your languages via Mason:

| Language | Adapter | Install |
|----------|---------|---------|
| C/C++ | cpptools (GDB) | `:MasonInstall cpptools` |
| C/C++/Rust | codelldb (LLDB) | `:MasonInstall codelldb` |
| Python | debugpy | `:MasonInstall debugpy` |
| Go | delve | `:MasonInstall delve` |
| JavaScript/Node | js-debug-adapter | `:MasonInstall js-debug-adapter` |
| Ruby | rdbg | `:MasonInstall ruby-debug-ide` |
| Bash | bash-debug-adapter | `:MasonInstall bash-debug-adapter` |

Or install all at once:
```
:MasonInstall cpptools debugpy delve js-debug-adapter ruby-debug-ide bash-debug-adapter
```

### 2. System Dependencies

**C/C++ (GDB):**
```bash
sudo apt install gdb
```

**Ruby:**
```bash
gem install debug
```

## Key Bindings

Press `<leader>d` to see the full debug menu in which-key.

| Key | Action |
|-----|--------|
| **Breakpoints** | |
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| **Execution** | |
| `<leader>dc` | Continue / Start debugging |
| `<leader>dC` | Run to cursor |
| `<leader>dl` | Run last |
| `<leader>dp` | Pause |
| `<leader>dt` | Terminate |
| **Stepping** | |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| **Navigation** | |
| `<leader>dj` | Down stack |
| `<leader>dk` | Up stack |
| **Tools** | |
| `<leader>dr` | Toggle REPL |
| `<leader>ds` | Session info |
| `<leader>dw` | Widgets (hover) |
| `<leader>du` | Toggle DAP UI |
| `<leader>de` | Eval expression |

## Usage

1. Open a source file
2. Set a breakpoint with `<leader>db`
3. Start debugging with `<leader>dc`
4. Select/enter the executable path when prompted
5. DAP UI opens automatically

## Configured Languages

- C/C++ (GDB via cpptools)
- Python (debugpy)
- Go (delve)
- JavaScript/TypeScript (js-debug-adapter)
- Ruby (rdbg)
- Bash (bash-debug-adapter)
