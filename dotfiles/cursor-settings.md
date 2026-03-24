# Cursor IDE Settings

Settings file: `~/.config/Cursor/User/settings.json`

## Terminal

- **Font**: `JetBrainsMono Nerd Font Mono` — Nerd Font for icon/symbol support in Neovim
- **Location**: `editor` — Terminal opens as an editor tab instead of a bottom panel
- **GPU Acceleration**: `on` — WebGL rendering for best performance

## Keybinding Passthrough

- **sendKeybindingsToShell**: `true` — Sends keybindings like Ctrl+K, Ctrl+P, Ctrl+W directly to the shell/Neovim instead of Cursor intercepting them
- **commandsToSkipShell**: Disabled `quickOpen` and `focusFind` so those keys reach Neovim

## Environment

- **COLORTERM**: `truecolor` — Tells Neovim true color is supported
- **TERM**: `xterm-256color` — Standard 256-color terminal type

## Color Accuracy

- **minimumContrastRatio**: `1` — Prevents Cursor from adjusting theme colors for accessibility contrast, so Neovim colors match what you see in Kitty

## Other

- **Command Center**: enabled (default, was already set)
