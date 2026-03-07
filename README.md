# buwai-ai-extension
BuWai's AI Extension

## Installation

```bash
./install.sh
```

This adds metadata to all extension files for identification.

## Uninstallation

```bash
./uninstall.sh
```

This removes all files with matching extension metadata.

## Documentation

- [Installation Guide](INSTALLATION.md) - Detailed installation and uninstallation instructions
- [AGENTS.md](AGENTS.md) - Agent development guide

## How It Works

This system uses **metadata-based identification**:

1. **Install**: Adds `extension: buwai-ai-extension` to all command/skill files
2. **Uninstall**: Scans files, removes those with matching metadata

No separate ID files needed - metadata is embedded in the files themselves.

## Project Structure

```
buwai-ai-extension/
├── extensions/
│   ├── commands/    # AI command definitions (.md files)
│   └── skills/      # AI skill definitions (.md files)
├── install.sh       # Installation script
├── uninstall.sh     # Uninstallation script
└── ...
```

## Quick Examples

```bash
# Install with custom extension ID
./install.sh --extension-id my-extension

# Preview what will be removed
./uninstall.sh --dry-run

# Uninstall with specific ID
./uninstall.sh --extension-id my-extension
```

## Installation

To install this extension for use with OpenCode:

```bash
./install.sh
```

For custom installation options:
```bash
./install.sh --id my-extension-name
./install.sh --target-dir ~/.opencode/extensions/
```

## Uninstallation

To uninstall this extension:

```bash
./uninstall.sh
```

## Documentation

- [Installation Guide](INSTALLATION.md) - Detailed installation and uninstallation instructions
- [AGENTS.md](AGENTS.md) - Agent development guide

## Extension Structure

```
buwai-ai-extension/
├── extensions/
│   ├── commands/    # AI command definitions
│   └── skills/      # AI skill definitions
├── install.sh      # Installation script
├── uninstall.sh    # Uninstallation script
└── ...
```
