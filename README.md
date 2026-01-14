# nvim-custom

Modern Neovim configuration for Neovim 0.11+.

## Requirements

- Neovim 0.11+
- gcc or clang (C compiler)
- tree-sitter-cli (`npm install -g tree-sitter-cli`)
- fzf
- ripgrep (rg)
- fd
- Nerd Font (for icons)
- gdb (for C/C++ debugging)

## Installation

```bash
# Clone the config
git clone https://github.com/yourusername/nvim-custom ~/.config/nvim-custom

# Install Neovim (optional helper script)
./install/install-neovim.sh

# Set up the alias
./install/setup-alias.sh
source ~/.bashrc

# Launch with custom config
nvimc
```

## Plugins

### Coding

- **nvim-treesitter** - Syntax highlighting and code parsing
- **nvim-lspconfig** - LSP configuration
- **mason.nvim** - LSP/linter/formatter installer
- **blink.cmp** - Fast autocompletion
- **conform.nvim** - Code formatting
- **nvim-lint** - Asynchronous linting
- **inc-rename.nvim** - Live rename preview
- **mini.pairs** - Auto-pairs

### Editor

- **mini.files** - File explorer
- **fzf-lua** - Fuzzy finder
- **gitsigns.nvim** - Git integration
- **nvim-spider** - CamelCase word motions
- **vim-illuminate** - Highlight references
- **todo-comments.nvim** - TODO highlighting
- **render-markdown.nvim** - Markdown rendering
- **hardtime.nvim** - Break bad habits with motion hints

### UI

- **Colorschemes** - onedark (default), tokyonight, catppuccin, kanagawa, vscode, nordic, teide
- **lualine.nvim** - Statusline
- **which-key.nvim** - Keybinding hints
- **snacks.nvim** - Dashboard, indent guides, terminal
- **noice.nvim** - Modern UI for cmdline, messages, notifications (with nvim-notify)
- **rainbow-delimiters.nvim** - Colored brackets
- **nvim-scrollview** - Scrollbar with diagnostics/search indicators
- **aerial.nvim** - Code outline sidebar and breadcrumbs
- **marks.nvim** - Show marks in sign column

### Debug

- **nvim-dap** - Debug Adapter Protocol client
- **nvim-dap-ui** - Debugging UI
- **nvim-dap-virtual-text** - Inline variable values
- **persistent-breakpoints.nvim** - Save breakpoints across sessions

See [lua/plugins/debug/README.md](lua/plugins/debug/README.md) for setup instructions.

### AI

- **copilot.vim** - GitHub Copilot authentication (inline suggestions disabled)
- **CodeCompanion.nvim** - AI chat, inline assistance, and agent workflows

Requires GitHub Copilot subscription. Run `:Copilot auth` to authenticate.

## Key Bindings

See [KEYBINDINGS.md](KEYBINDINGS.md) for full list.

### Custom Menu (Space Space)

| Key | Action |
| --- | ------ |
| `<leader><leader>f` | Files (cwd) |
| `<leader><leader>g` | Grep (cwd) |
| `<leader><leader>h` | Files (home) |
| `<leader><leader>j` | Grep (home) |
| `<leader><leader>r` | Recent files |
| `<leader><leader>m` | Marks |
| `<leader><leader>l` | Symbols (workspace) |
| `<leader><leader>s` | Toggle diagnostic signs |
| `<leader><leader>v` | Toggle virtual text |
| `<leader><leader>a` | Toggle format on save |
| `<leader><leader>t` | Toggle hardtime |

## Commands

See [COMMANDS.md](COMMANDS.md) for full list.

## Configuration

All plugins can be enabled/disabled from `lua/config/plugins.lua`.

Global settings (like large file limits) are in the `settings` table at the top of that file.
