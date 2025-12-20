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

    # Show current version if installed
    if command -v nvim &> /dev/null; then
        CURRENT_VERSION=$(nvim --version | head -n1)
        echo "Currently installed: $CURRENT_VERSION"
    else
        echo "Currently installed: Not found"
    fi

    # Show latest available version
    LATEST_VERSION=$(curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" | grep -oP '"tag_name": "\K(.*)(?=")')
    echo "Latest stable:       $LATEST_VERSION (tested/reliable)"

    # Try to get nightly version
    NIGHTLY_INFO=$(curl -s "https://api.github.com/repos/neovim/neovim/releases/tags/nightly" 2>/dev/null | grep -oP '"name": "\K(.*)(?=")' | head -1)
    if [ -n "$NIGHTLY_INFO" ]; then
        echo "Nightly build:       $NIGHTLY_INFO (bleeding-edge/experimental)"
    else
        echo "Nightly build:       Available (bleeding-edge/experimental)"
    fi
    echo ""

    echo "1) Install latest stable - tested, reliable official release"
    echo "2) Install nightly - cutting-edge features, may have bugs"
    echo "3) Install specific version - choose any older release"
    echo "4) List available versions"
    echo "5) Show version comparison"
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
            echo "Available Neovim versions (20 most recent):"
            echo ""
            curl -s "https://api.github.com/repos/neovim/neovim/releases?per_page=20" | \
                grep -oP '"tag_name": "\K(.*)(?=")' | \
                grep -v "nightly" | \
                head -20 | \
                nl -w2 -s') '
            echo ""
            echo "Plus: nightly, stable (latest)"
            exit 0
            ;;
        5)
            echo ""
            if command -v nvim &> /dev/null; then
                CURRENT=$(nvim --version | head -n1)
                echo "Currently installed: $CURRENT"
            else
                echo "Currently installed: Not found"
            fi
            LATEST=$(curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" | grep -oP '"tag_name": "\K(.*)(?=")')
            echo "Latest available:    $LATEST"
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
    "$INSTALL_DIR/nvim-linux-x86_64"
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

# Determine download URL and archive name based on version
# v0.11.5+ uses nvim-linux-x86_64.tar.gz, older versions use nvim-linux64.tar.gz
if [ "$VERSION" = "stable" ]; then
    ARCHIVE="nvim-linux-x86_64.tar.gz"
    EXTRACT_DIR="nvim-linux-x86_64"
    URL="https://github.com/neovim/neovim/releases/latest/download/${ARCHIVE}"
elif [ "$VERSION" = "nightly" ]; then
    ARCHIVE="nvim-linux-x86_64.tar.gz"
    EXTRACT_DIR="nvim-linux-x86_64"
    URL="https://github.com/neovim/neovim/releases/download/nightly/${ARCHIVE}"
else
    # Check if version is >= 0.11.5 (new naming) or older (old naming)
    VERSION_NUM=$(echo "$VERSION" | sed 's/^v//' | sed 's/\.//g')
    if [ "$VERSION_NUM" -ge 0115 ] 2>/dev/null; then
        ARCHIVE="nvim-linux-x86_64.tar.gz"
        EXTRACT_DIR="nvim-linux-x86_64"
    else
        ARCHIVE="nvim-linux64.tar.gz"
        EXTRACT_DIR="nvim-linux64"
    fi
    URL="https://github.com/neovim/neovim/releases/download/${VERSION}/${ARCHIVE}"
fi

# Create temp directory
TMP_DIR=$(mktemp -d)
cd "$TMP_DIR"

# Download and extract
echo "Downloading from ${URL}..."
curl -fLO "$URL"
tar xzf "$ARCHIVE"

# Install to ~/.local (no sudo required)
INSTALL_DIR="$HOME/.local"
mkdir -p "$INSTALL_DIR"

echo "Installing to ${INSTALL_DIR}..."
rm -rf "$INSTALL_DIR/nvim-linux64" "$INSTALL_DIR/nvim-linux-x86_64"
mv "$EXTRACT_DIR" "$INSTALL_DIR/"

# Create symlink
mkdir -p "$INSTALL_DIR/bin"
ln -sf "$INSTALL_DIR/${EXTRACT_DIR}/bin/nvim" "$INSTALL_DIR/bin/nvim"

# Cleanup
cd -
rm -rf "$TMP_DIR"

echo "✓ Neovim installed successfully!"
echo ""
echo "Make sure ~/.local/bin is in your PATH:"
echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
echo ""
"$INSTALL_DIR/bin/nvim" --version | head -n1
