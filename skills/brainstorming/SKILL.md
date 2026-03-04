---
name: brainstorming
description: Use when requirements are unclear, ambiguous, or have multiple valid interpretations — before planning or implementing
tags: [process, planning, discovery]
triggers: [unclear requirements, ambiguous, explore approaches, what should we build, help me think through, multiple valid interpretations, new feature with unknowns]
chains_to: [writing-plans]
priority: core
gate: false
---

# Brainstorming

## Quick Reference

Before planning or building anything with unclear requirements: explore the user's intent, surface assumptions, identify constraints, and converge on an approach. Output a concise brief, not a plan.

## When to Use

- User's request has multiple valid interpretations
- Requirements are vague or incomplete ("make it better", "add auth")
- You're unsure what the user actually wants
- Feature request could be solved in fundamentally different ways
- User explicitly asks to brainstorm or think through something

## When NOT to Use

- Requirements are clear and specific ("add a button that calls /api/logout")
- User has provided a detailed spec or plan
- The task is a bug fix (use `systematic-debugging` instead)
- Trivial changes (typo, rename, config tweak)

## Core Process

### Step 1: Understand the Intent

Ask yourself (silently, don't dump this on the user):
- What is the user trying to achieve? (goal, not implementation)
- What did they say vs. what did they mean?
- What assumptions am I making?

### Step 2: Explore the Codebase

Before asking questions, gather context:
- Read relevant files to understand what exists
- Check for existing patterns, conventions, or prior art
- Identify constraints (dependencies, architecture, existing APIs)

### Step 3: Surface Options

Present 2-3 approaches to the user. For each:
- **What**: One-sentence description
- **Trade-off**: Key advantage and disadvantage
- **Fits when**: What circumstance makes this the right choice

Keep it brief. No walls of text. The user should be able to pick in 10 seconds.

### Step 4: Converge

Based on the user's choice (or their clarification), produce a brief:

```
## Brief
- **Goal**: [one sentence]
- **Approach**: [chosen approach]
- **Scope**: [what's in, what's explicitly out]
- **Key decisions**: [1-3 decisions made during brainstorming]
```

This brief feeds into `writing-plans` if the task needs a plan, or directly into implementation if it's small enough.

### Step 5: Check Scope

Is this task:
- **Small** (< 30 min, < 3 files)? → Proceed directly to implementation
- **Medium** (clear steps, one session)? → Chain to `writing-plans`
- **Large** (multiple sessions, many unknowns)? → Chain to `writing-plans`, which may escalate to `ralph-loop`

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Brainstorming when requirements are clear | Wastes time. Just build it. |
| Presenting 5+ options | Decision paralysis. 2-3 max. |
| Long essays per option | User won't read them. Keep it scannable. |
| Asking too many questions upfront | Gather context from code first, then ask targeted questions. |
| Brainstorming alone without the user | The point is collaborative convergence. Present options, get input. |
| Skipping codebase exploration | You'll propose approaches that don't fit the existing architecture. |

## Chaining

REQUIRED: syntaxninja-dojo:writing-plans (for medium/large tasks after convergence)
