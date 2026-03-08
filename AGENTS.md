# BuWai AI Extension - Agent Development Guide

**Generated:** 2026-03-08
**Commit:** b3d417b
**Branch:** main

OpenCode extension framework using declarative markdown-based command/skill definitions.

---

## Project Structure

```
buwai-ai-extension/
├── extensions/
│   ├── commands/        # AI command definitions (.md files)
│   │   ├── trans-md-en-to-zh.md
│   │   ├── dr-diagnose.md
│   │   └── ai-doc-optimizer.md
│   └── skills/          # AI skill definitions (.md files)
├── containers/
│   └── ai-container/    # Docker dev environment
├── docs/                # Documentation
├── install-ai-extensions.sh   # Install to OpenCode
├── uninstall-extensions.sh    # Remove from OpenCode
├── init-ai-tools.sh           # Install language servers
└── AGENTS.md
```

---

## Commands

```bash
# Install extensions to OpenCode
./install-ai-extensions.sh
./install-ai-extensions.sh --verify-only    # Preview only

# Uninstall extensions
./uninstall-extensions.sh
./uninstall-extensions.sh --dry-run         # Preview removal
./uninstall-extensions.sh --force           # Skip confirmation

# Initialize AI tools (language servers)
./init-ai-tools.sh
```

---

## Code Style

### Bash Scripts

| Element | Convention | Example |
|---------|------------|---------|
| Functions | `snake_case` | `add_extension_metadata`, `find_opencode_dir` |
| Variables | `snake_case` | `local filename`, `local ext_id` |
| Constants | `UPPER_SNAKE_CASE` | `DEFAULT_EXTENSION_ID`, `SOURCE_EXTENSIONS_DIR` |

**Required:**
- Start with `#!/bin/bash` and `set -e`
- Quote all variables: `"$file"`, `"$ext_id"`
- Use `local` for function-scoped variables
- Use `[[ ]]` for string comparisons, `[ ]` for file tests

**Error Handling:**
```bash
error_exit "Error message"      # Fatal errors, exit 1
success_msg "Success message"   # Green ✓
warning_msg "Warning message"  # Yellow ⚠
info_msg "Info message"        # Blue ℹ
```

### Markdown Extension Files

**Required YAML frontmatter:**
```yaml
---
description: Brief command description
buwai-extension-id: filename-without-extension
---
```

**Example:** `trans-md-en-to-zh.md` → `buwai-extension-id: trans-md-en-to-zh`

**Naming:**
- Command files: `kebab-case.md`
- Directory names: lowercase, plural (`commands/`, `skills/`)
- Assets folders: `{command-name}-assets/`

---

## Anti-Patterns (FORBIDDEN)

From command implementations:

| Rule | File | Context |
|------|------|---------|
| DO NOT ask user whether to implement | `trans-md-en-to-zh.md` | Execute immediately |
| DO NOT propose implementation approaches | `trans-md-en-to-zh.md` | Execute immediately |
| DO NOT ask user whether to optimize | `ai-doc-optimizer.md` | Optimize immediately |
| NEVER use question tool when no patient names | `dr-diagnose.md` | Direct output only |

---

## Docker Container

**Location:** `containers/ai-container/`

**Key files:**
- `Dockerfile` — Ubuntu 22.04 + Node.js + Bun + OpenCode
- `entrypoint.sh` — Git credential setup with `GITHUB_TOKEN`
- `docker-compose.yml` — Container orchestration

**Usage:**
```bash
cd containers/ai-container
./start.sh      # Start container
./rebuild.sh    # Rebuild image
```

**Ports:** 4096 (OpenCode web), 4173 (serve)

---

## Testing

**Status:** Not configured (early-stage project).

**Planned conventions:**
- Framework: Bun test or Jest
- Test files: `*.test.js` or `*.spec.js` co-located with source
- Run: `bun test` or `bun test --test-name-pattern "pattern"`

---

## Extension Installation Flow

1. **Install** (`install-ai-extensions.sh`):
   - Scans `extensions/commands/` and `extensions/skills/`
   - Adds `buwai-extension-id` metadata to each file
   - Copies to `~/.config/opencode/` or `~/.opencode/`
   - Runs `init-ai-tools.sh` for language servers

2. **Uninstall** (`uninstall-extensions.sh`):
   - Scans OpenCode dirs for files with `buwai-extension-id`
   - Removes matched files and `{name}-assets/` folders

---

## Quick Checklists

### Bash Script
- [ ] `#!/bin/bash` + `set -e`
- [ ] Variables quoted: `"$var"`
- [ ] Local variables declared
- [ ] Uses message functions for output
- [ ] Exits non-zero on failure

### Extension Markdown
- [ ] kebab-case filename
- [ ] YAML frontmatter with `---` delimiters
- [ ] `buwai-extension-id` matches filename
- [ ] `description` field present
- [ ] Code blocks specify language

---

**No Cursor rules or Copilot instructions exist.** Follow this file for consistency.
