---
description: Requirement-driven development with progressive disclosure documentation, context-based generation, and archive system
buwai-extension-id: req-driven-dev
---

# Requirement-Driven Development

Transform user requirements into verified implementation through systematic workflow with progressive disclosure documentation.

## Key Features

- **Progressive Disclosure**: Requirements split into focused sub-documents
- **Context-Based Generation**: Generate requirements from session/tasks/code when directory empty
- **Smart Supplement Logic**: Update existing related requirements vs creating duplicates (70% similarity threshold)
- **Index & Tracking**: Master index + active tracker for navigation
- **Archive System**: Completed requirements archived with traceable naming

## Usage

```bash
# Basic usage
/req-driven-dev "Add user authentication with OAuth2 support"

# Specify output directory
/req-driven-dev "Implement payment integration" ./docs/requirements

# Specify both output and historical directories
/req-driven-dev "Add notification system" ./docs/requirements ./docs/legacy-requirements

# With context file reference
/req-driven-dev "Refactor API layer based on architecture-review.md"

# Mark requirement as completed (triggers archive)
/req-driven-dev --complete REQ-20260314-143025
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| Requirement | required | The requirement text or description to implement |
| OutputDir | `docs/requirements` | Directory for requirement documents |
| HistoryDir | `docs/requirements` | Directory containing historical requirements for reference |
| `--complete REQ-ID` | optional | Mark requirement as completed and archive |

## Workflow Phases

1. **Discovery** - Analyze context, check existing requirements, determine supplement vs independent
2. **Documentation** - Generate progressive disclosure document structure
3. **Planning** - Create detailed execution plan with user confirmation
4. **Execution** - Implement with continuous verification against requirements
5. **Validation & Archive** - Test, verify, and archive completed requirements

---

## DOCUMENT STRUCTURE (Progressive Disclosure)

### Directory Layout

```
{OutputDir}/                              # Default: docs/requirements/
├── requirements-index.md                  # Master index of all requirements
├── active-requirements.md                 # Current work tracker
├── req-{timestamp}-{slug}/               # Requirement directory
│   ├── index.md                          # Summary + progress (entry point)
│   ├── functional.md                     # Functional requirements (FR-*)
│   ├── non-functional.md                 # Non-functional requirements (NFR-*)
│   ├── technical.md                      # Technical approach + constraints
│   ├── test-strategy.md                  # Test plan + verification
│   ├── plan.md                           # Execution plan
│   └── verify.md                         # Verification report
└── _archive/                              # Completed requirements
    └── req-{timestamp}-{slug}/
        └── _archived-at.md               # Archive metadata
```

### Why Progressive Disclosure?

| Problem | Solution |
|---------|----------|
| Large monolithic docs overwhelm AI | Split into focused sub-documents |
| Context window exhaustion | Load only needed sections |
| Hard to find specific info | Index + sub-doc structure |
| Update conflicts | Granular file updates |

### File Naming Conventions

- **Directory**: `req-{timestamp}-{slug}/`
- **Timestamp**: `yyyyMMdd-HHmmss` (e.g., `20260314-143025`)
- **Slug**: Lowercase, hyphen-separated, max 50 chars from title

### Document Templates

#### requirements-index.md

Master index with tables for:
- **Active Requirements**: ID, Title, Status, Priority, Phase, Created, Summary
- **Pending Requirements**: ID, Title, Priority, Dependencies, Created
- **Completed (Last 10)**: ID, Title, Completed, Summary, Archive link

#### active-requirements.md

Tracker with sections for:
- **Currently In Progress**: Priority, ID, Title, Phase, Started, Blocking
- **Up Next**: Priority, ID, Title, Dependencies
- **Blocked**: ID, Title, Blocked By, Reason

#### req-{timestamp}-{slug}/index.md

YAML frontmatter: `id`, `title`, `status`, `priority`, `created`, `updated`, `source`, `related`, `affected_components`

Sections: Quick Summary, Document Structure (table with links), Context, Progress (table by phase), Supplement History

#### req-{timestamp}-{slug}/functional.md

Each requirement (FR-*):
- **Priority**: High | Medium | Low
- **Status**: Draft | Approved | Implemented | Verified
- **Description**: What the system must do
- **Acceptance Criteria**: AC-* checklist items
- **Notes**: Additional context

#### req-{timestamp}-{slug}/technical.md

Sections:
- **Recommended Approach**: Primary implementation strategy with rationale
- **Architecture Impact**: Components affected, new dependencies, breaking changes
- **Constraints**: Type, Constraint, Rationale table
- **Alternatives Considered**: Approach, Pros, Cons, Why Rejected table
- **Implementation Notes**: Technical details, patterns to follow

#### req-{timestamp}-{slug}/test-strategy.md

Tables for:
- **Unit Tests**: Test ID, Target, Description, Expected Result
- **Integration Tests**: Test ID, Components, Description, Expected Result
- **Manual Verification**: Step, Action, Expected Result
- **Test Coverage Goals**: Unit/Integration percentages

#### req-{timestamp}-{slug}/plan.md

- **Created**: datetime, **Status**: Draft/Approved/In Progress/Completed
- **Task Breakdown**: Phases with tables (Task ID, Description, Dependencies, Complexity, Status)
- **Verification Checkpoints**: Checklist items
- **Risk Assessment**: Risk, Likelihood, Impact, Mitigation table
- **Approval**: User checkbox and date

#### req-{timestamp}-{slug}/verify.md

- **Verified**: datetime, **Status**: Pass | Fail | Partial
- **Acceptance Criteria Results**: Criteria, Status, Evidence table
- **Test Results**: Test ID, Status, Notes table
- **Issues Found**: Issue, Severity, Resolution table
- **Conclusion**: Checkboxes + Verdict (PASS/FAIL)

#### _archive/req-{timestamp}-{slug}/_archived-at.md

YAML frontmatter: `original_id`, `title`, `archived_at`, `completion_status`

Sections: Archive Record (Original Requirement link, Archived date, Duration), Completion Summary, Key Artifacts, Lessons Learned

---

## IMPLEMENTATION INSTRUCTIONS

### Phase 1: Discovery

**Step 1.1: Check Requirements Directory State**

- If empty or doesn't exist → STATE="empty"
- If contains `req-*` directories → STATE="populated"

**Step 1.2: Context-Based Generation (When Empty)**

Generate initial requirements from:

1. **Session Context**: Current conversation, implicit requirements, user question patterns
2. **Planned Tasks**: TODOs in code (`// TODO:`, `// FIXME:`, `// HACK:`), task tracking files
3. **Code Analysis**: Incomplete implementations, placeholders, architectural gaps

**Step 1.3: Supplement vs Independent Decision (When Populated)**

```
DECISION LOGIC:
1. Scan all existing requirement index.md files
2. For each: Extract title, affected_components, functional requirements
3. Calculate similarity score (0.0-1.0):
   - Keyword overlap: 40% weight (Jaccard similarity)
   - Component overlap: 30% weight (intersection/union)
   - Semantic similarity: 30% weight (related concepts)
4. If highest_similarity >= 0.70 → SUPPLEMENT existing
5. Else → CREATE independent
```

**Step 1.4: Ask Clarifying Questions**

Ask questions ONLY when:
- Multiple valid interpretations with different implementations
- Critical technical decisions have no clear path
- Scope ambiguity could lead to 2x+ effort difference
- Supplement vs independent decision is borderline (0.65-0.75 similarity)

**MUST DO:**
- Parse requirement text for functionality, dependencies, components
- Explore codebase for architecture, patterns, file structure
- Reference historical requirements in HistoryDir
- Determine supplement vs independent before documentation

**MUST NOT DO:**
- Start implementation before documentation is complete
- Assume requirements without evidence
- Create new requirement without checking similarity
- Skip exploration of existing patterns

### Phase 2: Documentation

**Step 2.1: Create Directory Structure**

For NEW requirement:
```
{OutputDir}/req-{timestamp}-{slug}/
├── index.md
├── functional.md
├── non-functional.md (if needed)
├── technical.md
└── test-strategy.md
```

For SUPPLEMENT:
```
{OutputDir}/req-{existing-timestamp}-{existing-slug}/
├── index.md (UPDATE Progress + Supplement History)
├── functional.md (APPEND new FR-*)
├── non-functional.md (APPEND new NFR-* if needed)
├── technical.md (UPDATE if approach changes)
└── test-strategy.md (UPDATE test plan)
```

**Step 2.2: Generate Documents**

| Document | Required | Generated From |
|----------|----------|----------------|
| index.md | ✅ | Title, summary, context, related requirements |
| functional.md | ✅ | User requirements → FR-* items with acceptance criteria |
| non-functional.md | ⚪ | Performance, security, usability requirements |
| technical.md | ✅ | Architecture analysis, constraints, approach |
| test-strategy.md | ✅ | Functional requirements → test cases |

**Step 2.3: Update Index Files**

1. Create/update `requirements-index.md`: Add to "Active Requirements" (new) or update status/phase (supplement)
2. Create/update `active-requirements.md`: Add to "Currently In Progress" (immediate), "Up Next" (pending), or "Blocked" (has dependencies)

**Step 2.4: Update Supplement History (When Supplementing)**

Add entry to `index.md` Supplement History table: `| {datetime} | Supplemented | Added FR-003: {description} |`

**MUST DO:**
- Create directory structure for each independent requirement
- Generate all required sub-documents
- Update requirements-index.md on every new/updated requirement
- Update active-requirements.md on status changes
- Add supplement history entries when updating existing

**MUST NOT DO:**
- Create single monolithic requirement document
- Skip index updates after requirement creation/update
- Exceed 50 characters in slug
- Delete archived requirements

### Phase 3: Planning

**Step 3.1: Generate Execution Plan**

Create `plan.md` inside requirement directory:

1. **Break down into atomic tasks**: Clear input, output, success criteria; identify dependencies; mark parallel tasks
2. **Present plan to user**: Display numbered task list with dependencies; show estimated complexity; highlight decisions needing input

**Step 3.2: User Confirmation**

- Ask user to confirm the plan or request modifications
- Proceed only after explicit approval
- Update `plan.md` approval section on confirmation

**Step 3.3: Update Tracker**

Update `active-requirements.md` with current phase and task progress.

**MUST DO:**
- Create plan inside requirement directory
- Include test tasks when implementation is involved
- Get explicit user approval before execution

**MUST NOT DO:**
- Skip user plan approval
- Omit testing from plan

### Phase 4: Execution

**Step 4.1: Execute Tasks**

Execute tasks in dependency order; run parallel tasks simultaneously where possible.

**Step 4.2: Track Progress**

After each task:
- Verify against task acceptance criteria
- Update `index.md` Progress table
- Update `active-requirements.md` status
- Update requirements document if discoveries require changes

**Step 4.3: Handle Discrepancies**

- Compare implementation outputs against requirements document
- Add discrepancies to `plan.md` as new tasks if needed
- Document changes in `index.md` Supplement History

**MUST DO:**
- Update `index.md` Progress table after each phase
- Update `active-requirements.md` on status changes
- Document any requirement changes

**MUST NOT DO:**
- Skip verification after task completion
- Proceed to next phase if current phase verification fails
- Modify requirements without documenting the change

### Phase 5: Validation & Archive

**Step 5.1: Run Tests**

Execute all tests defined in `test-strategy.md`: unit tests, integration tests, manual verification steps.

**Step 5.2: Generate Verification Report**

Create `verify.md` with: acceptance criteria results, test results, issues found (if any), final verdict (PASS/FAIL).

**Step 5.3: Archive Process (When PASS)**

1. **Create archive directory**: `{OutputDir}/_archive/req-{timestamp}-{slug}/`
2. **Move all documents**: Preserve original directory name, move all sub-documents
3. **Create archive metadata**: Create `_archived-at.md` with completion info
4. **Update requirements-index.md**: Move from "Active" to "Completed (Last 10)"; if >10 completed, remove oldest
5. **Update active-requirements.md**: Remove from "Currently In Progress"; update dependent requirements status

**Archive Naming Convention**: Preserve original `req-{original-timestamp}-{original-slug}/` name for traceability, searchability, and link consistency.

**MUST DO:**
- Generate verification report before archive
- Move to `_archive/` with original name preserved
- Create `_archived-at.md` metadata
- Update index (move Active → Completed, keep last 10)
- Update tracker (remove from In Progress)

**MUST NOT DO:**
- Archive requirement with unverified acceptance criteria
- Delete archived requirements
- Remove completed requirements from index (keep last 10)

---

## TOOLS

| Tool | Purpose |
|------|---------|
| `read` | Read existing files, requirements, code |
| `write` | Create requirements documents, plans, reports |
| `glob` | Find req-* directories, pattern matching |
| `grep` | Search for TODOs, patterns, implementations |
| `bash` | Directory operations, file moves, archiving |
| `question` | Ask clarifying questions when ambiguity exists |
| `task` with `explore` | Deep codebase exploration |
| `task` with `librarian` | Research external dependencies/patterns |
| `lsp_diagnostics` | Verify code quality after changes |

---

## IMPLEMENTATION PRIORITY

### MUST Rules

1. Immediately start discovery phase
2. Create directory structure for each independent requirement
3. Generate progressive disclosure structure (index + sub-docs)
4. Check similarity before creating new requirement (70% threshold)
5. Supplement existing requirement if semantically related
6. Generate requirements document before planning
7. Update requirements-index.md on every new/updated requirement
8. Update active-requirements.md on status changes
9. Create detailed plan with user confirmation
10. Include testing in plan when implementation is involved
11. Archive completed requirements to _archive/ with metadata
12. Keep last 10 completed requirements in index
13. Analyze session context when requirements directory is empty
14. Verify outputs against requirements document
15. Ask clarifying questions only when genuinely ambiguous

### NEVER Rules

1. Create single monolithic requirement document
2. Create new requirement without checking for supplements
3. Skip index update after requirement creation/update
4. Skip tracker update after status change
5. Start implementation without requirements document
6. Skip user plan approval
7. Omit testing from plan
8. Archive requirement with unverified acceptance criteria
9. Delete archived requirements
10. Exceed 50 characters in slug
11. Remove completed requirements from index (keep last 10)
12. Declare complete without verification report
13. Reduce scope without explicit user approval

---

## OUTPUT FILES

### Index Files (At OutputDir Root)

| File | Purpose | Updated |
|------|---------|---------|
| `requirements-index.md` | Master index of all requirements | Every requirement change |
| `active-requirements.md` | Current work tracker | Every status change |

### Requirement Directory Structure

| File | Required | Description |
|------|----------|-------------|
| `index.md` | ✅ | Summary + progress (entry point) |
| `functional.md` | ✅ | Functional requirements (FR-*) |
| `non-functional.md` | ⚪ | Non-functional requirements (NFR-*) |
| `technical.md` | ✅ | Technical approach + constraints |
| `test-strategy.md` | ✅ | Test plan + verification |
| `plan.md` | Generated | Execution plan (Phase 3) |
| `verify.md` | Generated | Verification report (Phase 5) |

### Archive Structure

| File | Description |
|------|-------------|
| `_archive/req-{timestamp}-{slug}/` | Archived requirement |
| `_archived-at.md` | Archive metadata |

**Formats**: Timestamp `yyyyMMdd-HHmmss`; Slug lowercase, hyphen-separated, max 50 chars

---

## EXAMPLES

### Example 1: First Requirement (Empty Directory)

```bash
/req-driven-dev "Add dark mode toggle to settings page"
```

**Discovery**: Directory empty → Analyze session context → Create new independent requirement

**Generated**: `requirements-index.md`, `active-requirements.md`, `req-20260314-143025-add-dark-mode-toggle-settings-page/` with all sub-documents

**Index**: Added to "Active Requirements" table

### Example 2: Supplement Existing Requirement

```bash
/req-driven-dev "Add system preference auto-detection for dark mode"
```

**Discovery**: Similarity score 0.82 with existing dark mode requirement → SUPPLEMENT

**Updates**: Append FR-003 to `functional.md`, update `technical.md` with matchMedia approach, add test to `test-strategy.md`, update Supplement History

**Index**: Status updated to "In Progress - Supplemented"

### Example 3: Independent Requirement

```bash
/req-driven-dev "Implement payment integration with Stripe"
```

**Discovery**: No similar requirements → CREATE independent

**Generated**: New `req-20260315-100000-payment-integration-stripe/` with all sub-documents

**Index**: Added to "Pending Requirements" (dependency on auth completion)

### Example 4: Complete and Archive

```bash
/req-driven-dev --complete REQ-20260314-143025
```

**Process**:
1. Verify all acceptance criteria met
2. Generate final `verify.md` with PASS verdict
3. Move to `_archive/req-20260314-143025-add-dark-mode-toggle-settings-page/`
4. Create `_archived-at.md`
5. Update index: Active → Completed (last 10)
6. Update tracker: Remove from In Progress
