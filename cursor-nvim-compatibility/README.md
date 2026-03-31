# cursor-nvim-compatibility

Scripts and rules that let Cursor's AI agent interact with a running Neovim instance in the terminal.

## What the AI can do

- Open one or more files as Neovim buffers
- Open a file and jump to a specific line
- Show two files side by side in a vertical split
- Send keystrokes (visual select, motions, operators)
- Send ex commands (save, search, substitute, etc.)
- Query Neovim state (current file, working directory, line count)
- Reload buffers after editing files on disk
- Reference code using absolute line numbers for easy `<line>G` navigation

## What's included

| File | Purpose |
|------|---------|
| `scripts/nvim-send` | Send keystrokes, ex commands, or evaluate expressions in a running Neovim instance |
| `scripts/nvim-open` | Find and open files in Neovim (wraps `nvim-send`) |
| `rules/neovim-communication.mdc` | Cursor rule — tells the AI how to interact with Neovim |

## Setup

Symlink the rules into your global Cursor rules directory:

```bash
mkdir -p ~/.cursor/rules
ln -s <REPO_ROOT>/cursor-nvim-compatibility/rules/* ~/.cursor/rules/
```

The AI resolves the symlink to find the scripts automatically — no PATH setup needed.

## Requirements

- Neovim with a server socket (most installs create one automatically)
- `set autoread` in Neovim config (needed for `checktime` buffer reload)
- `bash` 4.0+

Run any script with `-h` for usage details.

## Testing

Open Neovim in a Cursor terminal, then paste the following to an AI chat to test each capability:

```
I have Neovim running in the terminal. Run through these tests one at a time, confirming each works before moving on:

1. Resolve SCRIPT_DIR — run the readlink command from the neovim-communication rule and confirm it points to cursor-nvim-compatibility/
2. Open a file by name — use nvim-open to open main.cpp
3. Open a file by absolute path — use nvim-open with the full path to Entity.cpp
4. Open multiple files — use nvim-open to open Entity.cpp, main.cpp, and Component.cpp in one call
5. Open and jump to line — use nvim-open -g 10 to open main.cpp and land on line 10
6. List search matches — use nvim-open -l Entity to list matches without opening
7. Vertical split — use nvim-send to open a header file in a vertical split next to the current buffer
8. Send keystrokes — use nvim-send to visual-line select lines 10-20 in the current buffer
9. Query Neovim state — use nvim-send -e to print the current buffer's file path
10. Edit and reload — edit a file that is currently open in Neovim, then run checktime and confirm the changes appear without switching buffers
11. Line numbers — point out something in the current file using an absolute line number
12. Show code — find something interesting in the codebase, then open the file and jump to the line so I can see it in Neovim
```
