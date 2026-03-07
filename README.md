# buwai-ai-extension
BuWai's AI Extension

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
