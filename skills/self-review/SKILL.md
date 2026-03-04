---
name: self-review
description: Use when implementation is complete and verification has passed — dispatches the sensei agent for fresh-context quality review
tags: [gate, review, quality]
triggers: [implementation complete, verification passed, before commit, before PR]
chains_to: [compound-docs]
priority: gate
gate: true
---

# Self-Review

## Quick Reference

After implementation + verification, dispatch the sensei for a fresh-context review of the actual `git diff`. The sensei has no memory of writing the code — pure quality signal.

## When to Use

- After `verification-before-completion` passes
- Before committing or creating a PR
- After any non-trivial implementation (>5 lines changed)

## When NOT to Use

- Single-line typo fixes
- Comment-only changes
- Changes the user explicitly marked as "skip review"

## Core Process

### Step 1: Check the diff

Run `git diff` (or `git diff --staged` if changes are staged) to see what changed. If the diff is empty, nothing to review.

### Step 2: Assess review level

| Change Size | Action |
|-------------|--------|
| < 20 lines, single file | Quick inline self-check (no agent needed) |
| 20-100 lines | Dispatch sensei at configured strictness |
| > 100 lines or 3+ files | Dispatch sensei at MEDIUM minimum |

### Step 3: Quick self-check (small changes)

For changes under 20 lines, ask yourself:
- Does this introduce any obvious issues?
- Is there dead code, debug prints, or TODOs?
- Does it match the project's existing patterns?

If all clear, proceed.

### Step 4: Dispatch the sensei (larger changes)

Use the Agent tool to dispatch the sensei review agent:

```
Agent: review/sensei
Task: Review the following git diff for quality, simplicity, and pattern compliance.
Context: [brief description of what was implemented and why]
```

The sensei reviews the actual diff and returns:
- REMOVE: things to delete
- SIMPLIFY: things to make simpler
- PATTERN MISMATCH: pattern violations by severity
- VERDICT: PASS | SIMPLIFY_FIRST | RETHINK

### Step 5: Act on sensei feedback

| Verdict | Action |
|---------|--------|
| PASS | Proceed to commit/PR |
| PASS_WITH_NOTES | Proceed to commit/PR. Show advisory notes to user for awareness. No simplification loop. |
| SIMPLIFY_FIRST | Apply simplifications, re-verify, re-review (max 2 rounds) |
| RETHINK | Discuss with user before proceeding |

### Simplification Loop

```
Round 1: Sensei review → Apply fixes → Re-verify
Round 2: Sensei review → Apply fixes → Done (show remaining items to user)
```

Maximum 2 simplification rounds. After round 2, show any remaining items to the user and proceed.

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Skipping review for "obvious" changes | Obvious changes often have subtle bugs |
| Reviewing from memory instead of the diff | Memory is biased. The diff is truth. |
| Infinite polish loops | 2 rounds max. Ship it. |
| Ignoring sensei feedback because "it works" | Working != good. Quality matters. |

## Chaining

OPTIONAL: syntaxninja-dojo:compound-docs (when a hard problem was solved)
