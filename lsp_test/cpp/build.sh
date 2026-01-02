#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"
EXECUTABLE="$BUILD_DIR/clangd_test"

build() {
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    cmake .. -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
    make
    # Copy compile_commands.json to project root for clangd
    cp compile_commands.json "$SCRIPT_DIR"
}

run() {
    if [[ -x "$EXECUTABLE" ]]; then
        "$EXECUTABLE"
    else
        echo "Executable not found. Build first."
        return 1
    fi
}

# Menu
echo "1) Build"
echo "2) Run"
echo "3) Build & Run"
read -p "Select: " choice

case "$choice" in
    1) build ;;
    2) run ;;
    3) build && run ;;
    *) echo "Invalid option"; exit 1 ;;
esac
