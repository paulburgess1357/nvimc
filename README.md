# nvim-custom

Neovim configuration for Neovim 0.12+ using the built-in `vim.pack` plugin manager.

## Requirements

- Neovim 0.12+
- gcc/clang, tree-sitter-cli, fzf, ripgrep, fd
- Nerd Font (for icons)
- gdb (optional, for debugging)

## Installation

```bash
git clone https://github.com/yourusername/nvim-custom ~/.config/nvim-custom
./install/setup-alias.sh && source ~/.bashrc
nvimc
```

Plugins install automatically on first startup via `vim.pack`.

### Migrating from lazy.nvim

If this machine previously used lazy.nvim, run the cleanup script before starting Neovim:

```bash
./install/migrate-from-lazy.sh
```

This removes stale lazy.nvim data and treesitter symlinks. Parsers and queries reinstall automatically on next startup.

## Structure

```
init.lua                    Entrypoint: options, keymaps, vim.pack.add()
lua/config/options.lua      Editor options
lua/config/keymaps.lua      Key mappings
lua/config/plugins.lua      Plugin enable/disable and settings
lua/config/colorscheme.lua  Colorscheme setup (loaded immediately after vim.pack.add)
plugin/coding/              Plugin configs: treesitter, lsp, blink, conform, lint, etc.
plugin/editor/              Plugin configs: fzf, gitsigns, mini.files, etc.
plugin/ui/                  Plugin configs: lualine, noice, snacks, whichkey, etc.
plugin/debug/               Plugin configs: dap, dap-ui
install/                    Install and migration scripts
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
- **LeetNeoCode** - LeetCode problems (local plugin, see `plugin/coding/leetneocode.lua`)

### Editor

- **mini.files** - File explorer
- **fzf-lua** - Fuzzy finder
- **gitsigns** - Git integration
- **spider** - CamelCase motions
- **illuminate** - Highlight references
- **todo-comments** - TODO highlighting
- **render-markdown** - Markdown rendering
- **marks** - Marks in sign column

### UI

- **Colorscheme** - onedark (transparent). Adding another theme: register its repo in `init.lua`, add a setup branch in `lua/config/colorscheme.lua`, and set `theme` in `lua/config/plugins.lua`.
- **lualine** - Statusline
- **which-key** - Keybinding hints
- **snacks** - Dashboard, indent guides, terminal
- **noice** - Modern cmdline/messages/notifications
- **rainbow-delimiters** - Colored brackets
- **aerial** - Code outline sidebar

### Debug

- **nvim-dap** - Debug Adapter Protocol
- **dap-ui** - Debugging UI
- **persistent-breakpoints** - Save breakpoints

## Documentation

- [KEYBINDINGS.md](KEYBINDINGS.md) - All key bindings
- [COMMANDS.md](COMMANDS.md) - All commands

## Configuration

All plugins can be enabled/disabled in `lua/config/plugins.lua`.

```lua
treesitter = { enabled = true },
colorscheme = { enabled = true, theme = "onedark" },
```

Global settings (file size limits, etc.) are in the `settings` table at the top of that file.
