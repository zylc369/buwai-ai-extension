#!/bin/bash

# AI Tools Initialization Script
# Installs required tools for AI extension functionality

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Message functions
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

success_msg() {
    echo -e "${GREEN}✓ $1${NC}"
}

warning_msg() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

info_msg() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check if npm is available
check_npm() {
    if ! command -v npm &> /dev/null; then
        error_exit "npm is not installed. Please install Node.js first."
    fi
    success_msg "npm is available"
}

# Install language server
install_language_server() {
    local server_name="$1"
    info_msg "Installing $server_name..."
    
    if npm install -g $server_name 2>&1; then
        success_msg "$server_name installed successfully"
        return 0
    else
        warning_msg "Failed to install $server_name"
        return 1
    fi
}

# Main function
main() {
    echo "========================================"
    echo "AI Tools Initialization"
    echo "========================================"
    echo ""
    
    check_npm
    
    local failed_count=0
    
    if ! install_language_server "bash-language-server"; then
        failed_count=$((failed_count + 1))
    fi

    echo ""
    echo ""

    if ! install_language_server "typescript-language-server"; then
        failed_count=$((failed_count + 1))
    fi
    
    echo ""
    echo "========================================"
    if [ "$failed_count" -eq 0 ]; then
        success_msg "All AI tools initialized successfully!"
        exit 0
    else
        warning_msg "$failed_count tool(s) failed to initialize"
        exit 1
    fi
}

main "$@"
