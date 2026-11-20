---
name: self-review
description: >-
  This skill should be used when the user asks to "self review", "review and
  plan fixes", "run my review", "review then plan", or invokes /self-review.
  Runs tux-code-review, runs ponytail-review alongside the simplify agent,
  merges those findings, reports the full summary, then writes a plan to fix
  every issue. Does not edit code.
---

# Self-review

Personal branch review: full tux parallel roster, ponytail over-engineering pass
in the same launch turn as simplify, merged simplification findings, mandatory
tux summary (both findings tables), optional PR post-offer, then a fix plan.
No code edits in this workflow.

## Prerequisites

- Skill `tux-review-workflows:tux-code-review` (tux-plugins `tux-review-workflows`)
- Skill `ponytail-review` (user or synced install)
- Skill `tux-review-workflows:tux-simplify-review` (via roster; do not run standalone)

## Workflow

### 1. Run tux-code-review

Follow skill `tux-review-workflows:tux-code-review` from base detection through
specialist launch. Requirements:

- Launch every reviewer with `enabled: true` in the roster — never substitute a
  single-pass review.
- Include **simplify** (`subagent_type: code-simplifier`, skill
  `tux-review-workflows:tux-simplify-review`, report `simplify-review.md`).
- If tux stops for an empty committed diff (or no committed changes to review),
  **stop immediately** — no ponytail pass, no summary, no fix plan.

### 2. Launch ponytail-review in the same turn

In the **same** parallel-agent message as the roster launches, add one extra
agent that follows skill `ponytail-review` on the committed range only:

| Input | Value |
|-------|-------|
| Diff | `git diff {merge_base} {head_sha}` (full, untruncated) |
| Output | `.tux/code-reviews/{branch}/ponytail-review.md` |

Same dirty-tree rules as tux: warn when uncommitted paths exist; do not review
working-tree diffs. Do not skip ponytail when the committed diff is non-empty.

### 3. Consolidate tux findings

After all specialists (including ponytail) finish, run tux steps 5–5 from
`tux-code-review`:

1. Read every expected roster report file plus `ponytail-review.md`.
2. Normalize → proximity consolidate → semantic merge per tux scripts into
   `consolidated.json`.

### 4. Merge ponytail into simplify before the summary

Fold `ponytail-review.md` into simplification findings **before** building the
summary tables. Ponytail stays complexity-only — never reclassify correctness,
security, architecture, or performance roster items.

| Case | Action |
|------|--------|
| Same file, same lines, same cut as a simplify item | One finding; keep the more specific replacement text |
| Ponytail-only cut (no matching simplify item) | Add to simplify/complexity presentation; tag source `ponytail` |
| Simplify item with no ponytail overlap | Keep unchanged |
| Non-simplify tux findings | Untouched |

When ponytail adds rows not yet in `consolidated.json`, append them with stable
IDs and include `ponytail` in **Sources**. When deduplicating, prefer the entry
with a cited repo precedent or concrete replacement.

### 5. Present full review summary

Build the user-facing summary from post-merge `consolidated.json` using
`${CLAUDE_PLUGIN_ROOT}/references/tux-code-review-summary.md`:

- **Both** tables are mandatory: **Findings Summary** and **Findings**.
- Include **Items Requiring Attention** and **Overall Assessment**.
- List ponytail in **Reviewers Run** (e.g. `…, Simplify, Ponytail`).
- Run `find-open-pr.sh` before presenting; include **Open PR** per tux rules.
- Offer PR comment posting per tux step 6 — never post without explicit approval.

### 6. Write fix plan

After the summary (and post-offer when applicable), produce a fix plan for
**every** finding still in the consolidated summary:

- One bullet per finding ID: location, severity, concrete change.
- Order: Critical/High first, then Medium, then Low.
- Group related IDs when one change addresses multiple findings.
- Use host plan mode when available (`SwitchMode` / plan tools).
- **Stop after the plan** — do not implement fixes in this turn unless the user
  explicitly asks in a follow-up message.

## Rules

- Never skip the full tux roster to save time.
- Never run ponytail instead of simplify — both run; merge their outputs.
- Never edit application code during self-review (summary + plan only).
- Never truncate diffs passed to ponytail or roster specialists.
- Never post PR comments without explicit user approval.

## Common mistakes

| Mistake | Fix |
|---------|-----|
| Ponytail in a second turn after roster | Launch ponytail in the same parallel message as roster |
| Summary before merge | Merge ponytail into simplify/complexity findings first |
| Ponytail overrides security bugs | Ponytail only adds or dedupes complexity findings |
| Implement fixes in the same turn | Deliver summary + fix plan; code changes wait for user |
