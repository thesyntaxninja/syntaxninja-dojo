---
name: story-decomposition
description: Use when a large task needs to be broken into independent, verifiable stories with pass/fail acceptance criteria
tags: [process, planning, decomposition]
triggers: [large task, too big for one session, decompose, break into stories, multiple stories]
chains_to: [ralph-loop, prd-generator]
priority: core
gate: false
---

# Story Decomposition

## Quick Reference

Break a large task into independent stories. Each story must be completable in one context window, have pass/fail acceptance criteria, and be verifiable in isolation.

## When to Use

- Task is too large for one context window
- `writing-plans` identified the need for decomposition
- Ralph loop escalation is being prepared
- User asks to break work into stories or chunks

## When NOT to Use

- Task fits in one session (just use `executing-plans`)
- Task can't be decomposed into independent pieces
- Exploratory work with no clear deliverables

## Core Process

### Step 1: Understand the Full Scope

Before decomposing:
1. Read the plan or requirements thoroughly
2. Identify all deliverables
3. Map dependencies between pieces of work
4. Identify the critical path

### Step 2: Identify Story Boundaries

Good stories have these properties:
- **Independent**: Can be implemented without other stories being done first (or with minimal, explicit dependencies)
- **Verifiable**: Has a concrete test or check that proves it works
- **Small enough**: Completable in one context window (~one focused session)
- **Valuable alone**: Delivers something useful even if other stories aren't done yet

### Step 3: Write Stories

Each story follows this format:

```markdown
## Story N: <Title>

**Goal**: [One sentence — what this delivers]

**Dependencies**: [Story numbers that must complete first, or "none"]

**Files**:
- `path/to/file.ts` — [what changes]

**Acceptance Criteria**:
- [ ] [Concrete, verifiable condition]
- [ ] [Another condition]

**Verification Command**:
```bash
# The exact command(s) to prove this story passes
npm test -- --grep "story-related-tests"
```
```

### Step 4: Order Stories

1. Foundation stories first (types, interfaces, schemas)
2. Core logic second (business rules, data layer)
3. Integration third (wiring pieces together)
4. Polish last (error handling, edge cases, UI refinement)

Stories with no dependencies can run in any order.

### Step 5: Validate the Decomposition

Check:
- [ ] Every deliverable from the original plan is covered by at least one story
- [ ] No story is too large (>200 lines of changes is a red flag)
- [ ] Dependencies form a DAG (no circular dependencies)
- [ ] Each story's acceptance criteria are objectively pass/fail
- [ ] The verification command actually tests what the story claims

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Stories that depend on everything | Not independent. Reorder or merge. |
| "And then do the rest" as a story | Not decomposed. Break it down further. |
| Acceptance criteria like "works correctly" | Not verifiable. What does "correctly" mean? |
| Stories without verification commands | How does the loop know it passed? |
| 20+ stories for a medium task | Over-decomposed. Merge related work. |
| Stories that touch the same files | Will cause conflicts in parallel execution. |

## Chaining

REQUIRED: syntaxninja-dojo:ralph-loop (when stories feed into a training loop)
OPTIONAL: syntaxninja-dojo:prd-generator (to produce the formal PRD document)
