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
| `:Tabs` | Tab pages, each with what its windows show; picking one goes to it (see [Tabs](#tabs)) |
| `:Dashboard [name]` | Open the dashboard; with a name, in that header gradient (tab-completes; `random`, `theme` or one of the palettes in `plugin/ui/snacks.lua`). `settings.dashboard_gradient` pins one |
| `:SessionSave` / `:SessionRestore` / `:SessionDelete` | Per-directory session (auto-saved on quit) |
| `:Session <name>` | Name the current session (shown in `:Sessions` and in the terminal title after the working directory), as `:Term 4 <name>` and `:Tab 4 <name>` name a terminal or a tab: the directory still identifies the session, the name is a label. `:Session -` clears it. Saved with the session, so it reaches disk when the session does (quit, `:SessionSave`) |
| `:Sessions` | Saved sessions, one per directory, most recent first (the current one marked, each with its `:Session` name), with each one's tabs, terminals and files in the preview. Picking one saves the current session, closes its tabs, files and idle shells (a shell running something is kept), moves to that directory and restores it. Refused while a buffer is modified or a debug session runs. Sessions under the temp directory and `~/.cache` are left out |
| `:Term <n>` | Toggle Term `<n>` (1-10), like `<C-/>` does Term 1: hidden, it opens in insert mode (spawning the shell if needed; its slot number decides where, see [Terminals](#terminals)); on screen in this tab, its window closes and the shell keeps running |
| `:Term <n> <name>` | Show Term `<n>` (never closes it) and label it `<name>` in its winbar; `:Term <n> -` clears the label |
| `:Term <name>` | Toggle the terminal labelled `<name>`; tab-completes labels |
| `:Term 1,2,5` / `:Term 1-4,10` | Open every terminal listed, ending in the last in insert mode |
| `:TermFocus [n\|name]` | Show the terminal (default Term 10) and enter insert mode; never closes it |
| `:[range]TermRun [n\|name]` | Paste the line/range into Term `<n>` or the terminal labelled `<name>` (default `settings.send_term`) and press Enter, then move the cursor below it |

## Terminals

```
+-----------------------+--------+--------+
|                       | Term 9 | Term 10|
|         files         |        |        |
|                       +--------+--------+
+-------+-------+-------+ Term 7 | Term 8 |
| Term 1|  ...  | Term 6|        |        |
+-------+-------+-------+--------+--------+
```

- **Term 1-6**: bottom row under the files, equal widths.
- **Term 7-10**: two full-height columns on the right. Term 10 sits over Term 8 at the far right, Term 9 over Term 7 to its left. A lone terminal takes its whole column.
- The two columns are always the same width: 28% of the screen with one open, 22% each with both.
- Shells keep running while hidden. Sessions restore which terminals were visible, their sizes, names and directories.
- A Term window shows only its terminal. Open a file into it by mistake (`:e`, a picker, the buffer popup) and the terminal is put back with a notice; the file is loaded, not shown.
- Tab pages: the ten slots and their shells are shared by every tab, the windows are per tab. `:Term 3` in a tab looks for Term 3 among that tab's windows only, so a shell can be on screen in two tabs at once (like a file) or in none. The layout above holds within each tab, and a session restores the terminals of every tab.
- Code lives in `lua/utils/terms.lua`.

## Tabs

A tab page is a window layout: each tab has its own splits, while buffers and Term shells are shared. Tabs are numbered slots like the terminals: Tab 4 stays Tab 4 for life, closing Tab 2 leaves Tab 1 and Tab 3, and tabs sit in slot order. `H` / `L` step through them. With two or more tabs the statusline shows them (`2 (build)`), the current one in the mode color. The commands have the same shapes as `:Term`.

| Command | Action |
| ------- | ------ |
| `:Tab <n>` | Go to Tab `<n>`, creating it (after the last lower slot, showing the dashboard) if there is none; typed in Tab `<n>` itself, closes it (a toggle, like `:Term <n>`). To open a file in a new one: `:Tab 4 \| e Makefile`. `:tabnew` is Neovim's own |
| `:Tab <n> <name>` | Go to Tab `<n>` (never closes it) and name it; `:Tab <n> -` clears the name |
| `:Tab <name>` | Toggle the tab named `<name>` the same way; tab-completes numbers and names |
| `:CloseTab [n\|name]` / `:TabClose [n\|name]` | Close the current tab (or that one). Closing the last tab leaves one window with the dashboard; buffers stay loaded and shells keep running. `:tabclose` is Neovim's own |
| `:Tabs` | fzf-lua picker: `Tab <n> (name) · files, Term slots and side windows open in it`, with the tab's current buffer in the preview |

- A tab made any other way (Neovim's `:tabnew`, the diff tab) takes the number after the highest in use.
- Slots and names are saved with the session, as are the current tab and the current window of every tab (`:mksession` keeps only the current tab's); `:mksession` saves the tabs and their windows. The file windows above restored terminals get their cursor and view back once the terminals are in place. A tab holding only the dashboard or only terminals comes back the same way.
- A diff (`<leader>gd`, `<leader>gh`) opens in its own tab at the end, named `diff` or `history`, and closes with `q` or the toggle from any tab. It is never saved in a session. Folders closed in its file panel stay closed when you come back to the tab or after a refresh (a save, a stage); diffview on its own reopens them all.
- Code lives in `lua/utils/tabs.lua` (`:Tabs` in `plugin/editor/fzf.lua`).

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
