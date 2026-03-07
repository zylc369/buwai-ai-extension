#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

CURRENT_DIR="$(pwd)"
EXTENSIONS_DIR="$CURRENT_DIR/extensions"
COMMANDS_DIR="$EXTENSIONS_DIR/commands"
SKILLS_DIR="$EXTENSIONS_DIR/skills"
DEFAULT_EXTENSION_ID="buwai-ai-extension"

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

has_extension_metadata() {
    local file="$1"
    local ext_id="$2"
    # Check for extension-id in the file
    grep -q "^extension-id: $ext_id" "$file" 2>/dev/null
}

find_assets_folder() {
    local file="$1"
    local filename=$(basename "$file" .md)
    local assets_folder="${file%/*}/${filename}-assets"

    if [ -d "$assets_folder" ]; then
        echo "$assets_folder"
    fi
}

list_files_to_remove() {
    local ext_id="$1"
    local files=()
    local folders=()

    while IFS= read -r file; do
        [[ "$file" != *"-assets"* ]] && files+=("$file")
    done < <(find "$COMMANDS_DIR" -type f -name "*.md" 2>/dev/null)

    while IFS= read -r file; do
        files+=("$file")
    done < <(find "$SKILLS_DIR" -type f -name "*.md" 2>/dev/null)

    local filtered_files=()
    for file in "${files[@]}"; do
        if has_extension_metadata "$file" "$ext_id"; then
            filtered_files+=("$file")
        fi
    done

    local unique_folders=()
    for file in "${filtered_files[@]}"; do
        local assets=$(find_assets_folder "$file")
        if [ -n "$assets" ]; then
            if [[ ! " ${unique_folders[@]} " =~ " ${assets} " ]]; then
                unique_folders+=("$assets")
            fi
        fi
    done

    echo "FILES:"
    for file in "${filtered_files[@]}"; do
        echo "  $file"
    done

    echo "FOLDERS:"
    for folder in "${unique_folders[@]}"; do
        echo "  $folder"
    done

    echo "COUNTS:${#filtered_files[@]}:${#unique_folders[@]}"
}

remove_files() {
    local ext_id="$1"
    local dry_run="$2"
    local files=()
    local folders=()

    while IFS= read -r file; do
        [[ "$file" != *"-assets"* ]] && files+=("$file")
    done < <(find "$COMMANDS_DIR" -type f -name "*.md" 2>/dev/null)

    while IFS= read -r file; do
        files+=("$file")
    done < <(find "$SKILLS_DIR" -type f -name "*.md" 2>/dev/null)

    local filtered_files=()
    for file in "${files[@]}"; do
        if has_extension_metadata "$file" "$ext_id"; then
            filtered_files+=("$file")
        fi
    done

    local unique_folders=()
    for file in "${filtered_files[@]}"; do
        local assets=$(find_assets_folder "$file")
        if [ -n "$assets" ]; then
            if [[ ! " ${unique_folders[@]} " =~ " ${assets} " ]]; then
                unique_folders+=("$assets")
            fi
        fi
    done

    for folder in "${unique_folders[@]}"; do
        if [ "$dry_run" = false ]; then
            rm -rf "$folder"
            success_msg "Removed folder: $folder"
        else
            info_msg "Would remove folder: $folder"
        fi
    done

    for file in "${filtered_files[@]}"; do
        if [ "$dry_run" = false ]; then
            rm -f "$file"
            success_msg "Removed file: $file"
        else
            info_msg "Would remove file: $file"
        fi
    done

    echo "${#filtered_files[@]}:${#unique_folders[@]}"
}

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

display_completion() {
    local ext_id="$1"
    local file_count="$2"
    local folder_count="$3"
    local dry_run="$4"

    echo ""
    echo "========================================"
    if [ "$dry_run" = true ]; then
        echo "Dry Run Complete!"
    else
        echo "Uninstallation Complete!"
    fi
    echo "========================================"
    echo ""
    echo "Extension: $ext_id"
    echo "Files removed: $file_count"
    echo "Folders removed: $folder_count"
    echo ""

    if [ "$dry_run" = false ]; then
        echo "All files and folders have been removed."
    else
        echo "No files were removed (dry run mode)."
        echo "To actually remove, run without --dry-run flag."
    fi
    echo "========================================"
}

main() {
    local extension_id="$DEFAULT_EXTENSION_ID"
    local dry_run=false
    local force=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            --extension-id)
                extension_id="$2"
                shift 2
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            --force)
                force=true
                shift
                ;;
            --help|-h)
                echo "AI Extension Uninstaller"
                echo ""
                echo "Usage: ./uninstall.sh [OPTIONS]"
                echo ""
                echo "Options:"
                echo "  --extension-id <name>  Extension identifier (default: buwai-ai-extension)"
                echo "  --dry-run              Show what would be removed without removing"
                echo "  --force                Skip confirmation prompt"
                echo "  --help, -h             Show this help message"
                echo ""
                echo "Description:"
                echo "  Removes extension files by scanning for metadata tags."
                echo "  Files with matching 'extension-id: <id>' metadata and their"
                echo "  associated assets folders will be removed."
                echo ""
                echo "Examples:"
                echo "  ./uninstall.sh"
                echo "  ./uninstall.sh --extension-id my-extension"
                echo "  ./uninstall.sh --dry-run"
                echo "  ./uninstall.sh --force"
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
    echo "Extension ID: $extension_id"
    echo ""

    info_msg "Scanning for extension files..."
    local output
    output=$(list_files_to_remove "$extension_id")

    local counts=$(echo "$output" | grep "^COUNTS:")
    local file_count=$(echo "$counts" | cut -d: -f2)
    local folder_count=$(echo "$counts" | cut -d: -f3)

    if [ "$file_count" -eq 0 ]; then
        warning_msg "No files found with extension ID: $extension_id"
        echo ""
        echo "Possible reasons:"
        echo "  1. Extension was never installed (no metadata added)"
        echo "  2. Extension ID is incorrect"
        echo "  3. Files have been manually modified"
        echo ""
        exit 0
    fi

    echo ""
    echo "Files and folders to be removed:"
    echo "$output" | grep -v "^COUNTS:"
    echo ""

    if [ "$dry_run" = true ]; then
        info_msg "Dry run mode - no files will be removed"
        display_completion "$extension_id" "$file_count" "$folder_count" true
        exit 0
    fi

    confirm_uninstall "$force"

    info_msg "Removing files and folders..."
    local result
    result=$(remove_files "$extension_id" false)

    local removed_files=$(echo "$result" | cut -d: -f1)
    local removed_folders=$(echo "$result" | cut -d: -f2)

    display_completion "$extension_id" "$removed_files" "$removed_folders" false
}

main "$@"
