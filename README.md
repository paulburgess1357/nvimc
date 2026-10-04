# nvim-custom

Neovim configuration for Neovim 0.12+ using the built-in `vim.pack` plugin manager.

## Requirements

- Neovim 0.12+
- gcc/clang, tree-sitter-cli, fzf, ripgrep, fd
- Nerd Font (for icons)
- gdb (optional, for debugging)

### Installing dependencies (Ubuntu/Debian/WSL)

```bash
sudo apt update && sudo apt install -y build-essential unzip fzf ripgrep fd-find python3-venv wl-clipboard shellcheck gdb cmake golang-go rustup && sudo npm install -g tree-sitter-cli && mkdir -p ~/.local/bin && ln -sf "$(which fdfind)" ~/.local/bin/fd && rustup default stable
```

Requires node/npm. Drop `golang-go`, `rustup` and the trailing `rustup default stable` if you don't write Go or Rust.

Mason installs the LSP servers, `shfmt` and `hadolint` on first startup. Formatters and debug adapters are installed manually from inside Neovim:

```
:MasonInstall stylua ruff prettier clang-format cpptools debugpy delve js-debug-adapter bash-debug-adapter
```

### Installing a Nerd Font

Pick any font from [nerdfonts.com](https://www.nerdfonts.com/font-downloads) and download its zip. The zip contains several variants; the plain `NerdFont` files (Regular, Bold, Italic, BoldItalic) are enough. Skip `NerdFontPropo` (proportional).

**WSL / Windows** (the terminal renders with Windows fonts, so nothing is installed inside WSL):

1. Unzip, select the `.ttf` files, right-click → **Install**.
2. In Windows Terminal: Settings → Profiles → **Defaults** → Appearance → Font face, pick the font (e.g. "JetBrainsMono Nerd Font") and save. Use Defaults rather than the WSL profile: a distro opened from the Start menu shortcut doesn't use that profile.
3. If the font isn't listed, close all Terminal windows and reopen.

**Native Linux:**

```bash
mkdir -p ~/.local/share/fonts && unzip <font>.zip '*.ttf' -d ~/.local/share/fonts && fc-cache -f
```

Then select the font in your terminal emulator's settings.

## Installation

```bash
git clone https://github.com/paulburgess1357/nvimc ~/.config/nvim-custom
./install/setup-alias.sh && source ~/.bashrc
nvimc
```

Plugins install automatically on first startup via `vim.pack`.

### Windows Terminal keys (WSL)

Windows Terminal grabs some keys for itself (`ctrl+shift+space` opens its dropdown, `f11` toggles fullscreen) and sends `ctrl+shift+<letter>` and `ctrl+/` as the same bytes as the unshifted keys, so several mappings in this config never reach Neovim. Add these to the `"actions"` array in its `settings.json` (Settings → Open JSON file) to send them as distinct escape sequences:

```json
{ "command": { "action": "sendInput", "input": "\u001b[32;6u" }, "keys": "ctrl+shift+space" },
{ "command": { "action": "sendInput", "input": "\u001b[104;6u" }, "keys": "ctrl+shift+h" },
{ "command": { "action": "sendInput", "input": "\u001b[106;6u" }, "keys": "ctrl+shift+j" },
{ "command": { "action": "sendInput", "input": "\u001b[107;6u" }, "keys": "ctrl+shift+k" },
{ "command": { "action": "sendInput", "input": "\u001b[108;6u" }, "keys": "ctrl+shift+l" },
{ "command": { "action": "sendInput", "input": "\u001b[47;5u" }, "keys": "ctrl+/" },
{ "command": { "action": "sendInput", "input": "\u001b[57374;2u" }, "keys": "shift+f11" },
{ "command": "unbound", "keys": "f11" },
```

Fullscreen stays on `alt+enter`. If `ctrl+v` is bound to paste in the terminal, use `ctrl+q` for visual block mode. Terminals with the kitty keyboard protocol (kitty, WezTerm, Ghostty) need none of this.

## Structure

```
init.lua                    Entrypoint: options, keymaps, vim.pack.add()
lua/config/options.lua      Editor options
lua/config/keymaps.lua      Key mappings
lua/config/plugins.lua      Plugin enable/disable and settings
lua/config/colorscheme.lua  Colorscheme setup (loaded immediately after vim.pack.add)
lua/utils/                  Hand-rolled features: terminals, sessions, buffer tabs, resize, ...
plugin/coding/              Plugin configs: treesitter, lsp, blink, conform, lint, etc.
plugin/editor/              Plugin configs: fzf, gitsigns, mini.files, etc.
plugin/ui/                  Plugin configs: lualine, noice, snacks, whichkey, etc.
plugin/debug/               Plugin configs: dap, dap-ui
install/                    Install scripts
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
- **diffview** - Side-by-side diff viewer
- **spider** - CamelCase motions
- **illuminate** - Highlight references
- **todo-comments** - TODO highlighting
- **render-markdown** - Markdown rendering
- **marks** - Marks in sign column

### UI

- **Colorscheme** - onedark (transparent). Adding another theme: register its repo in `init.lua`, add a setup branch in `lua/config/colorscheme.lua`, and set `theme` in `lua/config/plugins.lua`.
- **lualine** - Statusline
- **which-key** - Keybinding hints
- **snacks** - Dashboard, indent guides, bigfile
- **noice** - Modern cmdline/messages/notifications
- **rainbow-delimiters** - Colored brackets
- **aerial** - Code outline sidebar
- **Stardust** - Twinkling stars, meteors, etc.

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
