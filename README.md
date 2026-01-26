# nvim-custom

Modern Neovim configuration for Neovim 0.11+.

## Requirements

- Neovim 0.11+
- gcc/clang, tree-sitter-cli, fzf, ripgrep, fd
- Nerd Font (for icons)
- gdb (optional, for debugging)

## Installation

```bash
git clone https://github.com/yourusername/nvim-custom ~/.config/nvim-custom
./install/setup-alias.sh && source ~/.bashrc
nvimc
```

## Plugins

### Coding

- **treesitter** - Syntax highlighting
- **lspconfig + mason** - LSP with auto-install
- **blink.cmp** - Autocompletion
- **conform** - Formatting
- **nvim-lint** - Linting
- **inc-rename** - Live rename preview
- **mini.pairs** - Auto-pairs

### Editor

- **mini.files** - File explorer
- **fzf-lua** - Fuzzy finder
- **gitsigns** - Git integration
- **spider** - CamelCase motions
- **illuminate** - Highlight references
- **todo-comments** - TODO highlighting
- **render-markdown** - Markdown rendering
- **hardtime** - Motion hints

### UI

- **Colorschemes** - onedark (default), tokyonight, catppuccin, kanagawa, vscode, nordic, teide
- **lualine** - Statusline
- **which-key** - Keybinding hints
- **snacks** - Dashboard, indent guides, terminal
- **noice** - Modern cmdline/messages/notifications
- **rainbow-delimiters** - Colored brackets
- **aerial** - Code outline sidebar
- **marks** - Marks in sign column

### Debug

- **nvim-dap** - Debug Adapter Protocol
- **dap-ui** - Debugging UI
- **persistent-breakpoints** - Save breakpoints

See [lua/plugins/debug/README.md](lua/plugins/debug/README.md) for setup.

### AI

- **CodeCompanion** - AI chat and inline assist
- **copilot.vim** - Inline suggestions
- **mcphub** - MCP server integration

See [lua/plugins/ai/README.md](lua/plugins/ai/README.md) for setup.

## Documentation

- [KEYBINDINGS.md](KEYBINDINGS.md) - All key bindings
- [COMMANDS.md](COMMANDS.md) - All commands

## Configuration

All plugins can be enabled/disabled in `lua/config/plugins.lua`.

```lua
treesitter = { enabled = true },
copilot = { enabled = true, inline_suggestions = true },
-- etc.
```

Global settings (file size limits, etc.) are in the `settings` table at the top of that file.
