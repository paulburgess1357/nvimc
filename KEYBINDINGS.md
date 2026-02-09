# Key Bindings

Leader key is `Space`.

## Navigation

| Key | Action |
| --- | ------ |
| `<C-h/j/k/l>` | Window navigation |
| `<S-h/l>` | Buffer prev/next |
| `{` / `}` | Previous/next symbol |
| `]]` / `[[` | Next/prev reference |

## Find (Space f)

| Key | Action |
| --- | ------ |
| `ff` | Files |
| `fr` | Recent files |
| `fb` | Buffers |
| `fh` | Help |
| `fk` | Keymaps |
| `fm` | Marks |

## Search (Space s)

| Key | Action |
| --- | ------ |
| `sg` | Grep |
| `sw` | Word under cursor |
| `sb` | Current buffer |
| `ss` | Document symbols |
| `so` | Outline (aerial) |
| `st` | Todo comments |

## Code (Space c)

| Key | Action |
| --- | ------ |
| `ca` | Code action |
| `cr` | Rename |
| `cf` | Format |
| `cd` | Document diagnostics |
| `cl` | Trigger lint |

## Git (Space g/h)

| Key | Action |
| --- | ------ |
| `gf` | Git files |
| `gc` | Commits |
| `gb` | Branches |
| `gs` | Status |
| `hs` | Stage hunk |
| `hr` | Reset hunk |
| `hp` | Preview hunk |
| `hb` | Blame line |

## Debug (Space d)

| Key | Action |
| --- | ------ |
| `db` | Toggle breakpoint |
| `dB` | Conditional breakpoint |
| `dc` | Continue / Start |
| `di/do/dO` | Step into/over/out |
| `du` | Toggle DAP UI |
| `de` | Eval expression |
| `dt` | Terminate |
| `F5/F9/F10/F11` | Continue/Breakpoint/Over/Into |

See [lua/plugins/debug/README.md](lua/plugins/debug/README.md) for full debug documentation.

## Custom Menu (Space Space)

| Key | Action |
| --- | ------ |
| `f` | Files (cwd) |
| `g` | Grep (cwd) |
| `h` | Files (home) |
| `j` | Grep (home) |
| `r` | Recent files |
| `m` | Marks |
| `l` | Symbols (workspace) |
| `a` | Toggle format on save |
| `s` | Toggle diagnostic signs |
| `v` | Toggle virtual text |

## AI

| Key | Action |
| --- | ------ |
| `Tab` | Accept Copilot suggestion (insert mode) |

Chat buffer keymaps: see [lua/plugins/ai/README.md](lua/plugins/ai/README.md).

## Other

| Key | Action |
| --- | ------ |
| `<C-/>` | Toggle terminal |
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
| `Esc` | Clear search highlights |
