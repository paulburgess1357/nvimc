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

- **onedark.nvim** - Colorscheme
- **lualine.nvim** - Statusline
- **which-key.nvim** - Keybinding hints
- **snacks.nvim** - Dashboard, indent guides, terminal
- **noice.nvim** - Modern UI for cmdline, messages, notifications (with nvim-notify)
- **rainbow-delimiters.nvim** - Colored brackets
- **nvim-scrollview** - Scrollbar with diagnostics/search indicators
- **aerial.nvim** - Code outline sidebar and breadcrumbs
- **marks.nvim** - Show marks in sign column

## Key Bindings

### General

| Key | Action |
|-----|--------|
| `Space` | Leader key |
| `Esc` | Clear search highlights |

### Navigation

| Key | Action |
|-----|--------|
| `<C-h/j/k/l>` | Window navigation |
| `<S-h/l>` | Buffer prev/next |
| `{` / `}` | Previous/next symbol |
| `]]` / `[[` | Next/prev reference |

### Find (Space f)

| Key | Action |
|-----|--------|
| `ff` | Files |
| `fr` | Recent files |
| `fb` | Buffers |
| `fh` | Help |
| `fk` | Keymaps |
| `fm` | Marks |

### Search (Space s)

| Key | Action |
|-----|--------|
| `sg` | Grep |
| `sw` | Word under cursor |
| `sb` | Current buffer |
| `ss` | Document symbols |
| `so` | Outline symbols (aerial) |
| `st` | Todo comments |

### Code (Space c)

| Key | Action |
|-----|--------|
| `ca` | Code action |
| `cr` | Rename |
| `cf` | Format |
| `cd` | Document diagnostics |
| `cl` | Trigger lint |

### Git (Space g/h)

| Key | Action |
|-----|--------|
| `gf` | Git files |
| `gc` | Commits |
| `gb` | Branches |
| `gs` | Status |
| `hs` | Stage hunk |
| `hr` | Reset hunk |
| `hp` | Preview hunk |
| `hb` | Blame line |

### Other

| Key | Action |
|-----|--------|
| `<leader>o` | Toggle outline |
| `<leader>e` | File explorer (current file) |
| `<leader>E` | File explorer (cwd) |
| `<leader>n` | Notification history |
| `<leader>un` | Dismiss notifications |
| `<leader>w` | Save |
| `<leader>q` | Quit |
| `<leader>-` | Split horizontal |
| `<leader>\|` | Split vertical |
| `gl` | Line diagnostics |

## Commands

| Command | Action |
|---------|--------|
| `:Files` | Find files |
| `:Buffers` | Buffer list |
| `:Rg` / `:Grep` | Live grep |
| `:Symbols` | Document symbols |
| `:Marks` | Marks |
| `:Help` | Help tags |
| `:Commands` | Commands |
| `:Keymaps` | Keymaps |
| `:Aerials` | Toggle outline sidebar |

## Custom Menu (Space Space)

| Key | Action |
|-----|--------|
| `a` | Toggle format on save |
| `t` | Toggle hardtime |
| `s` | Toggle diagnostic signs |
| `v` | Toggle virtual text |
| `f` | Find files (cwd) |
| `g` | Grep (cwd) |
| `h` | Find files (home) |
| `j` | Grep (home) |

## Configuration

All plugins can be enabled/disabled from `lua/config/plugins.lua`.

Global settings (like large file limits) are in the `settings` table at the top of that file.
