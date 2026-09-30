# Commands

See [KEYBINDINGS.md](KEYBINDINGS.md) for key bindings.

## General

| Command | Action |
| ------- | ------ |
| `:Files` | Find files |
| `:Buffers` | Buffer list |
| `:Rg` / `:Grep` | Live grep |
| `:Symbols` | Document symbols |
| `:SymbolsAll` | Workspace symbols (live, search root only) |
| `:Marks` | Marks |
| `:Help` | Help tags |
| `:Commands` | Commands |
| `:Keymaps` | Keymaps |
| `:Aerials` | Toggle outline sidebar |
| `:SessionSave` / `:SessionRestore` / `:SessionDelete` | Per-directory session (auto-saved on quit) |
| `:Term1`..`:Term9`, `:Term10` | Toggle a bottom (1-9) or right-column (10) terminal |
| `:Term<n> <name>` | Show Term<n> (opening it if needed) and label it `<name>` in its winbar; never closes it |
| `:Term<n> -` | Same, but clears the label |
| `:Term <name>` | Toggle the terminal labelled `<name>` (a number works too); tab-completes names |
| `:Term10Focus` | Show Term10 and enter insert mode |
| `:[range]TermRun [n\|name]` | Paste the line/range into Term<n> or the terminal labelled `<name>` (default `settings.send_term`) and press Enter, then move the cursor below it |

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
| `:LspLog` | Open the LSP log file |
| `:IncRename <name>` | Rename with live preview (`<leader>cr` prefills the word under cursor) |

## Misc

| Command | Action |
| ------- | ------ |
| `:McpClearHighlights` / `:McpClearVirtualTexts` | Clear annotations left by nvim-mcp |
