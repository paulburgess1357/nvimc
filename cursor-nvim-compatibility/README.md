# cursor-nvim-compatibility

Scripts and rules that let Cursor's AI agent interact with a running Neovim instance in the terminal.

## What's included

| File | Purpose |
|------|---------|
| `scripts/nvim-send` | Send keystrokes, ex commands, or evaluate expressions in a running Neovim instance |
| `scripts/nvim-open` | Find and open files in Neovim (wraps `nvim-send`) |
| `rules/neovim-communication.mdc` | Cursor rule — tells the AI to use absolute line numbers, use these scripts, and never change Neovim settings |

## Setup

Symlink the rules into your global Cursor rules directory:

```bash
mkdir -p ~/.cursor/rules
ln -s <REPO_ROOT>/cursor-nvim-compatibility/rules/* ~/.cursor/rules/
```

The AI resolves the symlink to find the scripts automatically — no PATH setup needed.

## Requirements

- Neovim with a server socket (most installs create one automatically)
- `bash` 4.0+

Run any script with `-h` for usage details.
