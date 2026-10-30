# Commands

See [KEYBINDINGS.md](KEYBINDINGS.md) for key bindings.

## General

| Command | Action |
| ------- | ------ |
| `:Files` | Files |
| `:Buffers` | Buffers |
| `:Terms` | Open Term slots, with a preview of each terminal; picking one focuses it |
| `:Rg` / `:Grep` | Live grep |
| `:Symbols` | Document symbols |
| `:SymbolsAll` | Workspace symbols (live, search root only) |
| `:Marks` | Marks |
| `:Help` | Help |
| `:Commands` | Commands |
| `:Keymaps` | Keymaps |
| `:Aerials` | Toggle outline sidebar |
| `:Dashboard [name]` | Open the dashboard; with a name, in that header gradient (tab-completes; `random`, `theme` or one of the palettes in `plugin/ui/snacks.lua`). `settings.dashboard_gradient` pins one |
| `:SessionSave` / `:SessionRestore` / `:SessionDelete` | Per-directory session (auto-saved on quit) |
| `:Term1`..`:Term10` | Toggle a terminal; its slot number decides where it opens (see [Terminals](#terminals)). Opening it puts you in it in insert mode |
| `:Term<n> <name>` | Show Term<n> (opening it if needed) in insert mode and label it `<name>` in its winbar; never closes it |
| `:Term<n> -` | Same, but clears the label |
| `:Term1,2,5` / `:Term1-4,10` | Open every terminal listed (never closes one), ending in the last in insert mode. No space after the number: with one, the rest is a label. `:Term 1,3-5` works too |
| `:Term <name>` | Toggle the terminal labelled `<name>` (a number works too), in insert mode when it opens; tab-completes names |
| `:TermFocus [n\|name]` | Show the terminal (default Term10) and enter insert mode; never closes it |
| `:[range]TermRun [n\|name]` | Paste the line/range into Term<n> or the terminal labelled `<name>` (default `settings.send_term`) and press Enter, then move the cursor below it |

## Terminals

```
+-----------------------+--------+--------+
|                       | Term9  | Term10 |
|         files         |        |        |
|                       +--------+--------+
+-------+-------+-------+ Term7  | Term8  |
| Term1 |  ...  | Term6 |        |        |
+-------+-------+-------+--------+--------+
```

- **Term1-6**: bottom row under the files, equal widths.
- **Term7-10**: two full-height columns on the right. Term10 sits over Term8 at the far right, Term9 over Term7 to its left. A lone terminal takes its whole column.
- The two columns are always the same width: 28% of the screen with one open, 22% each with both.
- Shells keep running while hidden. Sessions restore which terminals were visible, their sizes, names and directories.
- Lowercase works too: `:term9` is rewritten to `:Term9` (it would otherwise be Vim's `:terminal 9`).
- Code lives in `lua/utils/terms.lua`.

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
| `:LspIndexAll` | Force LSP to index all project files; progress shows in the LSP progress line (bottom right) |
| `:LspLog` | Open the LSP log file |
| `:IncRename <name>` | Rename with live preview (`<leader>cr` prefills the word under cursor) |

## Misc

| Command | Action |
| ------- | ------ |
| `:McpClearHighlights` / `:McpClearVirtualTexts` | Clear annotations left by nvim-mcp |
