# Commands

See [KEYBINDINGS.md](KEYBINDINGS.md) for key bindings.

## General

| Command | Action |
| ------- | ------ |
| `:Files` | Find files |
| `:Buffers` | Buffer list |
| `:Rg` / `:Grep` | Live grep |
| `:Symbols` | Document symbols |
| `:Marks` | Marks |
| `:Help` | Help tags |
| `:Commands` | Commands |
| `:Keymaps` | Keymaps |
| `:Aerials` | Toggle outline sidebar |
| `:Term1`..`:Term9`, `:Term10` | Toggle a bottom (1-9) or right-column (10) terminal |
| `:Term10Focus` | Show Term10 and enter insert mode |
| `:[range]TermRun` | Paste the line/range into Term<`settings.send_term`> and press Enter, then move the cursor below it |

## Git / Diff

| Command | Action |
| ------- | ------ |
| `:DiffviewOpen` | Side-by-side diff of uncommitted changes |
| `:DiffviewOpen <rev>` | Diff against a rev/range (e.g. `main...HEAD`, `HEAD~2`) |
| `:DiffviewClose` | Close the diff view |
| `:DiffviewFileHistory %` | History of the current file |
| `:DiffviewFileHistory` | History of the current branch |

## LSP

| Command | Action |
| ------- | ------ |
| `:LspIndexAll` | Force LSP to index all project files |
