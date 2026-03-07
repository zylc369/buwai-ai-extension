#!/bin/bash

################################################################################
# AI Extension Uninstaller
#
# Description: Uninstalls AI extensions safely using extension ID verification
# Usage: ./uninstall.sh [--id <extension-id>] [--force]
#
# Options:
#   --id <extension-id>    Extension ID to uninstall (optional, auto-detected if not provided)
#   --force               Skip confirmation prompt
#
################################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
CURRENT_DIR="$(pwd)"
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

# Function to print info message
info_msg() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Function to read extension ID
read_extension_id() {
    if [ ! -f "$EXTENSION_ID_FILE" ]; then
        error_exit "Extension ID file not found: $EXTENSION_ID_FILE"
    fi

    # Source the extension ID file
    source "$EXTENSION_ID_FILE"

    if [ -z "$EXTENSION_ID" ]; then
        error_exit "Extension ID not found in $EXTENSION_ID_FILE"
    fi

    echo "$EXTENSION_ID"
}

# Function to verify extension ID
verify_extension_id() {
    local provided_id="$1"
    local detected_id="$2"

    if [ -z "$provided_id" ]; then
        # No ID provided, use detected ID
        success_msg "Using detected extension ID: $detected_id"
        echo "$detected_id"
        return 0
    fi

    if [ "$provided_id" = "$detected_id" ]; then
        success_msg "Extension ID verified: $detected_id"
        echo "$detected_id"
        return 0
    else
        error_exit "Extension ID mismatch!\n  Provided: $provided_id\n  Detected: $detected_id"
    fi
}

# Function to display extension info
display_extension_info() {
    echo ""
    echo "Extension Information:"
    echo "  ID: $EXTENSION_ID"
    echo "  Project: $PROJECT_NAME"
    echo "  Install Date: $INSTALL_DATE"
    echo "  Version: $VERSION"
    echo "  Location: $INSTALL_DIR"
    echo ""
}

# Function to confirm uninstallation
confirm_uninstall() {
    local force="$1"

    if [ "$force" = true ]; then
        info_msg "Force mode enabled, skipping confirmation"
        return 0
    fi

    echo "This will uninstall the extension and remove all its files."
    echo ""
    read -p "Are you sure you want to uninstall? (yes/no): " -r
    echo

    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        warning_msg "Uninstallation cancelled by user"
        exit 0
    fi
}

# Function to remove extension files
remove_extension_files() {
    info_msg "Removing extension identification files..."

    # Remove extension ID file
    if [ -f "$EXTENSION_ID_FILE" ]; then
        rm -f "$EXTENSION_ID_FILE"
        success_msg "Removed: $EXTENSION_ID_FILE"
    fi

    # Remove install log file
    if [ -f "$INSTALL_LOG_FILE" ]; then
        rm -f "$INSTALL_LOG_FILE"
        success_msg "Removed: $INSTALL_LOG_FILE"
    fi

    # Note: We do NOT remove the extensions/ directory as it contains the actual extension content
    warning_msg "Note: The extensions/ directory is preserved as it contains the actual extension content."
    warning_msg "Note: The current directory structure is preserved for safety."
}

# Function to check for external references
check_external_references() {
    info_msg "Checking for external file references..."

    local external_files=()

    # Check install log for external target directory
    if [ -f "$INSTALL_LOG_FILE" ]; then
        source "$INSTALL_LOG_FILE"
        if [ -n "$TARGET_DIR" ] && [[ ! "$TARGET_DIR" == "$CURRENT_DIR"* ]]; then
            external_files+=("$TARGET_DIR")
        fi
    fi

    if [ ${#external_files[@]} -gt 0 ]; then
        echo ""
        warning_msg "This extension was installed to external directories:"
        for file in "${external_files[@]}"; do
            echo "  - $file"
        done
        echo ""
        read -p "Do you want to remove these external files? (yes/no): " -r
        echo
        if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
            for file in "${external_files[@]}"; do
                if [ -e "$file" ]; then
                    warning_msg "Removing external reference: $file"
                    rm -rf "$file"
                    success_msg "Removed: $file"
                else
                    warning_msg "External file not found: $file"
                fi
            done
        else
            warning_msg "External files preserved. You may need to remove them manually."
        fi
    fi
}

# Function to display completion message
display_completion() {
    echo ""
    echo "========================================"
    echo "Uninstallation Complete!"
    echo "========================================"
    echo ""
    echo "Extension $EXTENSION_ID has been uninstalled."
    echo ""
    echo "Removed files:"
    echo "  - $EXTENSION_ID_FILE"
    echo "  - $INSTALL_LOG_FILE"
    echo ""
    echo "Preserved files:"
    echo "  - extensions/ (contains your actual extension content)"
    echo ""
    echo "Note: The current directory still exists for safety."
    echo "You can remove it manually if needed:"
    echo "  cd .. && rm -rf $CURRENT_DIR"
    echo "========================================"
}

# Main uninstallation process
main() {
    local provided_id=""
    local force=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --id)
                provided_id="$2"
                shift 2
                ;;
            --force)
                force=true
                shift
                ;;
            --help|-h)
                cat <<EOF
AI Extension Uninstaller

Usage: ./uninstall.sh [OPTIONS]

Options:
  --id <extension-id>      Extension ID to uninstall (optional, auto-detected if not provided)
  --force                 Skip confirmation prompt
  --help, -h              Show this help message

Description:
  Uninstalls the AI extension from the current directory.
  Uses extension ID verification to prevent accidental uninstallation.

Examples:
  ./uninstall.sh
  ./uninstall.sh --id buwai-ai-extension_20250307_123456_abc1
  ./uninstall.sh --force
EOF
                exit 0
                ;;
            *)
                error_exit "Unknown option: $1. Use --help for usage information."
                ;;
        esac
    done

    echo "========================================"
    echo "AI Extension Uninstaller"
    echo "========================================"
    echo ""

    # Read extension ID from file
    local detected_id
    detected_id=$(read_extension_id)

    # Verify extension ID
    local extension_id
    extension_id=$(verify_extension_id "$provided_id" "$detected_id")

    # Re-source extension ID file to make variables available for display
    source "$EXTENSION_ID_FILE"

    # Display extension info
    display_extension_info

    # Check for external references
    check_external_references

    # Confirm uninstallation
    confirm_uninstall "$force"

    # Remove extension files
    remove_extension_files

    # Display completion message
    display_completion
}

# Run main function
main "$@"
