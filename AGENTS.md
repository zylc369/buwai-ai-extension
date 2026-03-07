# BuWai's AI Extension - Agent Development Guide

This repository is an AI extension framework using a declarative markdown-based command and skill definition system.

## Project Structure

```
buwai-ai-extension/
├── extensions/
│   ├── commands/        # AI command definitions (markdown with YAML frontmatter)
│   └── skills/          # AI skill definitions
├── .gitignore           # Git ignore rules (includes Bun, node_modules, dist/)
└── README.md            # Basic project description
```

## Build and Development Status

**Current State**: Early-stage repository. No build system, linting, or testing configured yet.

**Planned Tooling** (based on .gitignore):
- **Package Manager**: Bun (bun.lockb, *.bun-build)
- **Runtime**: Node.js
- **Output Directory**: dist/

Since no package.json exists yet, there are no build/lint/test commands. When the build system is added, commands should be documented here.

## Command Definition Format

Commands are defined as markdown files in `extensions/commands/` with YAML frontmatter:

```markdown
---
description: [Brief command description]
---

[Detailed command specification in markdown]

## Sections may include:
- Request parameters and their types
- Expected behavior and actions
- Execution rules
- File format requirements
```

**Example**: `trans-md-en-to-zh.md` defines a command for translating English markdown to Chinese.

## Adding New Commands

1. Create a `.md` file in `extensions/commands/`
2. Use YAML frontmatter delimited by `---` on separate lines
3. Include a `description` field in the frontmatter
4. Document the command specification in markdown format below the frontmatter
5. Use clear section headers (##) for command behavior, parameters, and execution rules

## Adding New Skills

Skills are placed in `extensions/skills/`. The directory currently has a `.gitkeep` placeholder.

When implementing skills, follow the same declarative markdown pattern as commands.

## Code Style Guidelines

**Note**: This repository currently has no TypeScript, JavaScript, or other programming language files. Style guidelines will be established once the codebase is populated.

When code is added:

- Use the tooling indicated in `.gitignore` (Bun, TypeScript/JavaScript)
- Follow standard conventions for the chosen language/framework
- Add linting and formatting configurations (ESLint, Prettier, etc.)

## Naming Conventions

### Command Files
- Use kebab-case: `trans-md-en-to-zh.md`
- Descriptive names that indicate the command's purpose
- English names preferred (as shown in the existing example)

### Directories
- Lowercase: `commands/`, `skills/`
- Plural forms for collections: `extensions/`

## Documentation Language

- **File Names**: English
- **Description Field (YAML)**: English
- **Command Specification Content**: Can use the language appropriate for the command's domain
  - Example: `trans-md-en-to-zh.md` uses Chinese for the specification content since it's a translation command

## Development Workflow

Since no build/test/lint commands exist yet:

1. Create command/skill markdown files directly in `extensions/`
2. No build step required (declarative format)
3. Commit changes normally with git

## Future Considerations

When adding a proper build system:

- Initialize with `bun init` (matching .gitignore intent)
- Add build, test, and lint scripts to package.json
- Document how to run individual tests once a test framework is chosen
- Update this file with actual commands

## Git Workflow

Standard git workflow. No special hooks or pre-commit configurations are currently in place.

---

**Last Updated**: Repository is in early development stage. This file should be updated as the build system and codebase evolve.
