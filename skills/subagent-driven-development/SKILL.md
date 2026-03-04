---
name: subagent-driven-development
description: Use when executing an implementation plan with independent tasks that can be delegated to subagents within the current session
tags: [process, execution, parallel, agents]
triggers: [parallel tasks in plan, independent implementation steps, delegate to agents, multiple files same pattern]
chains_to: [verification-before-completion, self-review]
priority: core
gate: false
---

# Subagent-Driven Development

## Quick Reference

When a plan has independent steps, delegate them to subagents. You orchestrate — subagents implement. Merge their work, verify the whole, then proceed.

## When to Use

- An approved plan has steps that are genuinely independent
- Multiple files need similar changes (migrations, refactors)
- Implementation can be parallelized without shared state conflicts
- During `executing-plans` when you identify parallel opportunities

## When NOT to Use

- Steps have dependencies (step 2 needs step 1's output)
- Changes touch the same files (merge conflicts)
- The task is small enough to do sequentially in less time than orchestrating agents
- You're unsure if steps are truly independent (sequential is safer)

## Core Process

### Step 1: Identify Parallel Work

From the plan, find steps that:
- Touch different files
- Have no shared state
- Can be verified independently
- Don't need each other's output

### Step 2: Define Agent Tasks

For each parallel task, create a clear brief:

```
Task: [What to implement]
Files: [Which files to create/modify]
Acceptance: [How to verify success]
Context: [Relevant code patterns, types, APIs to follow]
Constraints: [What NOT to do]
```

Each brief must be self-contained. The agent has no context from your conversation.

### Step 3: Dispatch Agents

Use the Agent tool to launch subagents:
- Use `subagent_type: "general-purpose"` for implementation tasks
- Launch independent agents in a **single message** (parallel execution)
- Set `isolation: "worktree"` when agents modify overlapping areas (rare — prefer non-overlapping splits)

### Step 4: Merge and Verify

After all agents complete:
1. Review each agent's output for quality
2. If agents worked in worktrees, merge their branches
3. Run the full test suite — agents may have introduced conflicts
4. Fix any integration issues yourself

### Step 5: Integration Check

After merging:
- Do the pieces work together?
- Are there naming inconsistencies between agents' work?
- Does the combined output match the plan?

Chain to `verification-before-completion`.

## Splitting Strategies

| Pattern | How to Split |
|---------|-------------|
| Multiple independent components | One agent per component |
| Same change across many files | One agent per file group |
| Feature + tests | Same agent (tests verify the feature) |
| Frontend + backend | One agent each IF the API contract is defined |

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Parallelizing dependent work | Agents will produce inconsistent code |
| Agents editing the same file | Merge conflicts, lost work |
| Vague agent briefs | Garbage in, garbage out |
| No verification after merge | Agents don't know about each other's changes |
| Over-splitting simple work | Orchestration overhead exceeds time saved |
| Trusting agent output blindly | Review before merging. Agents make mistakes. |

## When to Use Worktrees

Use `isolation: "worktree"` when:
- You want to protect the main branch from partial work
- Multiple agents might touch adjacent (not same) files
- The task is large enough that isolation is worth the merge cost

For most subagent work, direct execution without worktrees is simpler.

## Chaining

REQUIRED: syntaxninja-dojo:verification-before-completion (after all agents complete and work is merged)
REQUIRED: syntaxninja-dojo:self-review (after verification passes)
