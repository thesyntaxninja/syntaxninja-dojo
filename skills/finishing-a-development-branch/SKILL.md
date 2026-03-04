---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work — merge, PR, or cleanup
tags: [git, workflow, completion]
triggers: [work complete, ready to merge, create PR, finish branch, integration]
chains_to: [verification-before-completion]
priority: core
gate: false
---

# Finishing a Development Branch

## Quick Reference

When work is done and verified: present the user with integration options (merge, PR, keep branch). Don't auto-merge or auto-push. The user decides.

## When to Use

- Implementation is complete and verified
- All tests pass, sensei review is done
- Work is on a feature branch or worktree
- Ready to integrate into the main branch

## When NOT to Use

- Work is still in progress
- Tests are failing
- Sensei review returned SIMPLIFY_FIRST or RETHINK

## Core Process

### Step 1: Verify Everything

Before presenting options, confirm:
- [ ] All tests pass
- [ ] Build succeeds
- [ ] Sensei review passed (or PASS_WITH_NOTES)
- [ ] No uncommitted changes

### Step 2: Assess the Situation

Check:
```bash
# What branch are we on?
git branch --show-current

# How many commits ahead of main?
git log main..HEAD --oneline

# Any remote tracking?
git remote -v
```

### Step 3: Present Options

Offer the user these choices:

**Option A: Merge to main**
```bash
git checkout main
git merge --no-ff <branch-name> -m "Merge: <description>"
```
Best for: local work, solo projects, small features.

**Option B: Create a PR**
```bash
git push -u origin <branch-name>
gh pr create --title "<title>" --body "<body>"
```
Best for: team projects, changes that need review, anything going to production.

**Option C: Keep the branch**
Leave it as-is. User will handle integration later.
Best for: when the user wants to review more, or is waiting on something.

### Step 4: Execute the Chosen Option

Only proceed with the option the user chose.

For **merge**:
1. Merge the branch
2. Delete the feature branch: `git branch -d <branch-name>`
3. If worktree: `git worktree remove <path>`

For **PR**:
1. Push the branch
2. Create the PR with a clear title and summary
3. Include test plan and any relevant notes

For **keep**:
1. Confirm the branch name and status
2. Remind the user where it is

### Step 5: Cleanup

After merge:
- Delete local feature branch
- Delete remote feature branch (if pushed)
- Remove worktree (if applicable)
- Return to the main branch

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Auto-merging without asking | The user decides when to merge |
| Auto-pushing without asking | Pushing affects shared state |
| Merging with failing tests | Fix tests first |
| Forgetting cleanup | Stale branches and worktrees accumulate |
| Force-pushing | Destroys history. Only with explicit user approval. |

## Chaining

REQUIRED: syntaxninja-dojo:verification-before-completion (must be done before this skill)
