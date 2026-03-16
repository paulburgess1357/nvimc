# Avante.nvim Reference

## Chat Controls

| Key | Action |
|-----|--------|
| `<CR>` | Send message (normal mode) |
| `<C-s>` | Send message (insert mode) |
| `q` | Close sidebar |
| `<Tab>` | Switch between input/response windows |
| `<S-Tab>` | Expand tool use output |
| `r` | Retry last request |
| `e` | Edit last request |
| `x` | Toggle code window |

## Accepting Code Changes

| Key | Action |
|-----|--------|
| `a` | Apply suggestion at cursor |
| `A` | Apply all suggestions |

After applying, in the diff:

| Key | Action |
|-----|--------|
| `co` | Accept "ours" (keep original) |
| `ct` | Accept "theirs" (accept AI change) |
| `ca` | Accept all AI changes |
| `cb` | Keep both |
| `cc` | Accept whichever side cursor is on |
| `]x` / `[x` | Next/prev conflict |

## Context & Files

| Key | Action |
|-----|--------|
| `@` | Add file to context (in sidebar) |
| `d` | Remove file from context |
| `<leader>ac` | Add current buffer to context |
| `<leader>aB` | Add all open buffers to context |

## History

| Key | Action |
|-----|--------|
| `<leader>ah` | Select history |

## Global Keybindings

| Key | Action |
|-----|--------|
| `<leader>aa` | Open ask prompt |
| `<leader>at` | Toggle sidebar |
| `<leader>an` | New conversation |
| `<leader>ae` | Edit selection with AI |
| `<leader>af` | Focus sidebar |
| `<leader>ar` | Refresh |
| `<leader>aS` | Stop generation |

## Navigation

| Key | Action |
|-----|--------|
| `]]` / `[[` | Next/prev jump point |
| `]p` / `[p` | Next/prev prompt in sidebar |

## Commands

| Command | Action |
|---------|--------|
| `:Chat` | Toggle AI sidebar |
| `:ChatNew` | New conversation |
| `:ChatHistory` | Browse saved chats |
| `:ChatCommands` | Open this reference |

## Project Prompts

Create an `avante.md` file in your project root to customize the system prompt per-project.
