---
description: Translate English markdown documents to Chinese
buwai-extension-id: trans-md-en-to-zh
---

# Translate English Markdown to Chinese

Translate English markdown files to Chinese with proper handling of internal links and formatting preservation.

## Usage

### Single file translation
```
/translate-md-en-to-zh README.md
```

### Directory translation
```
/translate-md-en-to-zh docs/
```

### With verification mode
```
/translate-md-en-to-zh docs/ verify
```

### Non-recursive directory translation
```
/translate-md-en-to-zh docs/ trans false
```

## Parameters

1. **Path** (required): File or directory path
   - **File**: Translates single markdown file if it's in English
   - **Directory**: Translates all English markdown files in that directory

2. **Mode** (optional, default: `trans`):
   - `trans`: Translate English to Chinese
   - `verify`: Verify existing translations for accuracy and fix issues

3. **Recursive** (optional, default: `true`):
   - `true`: Translate directory and all subdirectories
   - `false`: Translate only the specified directory (ignored for single files)

## Output

- Translated files use `.zh-cn.md` suffix
- Example: `README.md` → `README.zh-cn.md`
- Example: `docs/guide.md` → `docs/guide.zh-cn.md`

## Translation Rules

1. **Accuracy**: Translate precisely without adding content not present in the source
2. **Link handling**: Check if linked English markdown files have Chinese versions, replace links accordingly
3. **Formatting**: Preserve markdown structure, code blocks, and syntax
4. **Terminology**: Maintain consistent terminology throughout translations

## Error Handling

- If input file is not English markdown: Display error "This is not an English markdown document, cannot translate!"
- If directory contains no English markdown files: Display error "There are no English documents in this directory!"

## Advanced Features

### Link Replacement
When translating, the command automatically detects links to other English markdown files:
- If a Chinese version exists (`file.zh-cn.md`), replace the link
- If no Chinese version exists, keep the original link

### Verification Mode
Use `verify` mode to review existing translations:
- Check translation accuracy
- Verify terminology consistency
- Fix formatting issues
- Update broken links

---

## Advanced Workflow (Git-based Incremental Translation)

For production workflows with git-based incremental translation, translation record management, and change detection, see the [Translation Workflow Guide](./trans-md-en-to-zh-assets/translation-workflow.md).

---

## IMPLEMENTATION INSTRUCTIONS

This section contains step-by-step instructions for AI agents to execute the translation command.

### STEP 1: Parse Parameters

Parse the user's command input:
- `$1`: Path (required) - file or directory path
- `$2`: Mode (optional, default: `trans`) - `trans` or `verify`
- `$3`: Recursive (optional, default: `true`) - `true` or `false`

### STEP 2: Validate Input

1. **Check if path exists**:
   - Use bash to check: `test -e "$1" || echo "Path not found"`
   - If path doesn't exist: Display error "Path does not exist: [path]" and exit

2. **Determine if file or directory**:
   - Use bash: `test -f "$1"` (file) or `test -d "$1"` (directory)

### STEP 3: Identify Files to Process

**If single file**:
1. Check if it's a markdown file (extension `.md`)
2. Check if content is English (simple heuristic: contains primarily English text, not Chinese characters)
3. If not English markdown: Display error "This is not an English markdown document, cannot translate!"

**If directory**:
1. Find all markdown files:
   - Recursive: `find "$1" -name "*.md" -type f`
   - Non-recursive: `find "$1" -maxdepth 1 -name "*.md" -type f`
2. Filter for English files (check content, exclude files that appear to be Chinese)
3. If no English markdown files found: Display error "There are no English documents in this directory!"
4. Create a list of files to process

### STEP 4: Execute Translation or Verification

For **trans** mode:

For each file to translate:
1. Read the file content
2. Use AI translation capability to translate English to Chinese
   - Preserve markdown structure
   - Keep code blocks unchanged
   - Maintain links for now (handle in Step 5)
   - Translate precisely without adding content
3. Generate output filename: `[original_filename_without_ext].zh-cn.md`
4. Write translated content to output file
5. Report progress: "Translated: [input] → [output]"

For **verify** mode:

For each `.zh-cn.md` file to verify:
1. Read the translated file
2. Find original English file (same path without `.zh-cn.md`)
3. Compare and identify issues:
   - Translation accuracy
   - Terminology consistency
   - Formatting issues
   - Broken links
4. Display issues found or "Translation verified: No issues found"
5. Optionally auto-fix issues if appropriate

### STEP 5: Link Replacement (trans mode only)

After all translations complete:

For each translated file:
1. Read the translated content
2. Scan for markdown links to other `.md` files:
   - Pattern: `[text](path/to/file.md)`
   - Pattern: `[text](./file.md)`
   - Pattern: `[text](../file.md)`
3. For each link found:
   - Check if the linked file has a Chinese version:
     - Append `.zh-cn.md` to the link path
     - Check if that file exists
   - If Chinese version exists: Replace the link with the Chinese version
   - If no Chinese version: Keep original link unchanged
4. Write the updated content back to the translated file
5. Report: "Updated links: [output file]"

### STEP 6: Completion Report

After processing all files:

Display a summary:
```
✓ Translation completed
- Files processed: [count]
- Output files: [list of output files]
```

For verify mode:
```
✓ Verification completed
- Files verified: [count]
- Issues found: [count]
- Issues fixed: [count]
```

### ERROR HANDLING RULES

1. **Never proceed with invalid input** - Always validate before processing
2. **Preserve original files** - Never overwrite source files
3. **Fail fast on critical errors** - Stop processing if a critical error occurs
4. **Report all errors clearly** - Use descriptive error messages
5. **Skip non-fatal errors** - Continue processing other files if one file fails

### TOOLS TO USE

- `read`: Read markdown file contents
- `write`: Write translated content
- `bash`: Execute shell commands for file operations
- `glob`: Find markdown files in directories
- `grep`: Search for link patterns

### IMPLEMENTATION NOTES

- AI translation capability: Use the agent's built-in translation ability
- Link replacement is a post-processing step after all translations
- For verification mode, compare against original English files
- Use bash commands for file system operations (exists checks, file listing)
- Handle edge cases: empty files, files with only code blocks, files with mixed English/Chinese

---

## IMPLEMENTATION PRIORITY

When this command is invoked:
1. **DO NOT** ask the user whether to implement
2. **DO NOT** propose implementation approaches
3. **DO** immediately proceed with execution using the instructions above
4. **DO** validate inputs before processing
5. **DO** execute translation/verification directly
6. **DO** report progress and completion

The user expects the command to work immediately, not to be asked about implementation.
