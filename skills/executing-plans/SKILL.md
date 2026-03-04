---
name: executing-plans
description: Use when an approved plan exists and implementation should begin — executes steps sequentially with verification checkpoints
tags: [process, execution, implementation]
triggers: [approved plan, start implementing, execute plan, begin work, plan approved]
chains_to: [verification-before-completion, self-review, subagent-driven-development]
priority: core
gate: false
---

# Executing Plans

## Quick Reference

With an approved plan: execute step by step. Verify each step before moving to the next. If anything changes, pause and re-scope with the user. Ship working increments, not a big bang.

## When to Use

- An approved plan exists (from `writing-plans`)
- User has given explicit steps to follow
- Resuming work on a partially-completed plan

## When NOT to Use

- No plan exists yet (go to `writing-plans` first)
- The task is small enough to do without a plan
- The plan needs revision (go back to `writing-plans`)

## Core Process

### Step 1: Load the Plan

Read the plan file. Identify:
- Which steps are already done (check git history or markers)
- Which step is next
- Any blockers or dependencies

### Step 2: Execute Step by Step

For each step:

1. **Announce**: Brief one-line status: "Working on step N: [name]"
2. **Implement**: Make the changes described in the step
3. **Verify**: Run the step's acceptance criteria
4. **Checkpoint**: If verification passes, move to the next step

If the step's acceptance criteria fail:
- Debug using `systematic-debugging` principles (reproduce, isolate, fix)
- Do NOT skip to the next step

### Step 3: Parallel Opportunities

While executing, look for steps that can run in parallel:
- Independent steps with no shared state → use `dispatching-parallel-agents`
- Multiple files with similar changes → use `subagent-driven-development`

Only parallelize when steps are genuinely independent. When in doubt, run sequentially.

### Step 4: Scope Changes

If during execution you discover:
- A step is more complex than planned → pause, re-scope with the user
- A new step is needed → add it, inform the user
- A step is unnecessary → skip it, inform the user
- The plan is fundamentally wrong → stop, discuss with the user

**Never silently deviate from the plan.** The user approved a specific plan. Changes need acknowledgment.

### Step 5: Completion

After all steps pass:
1. Run full project verification (build, lint, test)
2. Chain to `verification-before-completion`
3. Chain to `self-review`

## Progress Tracking

Update the plan file as you go:
- Mark completed steps with `[x]` or a "DONE" note
- Note any deviations or discoveries
- Keep the plan as a living document during execution

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Implementing all steps then verifying at the end | Errors compound. Verify as you go. |
| Silently adding scope during execution | The user approved X, not X + Y. |
| Skipping verification for "easy" steps | Easy steps fail too. |
| Abandoning the plan midway | If the plan is wrong, revise it — don't wing it. |
| Not announcing progress | The user should know where you are. |
| Big-bang implementation | Working increments are debuggable. Monoliths aren't. |

## Chaining

REQUIRED: syntaxninja-dojo:verification-before-completion (after all steps complete)
REQUIRED: syntaxninja-dojo:self-review (after verification passes)
OPTIONAL: syntaxninja-dojo:subagent-driven-development (for parallelizable steps)
OPTIONAL: syntaxninja-dojo:dispatching-parallel-agents (for independent steps)
