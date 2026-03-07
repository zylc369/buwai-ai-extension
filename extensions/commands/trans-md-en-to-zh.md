---
description: Translate English markdown documents to Chinese
buwai-extension-id: trans-md-en-to-zh
---

# Translate English Markdown to Chinese

Translate English markdown files to Chinese with proper handling of internal links and formatting preservation.

## Usage

```bash
# Single file
/trans-md-en-to-zh README.md

# Directory (recursive, trans mode)
/trans-md-en-to-zh docs/

# Verification mode
/trans-md-en-to-zh docs/ verify

# Non-recursive
/trans-md-en-to-zh docs/ trans false
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| Path | required | File or directory path to translate |
| Mode | `trans` | `trans`: Translate English to Chinese<br>`verify`: Check and fix existing translations |
| Recursive | `true` | `true`: Process directory and subdirectories<br>`false`: Process only specified directory (ignored for files) |

## Output

Translated files use `.zh-cn.md` suffix:
- `README.md` → `README.zh-cn.md`
- `docs/guide.md` → `docs/guide.zh-cn.md`

## Key Rules

1. **Accuracy**: Translate precisely, no extra content
2. **Links**: Auto-replace links to files that have `.zh-cn.md` versions
3. **Format**: Preserve markdown structure, code blocks, syntax
4. **Terminology**: Keep consistent terminology
5. **Errors**: Display clear messages for non-English files or empty directories

---

## IMPLEMENTATION INSTRUCTIONS

### Workflow

1. **Parse Parameters**: Extract path, mode, recursive flag from input
2. **Validate Input**: Check path exists, determine file or directory
3. **Identify Files**:
   - File: Check if `.md` and contains English (not Chinese)
   - Directory: Find `.md` files (use `find` with `-maxdepth` if non-recursive)
   - Error: "This is not an English markdown document, cannot translate!" or "No English documents in this directory!"
4. **Execute** (for each file):
   - **trans mode**: Read → Translate (preserve structure/code) → Write to `[name].zh-cn.md` → Report progress
   - **verify mode**: Read translated → Compare with original → Check accuracy/terminology/format/links → Display issues or fix
5. **Replace Links** (trans mode only):
   - Scan translated files for `.md` links: `[text](path/file.md)`, `./file.md`, `../file.md`
   - For each link: Check if `[path/file.md].zh-cn.md` exists → Replace link if yes
   - Write updated content back to translated file
6. **Complete**: Display summary (files processed, output files, issues found/fixed)

### Error Handling

- Validate before processing any files
- Never overwrite original files
- Stop on critical errors, continue on non-fatal
- Report errors clearly with descriptive messages

### Tools

- `read`/`write`: File content I/O
- `bash`: File system operations (path checks, `find` command)
- `glob`/`grep`: Pattern matching and searching

---

## IMPLEMENTATION PRIORITY

When this command is invoked:
1. **DO NOT** ask the user whether to implement
2. **DO NOT** propose implementation approaches
3. **DO** immediately proceed with execution using the instructions above
4. **DO** validate inputs before processing
5. **DO** execute translation/verification directly
6. **DO** report progress and completion

The user expects the command to work immediately.

---

## Advanced Workflow

For production workflows with git-based incremental translation, translation record management, and change detection, see the [Translation Workflow Guide](./trans-md-en-to-zh-assets/translation-workflow.md).
