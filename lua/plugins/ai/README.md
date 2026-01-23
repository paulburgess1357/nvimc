# AI Plugins

- [copilot.vim](https://github.com/github/copilot.vim) - GitHub Copilot authentication and inline suggestions
- [CodeCompanion.nvim](https://github.com/olimorris/codecompanion.nvim) - AI chat, inline assistance, and agent workflows
- [codecompanion-history.nvim](https://github.com/ravitemer/codecompanion-history.nvim) - Save and restore chat sessions
- [mcphub.nvim](https://github.com/ravitemer/mcphub.nvim) - MCP (Model Context Protocol) server integration

## Setup

### Requirements

- [Anthropic API key](https://console.anthropic.com/) (recommended), OR
- [GitHub Copilot](https://github.com/features/copilot) subscription

### Environment Variables

| Adapter | Environment Variable |
| ------- | -------------------- |
| Anthropic | `ANTHROPIC_API_KEY` |
| OpenAI | `OPENAI_API_KEY` |
| Gemini | `GEMINI_API_KEY` |

### Copilot Authentication

1. Open Neovim
2. Run `:Copilot auth`
3. Follow the prompts to authenticate with GitHub

### MCP Servers

If you get a "mcp-hub executable not found" error, run:

```
:Lazy build mcphub.nvim
```

## Configuration

### Adapter and Model

Edit `lua/plugins/ai/codecompanion.lua`:

```lua
-- Change adapter (line 11)
local DEFAULT_ADAPTER = "anthropic"  -- or "copilot", "openai", "gemini", "ollama"

-- Change model per adapter (MODELS table)
local MODELS = {
	anthropic = "claude-sonnet-4-5-20250929",
	copilot = "claude-sonnet-4",
	openai = "gpt-4o",
	...
}
```

Available models are documented in the comments at the top of the file.

### Copilot Options

In `lua/config/plugins.lua`:

```lua
copilot = { enabled = true, inline_suggestions = true },
```

- `inline_suggestions` - Enable Copilot ghost text suggestions (Tab to accept)

### System Prompts

Custom system prompts are loaded from `lua/plugins/ai/prompts/startup/`. All `.md` files in this folder are concatenated (alphabetically) into the system prompt for every chat.

```
lua/plugins/ai/prompts/
└── startup/
    └── 01-communication-style.md  # Response style guidelines
```

To customize AI behavior, edit the files in `startup/` or add new ones. Changes apply on next chat.

## Commands

| Command | Description |
| ------- | ----------- |
| `:Chat` | Toggle chat window |
| `:NewChat` / `:ChatNew` | Start a new chat |
| `:ChatHistory` | Browse and restore saved chats |
| `:CodeCompanion` | Inline assist |
| `:CodeCompanionActions` | Actions menu |
| `:MCPHub` | Open MCP Hub interface |

## Lualine Status

Status indicators in lualine (section x):

| Component | Idle | Active |
| --------- | ---- | ------ |
| CodeCompanion | `✓` | Spinner + request count |
| MCPHub | `󰐻 N` (server count) | Spinner |

## CodeCompanion Chat

### Keymaps

| Key | Action |
| --- | ------ |
| `<CR>` / `<C-s>` | Send message |
| `q` | Toggle chat (hide window) |
| `<C-c>` | Close chat |
| `ga` | Change adapter, then model |
| `gr` | Regenerate last response |
| `gx` | Clear chat |
| `gh` | Browse chat history |
| `?` | Show all keymaps |

### Chat History

Chats are automatically saved and can be restored later with full context (messages, tools, system prompts). History is filtered by current working directory - you only see chats from your current project.

| Command / Key | Action |
| ------------- | ------ |
| `:ChatHistory` | Browse saved chats (current project) |
| `gh` (in chat) | Browse history |
| `<CR>` | Select/restore chat |
| `d` | Delete chat |
| `r` | Rename chat |

History is stored in `~/.local/share/nvim/codecompanion-history/`.

### Completion Prefixes

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

## MCP Server Usage

To give the AI access to MCP tools (file operations, shell commands, etc.), include `@neovim` in your message:

```
@neovim list all lua files in this project
@neovim read the file /path/to/file.lua
@neovim use execute_command to run :wincmd p | e /path/to/file.lua
```

Without `@neovim` (or another server), the AI cannot use those tools.

### Syntax

| Syntax | Description |
| ------ | ----------- |
| `@neovim` | Load all neovim tools (files, commands, LSP) |
| `@mcp` | Access all MCP servers |
| `@server__tool` | Use specific tool (e.g., `@neovim__read_file`) |
| `#resource` | Access MCP resources as variables |
| `/mcp:prompt` | Run MCP prompts |

### Built-in Neovim Tools

| Tool | Description |
| ---- | ----------- |
| `read_file` | Read file contents |
| `read_multiple_files` | Read several files |
| `find_files` | Search for files by pattern |
| `list_directory` | List directory contents |
| `edit_file` | Edit a file |
| `write_file` | Create/write a file |
| `delete_items` | Delete files/directories |
| `move_item` | Move/rename files |
| `execute_command` | Run shell commands |
| `execute_lua` | Run Lua code in Neovim |
