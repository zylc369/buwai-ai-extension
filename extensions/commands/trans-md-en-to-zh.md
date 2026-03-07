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
