---
name: create-potato-task
description: Create a new ticket for the Potato Cannon pipeline from a text description.
user_invocable: true
tools: Read, Write, Bash, Glob
---

# Create Potato Task

Create a new ticket for the Potato Cannon pipeline from a text description.

## Usage

```
/create-potato-task {description}
```

### Arguments

- `{description}` - A text description of what you want the ticket to accomplish

### Examples

```
/create-potato-task Add a dark mode toggle to the settings page that persists user preference
/create-potato-task Fix the login form validation to show inline errors instead of alerts
/create-potato-task Refactor the API client to use axios instead of fetch
```

## Execution

### Step 1: Validate Setup

Check that Potato Cannon is initialized:

```bash
ls .potato/tickets 2>/dev/null
```

If not found:
```markdown
❌ Potato Cannon not initialized in this project.

Run `/init-potato-cannon` first to set up the scratch space.
```

### Step 2: Parse Description

The description comes from `$ARGUMENTS`. This is the user's guidance on what the ticket should accomplish.

### Step 3: Generate Ticket ID

Create a ticket ID based on the description:

1. Take the first few significant words from the description
2. Convert to lowercase kebab-case
3. Ensure uniqueness by checking existing tickets

For example:
- "Add a dark mode toggle" → `add-dark-mode-toggle`
- "Fix login validation" → `fix-login-validation`
- "Refactor API client" → `refactor-api-client`

Check for conflicts:
```bash
ls .potato/tickets/{proposed-id}.md 2>/dev/null
```

If exists, append a number: `add-dark-mode-toggle-2`

### Step 4: Analyze and Expand Description

Based on the user's description, intelligently expand it into a well-structured ticket:

1. **Infer the title** - A clear, concise title summarizing the work
2. **Expand the description** - Add relevant context and clarifications based on:
   - What the feature/fix likely involves
   - Common considerations for this type of work
   - Any implicit requirements
3. **Generate acceptance criteria** - Create specific, testable criteria:
   - Core functionality requirements
   - Edge cases to consider
   - Any UX/DX considerations
4. **Add context notes** - Any relevant technical considerations

### Step 5: Write the Ticket

Create the ticket file at `.potato/tickets/{ticket-id}.md`:

```markdown
# Ticket: {ticket-id}

## Title

{Clear, concise title derived from description}

## Description

{Expanded description based on user input}

**Original request:** {user's original description}

{Additional context and considerations you've inferred}

## Acceptance Criteria

- [ ] {Primary criterion 1}
- [ ] {Primary criterion 2}
- [ ] {Primary criterion 3}
- [ ] {Additional relevant criteria...}

## Additional Context

{Technical considerations, related patterns, or implementation notes}

---

*Generated from: `{original description}`*
```

### Step 6: Report Success

```markdown
## Ticket Created! 🎫

**Ticket ID:** {ticket-id}
**File:** `.potato/tickets/{ticket-id}.md`

### Summary

{Brief summary of what was captured in the ticket}

### Next Steps

1. **Review the ticket** to ensure it captures your intent:
   ```bash
   cat .potato/tickets/{ticket-id}.md
   ```

2. **Edit if needed** - Feel free to refine the ticket before processing

3. **Process the ticket** when ready:
   ```
   /potato-cannon {ticket-id}
   ```

### Quick Actions

- View ticket: `cat .potato/tickets/{ticket-id}.md`
- Edit ticket: Open `.potato/tickets/{ticket-id}.md` in your editor
- Process now: `/potato-cannon {ticket-id}`
```

## Error Handling

### No Description Provided

If `$ARGUMENTS` is empty:
```markdown
❌ No description provided

Usage: `/create-potato-task {description}`

Example: `/create-potato-task Add user authentication with OAuth support`
```

### Not Initialized

```markdown
❌ Potato Cannon not initialized

Run `/init-potato-cannon` first to set up the scratch space.
```

## Expansion Guidelines

When expanding the user's description, consider:

1. **For feature requests:**
   - What UI changes might be needed?
   - What state management is involved?
   - Are there API changes needed?
   - What about error handling?
   - Accessibility considerations?

2. **For bug fixes:**
   - What is the expected vs actual behavior?
   - What are the reproduction steps?
   - What's the root cause hypothesis?
   - How to verify the fix?

3. **For refactoring:**
   - What's the current state?
   - What's the target state?
   - What are the migration steps?
   - How to ensure no regressions?

4. **General considerations:**
   - Testing requirements
   - Documentation needs
   - Performance implications
   - Security considerations
