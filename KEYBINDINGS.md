# Key Bindings

Leader key is `Space`.

## Navigation

| Key | Action |
| --- | ------ |
| `<C-h/j/k/l>` | Window navigation |
| `<C-S-j/k>` | Bisect jump — binary-search the visible window for a line |
| `<S-h/l>` | Buffer prev/next (tabline order) |
| `<C-S-h/l>` | Move current buffer tab left/right |
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
| `w` | Toggle smart wrap copy (rejoin soft-wrapped lines yanked from terminals) |

## Other

| Key | Action |
| --- | ------ |
| `<C-/>` | Toggle bottom terminal (Term1) |
| `<C-S-Space>` | Focus right terminal (Term10) and enter insert mode |
| `<F8>` | Paste current line (visual: selection) into Term1 and press Enter, then move down (`:TermRun`; target set by `settings.send_term`) |
| `Esc` (in terminal normal mode) | Jump to leftmost window |
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
| `q` (in quickfix) | Close quickfix/location list |
| `<leader><CR>` | Resume last FZF picker (or unhide a hidden one) |
| `s` (on dashboard) | Restore this directory's session (auto-saved on quit); also `:SessionRestore` / `:SessionSave` / `:SessionDelete` |

## FZF Picker (inside a picker)

| Key | Action |
| --- | ------ |
| `<C-d>` / `<C-u>` | Scroll preview page-wise |
| `<C-e>` / `<C-y>` | Scroll preview line-wise |
| `<C-j>` / `<C-k>` | Move down / up |
| `<C-s>` / `<C-v>` / `<C-t>` | Open in split / vsplit / tab |
| `Tab` (or `<C-i>`) | Mark / unmark the current line |
| `<C-a>` | Mark every line in the filtered list |
| `<C-q>` | Send marked lines to quickfix; nothing marked sends the whole filtered list |
| `<C-z>` | Hide the picker (keeps query, cursor, marks); `:FzfLua unhide` or `<leader><CR>` restores it |
| `F4` | Toggle preview |
