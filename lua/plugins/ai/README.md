# AI Plugins

- [avante.nvim](https://github.com/yetone/avante.nvim) - AI chat with agentic capabilities

## Quick Start

1. Authenticate with Cursor: run `agent login` or set `CURSOR_API_KEY` env var
2. Run `:Chat` to open the AI sidebar
3. Run `:ChatNew` for a fresh conversation

## Commands

See [COMMANDS.md](../../COMMANDS.md) for all commands.

| Command | Description |
| ------- | ----------- |
| `:Chat` | Toggle AI sidebar |
| `:ChatNew` | New conversation |
| `:ChatHistory` | Browse saved chats |

## Configuration

### Provider

Edit `lua/plugins/ai/avante.lua`:

```lua
opts = {
    provider = "cursor",  -- or "openai", "claude", "gemini", etc.
    mode = "agentic",
},
```

### Project-specific prompts

Create an `avante.md` file in your project root to customize system prompts per-project.
