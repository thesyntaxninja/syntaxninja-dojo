---
name: prd-generator
description: Use when a structured PRD document is needed for the ralph loop — generates prd.json, progress.txt, PROMPT.md, and status.json
tags: [process, planning, autonomous]
triggers: [generate PRD, ralph loop setup, training loop artifacts, create prd.json]
chains_to: [ralph-loop]
priority: core
gate: false
---

# PRD Generator

## Quick Reference

Generate the structured artifacts that drive the ralph loop: `prd.json`, `progress.txt`, `PROMPT.md`, and `status.json`. These files are the single source of truth for the autonomous loop.

## When to Use

- Ralph loop has been approved by the user
- Stories have been decomposed via `story-decomposition`
- Artifacts need to be created in `.claude/plugin/ralph/`

## When NOT to Use

- Stories haven't been decomposed yet (do that first)
- User hasn't approved the training loop
- Task doesn't warrant a ralph loop

## Core Process

### Step 1: Create Directory Structure

```bash
mkdir -p .claude/plugin/ralph/notes
```

### Step 2: Generate `prd.json`

From the decomposed stories, create:

```json
{
  "title": "Feature Name",
  "goal": "One-sentence goal from the plan",
  "created": "2026-03-04T00:00:00Z",
  "stories": [
    {
      "id": 1,
      "title": "Story title",
      "goal": "What this delivers",
      "dependencies": [],
      "files": ["src/auth/store.ts", "src/auth/types.ts"],
      "acceptance": [
        "AuthStore exports useAuthStore hook",
        "Login mutation updates user state",
        "Tests pass: npm test -- auth/store"
      ],
      "verification": "npm test -- --grep 'AuthStore'",
      "passes": false
    }
  ],
  "totalStories": 5,
  "completedStories": 0
}
```

Rules:
- Story IDs are sequential integers starting at 1
- Dependencies reference story IDs
- `verification` is a runnable command (exit 0 = pass)
- `passes` starts as `false` for all stories
- `files` lists the expected files to create or modify

### Step 3: Generate `progress.txt`

```
=== Training Loop: Feature Name ===
Goal: One-sentence goal
Stories: 0/5 complete
Started: 2026-03-04

[ ] Story 1: Title
    Files: src/auth/store.ts, src/auth/types.ts
    Verify: npm test -- --grep 'AuthStore'

[ ] Story 2: Title
    Files: ...
    Verify: ...
```

### Step 4: Generate `PROMPT.md`

```markdown
You are continuing a training loop for: **Feature Name**

## Before You Start

Read these files in order:
1. `.claude/plugin/ralph/prd.json` — stories and their status
2. `.claude/plugin/ralph/progress.txt` — human-readable progress
3. `CLAUDE.md` — project conventions (if it exists)

## Your Task

1. Find the FIRST story in `prd.json` where `passes` is `false`
2. Check its `dependencies` — if any dependency has `passes: false`, skip to the next story
3. Implement the story following the acceptance criteria
4. Run the verification command
5. If verification passes:
   - Update `prd.json`: set `passes: true` for this story, increment `completedStories`
   - Update `progress.txt`: mark the story as `[x]`
   - Write implementation notes to `.claude/plugin/ralph/notes/story-<id>.md`
6. If verification fails:
   - Debug the failure (max 3 attempts)
   - If still failing after 3 attempts, write the failure details to notes and move on

## Completion Check

After updating, check: are ALL stories `passes: true`?
- YES → Update `.claude/plugin/ralph/status.json`: set `status` to `"complete"`
- NO → The loop runner will call you again for the next iteration

## Rules

- Implement ONE story per iteration
- Follow project conventions from CLAUDE.md
- Do not modify stories you didn't implement
- Write clear notes — the next iteration has fresh context
```

### Step 5: Generate `status.json`

```json
{
  "status": "ready",
  "iteration": 0,
  "completed_stories": [],
  "started": "2026-03-04T00:00:00Z"
}
```

### Step 6: Verify Artifacts

After generating all files:
- [ ] `prd.json` is valid JSON
- [ ] All story verification commands are syntactically valid
- [ ] Dependencies form a DAG (no cycles)
- [ ] `PROMPT.md` references the correct file paths
- [ ] `.claude/plugin/ralph/` directory exists with all 4 files + `notes/`

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Verification commands that always pass | Stories will be marked done without actual work |
| Missing dependency declarations | Stories will fail because prerequisites aren't met |
| Vague acceptance criteria | The loop can't determine pass/fail |
| PROMPT.md without CLAUDE.md reference | Iterations won't follow project conventions |

## Chaining

REQUIRED: syntaxninja-dojo:ralph-loop (after artifacts are generated)
