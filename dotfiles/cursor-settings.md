# Cursor IDE Settings

Settings file: `~/.config/Cursor/User/settings.json`

## Terminal

- **Font**: `JetBrainsMono Nerd Font Mono` — Nerd Font for icon/symbol support in Neovim
- **Location**: `editor` — Terminal opens as an editor tab instead of a bottom panel
- **GPU Acceleration**: `on` — WebGL rendering for best performance
- **enableKittyKeyboardProtocol**: `false` — Cursor's bundled xterm.js has a bug where the Kitty keyboard protocol mis-encodes Shift+number keys for apps that opt in (Neovim), so `Shift+1` typed `1` instead of `!`. This setting defaults to `true`, so it must be set explicitly to `false`. Re-enable once Cursor ships a newer xterm.js with the fix

## Keybinding Passthrough

- **sendKeybindingsToShell**: `true` — Sends keybindings like Ctrl+K, Ctrl+P, Ctrl+W directly to the shell/Neovim instead of Cursor intercepting them
- **commandsToSkipShell**: Disabled `quickOpen` and `focusFind` so those keys still reach Neovim

## Keybindings

File: `~/.config/Cursor/User/keybindings.json`

- **Ctrl+I**: Open the Agent (`composerMode.agent`)
- **Ctrl+Shift+Space**: Focus the agent chat input (`composer.focusComposer`). Works from the editor and the terminal/Neovim. Press `Esc` in the chat to return to Neovim

  Bound twice: once normally (for the editor) and once with `"when": "terminalFocus"`. The second entry is required because `sendKeybindingsToShell` is `true`, which would otherwise send the keys to the shell when the terminal is focused.

## Environment

- **COLORTERM**: `truecolor` — Tells Neovim true color is supported
- **TERM**: `xterm-256color` — Standard 256-color terminal type

## Color Accuracy

- **minimumContrastRatio**: `1` — Prevents Cursor from adjusting theme colors for accessibility contrast, so Neovim colors match what you see in Kitty

## Other

- **Command Center**: enabled (default, was already set)

## Example Configuration

`settings.json`:

```json
{
  "window.commandCenter": true,
  "terminal.integrated.fontFamily": "JetBrainsMono Nerd Font Mono",
  "terminal.integrated.defaultLocation": "editor",
  "terminal.integrated.gpuAcceleration": "on",
  "terminal.integrated.sendKeybindingsToShell": true,
  "terminal.integrated.commandsToSkipShell": [
    "-workbench.action.quickOpen",
    "-workbench.action.terminal.focusFind"
  ],
  "terminal.integrated.env.linux": {
    "COLORTERM": "truecolor",
    "TERM": "xterm-256color"
  },
  "terminal.integrated.minimumContrastRatio": 1,
  "terminal.integrated.enableKittyKeyboardProtocol": false,
  "window.autoDetectColorScheme": false
}
```

`keybindings.json`:

```json
[
  {
    "key": "ctrl+i",
    "command": "composerMode.agent"
  },
  {
    "key": "ctrl+shift+space",
    "command": "composer.focusComposer"
  },
  {
    "key": "ctrl+shift+space",
    "command": "composer.focusComposer",
    "when": "terminalFocus"
  }
]
```
