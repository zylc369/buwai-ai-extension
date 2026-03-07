# BuWai's AI Extension - Agent Development Guide

This repository provides an AI extension framework using declarative markdown-based command/skill definitions for OpenCode.

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
├── AGENTS.md           # This file
└── README.md           # Project overview
```

## Build, Lint, and Test Commands

**Current Status**: No build system, linting, or testing configured (early-stage repository).

**Planned Infrastructure** (based on `.gitignore`):
- Package Manager: Bun (`bun.lockb`, `*.bun-build`)
- Runtime: Node.js
- Output Directory: `dist/`

**When Build System is Added**:
- Initialize with `bun init`
- Add to `package.json`:
  ```json
  {
    "scripts": {
      "build": "bun build",
      "test": "bun test",
      "test:single": "bun test --test-name-pattern <pattern>",
      "lint": "bun run lint",
      "format": "bun run format"
    }
  }
  ```
- **Single Test Execution**: `bun test --test-name-pattern <test-name>` or `bun test <test-file>`
- Update this file with actual commands

## Code Style Guidelines

### Bash Scripts

#### Naming Conventions
- **Functions**: `snake_case` (e.g., `add_extension_metadata`, `copy_extension_files`)
- **Variables**: `snake_case` (e.g., `local filename`, `local ext_id`)
- **Constants**: `UPPER_SNAKE_CASE` (e.g., `DEFAULT_EXTENSION_ID`, `SOURCE_EXTENSIONS_DIR`)
- **Functions should be descriptive** and indicate their purpose clearly

#### Error Handling
- **Required**: Start scripts with `set -e` for strict error handling
- **Error Messages**: Use dedicated message functions:
  ```bash
  error_exit "Error message"      # Fatal errors, exit 1
  success_msg "Success message"   # Green ✓
  warning_msg "Warning message"    # Yellow ⚠
  info_msg "Info message"        # Blue ℹ
  ```
- **Validation**: Validate inputs and fail fast with clear error messages
- **No Silent Failures**: Always exit with non-zero on failure

#### Function Organization
- **Single Responsibility**: Each function does one thing well
- **Descriptive Names**: Function names clearly describe their action
- **Documentation**: Add brief comment blocks above complex functions
- **Local Variables**: Always use `local` for function-scoped variables

#### Code Patterns
- **Use Quotes**: Always quote variables: `"$file"`, `"$ext_id"`
- **Arrays**: Use explicit array declarations: `local files=()`
- **Loops**: Use `while IFS= read -r file; do ... done < <(command)`
- **Conditional Tests**: Use `[[ ]]` for string comparisons, `[ ]` for file tests

#### Formatting
- **Indentation**: 4 spaces (consistent)
- **Line Length**: Prefer lines under 100 characters
- **Comments**: Brief, purpose-driven comments above code blocks

### Markdown Files

#### Naming Conventions
- **Command Files**: `kebab-case` (e.g., `trans-md-en-to-zh.md`, `dr-diagnose.md`)
- **Directory Names**: Lowercase, plural (e.g., `commands/`, `skills/`, `docs/`)
- **Descriptive Names**: Names should clearly indicate purpose

#### Frontmatter Format
- **Required YAML frontmatter** delimited by `---` on separate lines
- **Minimum Required Fields**:
  ```yaml
  ---
  description: Brief command description
  buwai-extension-id: <filename-without-extension>
  ---
  ```
- **Extension ID**: Must match filename without `.md` extension
  - Example: `trans-md-en-to-zh.md` → `buwai-extension-id: trans-md-en-to-zh`

#### Content Structure
- **Section Headers**: Use `##` for major sections, `###` for subsections
- **Code Blocks**: Triple backticks with language specifier:
  ```bash
  # code here
  ```
  ```markdown
  # markdown code
  ```
- **Lists**: Use `-` for unordered lists, numbered lists for sequences
- **Links**: Use relative paths for internal links: `[text](./other-file.md)`

#### Documentation Language
- **File Names**: English (kebab-case)
- **YAML Fields**: English (description, etc.)
- **Content**: Can use language appropriate for domain (e.g., Chinese for translation commands)

## Error Handling Guidelines

### Bash Scripts
- **Never Use**: Empty catch blocks (`catch(e) {}`)
- **Always Exit**: Non-zero exit code on failure
- **Clear Messages**: Explain what went wrong and why
- **Cleanup**: Perform cleanup in `trap` for interrupted execution

### Example Error Handling
```bash
error_exit() {
  echo -e "${RED}Error: $1${NC}" >&2
  exit 1
}

validate_input() {
  if [ -z "$1" ]; then
    error_exit "Required parameter missing"
  fi
}
```

## Imports and Dependencies

### Current State
- No import system (declarative markdown-based)
- No external dependencies (uses only built-in bash commands)
- Shell scripts use POSIX-compatible bash

### Future (when Node.js code is added)
- Use ES modules: `import { something } from './module.js'`
- Prefer absolute imports: `import { x } from '@/utils/x'`
- No circular dependencies

## Testing Guidelines

**Current Status**: No tests exist yet.

**When Tests Are Added**:
- Framework: Bun test or Jest
- Test Files: `*.test.js` or `*.spec.js` co-located with source
- Structure:
  ```bash
  # Run all tests
  bun test
  
  # Run single test file
  bun test path/to/test.spec.js
  
  # Run single test (name pattern)
  bun test --test-name-pattern "should translate"
  ```
- **Naming**: Describe what's being tested (e.g., `add_extension_metadata.test.js`)

## CI/CD Considerations

**Current Status**: No CI/CD configured.

**When Adding CI/CD**:
- Use GitHub Actions or similar
- Test on multiple platforms
- Automate lint and test runs
- Document deployment process

## Git Workflow

**Standard Git Workflow**:
- No pre-commit hooks currently configured
- Commit messages: Conventional or clear descriptions
- Branching: Feature branches for work

## Quick Reference

### Bash Script Checklist
- [ ] Script starts with `#!/bin/bash`
- [ ] `set -e` for error handling
- [ ] All variables are quoted: `"$var"`
- [ ] Local variables declared: `local var=value`
- [ ] Functions use descriptive snake_case names
- [ ] Error messages use message functions (`error_exit`, `success_msg`, etc.)
- [ ] Exit on failure with non-zero code

### Markdown File Checklist
- [ ] File named with kebab-case
- [ ] YAML frontmatter with `---` delimiters
- [ ] `buwai-extension-id` matches filename without `.md`
- [ ] `description` field present and brief
- [ ] Section headers use proper hierarchy (`##`, `###`)
- [ ] Code blocks specify language

## AI Assistant Integration

No Cursor rules (`.cursor/rules/`, `.cursorrules`) or Copilot instructions (`.github/copilot-instructions.md`) exist in this repository. AI assistants should follow this AGENTS.md for consistency.

---

**Last Updated**: Repository is in early development stage. Update this file as build system, tests, and codebase evolve.
