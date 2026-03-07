# AI Extension Installation and Uninstallation Guide

This guide explains how to install and uninstall the AI extension using the provided shell scripts.

## Overview

The extension system uses an **identification mechanism** to prevent accidental uninstallation:

- **Extension ID File (`.extension-id`)**: Created during installation, contains unique identifier
- **Installation Log (`.install.log`)**: Records installation details for reference
- **ID Verification**: Uninstall script verifies the extension ID before proceeding

## Installation

### Basic Installation

```bash
./install.sh
```

This will:
1. Validate the extension structure
2. Generate a unique extension ID automatically
3. Create `.extension-id` and `.install.log` files
4. Display installation summary

### Installation with Custom Extension ID

```bash
./install.sh --id my-custom-extension
```

Use a custom extension ID for easier identification.

### Installation to External Directory

```bash
./install.sh --target-dir ~/.opencode/extensions/
```

**Important**: When installing to a directory outside the current project, the script will ask for confirmation before proceeding.

### Installation with All Options

```bash
./install.sh --id buwai-ai-ext-v1 --target-dir ~/.opencode/extensions/
```

## Uninstallation

### Basic Uninstallation (Auto-Detect Extension ID)

```bash
./uninstall.sh
```

The script will:
1. Read the `.extension-id` file
2. Display extension information
3. Ask for confirmation
4. Remove extension files

### Uninstallation with Specific Extension ID

```bash
./uninstall.sh --id buwai-ai-extension_20250307_123456_abc1
```

The script will verify the provided ID matches the detected ID before proceeding.

### Force Uninstallation (Skip Confirmation)

```bash
./uninstall.sh --force
```

⚠️ **Warning**: Use `--force` with caution. This skips the confirmation prompt.

## Extension ID File Structure

The `.extension-id` file contains:

```bash
EXTENSION_ID="buwai-ai-extension_20250307_123456_abc1"
PROJECT_NAME="buwai-ai-extension"
INSTALL_DATE="2025-03-07T11:34:51Z"
INSTALL_DIR="/path/to/extension"
VERSION="1.0.0"
```

This file is used to:
- Identify the extension during uninstallation
- Verify the correct extension is being uninstalled
- Prevent accidental deletion of wrong extensions

## Installation Log File Structure

The `.install.log` file contains:

```bash
EXTENSION_ID="buwai-ai-extension_20250307_123456_abc1"
INSTALL_DATE="2025-03-07T11:34:51Z"
SOURCE_DIR="/path/to/extension"
TARGET_DIR="/path/to/installed/extension"
INSTALLER_VERSION="1.0.0"
```

This file tracks:
- When the extension was installed
- Where it was installed from
- Where it was installed to (if external)

## Safety Features

### 1. Extension ID Verification
- The uninstall script verifies the extension ID before proceeding
- Prevents accidental uninstallation of wrong extensions

### 2. Confirmation Prompt
- Default behavior requires user confirmation before uninstalling
- Can be skipped with `--force` flag (use with caution)

### 3. External Directory Confirmation
- If installing outside current directory, asks for explicit confirmation
- Checks for external references during uninstallation

### 4. Safe Directory Removal
- Only removes extension-specific files and directories
- Preserves the current directory structure to prevent data loss

## Usage Examples

### Scenario 1: Standard Installation

```bash
# Install
./install.sh

# Later, uninstall
./uninstall.sh
```

### Scenario 2: Custom Extension ID

```bash
# Install with custom ID
./install.sh --id my-translator-ext

# Uninstall with same ID
./uninstall.sh --id my-translator-ext
```

### Scenario 3: Installation to OpenCode Extensions Directory

```bash
# Install to OpenCode extensions directory
./install.sh --target-dir ~/.opencode/extensions/

# Uninstall (will ask about external references)
./uninstall.sh
```

### Scenario 4: Automated Uninstallation

```bash
# Install
./install.sh --id automation-test-ext

# Force uninstall without confirmation (for CI/CD)
./uninstall.sh --id automation-test-ext --force
```

## Files Created During Installation

After running `./install.sh`, the following files are created:

```
buwai-ai-extension/
├── .extension-id          # Extension identifier (created by install.sh)
├── .install.log           # Installation log (created by install.sh)
├── extensions/            # Your extension files
│   ├── commands/
│   └── skills/
├── install.sh
└── uninstall.sh
```

## Files Removed During Uninstallation

Running `./uninstall.sh` removes:

- `.extension-id` - Extension identifier
- `.install.log` - Installation log

**Important**: The `extensions/` directory is **preserved** during uninstallation because it contains your actual extension content (commands and skills).

**Note**: The current directory structure is preserved for safety.
## Troubleshooting

### Error: Extension ID file not found

**Cause**: The `.extension-id` file doesn't exist in the current directory.

**Solution**: Run `./install.sh` first to create the extension ID file.

### Error: Extension ID mismatch

**Cause**: The provided extension ID doesn't match the detected ID.

**Solution**: 
- Check the `.extension-id` file for the correct ID
- Or run `./uninstall.sh` without `--id` flag to auto-detect

### Error: Extensions directory not found

**Cause**: The `extensions/` directory doesn't exist or is empty.

**Solution**: Ensure you're running the script in the correct project directory with a valid `extensions/` folder.

## Best Practices

1. **Always use extension IDs** for production installations
2. **Test uninstallation** before deploying to production
3. **Keep backup** of `.extension-id` file if manually tracking multiple extensions
4. **Use `--force` only** in automated scripts, never interactively
5. **Review external references** during uninstallation if using `--target-dir`

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

## Help

For detailed usage information:

```bash
./install.sh --help
./uninstall.sh --help
```
