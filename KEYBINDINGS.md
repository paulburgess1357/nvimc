# Key Bindings

Leader key is `Space`.

## Navigation

| Key | Action |
| --- | ------ |
| `<C-h/j/k/l>` | Window navigation |
| `<A-h/j/k/l>` | Resize window (drags the divider on that side) |
| `<C-S-j/k>` | Bisect jump — binary-search the visible window for a line |
| `<S-h/l>` | Buffer prev/next (tabline order) |
| `<C-S-h/l>` | Move current buffer tab left/right |
| `<C-d>` / `<C-u>` | Half-page down/up, cursor kept centered |
| `n` / `N` | Next/prev search match, centered |
| `w` / `e` / `b` | Word motions, camelCase/snake_case aware (spider) |
| `{` / `}` | Previous/next symbol (aerial) |
| `]]` / `[[` | Next/prev reference (illuminate) |
| `]d` / `[d` | Next/prev diagnostic |
| `]h` / `[h` | Next/prev git hunk |
| `]t` / `[t` | Next/prev todo comment |

## Find (Space f)

| Key | Action |
| --- | ------ |
| `ff` | Files (search root, see `<leader><leader>.`) |
| `fr` | Recent files |
| `fb` | Buffers |
| `fh` | Help |
| `fk` | Keymaps |
| `fm` | Marks |
| `fc` | Colorschemes |
| `fR` | Registers |
| `fd` | Document diagnostics |
| `fD` | Workspace diagnostics |
| `fq` | Quickfix list |
| `fl` | Location list |
| `f/` | Search history |

## Search (Space s)

| Key | Action |
| --- | ------ |
| `sg` | Grep (search root) |
| `sw` | Word under cursor (search root) |
| `sW` | WORD under cursor (search root) |
| `sv` (visual) | Selection (search root) |
| `sb` | Current buffer |
| `ss` | Document symbols |
| `sS` | Workspace symbols (live) |
| `so` | Outline (aerial) |
| `st` | Todo comments |
| `sT` | TODO/FIX/FIXME only |

## Code (Space c)

| Key | Action |
| --- | ------ |
| `ca` | Code action |
| `cr` | Rename (live preview) |
| `cf` | Format buffer |
| `cd` | Document diagnostics |
| `cl` | Trigger lint |
| `c` (visual) | Comment selection |

## LSP (active while a server is attached)

| Key | Action |
| --- | ------ |
| `gd` | Definition |
| `gD` | Declaration |
| `gr` | References |
| `gR` | Finder: references, definitions, implementations, calls in one picker |
| `gI` | Implementation |
| `gy` | Type definition |
| `K` | Hover |
| `gK` | Signature help |
| `gl` | Line diagnostics (float) |

## Git (Space g/h)

| Key | Action |
| --- | ------ |
| `gf` | Git files |
| `gc` | Commits |
| `gb` | Branches |
| `gs` | Status |
| `gd` | Diff view (toggle) |
| `gh` | File history (current file) |
| `hs` / `hr` | Stage / reset hunk (visual: selected lines) |
| `hS` / `hR` | Stage / reset buffer |
| `hu` | Undo stage hunk |
| `hp` | Preview hunk |
| `hb` | Blame line |
| `hd` / `hD` | Diff this against index / against `~` |

## Debug (Space d)

| Key | Action |
| --- | ------ |
| `db` | Toggle breakpoint |
| `dB` | Conditional breakpoint |
| `dL` | Log point |
| `dE` | Exception breakpoints (all / uncaught / none) |
| `dc` | Continue / Start |
| `dC` | Run to cursor |
| `dl` | Run last |
| `dp` | Pause |
| `dt` | Terminate |
| `di` / `do` / `dO` | Step into / over / out |
| `dj` / `dk` | Down / up the stack |
| `dr` | Toggle REPL |
| `ds` | Session |
| `da` | Add word under cursor to watches |
| `du` | Toggle DAP UI |
| `de` | Eval expression (normal: word, visual: selection) |
| `F5` / `F8` / `F10` / `F11` / `S-F11` | Continue / Toggle breakpoint / Step over / Step into / Step out |

## UI (Space u)

| Key | Action |
| --- | ------ |
| `uw` | Toggle line wrap |
| `ul` | Toggle relative numbers |
| `us` | Toggle spell |
| `un` | Dismiss all notifications |
| `um` | Toggle markdown rendering |

## Custom Menu (Space Space)

| Key | Action |
| --- | ------ |
| `f` | Files (search root) |
| `g` | Grep (search root) |
| `h` | Files (home directory) |
| `j` | Grep (home directory) |
| `r` | Recent files |
| `m` | Marks |
| `l` | Symbols (workspace) |
| `d` | Diff view: review branch vs a base you enter |
| `a` | Toggle format on save |
| `s` | Toggle diagnostic signs |
| `v` | Toggle virtual text |
| `b` | Toggle git blame (current line) |
| `w` | Toggle line wrap |
| `t` | Toggle smart wrap copy (rejoin soft-wrapped lines yanked from terminals) |
| `z` | Toggle zoom: current window (file or terminal) fills the screen; again restores the layout |
| `.` | Toggle search root: cwd (default) or the current file's directory. Applies to all files/grep pickers; the picker title shows the active root |

## Other

| Key | Action |
| --- | ------ |
| `<C-/>` | Toggle bottom terminal (Term1) |
| `<C-S-Space>` | Bounce between code and terminals: from a file, focus Term10 in insert mode (opening it if needed); from inside any terminal, return to the window you were in before (file or terminal) |
| `{n}<C-S-Space>` | Go to Term{n} in insert mode from anywhere: `8<C-S-Space>` focuses Term8 |
| `<F9>` | Paste current line (visual: selection) into the default terminal and press Enter, then move down (`:TermRun`; default set by `settings.send_term`) |
| `{n}<F9>` | Same, into Term{n}: `3<F9>` runs in Term3 (`:TermRun 3`) |
| `<Esc><Esc>` (terminal mode) | Back to normal mode |
| `Esc` (in terminal normal mode) | Jump to leftmost window |
| `q` (in terminal normal mode) | Close the terminal window (shell keeps running) |
| `<leader>e` | File explorer (directory of current file) |
| `<leader>E` | File explorer (cwd) |
| `<leader>o` | Toggle outline |
| `<leader>n` | Notification history |
| `<leader>w` | Save |
| `<leader>q` | Quit |
| `<leader>-` | Split horizontal |
| `<leader>\|` | Split vertical |
| `<leader>wd` | Close window |
| `<leader>bd` / `<leader>bD` | Delete buffer / force delete |
| `<leader>:` | Command history |
| `<leader>?` | Buffer-local keymaps (which-key) |
| `<leader>ts` | Cycle onedark style |
| `<leader><CR>` | Resume last FZF picker (or unhide a hidden one) |
| `J` / `K` (visual) | Move selected lines down / up |
| `<` / `>` (visual) | Indent and keep selection |
| `/` / `?` | Search is literal (`\V` prefix); `/\v` for regex. `:s` patterns are literal too |
| `Esc` | Clear search highlights |
| `q` (in quickfix) | Close quickfix/location list |
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
| `'text` / `^text` / `text$` / `!text` | Exact / prefix / suffix / exclude (fzf syntax) |
