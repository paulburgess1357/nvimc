#!/bin/bash

ALIAS_LINE="alias nvimc='NVIM_APPNAME=nvim-custom nvim'"
BASHRC="$HOME/.bashrc"

echo "=== Neovim Custom Alias Setup ==="
echo ""

# Check if alias already exists in .bashrc
if grep -q "alias nvimc=" "$BASHRC" 2>/dev/null; then
    echo "✓ Alias 'nvimc' already exists in $BASHRC"
    echo ""
    grep "alias nvimc=" "$BASHRC"
    echo ""
    echo "No changes needed."
else
    echo "Adding alias to $BASHRC..."
    echo "" >> "$BASHRC"
    echo "# Neovim custom configuration alias" >> "$BASHRC"
    echo "$ALIAS_LINE" >> "$BASHRC"
    echo ""
    echo "✓ Alias added successfully!"
    echo ""
    echo "To use immediately, run:"
    echo "  source ~/.bashrc"
    echo ""
    echo "Or restart your terminal."
fi

echo ""
echo "Usage:"
echo "  nvim   - uses default config (~/.config/nvim)"
echo "  nvimc  - uses custom config (~/.config/nvim-custom)"
