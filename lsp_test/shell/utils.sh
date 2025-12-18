#!/bin/bash
# Utility functions for testing LSP navigation
# Test: gd on function calls should jump to definitions

log_info() {
    echo "[INFO] $1"
}

log_error() {
    echo "[ERROR] $1" >&2
}

log_warning() {
    echo "[WARN] $1" >&2
}

check_command() {
    local cmd="$1"
    if command -v "$cmd" &>/dev/null; then
        log_info "$cmd is installed"
        return 0
    else
        log_error "$cmd is not installed"
        return 1
    fi
}

get_os() {
    case "$(uname -s)" in
        Linux*)  echo "linux" ;;
        Darwin*) echo "macos" ;;
        *)       echo "unknown" ;;
    esac
}

confirm() {
    local prompt="${1:-Continue?}"
    read -rp "$prompt [y/N] " response
    [[ "$response" =~ ^[Yy]$ ]]
}
