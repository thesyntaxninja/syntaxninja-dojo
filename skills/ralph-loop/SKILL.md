---
name: ralph-loop
description: Use when task scope exceeds one context window and decomposes into independent pass/fail stories with clean iteration boundaries
tags: [process, execution, autonomous, loop]
triggers: [large scope, multiple stories, too big for one session, autonomous loop, training loop]
chains_to: [story-decomposition, prd-generator, verification-before-completion]
priority: escalation
gate: false
---

# Ralph Loop (Training Loop)

## Quick Reference

For tasks too large for one context window: decompose into stories, generate loop artifacts, propose the loop to the user, and run autonomously with fresh context per iteration.

## When to Use

ALL of these must be true:
- Scope exceeds one context window
- Work decomposes into independent, verifiable stories
- Each story has pass/fail acceptance criteria
- Clean iteration boundaries exist (one story per iteration)

## When NOT to Use

- Task fits in one session (use `executing-plans`)
- Work can't be decomposed into independent stories
- Stories don't have objective pass/fail criteria
- User prefers manual step-by-step execution

## Core Process

### Step 1: Detection

During `writing-plans`, assess whether the task triggers ralph-loop conditions:

| Signal | Threshold |
|--------|-----------|
| Estimated stories | 4+ independent stories |
| Estimated changes | 500+ lines across 10+ files |
| Context window fit | Plan + implementation won't fit in one session |
| Story independence | Each story is verifiable in isolation |

If ALL signals fire, propose the training loop.

### Step 2: Prepare Artifacts

Generate the following in `.claude/plugin/ralph/`:

**`prd.json`** — the structured PRD:
```json
{
  "title": "Feature Name",
  "goal": "One-sentence goal",
  "stories": [
    {
      "id": 1,
      "title": "Story title",
      "goal": "What this delivers",
      "dependencies": [],
      "files": ["path/to/file.ts"],
      "acceptance": ["Condition 1", "Condition 2"],
      "verification": "npm test -- --grep 'pattern'",
      "passes": false
    }
  ],
  "totalStories": 5,
  "completedStories": 0
}
```

**`progress.txt`** — human-readable progress log:
```
=== Ralph Loop: Feature Name ===
Stories: 0/5 complete

[ ] Story 1: Title
[ ] Story 2: Title
...
```

**`PROMPT.md`** — the prompt fed to each iteration:
```markdown
You are continuing a training loop. Read these files before doing anything:

1. `.claude/plugin/ralph/prd.json` — the full PRD with story status
2. `.claude/plugin/ralph/progress.txt` — current progress
3. `CLAUDE.md` — project conventions

## Your Task

Find the FIRST story in prd.json where `passes` is `false`.
Implement it. Run its verification command. If it passes, update
prd.json (`passes: true`) and progress.txt. If it fails, debug
and retry (max 3 attempts per story). Write notes to
`.claude/plugin/ralph/notes/story-<id>.md`.

If all stories pass, set status to "complete" in status.json.
```

**`status.json`** — loop state:
```json
{
  "status": "ready",
  "iteration": 0,
  "completed_stories": []
}
```

### Step 3: Propose to User

Present the decomposition and ask for approval:

```
This task would benefit from a training loop.

**Stories**: N stories, estimated X iterations
**Approach**: Fresh context per story, git checkpoint between rounds
**Isolation**: Worktree (default) — your branch stays clean

Stories:
1. [Title] — [one-line goal]
2. [Title] — [one-line goal]
...

Approve? I'll set up the artifacts and provide the run command.
```

### Step 4: Run Command

After approval, provide the command:

```bash
# Default: interactive (requires permission approval per iteration)
bash scripts/ralph-loop.sh

# Full automation (opt-in, requires SKIP_PERMISSIONS=true)
SKIP_PERMISSIONS=true bash scripts/ralph-loop.sh

# Custom max iterations
bash scripts/ralph-loop.sh 15
```

The loop runs via `scripts/ralph-loop.sh`, which:
1. Reads `PROMPT.md` and feeds it to `claude --print`
2. Checkpoints via git after each story (configurable)
3. Checks `status.json` and `prd.json` for completion
4. Stops when all stories pass or max iterations reached

### Step 5: Post-Loop

After the loop completes:
1. Review the results in `.claude/plugin/ralph/`
2. Run full project verification
3. If in a worktree, merge back to the main branch
4. Chain to `verification-before-completion`

## Configuration

Set in `dojo.config.md` or `.claude/dojo-config.md`:

```markdown
## Training Loop
- Max rounds: 20
- Checkpoint: per-story          # none | per-iteration | per-story | end-only
- Checkpoint style: squash       # normal | squash
- Run in worktree: true
- Skip permissions: false        # opt-in only
```

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Using ralph-loop for small tasks | Overhead exceeds benefit. Just execute the plan. |
| Stories without verification commands | The loop can't check if stories pass. |
| Dependent stories without explicit ordering | Stories will fail due to missing prerequisites. |
| Skipping user approval | The user must approve the decomposition and the autonomous run. |
| Running without a worktree | Partial failures pollute the main branch. |

## Chaining

REQUIRED: syntaxninja-dojo:story-decomposition (to produce the stories)
OPTIONAL: syntaxninja-dojo:prd-generator (for the PRD document)
REQUIRED: syntaxninja-dojo:verification-before-completion (after loop completes)
