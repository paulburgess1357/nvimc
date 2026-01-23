# Key Bindings

## General

| Key     | Action                  |
| ------- | ----------------------- |
| `Space` | Leader key              |
| `Esc`   | Clear search highlights |

## Navigation

| Key           | Action               |
| ------------- | -------------------- |
| `<C-h/j/k/l>` | Window navigation    |
| `<S-h/l>`     | Buffer prev/next     |
| `{` / `}`     | Previous/next symbol |
| `]]` / `[[`   | Next/prev reference  |

## Find (Space f)

| Key  | Action       |
| ---- | ------------ |
| `ff` | Files        |
| `fr` | Recent files |
| `fb` | Buffers      |
| `fh` | Help         |
| `fk` | Keymaps      |
| `fm` | Marks        |

## Search (Space s)

| Key  | Action                   |
| ---- | ------------------------ |
| `sg` | Grep                     |
| `sw` | Word under cursor        |
| `sb` | Current buffer           |
| `ss` | Document symbols         |
| `so` | Outline symbols (aerial) |
| `st` | Todo comments            |

## Code (Space c)

| Key  | Action               |
| ---- | -------------------- |
| `ca` | Code action          |
| `cr` | Rename               |
| `cf` | Format               |
| `cd` | Document diagnostics |
| `cl` | Trigger lint         |

## Git (Space g/h)

| Key  | Action       |
| ---- | ------------ |
| `gf` | Git files    |
| `gc` | Commits      |
| `gb` | Branches     |
| `gs` | Status       |
| `hs` | Stage hunk   |
| `hr` | Reset hunk   |
| `hp` | Preview hunk |
| `hb` | Blame line   |

## Debug (Space d)

| Key             | Action                         |
| --------------- | ------------------------------ |
| `db`            | Toggle breakpoint (persistent) |
| `dB`            | Conditional breakpoint         |
| `dL`            | Log point                      |
| `dE`            | Exception breakpoints          |
| `dc`            | Continue / Start               |
| `di`            | Step into                      |
| `do`            | Step over                      |
| `dO`            | Step out                       |
| `du`            | Toggle DAP UI                  |
| `de`            | Eval expression                |
| `da`            | Add watch                      |
| `dt`            | Terminate                      |
| `F5/F9/F10/F11` | Continue/Breakpoint/Over/Into  |

## Custom Menu (Space Space)

| Key          | Action             |
| ------------ | ------------------ |
| `<leader><leader>f` | Files (cwd)        |
| `<leader><leader>g` | Grep (cwd)         |
| `<leader><leader>h` | Files (home)       |
| `<leader><leader>j` | Grep (home)        |
| `<leader><leader>r` | Recent files       |
| `<leader><leader>m` | Marks              |
| `<leader><leader>l` | Symbols (workspace)|
| `<leader><leader>s` | Toggle diagnostic signs |
| `<leader><leader>v` | Toggle virtual text|
| `<leader><leader>a` | Toggle format on save |
| `<leader><leader>t` | Toggle hardtime    |

## AI

| Key | Action |
| --- | ------ |
| `Tab` | Accept Copilot suggestion (insert mode, when inline_suggestions enabled) |

### CodeCompanion Chat Buffer

| Key | Action |
| --- | ------ |
| `q` | Toggle chat (hide window) |
| `<CR>` / `<C-s>` | Send message |
| `ga` | Change adapter/model |
| `gr` | Regenerate response |
| `gx` | Clear chat |
| `gh` | Browse chat history |
| `?` | Show all keymaps |

## Terminal

| Key     | Action          |
| ------- | --------------- |
| `<C-/>` | Toggle terminal |

## Other

| Key          | Action                       |
| ------------ | ---------------------------- |
| `<leader>o`  | Toggle outline               |
| `<leader>e`  | File explorer (current file) |
| `<leader>E`  | File explorer (cwd)          |
| `<leader>n`  | Notification history         |
| `<leader>un` | Dismiss notifications        |
| `<leader>w`  | Save                         |
| `<leader>q`  | Quit                         |
| `<leader>-`  | Split horizontal             |
| `<leader>\|` | Split vertical               |
| `gl`         | Line diagnostics             |
