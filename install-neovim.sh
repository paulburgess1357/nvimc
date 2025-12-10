#!/bin/bash
set -e

# Usage: ./install-neovim.sh [version|--list|--latest]
# Examples:
#   ./install-neovim.sh           # shows interactive menu
#   ./install-neovim.sh --list    # lists available versions
#   ./install-neovim.sh --latest  # shows latest version
#   ./install-neovim.sh v0.10.0   # installs specific version
#   ./install-neovim.sh nightly   # installs nightly build

# Interactive menu if no arguments
if [ $# -eq 0 ]; then
    echo "=== Neovim Installer ==="
    echo ""
    echo "1) Install latest stable (cleans up old versions)"
    echo "2) Install nightly (cleans up old versions)"
    echo "3) Install specific version (cleans up old versions)"
    echo "4) List available versions"
    echo "5) Show latest version"
    echo "6) Exit"
    echo ""
    read -p "Choose an option (1-6): " choice

    case $choice in
        1)
            VERSION="stable"
            ;;
        2)
            VERSION="nightly"
            ;;
        3)
            echo ""
            echo "Fetching recent versions..."
            curl -s "https://api.github.com/repos/neovim/neovim/releases?per_page=10" | \
                grep -oP '"tag_name": "\K(.*)(?=")' | \
                grep -v "nightly" | \
                head -10
            echo ""
            read -p "Enter version (e.g., v0.10.0): " VERSION
            if [ -z "$VERSION" ]; then
                echo "No version entered. Exiting."
                exit 1
            fi
            ;;
        4)
            echo ""
            echo "Available Neovim versions:"
            curl -s "https://api.github.com/repos/neovim/neovim/releases?per_page=20" | \
                grep -oP '"tag_name": "\K(.*)(?=")' | \
                grep -v "nightly" | \
                head -20
            echo ""
            echo "Plus: nightly, stable (latest)"
            exit 0
            ;;
        5)
            echo ""
            echo "Latest stable version:"
            curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" | \
                grep -oP '"tag_name": "\K(.*)(?=")'
            exit 0
            ;;
        6)
            echo "Exiting."
            exit 0
            ;;
        *)
            echo "Invalid option. Exiting."
            exit 1
            ;;
    esac
else
    VERSION="$1"
fi

# List available versions
if [ "$VERSION" = "--list" ]; then
    echo "Fetching available Neovim versions..."
    curl -s "https://api.github.com/repos/neovim/neovim/releases?per_page=20" | \
        grep -oP '"tag_name": "\K(.*)(?=")' | \
        grep -v "nightly" | \
        head -20
    echo ""
    echo "Plus: nightly, stable (latest)"
    exit 0
fi

# Show latest version
if [ "$VERSION" = "--latest" ]; then
    echo "Latest stable version:"
    curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" | \
        grep -oP '"tag_name": "\K(.*)(?=")'
    exit 0
fi

# Clean up existing Neovim installations
INSTALL_DIR="$HOME/.local"
echo "Checking for existing Neovim installations..."

# Check various possible locations
CLEANUP_PATHS=(
    "$INSTALL_DIR/nvim-linux64"
    "$INSTALL_DIR/nvim"
    "$INSTALL_DIR/share/nvim"
    "/usr/local/nvim-linux64"
)

for path in "${CLEANUP_PATHS[@]}"; do
    if [ -d "$path" ] || [ -f "$path" ]; then
        echo "  Removing: $path"
        rm -rf "$path"
    fi
done

# Remove old symlinks
if [ -L "$INSTALL_DIR/bin/nvim" ]; then
    echo "  Removing old symlink: $INSTALL_DIR/bin/nvim"
    rm -f "$INSTALL_DIR/bin/nvim"
fi

echo ""
echo "Installing Neovim ${VERSION}..."

# Determine download URL
if [ "$VERSION" = "stable" ]; then
    URL="https://github.com/neovim/neovim/releases/latest/download/nvim-linux64.tar.gz"
elif [ "$VERSION" = "nightly" ]; then
    URL="https://github.com/neovim/neovim/releases/download/nightly/nvim-linux64.tar.gz"
else
    URL="https://github.com/neovim/neovim/releases/download/${VERSION}/nvim-linux64.tar.gz"
fi

# Create temp directory
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

# Download and extract
echo "Downloading from ${URL}..."
curl -LO "$URL"
tar xzf nvim-linux64.tar.gz

# Install to ~/.local (no sudo required)
INSTALL_DIR="$HOME/.local"
mkdir -p "$INSTALL_DIR"

echo "Installing to ${INSTALL_DIR}..."
rm -rf "$INSTALL_DIR/nvim-linux64"
mv nvim-linux64 "$INSTALL_DIR/"

# Create symlink
mkdir -p "$INSTALL_DIR/bin"
ln -sf "$INSTALL_DIR/nvim-linux64/bin/nvim" "$INSTALL_DIR/bin/nvim"

# Cleanup
cd -
rm -rf "$TMP_DIR"

echo "✓ Neovim installed successfully!"
echo ""
echo "Make sure ~/.local/bin is in your PATH:"
echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
echo ""
"$INSTALL_DIR/bin/nvim" --version | head -n1
