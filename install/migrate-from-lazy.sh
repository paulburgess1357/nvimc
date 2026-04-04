#!/bin/bash
# Migrate from lazy.nvim to vim.pack (Neovim 0.12)
#
# Run this on any machine that previously used lazy.nvim.
# Safe to run multiple times -- skips anything already clean.

set -euo pipefail

DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim-custom"
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/nvim-custom"

removed=0

remove_if_exists() {
    if [ -e "$1" ] || [ -L "$1" ]; then
        rm -rf "$1"
        echo "  Removed: $1"
        removed=1
    fi
}

echo "=== Cleaning lazy.nvim data ==="
remove_if_exists "$DATA_DIR/lazy"
remove_if_exists "$STATE_DIR/lazy"

echo "=== Cleaning stale treesitter data ==="
echo "  (Query symlinks point to old lazy dir; parsers will reinstall on next startup)"
remove_if_exists "$DATA_DIR/site/parser"
remove_if_exists "$DATA_DIR/site/queries"
for d in "$DATA_DIR"/tree-sitter-*-tmp; do
    remove_if_exists "$d"
done

if [ "$removed" -eq 0 ]; then
    echo "  Nothing to clean -- already migrated."
fi

echo ""
echo "Done. Restart Neovim to reinstall treesitter parsers and queries."
