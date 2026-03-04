---
name: using-git-worktrees
description: Use when starting feature work that needs isolation from the current workspace or before executing plans that could leave the branch in a broken state
tags: [git, workflow, isolation]
triggers: [worktree, isolated work, parallel branch, protect main branch, feature isolation]
chains_to: [finishing-a-development-branch]
priority: core
gate: false
---

# Using Git Worktrees

## Quick Reference

When work needs isolation: create a worktree. It gives you a separate working directory on a new branch while keeping the original branch clean. Use for ralph loops, risky refactors, or parallel feature work.

## When to Use

- Ralph loop execution (default: runs in worktree)
- Risky refactors where you want a clean rollback point
- Parallel feature work (two features at once)
- User explicitly asks for a worktree
- Plan execution that might leave things broken mid-way

## When NOT to Use

- Simple changes that won't break the branch
- Quick bug fixes
- Single-file edits
- The user prefers regular branches

## Core Process

### Step 1: Create the Worktree

```bash
# Standard: create under .claude/plugin/worktrees/
git worktree add .claude/plugin/worktrees/<task-slug> -b dojo/<task-slug>

# Example:
git worktree add .claude/plugin/worktrees/add-auth -b dojo/add-auth
```

Naming convention:
- **Path**: `.claude/plugin/worktrees/<task-slug>/`
- **Branch**: `dojo/<task-slug>`
- **Task slug**: lowercase, hyphens, descriptive

### Step 2: Work in the Worktree

Change to the worktree directory and work normally:

```bash
cd .claude/plugin/worktrees/<task-slug>
# ... do the work ...
```

The worktree has its own working directory but shares the git history.

### Step 3: Finish the Work

When the work is complete and verified:

1. Commit all changes in the worktree
2. Chain to `finishing-a-development-branch` for merge/PR decisions
3. Clean up the worktree after merge

### Step 4: Cleanup

```bash
# After merge, remove the worktree
git worktree remove .claude/plugin/worktrees/<task-slug>

# If the worktree is dirty (force remove)
git worktree remove --force .claude/plugin/worktrees/<task-slug>

# Clean up the branch if it was merged
git branch -d dojo/<task-slug>
```

## Worktree Safety

- Always verify the worktree directory exists before working in it
- Never force-remove a worktree with uncommitted changes without user approval
- If the worktree has conflicts, resolve them before removing
- List active worktrees: `git worktree list`

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Creating worktrees for trivial changes | Overhead isn't worth it for small fixes |
| Leaving worktrees around after merging | Clutters the workspace. Clean up. |
| Force-removing dirty worktrees | Loses uncommitted work. Commit first. |
| Forgetting to switch back | After worktree work, return to the original directory |
| Nested worktrees | Don't create worktrees inside worktrees |

## Chaining

REQUIRED: syntaxninja-dojo:finishing-a-development-branch (when work in the worktree is complete)
