---
description: Optimize and shorten command/skill documentation while preserving clarity and accuracy
buwai-extension-id: ai-doc-optimizer
---

# Document Optimizer

Optimize and shorten OpenCode command/skill documentation while ensuring AI agents can still execute tasks accurately.

## Usage

```bash
# Optimize a single command/skill file
/ai-doc-optimizer path/to/command.md

# Optimize all command files in directory
/ai-doc-optimizer ~/.config/opencode/commands/

# Preview changes without applying
/ai-doc-optimizer command.md preview

# Set target reduction (default: 30%)
/ai-doc-optimizer command.md 40
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| Path | required | File or directory path to optimize |
| Mode | `apply` | `apply`: Apply optimizations<br>`preview`: Show before/after comparison |
| Reduction | `30` | Target reduction percentage (20-50) |

## Optimization Rules

1. **Preserve Core Information**:
   - Keep all essential instructions for task execution
   - Maintain critical rules and constraints
   - Retain error handling logic
   - Preserve tool usage requirements

2. **Remove Redundancy**:
   - Eliminate duplicate descriptions
   - Consolidate overlapping sections
   - Remove verbose examples (keep 1-2 key examples)
   - Simplify repetitive formatting

3. **Maintain Clarity**:
   - Use concise language
   - Prefer tables over bullet lists for structured data
   - Merge related sections
   - Remove filler words and phrases

4. **Ensure Completeness**:
   - All steps required for execution must remain
   - Error conditions and handling must be clear
   - Output format must be specified
   - Tool requirements must be listed

---

## IMPLEMENTATION INSTRUCTIONS

### Workflow

1. **Parse Parameters**: Extract path, mode, reduction target from input
2. **Validate Input**:
   - Check path exists (file or directory)
   - If directory: Find all `.md` files
   - Validate reduction target (20-50%)
3. **Analyze Document** (for each file):
   - Read and parse markdown content
   - Identify YAML frontmatter (preserve unchanged)
   - Identify sections and their purposes
   - Calculate current line count
4. **Optimize Content**:
   - **Identify redundant content**:
     - Duplicate descriptions across sections
     - Overlapping parameter explanations
     - Excessive examples (keep 1-2 essential)
     - Verbose explanations that can be shortened
   - **Consolidate sections**:
     - Merge "Usage" + "Parameters" into table
     - Combine "Error Handling" into main workflow
     - Integrate "Tools" list into relevant sections
   - **Simplify language**:
     - Remove filler: "Please note that", "It is important to", "Make sure to"
     - Convert paragraphs to bullet points
     - Use tables for structured information
     - Shorten example blocks
   - **Preserve critical elements**:
     - All numbered steps in workflows
     - All MUST/NEVER rules
     - Error conditions and messages
     - Output file formats
     - Tool requirements
5. **Calculate Reduction**:
   - Count lines before and after
   - Calculate percentage reduction
   - Ensure target reduction achieved
6. **Output**:
   - **preview mode**: Display before/after comparison with statistics
   - **apply mode**: Write optimized content to file, display summary

### Optimization Strategies

**For Usage Sections**:
```
Before:
### Option 1
Description of option 1
### Option 2
Description of option 2

After:
| Option | Description |
|--------|-------------|
| Option 1 | Description |
| Option 2 | Description |
```

**For Implementation Instructions**:
- Remove explanatory text, keep actionable steps
- Consolidate sub-steps into single numbered lists
- Remove "This step will..." introductions
- Keep specific commands/patterns, remove surrounding prose

**For Error Handling**:
- Merge into main workflow as conditional steps
- Use concise error messages in quotes
- Remove explanatory paragraphs

**For Examples**:
- Keep maximum 2 examples
- Remove example explanations if code is self-explanatory
- Use inline comments instead of separate explanation paragraphs

### Validation Checklist

After optimization, verify:
- [ ] YAML frontmatter unchanged
- [ ] All required parameters documented
- [ ] All workflow steps present
- [ ] Error conditions specified
- [ ] Tool requirements listed
- [ ] Output format described
- [ ] Critical rules (MUST/NEVER) preserved
- [ ] AI can execute task using only the optimized document

### Tools

- `read`: Read document content
- `write`: Write optimized content
- `bash`: File operations, line counting
- `glob`: Find markdown files in directories

### Error Handling

- If file not markdown: "Error: [file] is not a markdown file"
- If reduction target not achievable: "Warning: Can only reduce by X%, not Y%"
- If critical content would be lost: "Error: Optimization would remove essential content from [section]"

---

## IMPLEMENTATION PRIORITY

When this command is invoked:
1. **DO NOT** ask the user whether to optimize
2. **DO NOT** propose optimization strategies
3. **DO** immediately proceed with analysis and optimization
4. **DO** preserve all critical information
5. **DO** validate that AI can still execute from optimized doc
6. **DO** report reduction statistics

The user expects immediate optimization with preserved functionality.

---

## Example Optimization

**Before** (verbose):
```markdown
## Usage

### Single file translation
This command allows you to translate a single markdown file. For example:
```
/translate-md-en-to-zh README.md
```
This will translate the README.md file from English to Chinese.

### Directory translation
You can also translate all files in a directory:
```
/translate-md-en-to-zh docs/
```
This will process all markdown files in the docs directory.
```

**After** (optimized):
```markdown
## Usage

```bash
# Single file
/translate-md-en-to-zh README.md

# Directory
/translate-md-en-to-zh docs/
```
```

Reduction: ~50% while preserving all essential information.
