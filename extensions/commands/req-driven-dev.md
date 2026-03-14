---
description: Requirement-driven development workflow - transform user requirements into verified implementation through structured documentation and planning
buwai-extension-id: req-driven-dev
---

# Requirement-Driven Development

Transform user requirements into verified implementation through a systematic workflow: requirement analysis → documentation → planning → execution → verification.

## Usage

```bash
# Basic usage with requirement text
/req-driven-dev "Add user authentication with OAuth2 support"

# Specify output directory
/req-driven-dev "Implement payment integration" ./docs/requirements

# Specify both output and historical directories
/req-driven-dev "Add notification system" ./docs/requirements ./docs/legacy-requirements

# With context file reference
/req-driven-dev "Refactor API layer based on architecture-review.md"
```

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| Requirement | required | The requirement text or description to implement |
| OutputDir | `docs/requirements` | Directory for generated requirements document |
| HistoryDir | `docs/requirements` | Directory containing historical requirements for reference |

## Workflow Phases

1. **Discovery** - Explore codebase, understand context, reference historical requirements
2. **Documentation** - Generate structured requirements document
3. **Planning** - Create detailed execution plan with user confirmation
4. **Execution** - Implement with continuous verification against requirements
5. **Validation** - Test and verify all acceptance criteria are met

---

## IMPLEMENTATION INSTRUCTIONS

### Phase 1: Discovery

**MUST DO:**
1. Parse the requirement text and identify:
   - Core functionality requested
   - Implicit dependencies or constraints
   - Affected components/modules

2. Explore the codebase to understand:
   - Current architecture and patterns
   - Related existing implementations
   - File/module structure

3. Reference historical requirements:
   - Scan `HistoryDir` for related requirement documents
   - Extract patterns, conventions, and decisions from past requirements
   - Identify any dependencies or conflicts with existing requirements

4. Ask clarifying questions **ONLY** when:
   - Multiple valid interpretations exist with significantly different implementations
   - Critical technical decisions have no clear best path
   - Scope ambiguity could lead to 2x+ effort difference

**MUST NOT DO:**
- Do NOT start implementation before documentation is complete
- Do NOT assume requirements without evidence
- Do NOT skip exploration of existing patterns

### Phase 2: Documentation

Generate a requirements document at `{OutputDir}/req-{timestamp}-{slug}.md`:

```markdown
# Requirement: {Title}

**ID**: REQ-{timestamp}
**Status**: Draft
**Created**: {datetime}
**Source**: User input / {context-file}

## Summary
{One-paragraph description of what is being requested}

## Context
- Project: {project name/type}
- Related Requirements: {links to related docs}
- Affected Components: {list of modules/files}

## Functional Requirements
1. {FR-001}: {requirement description}
   - Acceptance Criteria: {how to verify}
   - Priority: High/Medium/Low

## Non-Functional Requirements
1. {NFR-001}: {requirement description}
   - Acceptance Criteria: {how to verify}

## Constraints
- {Technical constraints}
- {Business constraints}
- {Timeline constraints}

## Dependencies
- {External dependencies}
- {Internal dependencies}

## Out of Scope
- {Explicitly excluded items}

## Technical Approach
- Recommended: {recommended approach with rationale}
- Alternatives Considered: {other options and why rejected}

## Test Strategy
- Unit Tests: {what to test at unit level}
- Integration Tests: {what to test at integration level}
- Manual Verification: {steps to manually verify}

## References
- {Links to docs, APIs, examples}
```

**Slug format**: Convert requirement title to lowercase, replace spaces with hyphens, max 50 chars.

### Phase 3: Planning

Create execution plan with the following structure:

1. **Break down into atomic tasks**:
   - Each task has clear input, output, and success criteria
   - Identify dependencies between tasks
   - Mark tasks that can run in parallel

2. **Present plan to user**:
   - Display numbered task list with dependencies
   - Show estimated complexity for each task
   - Highlight any decisions requiring user input

3. **User confirmation**:
   - Ask user to confirm the plan or request modifications
   - Allow user to add/remove/reorder tasks
   - Proceed only after explicit approval

4. **Plan document location**: `{OutputDir}/plan-{timestamp}-{slug}.md`

**Plan Template**:
```markdown
# Execution Plan: {Requirement Title}

**Requirement ID**: REQ-{timestamp}
**Plan Created**: {datetime}

## Task Breakdown

### Phase 1: {Phase Name}
| Task ID | Description | Dependencies | Complexity | Parallel? |
|---------|-------------|--------------|------------|-----------|
| T-001 | {task} | None | Medium | Yes |
| T-002 | {task} | T-001 | Low | No |

### Phase 2: {Phase Name}
...

## Verification Checkpoints
- [ ] Checkpoint 1: {what to verify}
- [ ] Checkpoint 2: {what to verify}

## Test Plan
| Test ID | Description | Type | Expected Result |
|---------|-------------|------|-----------------|
| TEST-001 | {test} | Unit | {expected} |

## Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| {risk} | {L/M/H} | {L/M/H} | {strategy} |

## Approval
- [ ] User approved this plan
- Approval Date: {datetime}
```

### Phase 4: Execution

**MUST DO:**
1. Execute tasks in dependency order
2. Run parallel tasks simultaneously where possible
3. After each task:
   - Verify against task acceptance criteria
   - Update requirements document if discoveries require changes
   - Log completion status
4. Compare implementation outputs against requirements document
5. Add discrepancies to plan as new tasks if needed

**MUST NOT DO:**
- Do NOT skip verification after task completion
- Do NOT proceed to next phase if current phase verification fails
- Do NOT modify requirements without documenting the change

### Phase 5: Validation

1. **Run all tests** defined in test plan
2. **Manual verification** of each acceptance criteria
3. **Generate verification report**:
   ```markdown
   # Verification Report: {Requirement Title}
   
   **Requirement ID**: REQ-{timestamp}
   **Verified**: {datetime}
   
   ## Acceptance Criteria Results
   | Criteria | Status | Evidence |
   |----------|--------|----------|
   | AC-001 | PASS | {description/evidence} |
   | AC-002 | FAIL | {description/evidence} |
   
   ## Test Results
   | Test | Status | Notes |
   |------|--------|-------|
   | TEST-001 | PASS | |
   
   ## Issues Found
   1. {issue description}
     - Severity: Critical/High/Medium/Low
     - Resolution: {how resolved or status}
   
   ## Conclusion
   - [ ] All acceptance criteria met
   - [ ] All tests passing
   - [ ] Ready for deployment
   ```

---

## IMPLEMENTATION PRIORITY

When this command is invoked:

| Priority | Action |
|----------|--------|
| 1 | **DO** immediately start discovery phase |
| 2 | **DO** generate requirements document before planning |
| 3 | **DO** create detailed plan with user confirmation |
| 4 | **DO** include testing in plan when implementation is involved |
| 5 | **DO** verify outputs against requirements document |
| 6 | **DO** ask clarifying questions only when genuinely ambiguous |

| Priority | Anti-Pattern |
|----------|--------------|
| NEVER | Start implementation without requirements document |
| NEVER | Skip user plan approval |
| NEVER | Omit testing from plan |
| NEVER | Declare complete without verification report |
| NEVER | Reduce scope without explicit user approval |

---

## Output Files

| File | Pattern | Description |
|------|---------|-------------|
| Requirements | `{OutputDir}/req-{timestamp}-{slug}.md` | Structured requirements document |
| Plan | `{OutputDir}/plan-{timestamp}-{slug}.md` | Execution plan with tasks |
| Verification | `{OutputDir}/verify-{timestamp}-{slug}.md` | Final verification report |

**Timestamp format**: `yyyyMMdd-HHmmss`
**Slug**: Lowercase, hyphen-separated, max 50 chars from requirement title

---

## Examples

### Example 1: Simple Feature
```bash
/req-driven-dev "Add dark mode toggle to settings page"
```

Discovery finds: existing theme context, settings component structure
Requirements doc covers: toggle placement, persistence, system preference detection
Plan includes: context update, UI component, CSS variables, tests

### Example 2: Complex Feature with Context
```bash
/req-driven-dev "Implement real-time notifications based on notifications-arch.md"
```

Discovery reads: `notifications-arch.md` for architectural decisions
Requirements doc references: existing architecture document
Plan includes: WebSocket setup, notification service, UI components, integration tests

### Example 3: Refactoring
```bash
/req-driven-dev "Migrate authentication from JWT to session-based"
```

Discovery explores: current auth implementation, session middleware options
Requirements doc covers: migration path, backward compatibility, security considerations
Plan includes: incremental migration steps, rollback strategy, verification at each step
