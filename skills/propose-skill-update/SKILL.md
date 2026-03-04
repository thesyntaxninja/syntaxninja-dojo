---
name: propose-skill-update
description: Use when 3+ distinct occurrences suggest a skill should be updated with a new trigger, anti-pattern, or verification step
tags: [knowledge, meta, improvement]
triggers: [skill improvement, recurring pattern, update skill, skill refinement, 3 occurrences]
chains_to: []
priority: core
gate: false
---

# Propose Skill Update

## Quick Reference

When you observe 3+ distinct occurrences of a pattern, propose a skill update. Only specific additions are allowed. Core process rewrites are never allowed. The user approves before any change.

## When to Use

- You've seen the same trigger condition 3+ times that isn't in a skill
- You've seen the same anti-pattern 3+ times that isn't documented
- A verification step was needed 3+ times that isn't in the checklist
- `compound-docs` has captured 3+ learnings about the same topic

## When NOT to Use

- Fewer than 3 distinct occurrences (one-offs aren't patterns)
- The update would rewrite a skill's core process
- The update adds project-specific details to a general skill
- You're unsure — wait for more evidence

## The Ratchet: What's Allowed

| Allowed | Must Cite 3+ Occurrences |
|---------|--------------------------|
| New trigger condition | "I've seen this trigger 3 times: [evidence]" |
| New anti-pattern | "This mistake has happened 3 times: [evidence]" |
| New verification step | "This check was needed 3 times: [evidence]" |

| Never Allowed | Reason |
|---------------|--------|
| Rewriting core process | Core processes are stable — propose a new skill instead |
| Removing steps | Removal requires explicit user decision, not automated ratchet |
| Adding project-specific details | Skills are general. Use `dojo.config.md` for project specifics. |
| Changing skill priority/gate status | Architecture decision, not an automated update |

## Core Process

### Step 1: Gather Evidence

Document the 3+ occurrences:

```
SKILL UPDATE PROPOSAL: <skill-name>

Type: new trigger | new anti-pattern | new verification step

Evidence:
1. [Date/context] — [what happened]
2. [Date/context] — [what happened]
3. [Date/context] — [what happened]

Proposed Addition:
[The exact text to add to the skill]

Location in Skill:
[Which section: triggers, Anti-Patterns table, or verification checklist]
```

### Step 2: Present to User

> "I've noticed [pattern] across 3 separate instances. I'd like to add it to the `<skill-name>` skill. Here's the proposal:"
>
> [Show the proposal]

### Step 3: Apply If Approved

If the user approves:
1. Edit the SKILL.md file with the addition
2. Update the frontmatter if a new trigger was added
3. Run `build-index.ts` to regenerate the index
4. Note the update in a learning (`compound-docs`)

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Proposing updates from 1-2 occurrences | Not enough evidence. Wait for 3. |
| Rewriting instead of appending | The ratchet only adds. It never rewrites. |
| Adding without user approval | Skills belong to the user. Always ask first. |
| Project-specific additions to general skills | Use config, not skill edits. |

## Chaining

None — this is a terminal skill.
