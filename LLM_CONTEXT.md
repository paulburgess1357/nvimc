# LLM Context — Read This First

You are looking at **nvim-custom**, Paul's personal Neovim configuration. This
document exists to get an LLM (you) fully up to speed on what this repo is, how
it is structured, how it loads, what every file does, and the conventions you
must follow when changing anything. Read it top to bottom before touching code.

---

## 1. What this repo is

- A complete Neovim configuration targeting **Neovim 0.12+**.
- It is **not** the user's default config. It lives at `~/.config/nvim-custom`
  and is launched with the shell alias **`nvimc`**:

  ```bash
  alias nvimc='NVIM_APPNAME=nvim-custom nvim'
  ```

  `NVIM_APPNAME=nvim-custom` means Neovim uses `~/.config/nvim-custom` for
  config, `~/.local/share/nvim-custom` for data (plugins, mason packages), and
  `~/.local/state/nvim-custom` for state. Plain `nvim` still uses the untouched
  default config. **When testing headlessly, always set `NVIM_APPNAME=nvim-custom`.**

- Plugins are managed by Neovim's **built-in `vim.pack`** plugin manager
  (new in 0.12) — there is no lazy.nvim, packer, or similar. The config was
  migrated *from* lazy.nvim; `install/migrate-from-lazy.sh` cleans up old
  machines. Plugin versions are pinned in `nvim-pack-lock.json`.
- Plugins install automatically on first startup via `vim.pack.add()`.
  Update with `:lua vim.pack.update()` (also on the dashboard as `u`).

---

## 2. Repository map

```
init.lua                    Entrypoint: builds plugin spec list, vim.pack.add()
lua/config/options.lua      Editor options + small autocmds
lua/config/keymaps.lua      Core keymaps + custom user commands
lua/config/plugins.lua      ★ Central on/off switch for every plugin + settings
lua/config/colorscheme.lua  Theme setup (loaded explicitly at end of init.lua)
lua/utils/resize.lua        Directional window-resize helper (Alt+hjkl)
lua/utils/smart_wrap_copy.lua  Rejoins soft-wrapped lines yanked from terminals

plugin/                     Per-plugin config, auto-sourced by Neovim natively
  coding/                     treesitter, lsp, blink, conform, lint, pairs,
                              increname, leetneocode
  editor/                     fzf, gitsigns, diffview, mini-files, illuminate,
                              marks, spider, todo-comments, render-markdown
  ui/                         snacks (dashboard + terminals), lualine, noice,
                              whichkey, aerial, rainbow-delimiters
  debug/                      dap (adapters, dap-ui, virtual text, breakpoints)

install/
  setup-alias.sh            Adds the `nvimc` alias to ~/.bashrc
  install-neovim.sh         Interactive Neovim version installer (stable/nightly)
  migrate-from-lazy.sh      Removes stale lazy.nvim + treesitter data

dotfiles/                   Copyable config TEMPLATES for other projects
                            (.clangd, .clang-format, .clang-tidy, pyproject.toml,
                            .mypy.ini, .shellcheckrc, .hadolint.yaml, .yamllint,
                            .markdownlint.json, .rustfmt.toml, kitty.conf, …).
                            These are NOT loaded by Neovim — they are for
                            copying into other repos so linters/LSPs match
                            this config's tooling.

lsp_test/                   Throwaway sample projects (C++/CMake, Python, shell)
                            used to manually exercise LSP, linters, formatters,
                            and DAP. NOT config code. Contains build artifacts,
                            caches, and .pyc files — ignore them; never "clean
                            up" or lint this directory as if it were the config.

KEYBINDINGS.md              Human-readable keymap reference (keep in sync!)
COMMANDS.md                 Human-readable user-command reference (keep in sync!)
README.md                   Short public-facing overview
nvim-pack-lock.json         vim.pack lockfile (plugin name → rev + src URL)
.gitignore                  Ignores pack/ (local plugin symlinks), build junk
```

Not in git but relevant:

- `pack/local/opt/LeetNeoCode` — symlink to a private local plugin (see §8).
- `.git/hooks/pre-push` — auto-disables personal plugins before push (see §8).

---

## 3. Load order (important for reasoning about bugs)

1. `init.lua` runs:
   1. `vim.loader.enable()`
   2. `require("config.options")` — options, leader key (`<Space>`), autocmds
   3. `require("config.keymaps")` — core maps; requires `utils.resize`
   4. Reads `lua/config/plugins.lua` and builds a flat spec list. The local
      helper `add(key, ...)` **skips a plugin's specs entirely if
      `plugins[key].enabled == false`** — a disabled plugin is not even
      downloaded/loaded by vim.pack.
   5. Registers a `PackChanged` autocmd **before** `vim.pack.add()`: when
      `nvim-treesitter` is installed or updated, it runs `:TSUpdate`.
   6. `vim.pack.add(specs)` — installs (first run) and loads all plugins.
   7. `require("config.colorscheme")` — theme setup, immediately after load.
2. **After** `init.lua`, Neovim natively sources every file under `plugin/`
   (recursively, alphabetically). This is stock runtimepath behavior, not a
   plugin manager feature. Each file configures one plugin.

### The guard pattern (used by every `plugin/**/*.lua` file)

```lua
local cfg = require("config.plugins").<key> or {}
if cfg.enabled == false then return end
```

So disabling a plugin in `plugins.lua` does two things: the spec is never
passed to `vim.pack.add`, **and** its config file no-ops. Both must reference
the same key. Absent/omitted `enabled` counts as enabled (only an explicit
`false` disables).

---

## 4. The control panel: `lua/config/plugins.lua`

Single source of truth. Two kinds of entries:

- **`settings` table** — global tunables read by several configs:
  - `treesitter_max_kb = 100` — no treesitter for files bigger than this
  - `illuminate_max_lines = 20000`
  - `bigfile_max_mb = 1.5` — snacks bigfile threshold
  - `aerial_max_lines = 50000`
  - `cppcheck = false` — opt-in cppcheck for C/C++ in nvim-lint
- **Per-plugin entries** — `key = { enabled = bool, branch = "..."(optional) }`.
  Currently only treesitter uses `branch` (`"main"` — the new treesitter API,
  not the legacy `master`).

`leetneo` is intentionally `enabled = false` in git (see §8).

---

## 5. How to make common changes

### Add a plugin
1. Add its spec in `init.lua` via `add("newkey", gh("owner/repo"))` in the
   right section (list dependencies first, in the same `add` call).
2. Add `newkey = { enabled = true }, -- comment` to `lua/config/plugins.lua`.
3. Create `plugin/<category>/<name>.lua` starting with the guard pattern,
   then `require("...").setup({...})` and any keymaps.
4. Update `KEYBINDINGS.md` / `COMMANDS.md` if you added maps or commands.

### Remove/disable a plugin
Flip `enabled = false` in `plugins.lua` (non-destructive, preferred), or fully
remove: delete the `add(...)` line, the plugins.lua entry, and the config file.
`:lua vim.pack.del({ "plugin-name" })` removes installed data.

### Add a colorscheme
Three places (comments in the code say the same):
1. `init.lua` — add the repo to the `colorscheme_specs` table.
2. `lua/config/colorscheme.lua` — add an `elseif theme == "name"` branch with
   its `setup()`/`load()` calls.
3. `lua/config/plugins.lua` — set `colorscheme.theme = "name"`.
Only the active theme's repo is installed.

### Change a keybinding
Core maps in `lua/config/keymaps.lua`; plugin-specific maps live in that
plugin's file under `plugin/`. **Always update `KEYBINDINGS.md`.**

---

## 6. Plugin inventory (what's installed and where it's configured)

| Plugin | Config file | Notes |
|---|---|---|
| nvim-treesitter (branch `main`) | `plugin/coding/treesitter.lua` | New-API install of ~15 parsers; a `FileType` autocmd calls `vim.treesitter.start()` per buffer and sets treesitter `indentexpr`; skipped for files > `treesitter_max_kb` |
| nvim-lspconfig + mason + mason-lspconfig + SchemaStore | `plugin/coding/lsp.lua` | Uses native `vim.lsp.config.<server>` tables (0.11+ style, no `lspconfig.setup()`). Mason `ensure_installed`: lua_ls, clangd, pyright, rust_analyzer, gopls, ts_ls, bashls, html, cssls, tailwindcss, jsonls, yamlls, taplo, dockerls, docker_compose_language_service; plus non-LSP tools shfmt + hadolint via mason-registry. clangd runs with `--clang-tidy --background-index`. Diagnostics: underline only, **no virtual text by default** (toggleable), rounded floats. LSP keymaps bound on `LspAttach`, mostly to fzf-lua pickers (`gd`, `gr`, `gI`, `gy`, `<leader>ca`, …). `gl` opens line diagnostics with severity-colored border |
| blink.cmp (+ friendly-snippets) | `plugin/coding/blink.lua` | Tab = accept/snippet-forward; `<C-j>/<C-k>` navigate menu; rounded borders; rust fuzzy matcher |
| conform.nvim | `plugin/coding/conform.lua` | Format-on-save (2.5 s timeout for cold prettier), gated by `vim.g.disable_autoformat` (toggle `<leader><leader>a`). stylua / ruff_format / clang-format / rustfmt / shfmt / prettier / taplo. `<leader>cf` manual format |
| nvim-lint | `plugin/coding/lint.lua` | shellcheck, hadolint; cppcheck opt-in via `settings.cppcheck`, with per-project cache dir under `~/.cache/nvim-cppcheck/`. Runs on BufWritePost/BufReadPost; `<leader>cl` manual |
| inc-rename.nvim | `plugin/coding/increname.lua` | `<leader>cr` live-preview LSP rename (integrates with noice) |
| mini.pairs | `plugin/coding/pairs.lua` | Insert mode only |
| LeetNeoCode | `plugin/coding/leetneocode.lua` | Personal/private, see §8 |
| fzf-lua | `plugin/editor/fzf.lua` | THE picker (no telescope). `--fixed-strings` grep by default. Registers `vim.ui.select`. Many `<leader>f*`, `<leader>s*`, `<leader>g*` maps + user commands (`Files`, `Rg`, `Symbols`, …). `<leader><cr>` resumes last picker |
| gitsigns.nvim | `plugin/editor/gitsigns.lua` | Hunk navigation `]h`/`[h`, `<leader>h*` hunk actions, blame toggle via whichkey |
| diffview.nvim | `plugin/editor/diffview.lua` | `<leader>gd` toggles working-tree diff; `<leader>gh` file history. Custom auto-cleanup: snapshots listed buffers before opening and wipes buffers diffview loaded once closed (never modified/visible ones). `q` closes; `<S-h>/<S-l>` disabled inside |
| mini.files | `plugin/editor/mini-files.lua` | `<leader>e` (dir of file) / `<leader>E` (cwd); `<CR>` mapped to `l` (go in) |
| vim-illuminate | `plugin/editor/illuminate.lua` | `]]`/`[[` jump between references |
| marks.nvim | `plugin/editor/marks.lua` | Marks in sign column |
| nvim-spider | `plugin/editor/spider.lua` | **Remaps `w`/`e`/`b`** to camelCase/subword motions |
| todo-comments.nvim (+ plenary) | `plugin/editor/todo-comments.lua` | `]t`/`[t`, `<leader>st` picker |
| render-markdown.nvim | `plugin/editor/render-markdown.lua` | `<leader>um` toggle |
| onedark.nvim | `lua/config/colorscheme.lua` (NOT under plugin/) | See §7 |
| lualine.nvim | `plugin/ui/lualine.lua` | Starts from the `auto` theme, then blanks section b/c backgrounds (`bg = "none"`) for transparency — never hardcodes colors. Globalstatus; aerial breadcrumb in section c; buffers listed in the tabline |
| which-key.nvim | `plugin/ui/whichkey.lua` | Helix preset. Defines leader groups (b/c/d/f/g/h/s/u and `<leader><leader>` "Custom"). Also holds all Snacks **toggles**: wrap, relativenumber, spell, diagnostic signs `<leader><leader>s`, diagnostic virtual text `<leader><leader>v`, format-on-save `<leader><leader>a`, smart wrap copy `<leader><leader>w`, git blame `<leader><leader>b`, plus `<leader><leader>` fzf shortcuts (cwd/home find & grep) |
| snacks.nvim | `plugin/ui/snacks.lua` | bigfile handling, dashboard (NEOVIM ascii header with per-line gradient derived from current colorscheme highlights), indent guides, toggles. Notifier/scroll disabled. **Also contains the entire custom terminal system — see §9, it's the most custom code in the repo** |
| noice.nvim (+ nui, nvim-notify) | `plugin/ui/noice.lua` | cmdline popup (`cmdheight=0`), messages, LSP progress. notify uses `background_colour = "#000000"` because the transparent theme gives it no bg to blend against. `<leader>n` history, `<leader>un` dismiss |
| aerial.nvim | `plugin/ui/aerial.lua` | `<leader>o` outline sidebar; **remaps `{`/`}`** to prev/next symbol |
| rainbow-delimiters.nvim | `plugin/ui/rainbow-delimiters.lua` | Global strategy; lua uses `rainbow-blocks` |
| nvim-dap + dap-ui + nvim-nio + virtual-text + persistent-breakpoints | `plugin/debug/dap.lua` | Adapters point into mason's package dir: cppdbg (cpptools/GDB), debugpy, delve, pwa-node, bashdb. `<leader>d*` maps + F5/F9/F10/F11. Breakpoints persist across sessions (BufReadPost reload). dap-ui auto-opens/closes with the session |
| nvim-web-devicons | (no file) | Shared dependency, always installed |

---

## 7. Colorscheme & transparency (a recurring theme in this config)

`lua/config/colorscheme.lua` sets up **onedark, style "darker", transparent**.
Transparency drives a lot of custom code:

- onedark's `transparent` option only blanks the main editor, so a loop
  overrides ~30 highlight groups (floats, popups, statusline, Pmenu, blink
  menus, whichkey, noice, mini.files, snacks picker, …) to `bg = "none"`.
- onedark has **no fzf-lua groups**, so `FzfLua*` highlights are hand-defined
  using onedark palette variables (`$cyan`, `$orange`, `$bg_d`, …) via
  onedark's `highlights` override (applied last).
- CursorLine bg is removed; the current line is marked by a bold orange
  `CursorLineNr` instead.
- lualine blanks section backgrounds instead of hardcoding (see §6).
- noice/notify needs an explicit `background_colour` hex for its fade.
- `plugin/coding/lsp.lua` has a `sync_highlights()` that re-derives
  NormalFloat/FloatBorder and diagnostic virtual-text colors on every
  `ColorScheme` event.
- The dashboard header gradient re-derives its colors from `@keyword`,
  `@function`, etc. on `ColorScheme`.

**Rule: never hardcode a color where a highlight group or palette variable
works** — the whole setup is built to survive theme switches
(`<leader>ts` cycles onedark styles).

---

## 8. Git conventions & the personal-plugin mechanism

- Branches: `master` is the main branch. Work happens on feature branches
  (currently `fable_update`). Commit messages are short and lowercase-ish
  ("fix term", "cleanup diffview").
- **LeetNeoCode** is a private plugin (LeetCode helper) that is NOT a vim.pack
  plugin. It's a local repo symlinked to `pack/local/opt/LeetNeoCode`
  (gitignored via `pack/`) and lazy-loaded with `:packadd` on first use of its
  commands (`LC`, `LCPull`, …). Setup instructions are in a comment at the
  bottom of `plugin/coding/leetneocode.lua`.
- **`.git/hooks/pre-push`** (not in the repo tree): before any push, if
  `leetneo = { enabled = true` appears in `plugins.lua`, the hook flips it to
  `false`, commits ("Auto-disable personal plugins before push"), re-pushes
  with a recursion guard env var, then restores `true` locally *uncommitted*,
  and aborts the original push. Consequence: **the committed state of
  `leetneo` is always `enabled = false`, but the working tree on Paul's
  machine may show `true`.** Don't "fix" that discrepancy, and don't be
  surprised by the auto-commit during pushes.

---

## 9. Custom subsystems (hand-written, no plugin equivalents)

These are the parts you can't look up in any plugin's docs.

### Terminal system — `plugin/ui/snacks.lua` (bottom half of the file)
User commands `Term1`…`Term9`, `Term10`, `Term10Focus`:

- **Term1–9**: a bottom row (30% height). Multiple bottom terminals split
  vertically within the row, kept ordered by number and **equalized in width**.
- **Term10**: a full-height **right column at 28% width**, intended for
  streaming chat/LLM output. `botright split` from the first bottom terminal
  would cut it short, so `fix_term10_layout()` pushes it back to the far right
  (`wincmd L`) and restores width. A `WinLeave` autocmd snaps its cursor to the
  last line so terminal auto-scroll keeps following output when unfocused.
- Each `Term<n>` command **toggles**: hides the window if visible, reopens the
  existing buffer if hidden, creates a fresh shell if none. Terminal buffers
  are unlisted, named `Term<n>`, `q` closes the window, `<Esc>` (normal mode)
  jumps to the top window, and `<S-h>/<S-l>/<leader>-/<leader>|` are disabled
  inside. On shell exit (`TermClose`) the buffer is deleted and the slot freed.
- `WinClosed` on Term10 re-equalizes the bottom row (Term10 stealing/returning
  width otherwise deforms only the rightmost bottom terminal).
- Keymaps: `<C-/>` toggles Term1; `<C-S-Space>` focuses Term10 (creating it if
  needed) and enters insert mode.

### Literal-by-default search — `lua/config/keymaps.lua`
`/` and `?` (n/x/o modes) auto-insert `\V` (very-nomagic) so searches need no
regex escaping; a cmdline-mode `/` mapping does the same for the pattern
position of `:s`, `:%s`, `:'<,'>s`, `:1,5s`. Typing `\v`/`\m` after the `/`
restores regex. **Do not set `magic` off instead** — plugins assume it's on
(there's a comment in options.lua about this).

### `:LspIndexAll` — `lua/config/keymaps.lua`
Batch-loads (bufadd/bufload, 50 files per scheduled batch) every file under the
cwd whose filetype matches an attached LSP client, to force clangd to index
the whole project so `gr` (references) is complete.

### `:McpClearHighlights` / `:McpClearVirtualTexts` — `lua/config/keymaps.lua`
Clear the `mcp_highlight` / `mcp_virtual_text` extmark namespaces in all
buffers. These exist because Paul drives this Neovim from LLM tooling via an
**nvim-mcp** server (tools like `highlight_range` / `add_virtual_text` leave
annotations; these commands wipe them).

### Smart Wrap Copy — `lua/utils/smart_wrap_copy.lua`
Terminal buffers store each screen row as its own buffer line, so yanking a
soft-wrapped command captures hard newlines that were never in the output
(neovim/neovim#30117). A `TextYankPost` autocmd (activated from keymaps.lua)
rewrites yanks in terminal buffers: any yanked line whose display width
exactly fills the terminal's text width (window width − textoff) is a wrapped
continuation and gets joined with the next line. Rewrites the target register
and, for unnamed yanks under `clipboard=unnamedplus`, the `+` register too.
Skips blockwise yanks. Enabled by default; toggle `<leader><leader>w`
(registered with the other Snacks toggles in whichkey.lua). Inherent
limitation: a genuine line exactly as wide as the terminal gets joined.

### Directional resize — `lua/utils/resize.lua`
`Alt+h/j/k/l` resizes the current window in the *intuitive* screen direction
regardless of which neighbor the window has (temporarily hops to a neighbor
when Vim's resize semantics would invert the direction).

### Diffview buffer cleanup — `plugin/editor/diffview.lua`
See §6 table. Controlled by the `AUTO_CLOSE_BROWSED_BUFFERS` flag at the top
of the file.

---

## 10. Notable option choices (things that might surprise you)

- Leader = `<Space>`; `timeoutlen=300`, `updatetime=250`.
- `cmdheight = 0` — there is no native cmdline; noice renders it as a popup.
  Messages behave differently than stock Neovim; when debugging headlessly use
  `:messages` / `vim.notify`.
- `showmode = false` (lualine shows mode).
- System clipboard is the default register (`clipboard=unnamedplus`).
- No swapfile, no backup, but persistent undo (`undofile`).
- `confirm = true` — `:q` on modified buffers prompts instead of erroring.
- Auto `checktime` on FocusGained/BufEnter/CursorHold (external file reloads —
  important because external tools edit files while Neovim is open).
- 2-space indentation for editing (`tabstop/shiftwidth = 2`, `expandtab`) —
  but note the **repo's own Lua files are indented with tabs** (stylua
  default). Match tabs when editing this config's Lua.
- `<C-d>/<C-u>/n/N` recenter (`zz`).
- Visual `J`/`K` move selected lines.
- `<S-h>/<S-l>` cycle buffers (tabline shows buffers, not tabs).
- `<Esc>` in normal mode clears search highlight; `<Esc><Esc>` exits
  terminal mode.

---

## 11. Testing & verification workflow

There is no test suite. Verify changes by booting Neovim headlessly:

```bash
# Clean-boot check (prints messages if anything errored during startup):
NVIM_APPNAME=nvim-custom timeout 30 nvim --headless \
  "+lua vim.defer_fn(function() local m=vim.fn.execute('messages'):gsub('^%s+','') \
   io.stdout:write(m=='' and 'CLEAN BOOT\n' or ('MESSAGES: '..m..'\n')) \
   vim.cmd('qa!') end, 4000)"
```

- First boot after adding a plugin is slow (vim.pack clones repos) — use a
  generous timeout (120s+) the first time.
- To check a specific mapping/command exists, use `vim.fn.maparg()` /
  `vim.fn.exists(':Cmd')` inside the same deferred-lua pattern.
- `--startuptime <file>` for performance questions.
- Format Lua with `stylua`; the repo style is tabs.
- Sample projects for exercising LSP/lint/format/DAP live in `lsp_test/`.

If Neovim is running interactively and you have nvim-mcp tools available,
prefer them (buffer reads/edits, `send_command`) over disk edits so the user
sees changes live — but for pure config changes to files not open in a buffer,
disk edits are fine.

---

## 12. Documentation upkeep rules

- **`KEYBINDINGS.md`** — table of all keymaps grouped by prefix (Navigation,
  Find, Search, Code, Git, Debug, Custom menu, Other). Any keymap change must
  be reflected here.
- **`COMMANDS.md`** — table of user commands (General, Git/Diff, LSP). Any
  user-command change must be reflected here.
- **`README.md`** — high-level overview; update the plugin list if you add or
  remove a plugin.
- This file (`LLM_CONTEXT.md`) — update it if you change the architecture,
  add a custom subsystem, or alter a convention it describes.

---

## 13. Quick orientation checklist for a new session

1. `lua/config/plugins.lua` — see what's enabled and the global settings.
2. `init.lua` — see the actual specs/deps if a plugin fails to load.
3. The relevant `plugin/<category>/<name>.lua` — for any plugin behavior.
4. `plugin/ui/snacks.lua` — if the question involves terminals.
5. `lua/config/colorscheme.lua` + §7 — if the question involves colors,
   transparency, floats, or highlight groups.
6. Remember: launched as `nvimc` / `NVIM_APPNAME=nvim-custom`; data dir is
   `~/.local/share/nvim-custom`; `leetneo` working-tree state is intentional.
