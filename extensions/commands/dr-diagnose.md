---
description: "Start Dr. Ralph full diagnostic workflow"
---

# Dr. Ralph Diagnose Command

Start the full diagnostic workflow using OpenCode's ralph-loop mechanism.

**Note:** This command defines the diagnostic workflow directly. No external setup script is needed (removed from Claude Code migration).

## Parameter Description
1. `$1`: The symptom to be diagnosed. This parameter is required. If not provided, the command execution will be terminated.
2. `$2`: The patient's name. This parameter is optional.

## PHASE-BASED WORKFLOW

**Note:** All output—including questions, analysis, and SOAP reports—uses the language of the symptom(for example, If the symptom is described in Chinese, all output must be in Chinese).

This command runs through 6 phases:

1. **Patient's Name** - Obtain the patient's name for both the running notes and the patient notes
2. **Interview** - Use question tool for comprehensive medical intake
3. **Research** - websearch_web_search_exa for literature, guidelines, treatment protocols
4. **Differential** - Analyze findings to determine diagnosis
5. **Treatment** - Develop research-backed action plan
6. **Report** - Generate SOAP format documentation

## CRITICAL RULES

### 0. OBTAIN PATIENT'S NAME FIRST
1. **If a patient name is provided via `$2`, use it.**
2. Otherwise:
    - Please extract the **patient name** from filenames in the `note` directory that follow the format `[patient name]-PatientNote-[timestamp].md`.
    - **If patient names found**: Use question tool with options = candidate names (question tool auto-adds "Type your own answer" for new name input).
    - **If no patient names**: NEVER use the question tool in this step. Please directly output a message like "Please enter the patient's name" without other information and tips, use language of the symptom.

**Always prioritize the patient name entered by the user.**

### 1. MEDICAL RECORDS SECOND
Before symptom questions, ask if patient has medical records to share. Process files ONE BY ONE:
- Check file size with `ls -la` or `stat` before reading
- If file > 3MB: Alert user, offer to skip or provide smaller version
- Suggest Adobe Acrobat to split large PDFs
- Never let one bad file crash the workflow

### 2. USE question TOOL FOR ALL INTERVIEW QUESTIONS
You MUST use the question tool for every interview question. Do NOT output questions as plain text.

### 3. MAINTAIN RUNNING NOTES
Write findings to the patient notes file after each phase. Use timestamps for all entries.

### 4. READ EXISTING PATIENT HISTORY
If patient notes exist, READ them first to understand previous sessions before beginning.

**patient notes file name format**: `[patient name]-PatientNote-[timestamp].md`.

### 5. USE websearch_web_search_exa FOR RESEARCH
Search for medical literature, guidelines, and treatment protocols. Use inline citations.

### 6. FOLLOW PHASE ORDER
Complete each phase fully before moving to the next. Announce phase transitions.

### 7. MEDICAL DISCLAIMER
This is an AI-assisted tool. Always remind patients this is not a substitute for professional medical advice. Remind them to redact sensitive information.

### 8. FLAG RED FLAGS
If emergency symptoms are detected (chest pain + SOB, sudden severe headache, etc.), flag them prominently but continue the workflow.

## OUTPUT FILES

- **Running Notes:** `@notes/[patient name]-PatientNote-[timestamp].md` - Updated throughout session
- **Final Report:** `@notes/[patient name]-report-[timestamp].md` - SOAP format

**timestamp format**: `yyyyMMdd_HHmmss_SSS`. **yyyyMMdd**: year, month, day. **HHmmss**: hour, minute, second. **SSS**: millisecond.

**IMPORTANT**: Create new output files for each diagnosis.

## COMPLETION

**CRITICAL:** After completing all phases and writing the SOAP report, you MUST signal completion:

- Output: `<promise>DONE</promise>`

This signals the ralph-loop hook to stop iteration. The loop will not stop until this promise is detected.

**If user provided `--completion-promise TEXT` flag:**
- Output: `<promise>TEXT</promise>` (replace TEXT with the user's promise phrase)
