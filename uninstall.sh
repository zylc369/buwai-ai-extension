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

# OpenCode installation directories
POSSIBLE_OPENCODE_DIRS=(
    "$HOME/.config/opencode"
    "$HOME/.opencode"
    "$HOME/.openclaw"
)

# Function to find OpenCode directory
find_opencode_dir() {
    for dir in "${POSSIBLE_OPENCODE_DIRS[@]}"; do
        if [ -d "$dir" ]; then
            echo "$dir"
            return 0
        fi
    done
    echo ""
}

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

find_extensions_in_dir() {
    local opencode_dir="$1"
    local ext_id="$2"
    local files=()
    local folders=()

    # Search in commands directory
    local commands_dir="$opencode_dir/commands"
    if [ -d "$commands_dir" ]; then
        while IFS= read -r file; do
            files+=("$file")
        done < <(find "$commands_dir" -type f -name "*.md" 2>/dev/null)
    fi

    # Search in skills directory
    local skills_dir="$opencode_dir/skills"
    if [ -d "$skills_dir" ]; then
        while IFS= read -r file; do
            files+=("$file")
        done < <(find "$skills_dir" -type f -name "*.md" 2>/dev/null)
    fi

    echo "${files[@]}"
}

list_extensions_in_dir() {
    local opencode_dir="$1"
    local ext_id="$2"
    
    local files=()
    local folders=()

    # Get all files
    local all_files
    all_files=$(find_extensions_in_dir "$opencode_dir" "$ext_id")

    for file in "${all_files[@]}"; do
        local has_metadata=false
        if [ -n "$ext_id" ]; then
            has_metadata=$(grep -q "^extension-id: $ext_id" "$file" 2>/dev/null && echo "true" || echo "false")
        fi
        
        if [ "$has_metadata" = "true" ]; then
            files+=("$file")
            
            # Find assets folder
            local filename=$(basename "$file" .md)
            local file_dir=$(dirname "$file")
            local assets_folder="${file_dir}/${filename}-assets"

            if [ -d "$assets_folder" ]; then
                if [[ ! " ${folders[@]} " =~ " ${assets_folder} " ]]; then
                    folders+=("$assets_folder")
                fi
            fi
        fi
    done

    # Output results
    echo "FILES:"
    for file in "${files[@]}"; do
        echo "  $file"
    done

    echo "FOLDERS:"
    for folder in "${folders[@]}"; do
        echo "  $folder"
    done

    echo "COUNTS:${#files[@]}:${#folders[@]}"
}

remove_files() {
    local opencode_dir="$1"
    local ext_id="$2"
    local dry_run="$3"
    local files=()
    local folders=()

    # Get all files
    local all_files
    all_files=$(find_extensions_in_dir "$opencode_dir" "$ext_id")

    for file in "${all_files[@]}"; do
        local has_metadata=false
        if [ -n "$ext_id" ]; then
            has_metadata=$(grep -q "^extension-id: $ext_id" "$file" 2>/dev/null && echo "true" || echo "false")
        fi
        
        if [ "$has_metadata" = "true" ]; then
            files+=("$file")
            
            # Find assets folder
            local filename=$(basename "$file" .md)
            local file_dir=$(dirname "$file")
            local assets_folder="${file_dir}/${filename}-assets"

            if [ -d "$assets_folder" ]; then
                if [[ ! " ${folders[@]} " =~ " ${assets_folder} " ]]; then
                    folders+=("$assets_folder")
                fi
            fi
        fi
    done

    # Remove folders first
    for folder in "${folders[@]}"; do
        if [ "$dry_run" = false ]; then
            rm -rf "$folder"
            success_msg "Removed folder: $folder"
        else
            info_msg "Would remove folder: $folder"
        fi
    done

    # Remove files
    for file in "${files[@]}"; do
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

    echo "${#files[@]}:${#folders[@]}"
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
    local used_record="$5"

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
    if [ "$used_record" = "true" ]; then
        echo "Used installation record to locate files."
    else
        echo "Scanned OpenCode directories to find extension files."
    fi

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
    local use_record=true

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
                echo "  If installation record is missing, the script will scan"
                echo "  OpenCode directories to find extension files."
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

    # Try to read installation record first
    local record_read=false
    local record_ext_id=""
    local record_install_dir=""

    if [ -f "$INSTALL_RECORD_FILE" ]; then
        source "$INSTALL_RECORD_FILE" 2>/dev/null || true
        if [ -n "$EXTENSION_ID" ]; then
            record_ext_id="$EXTENSION_ID"
        fi
        if [ -n "$INSTALL_DIR" ]; then
            record_install_dir="$INSTALL_DIR"
        fi
        record_read=true
    fi

    # If record exists and matches provided ID, use it
    if [ "$record_read" = true ]; then
        if [ -n "$extension_id" ] && [ "$extension_id" != "$DEFAULT_EXTENSION_ID" ]; then
            # User provided specific extension ID
            if [ "$extension_id" != "$record_ext_id" ]; then
                warning_msg "Provided extension ID ($extension_id) doesn't match record ($record_ext_id)"
                read -p "Use record anyway or provided ID? [record/provided] : " -r
                echo
                if [[ $REPLY =~ ^[Rr] ]]; then
                    extension_id="$record_ext_id"
                else
                    use_record=false
                fi
            fi
        else
            extension_id="$record_ext_id"
            install_dir="$record_install_dir"
        fi
    fi

    # If we don't have a valid install directory from record, scan OpenCode
    if [ -z "$install_dir" ] || [ "$use_record" = false ]; then
        info_msg "Scanning OpenCode directories for extension..."
        local found_dir=""
        local found_dir_count=0
        
        for dir in "${POSSIBLE_OPENCODE_DIRS[@]}"; do
            if [ -d "$dir" ]; then
                # Check if this directory has our extension
                local test_files
                test_files=$(list_extensions_in_dir "$dir" "$extension_id")
                local test_counts=$(echo "$test_files" | grep "^COUNTS:")
                local test_file_count=$(echo "$test_counts" | cut -d: -f2)
                
                if [ "$test_file_count" -gt 0 ]; then
                    install_dir="$dir"
                    found_dir_count=$((found_dir_count + 1))
                fi
            fi
        done

        if [ "$found_dir_count" -eq 0 ]; then
            if [ "$record_read" = true ]; then
                warning_msg "Extension files not found in OpenCode directories"
                warning_msg "The installation record may be outdated."
                echo ""
                read -p "Try to remove from the recorded directory anyway? (yes/no): " -r
                echo
                if [[ $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
                    install_dir="$record_install_dir"
                    use_record=false
                else
                    error_exit "No extension files found. Cannot proceed with uninstallation."
                fi
            else
                error_exit "No extension files found in OpenCode directories."
            fi
        fi

        use_record=false
    fi

    info_msg "Extension ID: $extension_id"
    if [ -n "$install_dir" ]; then
        info_msg "Install directory: $install_dir"
    fi

    if [ "$use_record" = true ]; then
        info_msg "Using installation record to locate files."
    else
        info_msg "Scanning for extension files in OpenCode."
    fi

    # List files to be removed
    info_msg "Scanning for extension files..."
    local output
    output=$(list_extensions_in_dir "$install_dir" "$extension_id")

    local counts=$(echo "$output" | grep "^COUNTS:")
    local file_count=$(echo "$counts" | cut -d: -f2)
    local folder_count=$(echo "$counts" | cut -d: -f3)

    if [ "$file_count" -eq 0 ]; then
        warning_msg "No files found with extension ID: $extension_id"
        echo ""
        echo "Possible reasons:"
        echo "  1. Extension was never installed"
        echo "  2. Extension files were manually deleted"
        echo "  3. Extension ID is incorrect"
        echo "  4. Extension was installed to a different OpenCode directory"
        echo ""
        exit 0
    fi

    echo ""
    echo "Files and folders to be removed:"
    echo "$output" | grep -v "^COUNTS:"
    echo ""

    if [ "$dry_run" = true ]; then
        info_msg "Dry run mode - no files will be removed"
        display_completion "$extension_id" "$file_count" "$folder_count" true "$use_record"
        exit 0
    fi

    confirm_uninstall "$force"

    info_msg "Removing files and folders..."
    local result
    result=$(remove_files "$install_dir" "$extension_id" false)

    local removed_files=$(echo "$result" | cut -d: -f1)
    local removed_folders=$(echo "$result" | cut -d: -f2)

    display_completion "$extension_id" "$removed_files" "$removed_folders" false "$use_record"
}

main "$@"
