---
name: init-potato-cannon
description: Initialize the Potato Cannon scratch space in a project. Creates .potato/ directory structure and updates .gitignore.
user_invocable: true
tools: Read, Write, Bash, Glob
---

# Initialize Potato Cannon

This command sets up the Potato Cannon scratch space in the current project.

## What It Does

1. Creates the `.potato/` directory structure
2. Updates `.gitignore` to exclude scratch space
3. Creates a sample ticket template
4. Provides instructions for creating tickets

## Usage

```
/init-potato-cannon
```

No arguments required.

## Execution

### Step 1: Check if Already Initialized

```bash
ls .potato/tickets 2>/dev/null
```

If exists, inform user and offer to skip or reinitialize.

### Step 2: Create Directory Structure

Create the following directories:

```
.claude/
└── scratch/
    ├── tickets/
    └── state/
```

```bash
mkdir -p .potato/tickets
mkdir -p .potato/state
```

### Step 3: Update .gitignore

Check if `.gitignore` exists and whether it already ignores scratch:

```bash
grep -q ".claude/scratch" .gitignore 2>/dev/null
```

If not found, append to `.gitignore`:

```
# Potato Cannon scratch space
.potato/
```

If `.gitignore` doesn't exist, create it with:

```
# Potato Cannon scratch space
.potato/
```

### Step 4: Create Sample Ticket Template

Write a template file to help users create tickets:

**File:** `.potato/tickets/_TEMPLATE.md`

```markdown
# Ticket: {TICKET-ID}

## Title

{Short descriptive title for this work}

## Description

{Detailed description of what needs to be done. Be specific about:
- What the current behavior is (if applicable)
- What the desired behavior is
- Any context that would help understand the request}

## Acceptance Criteria

{Optional but recommended - specific criteria that define "done"}

- [ ] {Criterion 1}
- [ ] {Criterion 2}
- [ ] {Criterion 3}

## Additional Context

{Optional - any extra information, links, screenshots, etc.}

---

**Usage:**
1. Copy this template to a new file: `{ticket-id}.md`
2. Fill in the sections above
3. Run `/potato-cannon {ticket-id}` to process
```

### Step 5: Create Example Ticket

Write an example ticket to show the format:

**File:** `.potato/tickets/example-001.md`

```markdown
# Ticket: example-001

## Title

Add dark mode toggle to settings page

## Description

Users have requested the ability to switch between light and dark themes. We should add a toggle to the settings page that allows users to choose their preferred theme.

The toggle should:
- Default to system preference on first visit
- Remember the user's choice across sessions
- Apply immediately without page refresh

## Acceptance Criteria

- [ ] Toggle component added to Settings page
- [ ] Three options: Light, Dark, System
- [ ] Preference persisted to localStorage
- [ ] Theme applies immediately on toggle
- [ ] System preference detected on first visit
- [ ] Theme persists across browser sessions

## Additional Context

- Similar feature exists in our mobile app
- Should use the existing Switch component from our UI library
- Design mockups: {link would go here}

---

*This is an example ticket. Delete or modify it as needed.*
```

### Step 6: Report Success

Output a success message:

```markdown
## Potato Cannon Initialized! 🥔💥

Created:
- `.potato/tickets/` - Place your tickets here
- `.potato/state/` - Pipeline state will be stored here
- `.gitignore` - Updated to exclude scratch space

### Getting Started

1. **Create a ticket:**
   ```bash
   cp .potato/tickets/_TEMPLATE.md .potato/tickets/my-feature.md
   # Edit my-feature.md with your requirements
   ```

2. **Process a ticket:**
   ```
   /potato-cannon my-feature
   ```

3. **Check progress:**
   Look in `.potato/state/{ticket-id}/STATE.md`

### Example Ticket

An example ticket has been created at:
`.potato/tickets/example-001.md`

Feel free to process it with `/potato-cannon example-001` to see the pipeline in action, or delete it and create your own.

### Ticket Format

```markdown
# Ticket: {ticket-id}

## Title
{Short title}

## Description
{What needs to be done}

## Acceptance Criteria
- [ ] {Criterion 1}
- [ ] {Criterion 2}

## Additional Context
{Optional extra info}
```

Happy shipping! 🚀
```

## Error Handling

### Git Not Initialized

If project isn't a git repo, warn but continue:

```markdown
⚠️ Note: This directory is not a git repository.
The .gitignore will be created but won't have any effect until you initialize git.
```

### Permission Errors

If unable to create directories or files:

```markdown
❌ Error: Unable to create directory .potato/
Check that you have write permissions in this directory.
```

### Already Initialized

If scratch space already exists:

```markdown
Potato Cannon scratch space already exists.

Existing structure:
- .potato/tickets/ ({N} tickets)
- .potato/state/ ({N} states)

Would you like to:
1. Keep existing setup (no changes)
2. Reinitialize (preserves existing tickets and state)
```
