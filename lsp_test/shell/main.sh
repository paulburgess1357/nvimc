#!/bin/bash
# Main script - tests LSP go-to-definition across files
# Source utils and call functions

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/utils.sh"

main() {
    log_info "Starting script"
    log_info "OS: $(get_os)"

    # Check dependencies
    check_command "git"
    check_command "nvim"

    if confirm "Run demo?"; then
        log_info "Running demo..."
    else
        log_warning "Skipped"
    fi

    log_info "Done"
}

main "$@"
