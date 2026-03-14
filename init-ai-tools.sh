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

# Detect operating system
detect_os() {
    case "$(uname -s)" in
        Darwin*)    echo "macos" ;;
        Linux*)     echo "linux" ;;
        *)          echo "unknown" ;;
    esac
}

# Check if npm is available
check_npm() {
    if ! command -v npm &> /dev/null; then
        error_exit "npm is not installed. Please install Node.js first."
    fi
    success_msg "npm is available"
}

# Check if pip3 is available
check_pip3() {
    if ! command -v pip3 &> /dev/null; then
        warning_msg "pip3 is not installed. Skipping basedpyright installation."
        return 1
    fi
    success_msg "pip3 is available"
    return 0
}

# Install language server via npm
install_language_server() {
    local server_name="$1"
    info_msg "Installing $server_name..."
    
    if npm install -g "$server_name" 2>&1; then
        success_msg "$server_name installed successfully"
        return 0
    else
        warning_msg "Failed to install $server_name"
        return 1
    fi
}

# Install ca-certificates based on OS
install_ca_certificates() {
    local os_type
    os_type=$(detect_os)
    
    info_msg "Installing ca-certificates for SSL verification..."
    
    case "$os_type" in
        macos)
            if command -v brew &> /dev/null; then
                brew install ca-certificates 2>&1 || warning_msg "ca-certificates may already be installed"
                # Set environment variables for SSL
                if [ -f "$(brew --prefix)/etc/ca-certificates/cert.pem" ]; then
                    export SSL_CERT_FILE="$(brew --prefix)/etc/ca-certificates/cert.pem"
                    export REQUESTS_CA_BUNDLE="$(brew --prefix)/etc/ca-certificates/cert.pem"
                    success_msg "SSL certificates configured for macOS"
                else
                    warning_msg "Could not find brew ca-certificates, SSL issues may occur"
                fi
            else
                warning_msg "Homebrew not found, skipping ca-certificates installation"
            fi
            ;;
        linux)
            if command -v apt-get &> /dev/null; then
                apt-get update && apt-get install -y ca-certificates 2>&1 || warning_msg "ca-certificates installation failed or already installed"
            elif command -v apk &> /dev/null; then
                apk add --no-cache ca-certificates 2>&1 && update-ca-certificates 2>&1 || warning_msg "ca-certificates installation failed"
            elif command -v dnf &> /dev/null; then
                dnf install -y ca-certificates 2>&1 || warning_msg "ca-certificates installation failed"
            elif command -v yum &> /dev/null; then
                yum install -y ca-certificates 2>&1 || warning_msg "ca-certificates installation failed"
            else
                warning_msg "Unknown package manager, skipping ca-certificates installation"
            fi
            success_msg "ca-certificates installed for Linux"
            ;;
        *)
            warning_msg "Unknown OS, skipping ca-certificates installation"
            ;;
    esac
}

# Install basedpyright with SSL handling
install_basedpyright() {
    info_msg "Installing basedpyright (Python language server)..."
    
    # Upgrade certifi first to ensure SSL works
    pip3 install --upgrade certifi 2>&1 || warning_msg "Failed to upgrade certifi"
    
    # Attempt installation
    if pip3 install "basedpyright==1.26.0"; then
        success_msg "basedpyright installed successfully"
        return 0
    else
        warning_msg "Failed to install basedpyright"
        return 1
    fi
}

# Main function
main() {
    echo "========================================"
    echo "AI Tools Initialization"
    echo "========================================"
    echo ""
    
    local failed_count=0
    local os_type
    os_type=$(detect_os)
    
    info_msg "Detected OS: $os_type"
    
    check_npm
    
    # Install npm language servers
    if ! install_language_server "bash-language-server"; then
        failed_count=$((failed_count + 1))
    fi

    echo ""

    if ! install_language_server "typescript-language-server"; then
        failed_count=$((failed_count + 1))
    fi
    
    echo ""
    
    # Install Python language server (basedpyright)
    if check_pip3; then
        echo ""
        install_ca_certificates
        echo ""
        
        if ! install_basedpyright; then
            failed_count=$((failed_count + 1))
        fi
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
