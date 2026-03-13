---
buwai-extension-id: AGENTS
---

# Commands

## OVERVIEW
OpenCode command definitions in markdown format with metadata-based identification.

## WHERE TO LOOK
`extensions/commands/`

## CONVENTIONS
- **Mandatory frontmatter**:
  ```yaml
  ---
  description: Brief command description
  buwai-extension-id: filename-without-extension
  ---
  ```
- **Sections**: Usage/Parameters, Implementation Instructions, Implementation Priority
- **Asset folders**: `{command-name}-assets/`
- **Workflows**: Numbered steps with clear actions
- **Tools**: read/write/bash/glob/grep for file operations
- **Output format**: Verbose but concise, error messages for validation failures
- **Naming**: kebab-case filenames match `buwai-extension-id`

## ANTI-PATTERNS
- **DO NOT** ask user whether to implement or optimize
- **DO NOT** propose implementation approaches
- **DO** execute immediately using documented workflow
- **DO** validate inputs before processing
- **DO** preserve critical information (MUST/NEVER rules)
- **NEVER** let one bad file crash the workflow (dr-diagnose)
- **NEVER** use question tool when no patient names exist (dr-diagnose)
