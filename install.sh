#!/bin/bash

################################################################################
# AI Extension Installer
#
# Description: Installs AI extensions for OpenCode
# Usage: ./install.sh [--target-dir <path>] [--id <extension-id>]
#
# Options:
#   --target-dir <path>    Target directory for installation (optional)
#   --id <extension-id>    Custom extension ID (optional, auto-generated if not provided)
#
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
CURRENT_DIR="$(pwd)"
EXTENSIONS_DIR="$CURRENT_DIR/extensions"
EXTENSION_ID_FILE=".extension-id"
INSTALL_LOG_FILE=".install.log"

# Function to print error and exit
error_exit() {
    echo -e "${RED}Error: $1${NC}" >&2
    exit 1
}

# Function to print success message
success_msg() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to print warning message
warning_msg() {
    echo -e "${YELLOW}⚠ $1${NC}"
}
# Function to generate extension ID
generate_extension_id() {
    local project_name=$(basename "$CURRENT_DIR")
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local random_suffix=$(openssl rand -hex 4 2>/dev/null || echo "0000")
    echo "${project_name}_${timestamp}_${random_suffix}"
}

# Function to validate extension structure
validate_extension() {
    if [ ! -d "$EXTENSIONS_DIR" ]; then
        error_exit "Extensions directory not found: $EXTENSIONS_DIR"
    fi

    # Check if there are any commands or skills
    local has_content=false
    if [ "$(find "$EXTENSIONS_DIR/commands" -type f 2>/dev/null | wc -l)" -gt 0 ]; then
        has_content=true
    fi
    if [ "$(find "$EXTENSIONS_DIR/skills" -type f 2>/dev/null | wc -l)" -gt 0 ]; then
        has_content=true
    fi

    if [ "$has_content" = false ]; then
        error_exit "No commands or skills found in extensions directory"
    fi

    success_msg "Extension structure validated"
}

# Function to create extension ID file
create_extension_id() {
    local custom_id="$1"
    local extension_id

    if [ -n "$custom_id" ]; then
        extension_id="$custom_id"
        warning_msg "Using custom extension ID: $extension_id"
    else
        extension_id=$(generate_extension_id)
    fi

    # Check if extension ID file already exists
    if [ -f "$EXTENSION_ID_FILE" ]; then
        warning_msg "Extension ID file already exists"
        read -p "Do you want to overwrite it? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            error_exit "Installation cancelled by user"
        fi
    fi

    # Create extension ID file
    cat > "$EXTENSION_ID_FILE" <<EOF
# Extension Identification File
# DO NOT DELETE - Used for safe uninstallation

EXTENSION_ID="$extension_id"
PROJECT_NAME="$(basename "$CURRENT_DIR")"
INSTALL_DATE="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
INSTALL_DIR="$CURRENT_DIR"
VERSION="1.0.0"
EOF

    success_msg "Extension ID created: $extension_id"
    echo "  ID file: $CURRENT_DIR/$EXTENSION_ID_FILE"
}

# Function to log installation
log_installation() {
    local extension_id="$1"
    local target_dir="$2"

    cat > "$INSTALL_LOG_FILE" <<EOF
# Installation Log
EXTENSION_ID="$extension_id"
INSTALL_DATE="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
SOURCE_DIR="$CURRENT_DIR"
TARGET_DIR="$target_dir"
INSTALLER_VERSION="1.0.0"
EOF

    success_msg "Installation logged to: $INSTALL_LOG_FILE"
}

# Function to display summary
display_summary() {
    local extension_id="$1"

    echo ""
    echo "========================================"
    echo "Installation Complete!"
    echo "========================================"
    echo ""
    echo "Extension Information:"
    echo "  ID: $extension_id"
    echo "  Project: $(basename "$CURRENT_DIR")"
    echo "  Location: $CURRENT_DIR"
    echo "  Commands: $(find "$EXTENSIONS_DIR/commands" -type f 2>/dev/null | wc -l)"
    echo "  Skills: $(find "$EXTENSIONS_DIR/skills" -type f 2>/dev/null | wc -l)"
    echo ""
    echo "Files created:"
    echo "  - $EXTENSION_ID_FILE (extension identifier)"
    echo "  - $INSTALL_LOG_FILE (installation record)"
    echo ""
    echo "To uninstall this extension, run:"
    echo "  ./uninstall.sh --id $extension_id"
    echo "  or simply: ./uninstall.sh"
    echo "========================================"
}

# Main installation process
main() {
    local custom_id=""
    local target_dir=""

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --id)
                custom_id="$2"
                shift 2
                ;;
            --target-dir)
                target_dir="$2"
                shift 2
                ;;
            --help|-h)
                cat <<EOF
AI Extension Installer

Usage: ./install.sh [OPTIONS]

Options:
  --id <extension-id>      Custom extension ID (optional)
  --target-dir <path>      Target directory for installation (optional)
  --help, -h              Show this help message

Description:
  Installs the AI extension in the current directory for use with OpenCode.
  Creates an extension ID file for safe uninstallation.

Examples:
  ./install.sh
  ./install.sh --id my-custom-extension
  ./install.sh --target-dir ~/.opencode/extensions/
EOF
                exit 0
                ;;
            *)
                error_exit "Unknown option: $1. Use --help for usage information."
                ;;
        esac
    done

    echo "========================================"
    echo "AI Extension Installer"
    echo "========================================"
    echo ""

    # Check if target directory is outside current directory
    if [ -n "$target_dir" ]; then
        if [[ ! "$target_dir" == "$CURRENT_DIR"* ]] && [ ! -d "$target_dir" ]; then
            echo ""
            echo "Warning: You are attempting to install to a directory outside the current project:"
            echo "  Target: $target_dir"
            echo "  Current: $CURRENT_DIR"
            echo ""
            read -p "This will modify files outside the current directory. Continue? (y/N): " -n 1 -r
            echo
            if [[ ! $REPLY =~ ^[Yy]$ ]]; then
                error_exit "Installation cancelled by user"
            fi
        fi
    fi

    # Validate extension structure
    validate_extension

    # Create extension ID file
    create_extension_id "$custom_id"

    # Read the generated extension ID
    source "$EXTENSION_ID_FILE"

    # Log installation
    log_installation "$EXTENSION_ID" "${target_dir:-$CURRENT_DIR}"

    # Display summary
    display_summary "$EXTENSION_ID"
}

# Run main function
main "$@"
