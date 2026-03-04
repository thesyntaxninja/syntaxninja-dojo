---
name: compound-docs
description: Use when a hard problem was just solved and the solution should be captured as a learning for future reference
tags: [knowledge, documentation, learning]
triggers: [that worked, figured it out, the issue was, hard problem solved, lesson learned, tricky bug fixed]
chains_to: [propose-skill-update]
priority: core
gate: false
---

# Compound Docs (Lessons Learned)

## Quick Reference

After solving a hard problem, propose capturing the solution as a learning. The user approves before anything is written. Learnings compound — the next time this problem appears, the solution is already documented.

## When to Use

- A non-obvious bug was debugged and fixed
- A workaround was needed for a library/framework limitation
- An integration required trial and error to get right
- A configuration or setup issue took significant effort
- The user says something like "that was tricky" or "finally figured it out"

## When NOT to Use

- Routine work with no novel insights
- The solution is obvious from the docs
- The user explicitly declines to capture it

## Core Process

### Step 1: Detect the Trigger

After solving a hard problem, propose the learning:

> "That was a non-trivial fix. Want me to capture this as a lesson learned? It'll help if this comes up again."

If the user says no, move on. No insistence.

### Step 2: Write the Learning

Create a file at `docs/learnings/<category>/<filename>.md`:

```markdown
---
date: YYYY-MM-DD
category: <category>
tags: [tag1, tag2]
---

# <Title: What the Problem Was>

## Problem
[1-3 sentences: what went wrong and how it manifested]

## Root Cause
[1-3 sentences: why it happened]

## Solution
[The fix, with code if relevant]

## Key Insight
[One sentence: the non-obvious thing that made this hard]

## References
- [Link or file:line if relevant]
```

### Categories

Use these categories (create new ones only if none fit):

| Category | When |
|----------|------|
| `debugging` | Bug fixes, error resolution |
| `configuration` | Setup, environment, tooling issues |
| `integration` | API, library, service integration |
| `performance` | Optimization insights |
| `architecture` | Structural decisions and their outcomes |
| `testing` | Test strategy, mocking, fixtures |
| `deployment` | Build, deploy, CI/CD issues |

### Step 3: Present for Approval

Show the proposed learning to the user. They approve before it's written to disk.

Keep the proposal concise — the learning file has the details.

### Step 4: Consider Skill Updates

If you've captured 3+ learnings about the same topic, chain to `propose-skill-update` — there might be a pattern worth codifying.

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Capturing everything | Not every fix is worth documenting. Only non-obvious ones. |
| Writing without user approval | The user decides what's worth keeping. |
| Long, essay-style learnings | Keep it scannable. Problem → Root Cause → Solution → Insight. |
| Duplicating existing learnings | Check `docs/learnings/` first. Update if it already exists. |
| Capturing the "what" without the "why" | The root cause and key insight are the valuable parts. |

## Chaining

OPTIONAL: syntaxninja-dojo:propose-skill-update (when 3+ learnings suggest a pattern)
