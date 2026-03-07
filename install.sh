#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CURRENT_DIR="$(pwd)"
EXTENSIONS_DIR="$CURRENT_DIR/extensions"
DEFAULT_EXTENSION_ID="buwai-ai-extension"
COMMANDS_DIR="$EXTENSIONS_DIR/commands"
SKILLS_DIR="$EXTENSIONS_DIR/skills"

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

has_frontmatter() {
    local file="$1"
    local first_line=$(head -n 1 "$file")
    [[ "$first_line" == "---" ]]
}

has_extension_metadata() {
    local file="$1"
    local ext_id="$2"
    # Check for extension-id in the file
    grep -q "^extension-id: $ext_id" "$file" 2>/dev/null
}

add_extension_metadata() {
    local file="$1"
    local ext_id="$2"

    # Skip if already has metadata
    if has_extension_metadata "$file" "$ext_id"; then
        return 0
    fi

    # Check if file has frontmatter
    if ! has_frontmatter "$file"; then
        # No frontmatter, add it
        local tmp_file=$(mktemp)
        echo "---" > "$tmp_file"
        echo "extension-id: $ext_id" >> "$tmp_file"
        echo "---" >> "$tmp_file"
        echo "" >> "$tmp_file"
        cat "$file" >> "$tmp_file"
        mv "$tmp_file" "$file"
        return 0
    fi

    # Has frontmatter, find the first closing ---
    local tmp_file=$(mktemp)
    local frontmatter_closed=false
    local line_num=0
    local first_delimiter_found=false

    while IFS= read -r line || [[ -n "$line" ]]; do
        line_num=$((line_num + 1))

        if [[ "$line_num" -eq 1 && "$line" == "---" ]]; then
            echo "$line" >> "$tmp_file"
            continue
        fi

        if [[ "$line" == "---" ]]; then
            if [ "$first_delimiter_found" = false ]; then
                # This is the closing ---, add extension-id before it
                echo "extension-id: $ext_id" >> "$tmp_file"
                echo "$line" >> "$tmp_file"
                first_delimiter_found=true
                frontmatter_closed=true
                continue
            fi
        fi

        echo "$line" >> "$tmp_file"
    done < "$file"

    if ! $frontmatter_closed; then
        error_exit "Invalid frontmatter in $file: missing closing ---"
    fi

    mv "$tmp_file" "$file"
}

find_extension_files() {
    # Find command files (excluding assets)
    find "$COMMANDS_DIR" -type f -name "*.md" 2>/dev/null | grep -v "assets"
    # Find skill files
    find "$SKILLS_DIR" -type f -name "*.md" 2>/dev/null
}

validate_extension() {
    if [ ! -d "$EXTENSIONS_DIR" ]; then
        error_exit "Extensions directory not found: $EXTENSIONS_DIR"
    fi

    if [ ! -d "$COMMANDS_DIR" ]; then
        error_exit "Commands directory not found: $COMMANDS_DIR"
    fi

    if [ ! -d "$SKILLS_DIR" ]; then
        error_exit "Skills directory not found: $SKILLS_DIR"
    fi

    # Check if there are any files
    local file_count=$(find "$COMMANDS_DIR" "$SKILLS_DIR" -type f -name "*.md" 2>/dev/null | grep -v "assets" | wc -l)

    if [ "$file_count" -eq 0 ]; then
        error_exit "No extension files found. Please add commands or skills."
    fi

    success_msg "Extension structure validated: $file_count file(s) found"
}

display_summary() {
    local ext_id="$1"
    local total_files="$2"
    local updated_files="$3"

    echo ""
    echo "========================================"
    echo "Extension Installation Complete!"
    echo "========================================"
    echo ""
    echo "Extension Information:"
    echo "  ID: $ext_id"
    echo "  Location: $CURRENT_DIR"
    echo "  Total files: $total_files"
    echo "  Updated files: $updated_files"
    echo ""
    echo "Metadata 'extension-id: $ext_id' has been added to all extension files."
    echo ""
    echo "To uninstall this extension, run:"
    echo "  ./uninstall.sh --extension-id $ext_id"
    echo "  or simply: ./uninstall.sh"
    echo "========================================"
}

main() {
    local extension_id="$DEFAULT_EXTENSION_ID"
    local verify_only=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --extension-id)
                extension_id="$2"
                shift 2
                ;;
            --verify-only)
                verify_only=true
                shift
                ;;
            --help|-h)
                echo "AI Extension Installer"
                echo ""
                echo "Usage: ./install.sh [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --extension-id <name>  Extension identifier (default: buwai-ai-extension)"
                echo "  --verify-only          Only verify extension structure, don't add metadata"
                echo "  --help, -h             Show this help message"
                echo ""
                echo "Description:"
                echo "  Adds extension metadata to all extension files for identification."
                echo "  This metadata is used during uninstallation to identify and remove"
                echo "  files belonging to this extension."
                echo ""
                echo "Examples:"
                echo "  ./install.sh"
                echo "  ./install.sh --extension-id my-extension"
                echo "  ./install.sh --verify-only"
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

    validate_extension

    if [ "$verify_only" = true ]; then
        info_msg "Verify-only mode: metadata not added"
        display_summary "$extension_id" "0" "0"
        return 0
    fi

    info_msg "Scanning for extension files..."
    local total_files=0
    local updated_files=0

    while IFS= read -r file; do
        total_files=$((total_files + 1))
        if has_extension_metadata "$file" "$extension_id"; then
            echo "  [SKIP] $file (already has metadata)"
        else
            add_extension_metadata "$file" "$extension_id"
            echo "  [DONE] $file"
            updated_files=$((updated_files + 1))
        fi
    done < <(find_extension_files)

    if [ "$total_files" -eq 0 ]; then
        error_exit "No extension files found"
    fi

    info_msg "Found $total_files extension file(s)"
    success_msg "Extension metadata added to $updated_files file(s)"

    display_summary "$extension_id" "$total_files" "$updated_files"
}

main "$@"
