# nvim-custom

Modern Neovim configuration for Neovim 0.11+.

## Requirements

- Neovim 0.11+
- gcc or clang (C compiler)
- tree-sitter-cli (`npm install -g tree-sitter-cli`)
- fzf
- ripgrep (rg)
- fd

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
- **snacks.nvim** - Dashboard, indent guides, notifications
- **noice.nvim** - Modern UI for messages/cmdline
- **incline.nvim** - Floating filename statuslines
- **nvim-navic** - Breadcrumb navigation
- **rainbow-delimiters.nvim** - Colored brackets
- **nvim-scrollview** - Scrollbar with diagnostics/search/marks

## Custom Menu (`Space Space`)

- `a` - Toggle format on save
- `t` - Toggle hardtime
- `s` - Toggle diagnostic signs
- `v` - Toggle virtual text
- `f` - Find files (cwd)
- `g` - Grep (cwd)
- `h` - Find files (home)
- `j` - Grep (home)
