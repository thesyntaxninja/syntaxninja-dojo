---
name: requesting-code-review
description: Use when implementation is complete and a comprehensive code review is needed — dispatches parallel review agents and merges findings
tags: [review, quality, agents]
triggers: [code review, review this, review my code, PR review, request review]
chains_to: [verification-before-completion]
priority: core
gate: false
---

# Requesting Code Review

## Quick Reference

Dispatch parallel review agents against the current diff. Each agent reviews from a different angle. Merge findings, deduplicate, prioritize by severity, and present a unified review.

## When to Use

- Implementation is complete and you want a thorough review
- Before creating a PR
- User explicitly asks for a code review
- After `self-review` when the sensei suggests deeper review

## When NOT to Use

- Trivial changes (< 10 lines) — sensei self-review is sufficient
- The code hasn't been verified yet (run tests first)
- Mid-implementation (review when done, not while building)

## Core Process

### Step 1: Prepare the Diff

Get the diff that will be reviewed:

```bash
# For unstaged changes
git diff

# For staged changes
git diff --staged

# For branch comparison
git diff main...HEAD
```

### Step 2: Select Reviewers

Based on the changes, pick the relevant agents:

| Change Type | Agents to Dispatch |
|------------|-------------------|
| Any code change | simplicity-reviewer (always) |
| New features, refactors | architecture-reviewer + simplicity-reviewer |
| API endpoints, auth, user input | security-reviewer + architecture-reviewer |
| Database queries, hot paths, render loops | performance-reviewer |
| Files matching registered patterns | pattern-reviewer |
| Large changes (100+ lines, 5+ files) | All review agents |

Minimum: **simplicity-reviewer** (always). Maximum: **all 5** (for large changes).

### Step 3: Dispatch in Parallel

Launch selected agents in a **single message** using the Agent tool:

```
Agent 1 (simplicity-reviewer): Review this diff for over-engineering and unnecessary code
Agent 2 (security-reviewer): Review this diff for security vulnerabilities
Agent 3 (pattern-reviewer): Check this diff against registered patterns
```

Each agent prompt should include:
- Brief context: what was implemented and why
- The command to get the diff (or paste the diff if small)
- Any project-specific concerns

### Step 4: Merge Findings

After all agents return:

1. **Collect** all findings from all agents
2. **Deduplicate** — multiple agents may flag the same issue
3. **Prioritize** by severity (P1 > P2 > P3)
4. **Group** by file for readability

### Step 5: Present Unified Review

```
CODE REVIEW: <one-line summary>

P1 (must fix before merge):
- file:line — [reviewer] — [finding + fix]

P2 (should fix):
- file:line — [reviewer] — [finding + fix]

P3 (nice to have):
- file:line — [reviewer] — [finding]

Reviewers: simplicity, security, pattern (3 dispatched)
```

### Step 6: Act on Findings

- **P1 findings**: Fix before proceeding. These block merge.
- **P2 findings**: Fix unless the user explicitly defers them.
- **P3 findings**: Present to user. Fix if quick, otherwise note for later.

After fixes, re-run verification → chain to `verification-before-completion`.

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Reviewing before tests pass | Fix functional issues first, then review quality |
| Dispatching all 5 agents for a 10-line change | Overkill. Sensei self-review is sufficient. |
| Ignoring P1 findings | P1 means "must fix." No exceptions. |
| Running agents sequentially | Dispatch in parallel. It's faster. |
| Not deduplicating findings | Presenting the same issue 3 times wastes the user's time. |

## Chaining

REQUIRED: syntaxninja-dojo:verification-before-completion (after fixes are applied)
