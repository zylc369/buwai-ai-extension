# AI Extension Installation/Uninstallation System

## Overview

This system provides shell scripts (`install.sh` and `uninstall.sh`) for managing AI extensions, with built-in safety mechanisms to prevent accidental uninstallation.

## Key Features

### 1. Extension Identification System

- **Extension ID File (`.extension-id`)**: Contains unique identifier, project name, install date, and version
- **Installation Log (`.install.log`)**: Records installation details including source and target directories
- **ID Verification**: Uninstall script verifies the extension ID before proceeding

### 2. Safety Mechanisms

- **ID Verification**: Prevents accidental uninstallation of wrong extensions
- **Confirmation Prompt**: Requires user confirmation before uninstallation (can be skipped with `--force`)
- **External Directory Confirmation**: Asks for confirmation when installing outside current directory
- **Safe File Removal**: Only removes identification files, preserves actual extension content

### 3. File Management

**Files Created During Installation:**
- `.extension-id` - Extension identifier
- `.install.log` - Installation log

**Files Removed During Uninstallation:**
- `.extension-id` - Extension identifier
- `.install.log` - Installation log

**Files Preserved During Uninstallation:**
- `extensions/` - Actual extension content (commands and skills)
- All other files in the extension directory

## Usage

### Installation

```bash
# Basic installation (auto-generates extension ID)
./install.sh

# Installation with custom extension ID
./install.sh --id my-extension-name

# Installation to external directory (prompts for confirmation)
./install.sh --target-dir ~/.opencode/extensions/

# Installation with all options
./install.sh --id my-extension --target-dir ~/.opencode/extensions/
```

### Uninstallation

```bash
# Basic uninstallation (auto-detects extension ID)
./uninstall.sh

# Uninstallation with specific extension ID
./uninstall.sh --id my-extension-name

# Force uninstallation (skips confirmation prompt)
./uninstall.sh --force
```

## Extension ID File Format

```bash
# Extension Identification File
# DO NOT DELETE - Used for safe uninstallation

EXTENSION_ID="buwai-ai-extension_20260307_121300_abc1"
PROJECT_NAME="buwai-ai-extension"
INSTALL_DATE="2026-03-07T04:12:32Z"
INSTALL_DIR="/path/to/extension"
VERSION="1.0.0"
```

## Design Decisions

### Why `extensions/` is Preserved During Uninstallation

The `extensions/` directory contains the actual extension content (commands and skills). It is preserved during uninstallation because:

1. **User Safety**: Prevents accidental loss of extension content
2. **Reusability**: Allows users to reuse extension content without reinstalling
3. **Development**: Supports development workflows where content is version-controlled

To completely remove an extension, users can manually:
```bash
cd .. && rm -rf buwai-ai-extension
```

### Why External Directory Confirmation is Required

Installing to directories outside the current project can modify the user's system. The confirmation prompt ensures:

1. **Awareness**: Users are explicitly informed about external modifications
2. **Control**: Users have the final decision on whether to proceed
3. **Security**: Prevents unintended system modifications

## Integration with OpenCode

To integrate with OpenCode:

1. Install the extension:
   ```bash
   ./install.sh --target-dir ~/.opencode/extensions/
   ```

2. OpenCode will automatically detect extensions in the target directory

3. To uninstall:
   ```bash
   ./uninstall.sh
   ```

The script will prompt you about external references to OpenCode's extension directory.

## Error Handling

### Common Errors

**Error: Extension ID file not found**
- Cause: `.extension-id` file doesn't exist
- Solution: Run `./install.sh` first

**Error: Extension ID mismatch**
- Cause: Provided ID doesn't match detected ID
- Solution: Check `.extension-id` for correct ID, or run without `--id` flag

**Error: Extensions directory not found**
- Cause: `extensions/` directory doesn't exist or is empty
- Solution: Ensure you're in the correct project directory

## Testing

The system has been tested with:

1. ✅ Basic installation with auto-generated ID
2. ✅ Installation with custom extension ID
3. ✅ External directory installation with confirmation
4. ✅ Basic uninstallation
5. ✅ Uninstallation with specific extension ID
6. ✅ Force uninstallation without confirmation
7. ✅ Extension ID verification
8. ✅ Preservation of `extensions/` directory
9. ✅ Git ignore of installation files

## Files

- `install.sh` - Installation script (executable)
- `uninstall.sh` - Uninstallation script (executable)
- `.extension-id` - Extension identifier (created during installation, ignored by git)
- `.install.log` - Installation log (created during installation, ignored by git)
- `INSTALLATION.md` - Detailed documentation
- `README.md` - Updated with installation/uninstallation instructions

## Notes

- Installation files (`.extension-id`, `.install.log`) are ignored by git via `.gitignore`
- Scripts use `set -e` to exit on errors for safety
- Color-coded output for better readability
- Scripts include comprehensive help documentation (`--help`)
