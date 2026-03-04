---
name: prd-generator
description: Use when a structured PRD document is needed for the ralph loop — generates prd.json and progress.txt
tags: [process, planning, autonomous]
triggers: [generate PRD, ralph loop setup, training loop artifacts, create prd.json]
chains_to: [ralph-loop]
priority: core
gate: false
---

# PRD Generator

## Quick Reference

Generate the structured artifacts that drive the ralph loop: `prd.json` and `progress.txt`. The loop prompt lives in `.claude/ralph-loop.local.md` (written by the ralph-loop skill), not in a separate PROMPT.md file.

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

### Step 4: Verify Artifacts

After generating all files:
- [ ] `prd.json` is valid JSON
- [ ] All story verification commands are syntactically valid
- [ ] Dependencies form a DAG (no cycles)
- [ ] `.claude/plugin/ralph/` directory exists with `prd.json`, `progress.txt`, and `notes/`

Note: `PROMPT.md` and `status.json` are no longer generated. The loop prompt lives in
`.claude/ralph-loop.local.md` (created by the ralph-loop skill when it activates the
Stop hook). Completion is detected by the Stop hook reading `prd.json` directly.

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Verification commands that always pass | Stories will be marked done without actual work |
| Missing dependency declarations | Stories will fail because prerequisites aren't met |
| Vague acceptance criteria | The loop can't determine pass/fail |
| PROMPT.md without CLAUDE.md reference | Iterations won't follow project conventions |

## Chaining

REQUIRED: syntaxninja-dojo:ralph-loop (after artifacts are generated)
