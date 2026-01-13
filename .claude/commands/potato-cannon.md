---
name: potato-cannon
description: Process a ticket through the Potato Cannon pipeline - from discovery through implementation and QA.
user_invocable: true
tools: Read, Write, Glob, Grep, Task
---

# Potato Cannon Pipeline

Process a ticket through the full Potato Cannon pipeline:

1. **Project Discovery** - Analyze project structure and patterns
2. **Business Analyst** - Transform ticket into product specification
3. **Architect** - Design implementation approach
4. **Dissenting Architect** - Review and approve architecture
5. **Engineer** - Implement the code
6. **QA** - Validate implementation

## Usage

```
/potato-cannon {ticket-id}
/potato-cannon --resume {ticket-id}
/potato-cannon --status {ticket-id}
```

### Arguments

- `{ticket-id}` - The ticket file name (without .md extension)
- `--resume` - Resume a previously started pipeline
- `--status` - Check the status of a ticket without processing

### Examples

```
/potato-cannon feature-123
/potato-cannon add-dark-mode
/potato-cannon --resume feature-123
/potato-cannon --status feature-123
```

## Execution

### Step 1: Parse Arguments

Parse `$ARGUMENTS` to extract:
- `TICKET_ID` - The ticket identifier
- `RESUME_MODE` - Whether `--resume` flag is present
- `STATUS_MODE` - Whether `--status` flag is present

### Step 2: Validate Setup

Check that Potato Cannon is initialized:

```bash
ls .potato/tickets 2>/dev/null
```

If not found:
```markdown
❌ Potato Cannon not initialized in this project.

Run `/init-potato-cannon` first to set up the scratch space.
```

### Step 3: Validate Ticket

Check that the ticket exists:

```bash
ls .potato/tickets/{TICKET_ID}.md 2>/dev/null
```

If not found:
```markdown
❌ Ticket not found: {TICKET_ID}

Expected file: .potato/tickets/{TICKET_ID}.md

Available tickets:
{list .potato/tickets/*.md}

To create a new ticket:
```bash
cp .potato/tickets/_TEMPLATE.md .potato/tickets/{TICKET_ID}.md
```
```

### Step 4: Handle Status Mode

If `--status` flag is present:

1. Check if state directory exists: `.potato/state/{TICKET_ID}/`
2. If exists, read and display `STATE.md`
3. If not exists, report "Ticket has not been processed yet"

```markdown
## Ticket Status: {TICKET_ID}

**Status:** {in_progress/completed/paused/not_started}
**Current Stage:** {stage name}

### Progress

- [x] ProjectDiscovery: Complete
- [x] BusinessAnalyst: Complete
- [x] Architect: Complete
- [ ] DissentingArchitect: In Progress (Attempt 2)
- [ ] Engineer: Pending
- [ ] QA: Pending

### State Files

- project-context.md ✅
- product-spec.md ✅
- architecture.md ✅
- architecture-review.md ✅ (REJECTED)
- implementation-log.md ❌
- qa-report.md ❌
```

Exit after displaying status.

### Step 5: Handle Resume Mode

If `--resume` flag is present:

1. Read `.potato/state/{TICKET_ID}/STATE.md`
2. Find the last completed stage
3. Set pipeline to continue from the next stage

If no state exists:
```markdown
❌ Cannot resume: No previous state found for {TICKET_ID}

The ticket hasn't been processed yet. Run without --resume:
```
/potato-cannon {TICKET_ID}
```
```

### Step 6: Initialize State (New Pipeline)

If not resuming:

1. Create state directory: `.potato/state/{TICKET_ID}/`
2. Create initial STATE.md

```markdown
# Ticket: {TICKET_ID}

**Ticket File:** .potato/tickets/{TICKET_ID}.md
**Started:** {ISO timestamp}
**Status:** in_progress

## Pipeline Progress

- [ ] ProjectDiscovery: Analyze project structure
- [ ] BusinessAnalyst: Create product specification
- [ ] Architect: Design implementation
- [ ] DissentingArchitect: Review architecture
- [ ] Engineer: Implement code and tests
- [ ] QA: Validate implementation

## Current Stage

**Stage:** ProjectDiscovery
**Attempt:** 1

## Stage History

{stages will be logged here}

## Errors

{errors will be logged here}
```

### Step 7: Execute Pipeline

Invoke the orchestrator agent to run the pipeline:

```
Task: potato-cannon-pipeline
Arguments: {TICKET_ID} {--resume if resuming}
```

The orchestrator will:
1. Run each stage in sequence
2. Handle approval gates with retries
3. Update STATE.md throughout
4. Report completion or failure

### Step 8: Report Results

When the orchestrator completes, report the final status:

**On Success:**
```markdown
## Pipeline Complete! 🥔💥

Ticket **{TICKET_ID}** has been processed successfully.

### Summary

| Stage | Status | Duration |
|-------|--------|----------|
| ProjectDiscovery | ✅ Complete | {time} |
| BusinessAnalyst | ✅ Complete | {time} |
| Architect | ✅ Complete | {time} |
| DissentingArchitect | ✅ Approved | {time} |
| Engineer | ✅ Complete | {time} |
| QA | ✅ Passed | {time} |

### Implementation Results

- **Files Created:** {N}
- **Files Modified:** {N}
- **Tests Added:** {N}

### Next Steps

1. Review the changes in your editor
2. Run tests manually to verify:
   ```bash
   {test command from project}
   ```
3. Commit and create a PR when satisfied

### State Files

All state preserved at: `.potato/state/{TICKET_ID}/`
```

**On Architecture Rejection (Max Retries):**
```markdown
## Pipeline Paused: Architecture Review

Ticket **{TICKET_ID}** paused after **{N}** architecture review attempts.

### Issue

The Dissenting Architect rejected the architecture {N} times. Human review is needed.

### Review History

| Attempt | Decision | Key Issues |
|---------|----------|------------|
| 1 | REJECTED | {summary} |
| 2 | REJECTED | {summary} |
| 3 | REJECTED | {summary} |

### How to Proceed

1. Review the architecture and feedback:
   - Architecture: `.potato/state/{TICKET_ID}/architecture.md`
   - Feedback: `.potato/state/{TICKET_ID}/architecture-review.md`

2. Options:
   a. Manually fix the architecture.md and resume:
      ```
      /potato-cannon --resume {TICKET_ID}
      ```
   b. Provide guidance and restart architecture:
      ```
      {guidance for manual intervention}
      ```
```

**On QA Failure (Max Retries):**
```markdown
## Pipeline Paused: QA Failure

Ticket **{TICKET_ID}** paused after **{N}** QA failure cycles.

### Issue

The implementation failed QA {N} times. Human intervention is needed.

### Failure History

| Attempt | Issues |
|---------|--------|
| 1 | {summary of failures} |
| 2 | {summary of failures} |
| 3 | {summary of failures} |

### How to Proceed

1. Review the QA report:
   `.potato/state/{TICKET_ID}/qa-report.md`

2. Review the implementation:
   `.potato/state/{TICKET_ID}/implementation-log.md`

3. Options:
   a. Manually fix the code and resume:
      ```
      /potato-cannon --resume {TICKET_ID}
      ```
   b. Start fresh with revised requirements
```

## Error Handling

### Ticket Not Found
```markdown
❌ Ticket not found: {TICKET_ID}

Looked for: .potato/tickets/{TICKET_ID}.md

Available tickets:
- ticket-1.md
- feature-xyz.md
```

### Not Initialized
```markdown
❌ Potato Cannon not initialized

Run `/init-potato-cannon` to set up the scratch space.
```

### Agent Failure
```markdown
❌ Pipeline Error

Stage **{stage}** encountered an error:
{error details}

State saved at: .potato/state/{TICKET_ID}/
You can resume after fixing: `/potato-cannon --resume {TICKET_ID}`
```
