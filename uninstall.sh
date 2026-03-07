#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
CURRENT_DIR="$(pwd)"
DEFAULT_EXTENSION_ID="buwai-ai-extension"
INSTALL_RECORD_FILE=".extension-install"

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

read_install_record() {
    if [ ! -f "$INSTALL_RECORD_FILE" ]; then
        error_exit "Installation record not found: $INSTALL_RECORD_FILE"
    fi

    source "$INSTALL_RECORD_FILE"

    if [ -z "$EXTENSION_ID" ]; then
        error_exit "Extension ID not found in installation record"
    fi

    if [ -z "$INSTALL_DIR" ]; then
        error_exit "Installation directory not found in installation record"
    fi

    echo "$EXTENSION_ID|$INSTALL_DIR|$FILES_COUNT"
}

has_extension_metadata() {
    local file="$1"
    local ext_id="$2"
    grep -q "^extension-id: $ext_id" "$file" 2>/dev/null
}

find_opencode_dir() {
    local home="$HOME"
    local dirs=(
        "$home/.config/opencode"
        "$home/.opencode"
        "$home/.openclaw"
    )

    for dir in "${dirs[@]}"; do
        if [ -d "$dir" ]; then
            echo "$dir"
            return 0
        fi
    done
    echo ""
}

list_files_to_remove() {
    local ext_id="$1"
    local install_dir="$2"
    local files=()
    local folders=()

    # Search in commands directory
    local commands_dir="$install_dir/commands"
    if [ -d "$commands_dir" ]; then
        while IFS= read -r file; do
            [[ "$file" != *"-assets"* ]] && files+=("$file")
        done < <(find "$commands_dir" -type f -name "*.md" 2>/dev/null)
    fi

    # Search in skills directory
    local skills_dir="$install_dir/skills"
    if [ -d "$skills_dir" ]; then
        while IFS= read -r file; do
            files+=("$file")
        done < <(find "$skills_dir" -type f -name "*.md" 2>/dev/null)
    fi

    # Filter by extension metadata
    local filtered_files=()
    for file in "${files[@]}"; do
        if has_extension_metadata "$file" "$ext_id"; then
            filtered_files+=("$file")
        fi
    done

    # Find assets folders
    local unique_folders=()
    for file in "${filtered_files[@]}"; do
        local filename=$(basename "$file" .md)
        local file_dir=$(dirname "$file")
        local assets_folder="${file_dir}/${filename}-assets"

        if [ -d "$assets_folder" ]; then
            if [[ ! " ${unique_folders[@]} " =~ " ${assets_folder} " ]]; then
                unique_folders+=("$assets_folder")
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
    local install_dir="$2"
    local dry_run="$3"
    local files=()
    local folders=()

    # Search in commands directory
    local commands_dir="$install_dir/commands"
    if [ -d "$commands_dir" ]; then
        while IFS= read -r file; do
            [[ "$file" != *"-assets"* ]] && files+=("$file")
        done < <(find "$commands_dir" -type f -name "*.md" 2>/dev/null)
    fi

    # Search in skills directory
    local skills_dir="$install_dir/skills"
    if [ -d "$skills_dir" ]; then
        while IFS= read -r file; do
            files+=("$file")
        done < <(find "$skills_dir" -type f -name "*.md" 2>/dev/null)
    fi

    # Filter by extension metadata
    local filtered_files=()
    for file in "${files[@]}"; do
        if has_extension_metadata "$file" "$ext_id"; then
            filtered_files+=("$file")
        fi
    done

    # Find assets folders
    local unique_folders=()
    for file in "${filtered_files[@]}"; do
        local filename=$(basename "$file" .md)
        local file_dir=$(dirname "$file")
        local assets_folder="${file_dir}/${filename}-assets"

        if [ -d "$assets_folder" ]; then
            if [[ ! " ${unique_folders[@]} " =~ " ${assets_folder} " ]]; then
                unique_folders+=("$assets_folder")
            fi
        fi
    done

    # Remove folders first
    for folder in "${unique_folders[@]}"; do
        if [ "$dry_run" = false ]; then
            rm -rf "$folder"
            success_msg "Removed folder: $folder"
        else
            info_msg "Would remove folder: $folder"
        fi
    done

    # Remove files
    for file in "${filtered_files[@]}"; do
        if [ "$dry_run" = false ]; then
            rm -f "$file"
            success_msg "Removed file: $file"
        else
            info_msg "Would remove file: $file"
        fi
    done

    # Remove installation record if not dry run
    if [ "$dry_run" = false ]; then
        rm -f "$INSTALL_RECORD_FILE"
        success_msg "Removed installation record: $INSTALL_RECORD_FILE"
    fi

    echo "${#filtered_files[@]}:${#unique_folders[@]}"
}

confirm_uninstall() {
    local force="$1"

    if [ "$force" = true ]; then
        info_msg "Force mode enabled, skipping confirmation"
        return 0
    fi

    echo "This will uninstall the extension and remove all its files from OpenCode."
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
        echo "All files and folders have been removed from OpenCode."
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
                echo "  Removes extension files from OpenCode by scanning for metadata tags."
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

    # Read installation record
    info_msg "Reading installation record..."
    local record
    record=$(read_install_record)

    if [ -z "$record" ]; then
        error_exit "Cannot read installation record"
    fi

    local installed_id=$(echo "$record" | cut -d\| -f1)
    local installed_dir=$(echo "$record" | cut -d\| -f2)
    local files_count=$(echo "$record" | cut -d\| -f3)

    # Verify extension ID
    if [ "$extension_id" != "$installed_id" ] && [ "$extension_id" != "$DEFAULT_EXTENSION_ID" ]; then
        error_exit "Extension ID mismatch: Provided $extension_id, Installed $installed_id"
    fi

    extension_id="$installed_id"

    if [ ! -d "$installed_dir" ]; then
        warning_msg "Installation directory not found: $installed_dir"
        echo "The extension may have been manually removed."
        echo ""
        read -p "Remove installation record? (yes/no): " -r
        echo
        if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
            rm -f "$INSTALL_RECORD_FILE"
            success_msg "Installation record removed"
        fi
        exit 0
    fi

    info_msg "Extension ID: $extension_id"
    info_msg "Install directory: $installed_dir"

    # List files to be removed
    info_msg "Scanning for extension files..."
    local output
    output=$(list_files_to_remove "$extension_id" "$installed_dir")

    local counts=$(echo "$output" | grep "^COUNTS:")
    local file_count=$(echo "$counts" | cut -d: -f2)
    local folder_count=$(echo "$counts" | cut -d: -f3)

    if [ "$file_count" -eq 0 ]; then
        warning_msg "No files found with extension ID: $extension_id in $installed_dir"
        echo ""
        echo "Possible reasons:"
        echo "  1. Extension files were manually deleted"
        echo "  2. Extension ID is incorrect"
        echo "  3. Installation record is outdated"
        echo ""
        read -p "Remove installation record? (yes/no): " -r
        echo
        if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
            rm -f "$INSTALL_RECORD_FILE"
            success_msg "Installation记录 removed"
        fi
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
    result=$(remove_files "$extension_id" "$installed_dir" false)

    local removed_files=$(echo "$result" | cut -d: -f1)
    local removed_folders=$(echo "$result" | cut -d: -f2)

    display_completion "$extension_id" "$removed_files" "$removed_folders" false
}

main "$@"
