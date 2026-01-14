# AI Plugins

- [copilot.vim](https://github.com/github/copilot.vim) - GitHub Copilot authentication (inline suggestions disabled)
- [CodeCompanion.nvim](https://github.com/olimorris/codecompanion.nvim) - AI chat, inline assistance, and agent workflows

## Requirements

- [GitHub Copilot](https://github.com/features/copilot) subscription

## Authentication

1. Open Neovim
2. Run `:Copilot auth`
3. Follow the prompts to authenticate with GitHub

## Commands

- `:Chat` - Toggle chat window
- `:NewChat` / `:ChatNew` - Start a new chat
- `:CodeCompanion` - Inline assist
- `:CodeCompanionActions` - Actions menu

## CodeCompanion Chat Reference

### Keymaps (in chat buffer)

| Key | Action |
| --- | ------ |
| `<CR>` / `<C-s>` | Send message |
| `q` | Toggle chat (hide window) |
| `<C-c>` | Close chat |
| `ga` | Change adapter, then model |
| `gr` | Regenerate last response |
| `gx` | Clear chat |
| `?` | Show all keymaps |

### Completion

| Prefix | Type | Example |
| ------ | ---- | ------- |
| `#` | Variables | `#buffer`, `#lsp`, `#viewport` |
| `/` | Slash commands | `/file`, `/buffer`, `/symbols` |
| `@` | Tools | `@files`, `@editor` |

### Slash Commands

| Command | Description |
| ------- | ----------- |
| `/file` | Add file contents |
| `/buffer` | Add open buffer contents |
| `/symbols` | Add symbolic outline of a file |
| `/fetch` | Add URL contents |
| `/help` | Add vim help content |
| `/now` | Insert datetime |
| `/terminal` | Add terminal output |
| `/compact` | Clear history, keep summary |

### Variables

| Variable | Description |
| -------- | ----------- |
| `#buffer` | Current buffer contents |
| `#lsp` | LSP info from current buffer |
| `#viewport` | What's visible on screen |

## Inline Assistant

Use `:CodeCompanion <prompt>` with optional visual selection.

### Diff Keymaps

| Key | Action |
| --- | ------ |
| `gda` | Accept edits |
| `gdr` | Reject edits |

### Built-in Prompts

| Command | Description |
| ------- | ----------- |
| `:CodeCompanion /commit` | Generate commit message |
| `:CodeCompanion /explain` | Explain code |
| `:CodeCompanion /fix` | Fix code |
| `:CodeCompanion /tests` | Generate unit tests |

## Action Palette

Use `:CodeCompanionActions` to open the action palette with all available prompts and actions.
