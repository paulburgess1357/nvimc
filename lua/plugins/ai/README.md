# AI Plugins

- [CodeCompanion.nvim](https://github.com/olimorris/codecompanion.nvim) - AI chat and inline assistance
- [copilot.vim](https://github.com/github/copilot.vim) - Inline suggestions (Tab to accept)
- [codecompanion-history.nvim](https://github.com/ravitemer/codecompanion-history.nvim) - Chat session persistence
- [mcphub.nvim](https://github.com/ravitemer/mcphub.nvim) - MCP server integration

## Quick Start

1. Set your API key: `export ANTHROPIC_API_KEY=...` (or OpenAI, Gemini)
2. Run `:Chat` to start chatting
3. Use `@neovim` in messages to enable file operations

## Commands

See [COMMANDS.md](../../COMMANDS.md) for all commands.

| Command | Description |
| ------- | ----------- |
| `:Chat` | Toggle chat (auto-inits with `@{neovim}` hint) |
| `:ChatNew` / `:NewChat` | New chat (with `@{neovim}` hint) |
| `:ChatSend` / `:SendChat` | Send selection with code content |
| `:SendRef` / `:RefSend` | Send selection reference only |
| `:ChatHistory` | Browse saved chats |
| `:ChatLog` | Open log file |
| `:CodeCompanion <prompt>` | Inline assist |
| `:CodeCompanionActions` | Action palette |
| `:MCPHub` | MCP Hub interface |

## Chat Keymaps

| Key | Action |
| --- | ------ |
| `<CR>` / `<C-s>` | Send message |
| `q` | Hide chat |
| `<C-c>` | Close chat |
| `ga` | Change adapter/model |
| `gr` | Regenerate response |
| `gx` | Clear chat |
| `gh` | Browse history |
| `?` | Show all keymaps |

## Chat Syntax

| Prefix | Purpose | Examples |
| ------ | ------- | -------- |
| `@` | Tools | `@neovim`, `@mcp` |
| `#` | Variables | `#buffer`, `#lsp`, `#viewport` |
| `/` | Commands | `/file`, `/buffer`, `/symbols`, `/fetch` |

## MCP Tools (`@neovim`)

Include `@neovim` in your message to enable these tools:

- `read_file`, `read_multiple_files` - Read files
- `write_file`, `edit_file` - Write/edit files
- `find_files`, `list_directory` - Search and browse
- `move_item`, `delete_items` - File operations
- `execute_command` - Shell commands
- `execute_lua` - Run Lua in Neovim

## Configuration

### Provider

Edit `lua/plugins/ai/codecompanion.lua`:

```lua
local DEFAULT_ADAPTER = "anthropic"  -- or "copilot", "openai", "gemini", "ollama"
local DEFAULT_MODEL = nil            -- nil uses adapter's default
```

### Environment Variables

| Provider | Variable |
| -------- | -------- |
| Anthropic | `ANTHROPIC_API_KEY` |
| OpenAI | `OPENAI_API_KEY` |
| Gemini | `GEMINI_API_KEY` |
| Copilot | `:Copilot auth` (no env var) |
| Ollama | (local, no env var) |

### System Prompts

Add `.md` files to `lua/plugins/ai/prompts/startup/` - they're concatenated alphabetically into the system prompt.

### Neovim Hint

The `NEOVIM_HINT` variable in `lua/plugins/ai/codecompanion.lua` is automatically included in new chats and when sending code. It reminds the AI about available tools.

### Copilot Inline Suggestions

In `lua/config/plugins.lua`:

```lua
copilot = { enabled = true, inline_suggestions = true },
```

## Troubleshooting

**MCP hub not found:** Run `:Lazy build mcphub.nvim`
