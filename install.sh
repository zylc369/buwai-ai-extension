#!/bin/bash

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
CURRENT_DIR="$(pwd)"
SOURCE_EXTENSIONS_DIR="$CURRENT_DIR/extensions"
DEFAULT_EXTENSION_ID="buwai-ai-extension"
INSTALL_RECORD_FILE=".extension-install"

# OpenCode installation directories
POSSIBLE_OPENCODE_DIRS=(
    "$HOME/.config/opencode"
    "$HOME/.opencode"
    "$HOME/.openclaw"
    "$XDG_CONFIG_HOME/opencode"
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

has_frontmatter() {
    local file="$1"
    local first_line=$(head -n 1 "$file")
    [[ "$first_line" == "---" ]]
}

has_extension_metadata() {
    local file="$1"
    local ext_id="$2"
    grep -q "^extension-id: $ext_id" "$file" 2>/dev/null
}

add_extension_metadata() {
    local file="$1"
    local ext_id="$2"

    if has_extension_metadata "$file" "$ext_id"; then
        return 0
    fi

    if ! has_frontmatter "$file"); then
        local tmp_file=$(mktemp)
        echo "---" > "$tmp_file"
        echo "extension-id: $ext_id" >> "$tmp_file"
        echo "---" >> "$tmp_file"
        echo "" >> "$tmp_file"
        cat "$file" >> "$tmp_file"
        mv "$tmp_file" "$file"
        return 0
    fi

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

validate_source_extension() {
    if [ ! -d "$SOURCE_EXTENSIONS_DIR" ]; then
        error_exit "Extensions directory not found: $SOURCE_EXTENSIONS_DIR"
    fi

    local command_count=$(find "$SOURCE_EXTENSIONS_DIR/commands" -type f -name "*.md" 2>/dev/null | grep -v "assets" | wc -l)
    local skill_count=$(find "$SOURCE_EXTENSIONS_DIR/skills" -type f -name "*.md" 2>/dev/null | wc -l)
    local total=$((command_count + skill_count))

    if [ "$total" -eq 0 ]; then
        error_exit "No extension files found. Please add commands or skills."
    fi

    success_msg "Source extension validated: $total file(s) found"
}

create_opencode_structure() {
    local opencode_dir="$1"
    
    local commands_dir="$opencode_dir/commands"
    local skills_dir="$opencode_dir/skills"

    if [ ! -d "$commands_dir" ]; then
        mkdir -p "$commands_dir"
        info_msg "Created directory: $commands_dir"
    fi

    if [ ! -d "$skills_dir" ]; then
        mkdir -p "$skills_dir"
        info_msg "Created directory: $skills_dir"
    fi
}

copy_extension_files() {
    local opencode_dir="$1"
    local ext_id="$2"
    
    local copied_files=0
    local commands_dir="$opencode_dir/commands"
    local skills_dir="$opencode_dir/skills"

    info_msg "Copying command files..."
    while IFS= read -r src_file; do
        # Skip .gitkeep files
        [[ "$src_file" == *".gitkeep"* ]] && continue
        # Skip assets folders
        [[ "$src_file" == *"assets"* ]] && continue
        
        local filename=$(basename "$src_file")
        local dest_file="$commands_dir/$filename"
        
        cp "$src_file" "$dest_file"
        add_extension_metadata "$dest_file" "$ext_id"
        echo "  [DONE] $filename"
        copied_files=$((copied_files + 1))
        
        # Copy assets folder if exists
        local src_dir=$(dirname "$src_file")
        local src_assets="${src_dir}/${filename%.md}-assets"
        if [ -d "$src_assets" ]; then
            local dest_assets="$commands_dir/${filename%.md}-assets"
            cp -r "$src_assets" "$dest_assets"
            echo "  [DONE] ${filename%.md}-assets/"
            copied_files=$((copied_files + 1))
        fi
    done < <(find "$SOURCE_EXTENSIONS_DIR/commands" -type f -name "*.md" 2>/dev/null)

    info_msg "Copying skill files..."
    while IFS= read -r src_file; do
        # Skip .gitkeep files
        [[ "$src_file" == *".gitkeep"* ]] && continue
        
        local filename=$(basename "$src_file")
        local dest_file="$skills_dir/$filename"
        
        cp "$src_file" "$dest_file"
        add_extension_metadata "$dest_file" "$ext_id"
        echo "  [DONE] $filename"
        copied_files=$((copied_files + 1))
        
        # Copy assets folder if exists
        local src_dir=$(dirname "$src_file")
        local src_assets="${src_dir}/${filename%.md}-assets"
        if [ -d "$src_assets" ]; then
            local dest_assets="$skills_dir/${filename%.md}-assets"
            cp -r "$src_assets" "$dest_assets"
            echo "  [DONE] ${filename%.md}-assets/"
            copied_files=$((copied_files + 1))
        fi
    done < <(find "$SOURCE_EXTENSIONS_DIR/skills" -type f -name "*.md" 2>/dev/null)

    echo "$copied_files"
}

create_install_record() {
    local ext_id="$1"
    local opencode_dir="$2"
    local file_count="$3"

    cat > "$INSTALL_RECORD_FILE" <<EOF
# Extension Installation Record
# DO NOT DELETE - Used for uninstallation

EXTENSION_ID="$ext_id"
INSTALL_DATE="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
INSTALL_DIR="$opencode_dir"
FILES_COUNT="$file_count"
VERSION="1.0.0"
EOF

    success_msg "Installation record created: $INSTALL_RECORD_FILE"
}

display_install_summary() {
    local ext_id="$1"
    local opencode_dir="$2"
    local file_count="$3"
    local copied_count="$4"

    echo ""
    echo "========================================"
    echo "Extension Installation Complete!"
    echo "========================================"
    echo ""
    echo "Extension Information:"
    echo "  ID: $ext_id"
    echo "  Source: $SOURCE_EXTENSIONS_DIR"
    echo "  Installed to: $opencode_dir"
    echo "  Files copied: $copied_count"
    echo ""
    echo "To uninstall this extension, run:"
    echo "  ./uninstall.sh"
    echo "  or:"
    echo "  ./uninstall.sh --extension-id $ext_id"
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
                echo "  --verify-only          Only verify, don't install"
                echo "  --help, -h             Show this help message"
                echo ""
                echo "Description:"
                echo "  Installs AI extension to OpenCode configuration directory."
                echo "  Copies extension files and adds metadata for identification."
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

    validate_source_extension

    if [ "$verify_only" = true ]; then
        info_msg "Verify-only mode: extension not installed"
        display_install_summary "$extension_id" "<not installed>" "0" "0"
        return 0
    fi

    # Find OpenCode directory
    local opencode_dir
    opencode_dir=$(find_opencode_dir)

    if [ -z "$opencode_dir" ]; then
        error_exit "OpenCode configuration directory not found. Please ensure OpenCode is installed."
    fi

    success_msg "Found OpenCode directory: $opencode_dir"

    # Create OpenCode structure if needed
    create_opencode_structure "$opencode_dir"

    # Copy files and add metadata
    local copied_count
    copied_count=$(copy_extension_files "$opencode_dir" "$extension_id")

    # Create installation record
    create_install_record "$extension_id" "$opencode_dir" "$copied_count")

    # Display summary
    display_install_summary "$extension_id" "$opencode_dir" "$copied_count" "$copied_count"
}

main "$@"
