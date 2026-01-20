# AI Plugins

- [copilot.vim](https://github.com/github/copilot.vim) - GitHub Copilot authentication and inline suggestions
- [CodeCompanion.nvim](https://github.com/olimorris/codecompanion.nvim) - AI chat, inline assistance, and agent workflows
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
local default_adapter = "anthropic"  -- or "copilot", "openai", "gemini", "ollama"
local default_model = "claude-sonnet-4-5-20250929"
```

### Copilot Options

In `lua/config/plugins.lua`:

```lua
copilot = { enabled = true, inline_suggestions = true },
```

- `inline_suggestions` - Enable Copilot ghost text suggestions (Tab to accept)

## Commands

| Command | Description |
| ------- | ----------- |
| `:Chat` | Toggle chat window |
| `:NewChat` / `:ChatNew` | Start a new chat |
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
| `?` | Show all keymaps |

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
