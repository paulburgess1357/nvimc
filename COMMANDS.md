# Commands

| Command         | Action                               |
| --------------- | ------------------------------------ |
| `:Files`        | Find files                           |
| `:Buffers`      | Buffer list                          |
| `:Rg` / `:Grep` | Live grep                            |
| `:Symbols`      | Document symbols                     |
| `:Marks`        | Marks                                |
| `:Help`         | Help tags                            |
| `:Commands`     | Commands                             |
| `:Keymaps`      | Keymaps                              |
| `:Aerials`      | Toggle outline sidebar               |
| `:LspIndexAll`  | Force LSP to index all project files |
| `:Chat`         | Toggle AI chat window                |
| `:NewChat` / `:ChatNew` | Start a new AI chat          |
| `:CodeCompanion`| AI inline assist                     |
| `:CodeCompanionActions` | AI actions menu              |

## LspIndexAll

Forces the current buffer's LSP to index all matching files in the project. LSP Agnostic.

1. Detects the LSP attached to your current buffer
2. Finds all files matching that LSP's filetypes
3. Loads them to trigger indexing

## Custom Menu (Space Space)

| Key | Action                  |
| --- | ----------------------- |
| `a` | Toggle format on save   |
| `t` | Toggle hardtime         |
| `s` | Toggle diagnostic signs |
| `v` | Toggle virtual text     |
| `f` | Find files (cwd)        |
| `g` | Grep (cwd)              |
| `h` | Find files (home)       |
| `j` | Grep (home)             |
| `r` | Recent files            |
| `m` | Marks                   |
| `l` | Symbols (workspace)     |
