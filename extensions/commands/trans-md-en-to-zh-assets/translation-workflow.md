# Translation Workflow Guide

This guide describes the advanced translation workflow with git-based incremental translation, record management, and change detection.

## Overview

The translation system supports incremental translation based on git changes, making it efficient for large codebases with frequent updates.

## Incremental Translation Process

### When Translating a Directory

The system checks for an existing translation record file (`translation-en-to-zh-record.md`):

#### Case 1: Record Exists

1. **Compare Git Commits**
   - Get current git commit id
   - Extract last translation's git commit id from record
   - If commits are identical: Skip and inform user
     - Message: "Translation results are current. Use 'verify' mode to validate translations."

2. **Detect File Changes**
   - Identify markdown files changed between the two commits
   - Change types:
     - **New file**: Translate the new English markdown
     - **Modified file**: Re-translate the updated English markdown
     - **Deleted file**: Remove the corresponding Chinese translation file

3. **Execute Translations**
   - Translate only changed files
   - Update translation record

#### Case 2: No Record Exists

1. **Full Translation**
   - Scan directory for all English markdown files
   - Translate each file according to parameters
   - Create new translation record

### When Translating a Single File

1. **Direct Translation**
   - Translate the specified file
   - If `translation-en-to-zh-record.md` exists in current directory:
     - Update the record with new file mapping
     - Update completion timestamp

## Translation Record File

### Location
- Created in the root of the translated directory
- Filename: `translation-en-to-zh-record.md`

### File Format

```markdown
# translation-en-to-zh Command Execution Record

## Git Commit id
[Git commit hash]

## Translated Document Mapping
1. [English document link] -> [Chinese document link]. Translation time: [YYYY/MM/DD HH:MM:SS]
2. [English document link] -> [Chinese document link]. Translation time: [YYYY/MM/DD HH:MM:SS]
...

## Translation Completion Time
[YYYY/MM/DD HH:MM:SS]
```

### Purpose

1. **Change Detection**: Tracks git commit id to identify changed files
2. **Mapping Management**: Maintains relationship between source and translated files
3. **Audit Trail**: Records translation history with timestamps
4. **Efficiency**: Enables incremental translation without re-translating unchanged files

## Git Change Detection Algorithm

### Step 1: Get Commit Range
```
from_commit = record.git_commit_id
to_commit = current_git_commit_id
```

### Step 2: List Changed Files
```
changed_files = git diff --name-only {from_commit} {to_commit} -- "*.md"
```

### Step 3: Classify Changes
For each file in `changed_files`:
- If file exists in `from_commit` but not `to_commit`: **DELETED**
- If file exists in `to_commit` but not `from_commit`: **NEW**
- If file exists in both: **MODIFIED**

### Step 4: Execute Actions
- **NEW**: Translate to `{filename}.zh-cn.md`
- **MODIFIED**: Re-translate to `{filename}.zh-cn.md` (overwrite)
- **DELETED**: Remove `{filename}.zh-cn.md` if exists

## Link Replacement Logic

When translating markdown files with internal links:

### Detection
- Parse all markdown links in the document
- Identify links to other markdown files in the same repository

### Replacement Rules
```
Original: [text](../other-file.md)
Check: Does ../other-file.zh-cn.md exist?
If yes: Replace with [text](../other-file.zh-cn.md)
If no: Keep original link
```

### Priority
- Local project links are checked first
- External URLs are never modified
- Absolute paths use the same logic

## Verification Mode

The `verify` mode focuses on quality assurance:

### Checks Performed

1. **Translation Accuracy**
   - Verify meaning preservation
   - Check for over-translation (adding content)
   - Identify under-translation (missing content)

2. **Terminology Consistency**
   - Ensure consistent term usage across files
   - Verify technical terms are correctly translated

3. **Formatting Preservation**
   - Check markdown structure integrity
   - Verify code blocks are unchanged
   - Ensure heading hierarchy is maintained

4. **Link Validation**
   - Update broken links to Chinese versions
   - Remove links to deleted files
   - Fix relative path issues

### Fix Actions
- Directly correct minor issues
- Flag major issues for manual review
- Update translation record with changes

## Best Practices

### 1. Commit Before Translation
```bash
git add .
git commit -m "Update docs before translation"
/translate-md-en-to-zh docs/
```

### 2. Regular Verification
After major documentation updates, use verify mode:
```bash
/translate-md-en-to-zh docs/ verify
```

### 3. Keep Records in Version Control
Commit `translation-en-to-zh-record.md` to track translation history:
```bash
git add translation-en-to-zh-record.md
git commit -m "Update translation record"
```

### 4. Handle Conflicts
If git merge conflicts occur in translated files:
- Resolve conflicts in English files first
- Re-translate conflicting files
- Update translation record

## Troubleshooting

### Issue: "Translation results are current"

**Cause**: No git changes since last translation

**Solution**: Use verify mode to validate existing translations
```
/translate-md-en-to-zh docs/ verify
```

### Issue: Chinese version of linked file not found

**Cause**: Link replacement logic cannot find `.zh-cn.md` file

**Solution**:
1. Translate the linked file first
2. Or manually update the link if translation is not needed

### Issue: Git history changed

**Cause**: Rebase or force push changed commit ids

**Solution**:
1. Delete `translation-en-to-zh-record.md`
2. Run full translation again
3. Commit new record

## Integration with CI/CD

### Automated Translation Workflow

```yaml
# Example GitHub Action
- name: Check for doc changes
  run: |
    git diff --name-only ${{ github.event.before }} ${{ github.event.after }} | grep "docs/.*\.md$"

- name: Run translation
  if: success()
  run: |
    /translate-md-en-to-zh docs/

- name: Verify translations
  run: |
    /translate-md-en-to-zh docs/ verify
```

## Related Skills

For modular implementation, consider splitting into these skills:

1. **incremental-translate**: Git-based change detection and translation
2. **replace-markdown-links**: Update internal markdown links
3. **generate-translation-record**: Create and manage translation records

Each skill can be invoked independently or composed together for complex workflows.
