# BuWai's AI Extension

An OpenCode extension framework using declarative markdown-based command/skill definitions with metadata-based identification.

## Installation

```bash
./install.sh
```

This adds `buwai-extension-id` metadata to all command/skill files. Each file gets a unique identifier based on its filename.

## Uninstallation

```bash
./uninstall.sh
```

This scans OpenCode directories for files with matching `buwai-extension-id` metadata and removes them.

## How It Works

This system uses **metadata-based identification with per-file unique IDs**:

1. **Install**:
   - Scans `extensions/commands/` and `extensions/skills/` for `.md` files
   - Adds `buwai-extension-id: <filename-without-extension>` to each file
   - Copies files to OpenCode configuration directory
   - Each file gets its own unique ID (e.g., `trans-md-en-to-zh.md` → `buwai-extension-id: trans-md-en-to-zh`)

2. **Uninstall**:
   - Scans OpenCode directories for files with matching `buwai-extension-id` metadata
   - Removes matched files and associated assets folders
   - No separate `.extension-install` file dependency needed

## Project Structure

```
buwai-ai-extension/
├── extensions/
│   ├── commands/        # AI command definitions (.md files)
│   └── skills/          # AI skill definitions (.md files)
├── docs/               # Documentation
│   ├── trans-md-en-to-zh/
│   └── dr-diagnose/
├── install.sh           # Installation script
├── uninstall.sh         # Uninstallation script
├── AGENTS.md           # Agent development guide
└── README.md           # This file
```

## Quick Examples

```bash
# Install with default extension ID
./install.sh

# Install in verify-only mode (don't actually install)
./install.sh --verify-only

# Preview what will be removed
./uninstall.sh --dry-run

# Uninstall with force (skip confirmation)
./uninstall.sh --force
```

## Options

### install.sh
- `--extension-id <name>` - Custom extension ID (default: buwai-ai-extension)
- `--verify-only` - Only verify, don't install
- `--help, -h` - Show help message

### uninstall.sh
- `--extension-id <name>` - Specific extension ID to uninstall
- `--dry-run` - Show what would be removed without removing
- `--force` - Skip confirmation prompt
- `--help, -h` - Show help message

## Documentation

- [AGENTS.md](AGENTS.md) - Agent development guide with code style guidelines
- [docs/trans-md-en-to-zh/README.md](docs/trans-md-en-to-zh/README.md) - Translation tool documentation
- [docs/dr-diagnose/README.md](docs/dr-diagnose/README.md) - AI Doctor documentation

## Adding New Extensions

1. Create a `.md` file in `extensions/commands/` or `extensions/skills/`
2. Add YAML frontmatter:
   ```yaml
   ---
   description: Brief command description
   buwai-extension-id: your-extension-name
   ---
   ```
3. Document command/skill specification in markdown format below frontmatter
4. Run `./install.sh` to install

## Metadata Format

Each extension file must have YAML frontmatter with:

```yaml
---
description: Brief command description
buwai-extension-id: filename-without-extension
---
```

**Note**: The `buwai-extension-id` value should match the filename without the `.md` extension.

## Requirements

- OpenCode environment
- Bash shell (for install/uninstall scripts)
- Write access to `~/.config/opencode/` or `~/.opencode/`

## License

This project is open source. See LICENSE file for details.
