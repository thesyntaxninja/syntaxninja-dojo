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

For tasks too large for one context window: decompose into stories, generate prd.json, activate the Stop hook loop, and iterate inside the current session until all stories pass.

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

## How It Works

The ralph loop uses Claude Code's Stop hook to keep the session alive:

1. Claude writes `.claude/ralph-loop.local.md` (state file with loop prompt)
2. Claude works on the first story in prd.json
3. When the session tries to end, the Stop hook fires
4. The hook reads prd.json — if all stories pass, it allows exit
5. Otherwise, it re-injects the prompt and Claude continues with the next story
6. No external scripts, no subprocess — the same interactive session continues

This is fully automatic. The planning chain activates it when scope demands it.

## Core Process

### Step 1: Detection

During `writing-plans`, assess whether the task triggers ralph-loop conditions:

| Signal | Threshold |
|--------|-----------|
| Estimated stories | 4+ independent stories |
| Estimated changes | 500+ lines across 10+ files |
| Context window fit | Plan + implementation won't fit in one session |
| Story independence | Each story is verifiable in isolation |

If ALL signals fire, propose the training loop to the user.

### Step 2: Prepare Artifacts

Chain to `story-decomposition` then `prd-generator`. This generates in `.claude/plugin/ralph/`:

- **`prd.json`** — stories with `passes: false` initially
- **`progress.txt`** — human-readable progress log
- **`notes/`** — per-story implementation notes (written during iterations)

### Step 3: Propose to User

Present the decomposition and ask for approval before activating:

```
This task would benefit from a ralph loop.

**Stories**: N stories, max 20 iterations
**Mechanism**: Stop hook — runs inside this session, fully interactive
**Completion**: Automatic when all prd.json stories pass

Stories:
1. [Title] — [one-line goal]
2. [Title] — [one-line goal]
...

Ready to start? I'll activate the loop now.
```

**Do not activate without user approval.**

### Step 4: Activate the Loop

After approval, write the state file `.claude/ralph-loop.local.md`:

```markdown
---
active: true
iteration: 1
session_id: <CLAUDE_CODE_SESSION_ID>
max_iterations: 20
prd_path: .claude/plugin/ralph/prd.json
started_at: "<current ISO 8601 timestamp>"
---

Read .claude/plugin/ralph/prd.json. Find the first story where passes is false.
Check its dependencies are met (all dependency story IDs must have passes: true).
Implement the story following its acceptance criteria. Run the verification
command. If it passes, update prd.json (set passes: true, increment
completedStories) and progress.txt (mark [x]). Write implementation notes to
.claude/plugin/ralph/notes/story-<id>.md. One story per iteration.

If you are stuck on a story after 3 attempts, or blocked on something requiring
human input, delete .claude/ralph-loop.local.md and explain what happened.
```

Write this file using the Write tool. The `session_id` should be read from the `CLAUDE_CODE_SESSION_ID` environment variable via Bash. The `max_iterations` defaults to 20 but can be adjusted based on story count or user preference.

Then immediately begin working on the first story.

### Step 5: Per-Iteration Behavior

Each iteration (after the Stop hook re-injects the prompt):

1. **Read prd.json** — find the first story where `passes` is `false`
2. **Check dependencies** — if a dependency story has `passes: false`, skip to the next eligible story
3. **Implement** — follow the story's acceptance criteria
4. **Verify** — run the story's verification command
5. **Update on success**:
   - Set `passes: true` in prd.json for this story
   - Increment `completedStories` in prd.json
   - Mark `[x]` in progress.txt
   - Write notes to `notes/story-<id>.md`
6. **On failure** — debug (max 3 attempts per story), then note the failure and move on

**ONE story per iteration.** Do not attempt multiple stories in one pass.

### Step 6: Self-Exit Rules

Claude MUST delete `.claude/ralph-loop.local.md` and stop when:

- **Stuck**: Same story has failed 3+ consecutive attempts with no progress
- **Blocked**: Something requires human input or a decision Claude can't make
- **Error**: An unresolvable error prevents further work
- **User request**: User explicitly asks to stop

When self-exiting, explain:
- Which story is blocked and why
- What was attempted
- What the user needs to do to unblock

### Step 7: Post-Loop

After the loop ends (all stories pass, self-exit, or max iterations):
1. Review notes in `.claude/plugin/ralph/notes/`
2. Summarize what was completed and what remains
3. Run full project verification
4. Chain to `verification-before-completion`

## Three Exit Paths

| Exit | Trigger | Who |
|------|---------|-----|
| All stories pass | prd.json check in Stop hook | Automatic |
| Claude bails out | Claude deletes state file | Agent |
| Safety net | max_iterations reached | Automatic |

## Monitoring

During the loop:
```bash
# Current iteration
grep '^iteration:' .claude/ralph-loop.local.md

# Story status
jq '.stories[] | {title, passes}' .claude/plugin/ralph/prd.json

# Progress
cat .claude/plugin/ralph/progress.txt
```

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Using ralph-loop for small tasks | Overhead exceeds benefit. Just execute the plan. |
| Stories without verification commands | The loop can't check if stories pass. |
| Attempting multiple stories per iteration | Context overflow; defeats the loop's purpose. |
| Skipping user approval | The user must approve the decomposition before activation. |
| Ignoring self-exit rules | Leads to infinite loops. Delete the state file when stuck. |
| Running without a worktree on sensitive branches | Partial failures pollute the branch. |

## Chaining

REQUIRED: syntaxninja-dojo:story-decomposition (to produce the stories)
OPTIONAL: syntaxninja-dojo:prd-generator (for the PRD document)
REQUIRED: syntaxninja-dojo:verification-before-completion (after loop completes)
