---
name: writing-plans
description: Use when a task requires multiple steps and benefits from a structured plan before implementation begins
tags: [process, planning, architecture]
triggers: [plan, implement feature, multi-step task, architecture decision, new feature, requirements clear]
chains_to: [executing-plans, ralph-loop]
priority: core
gate: false
---

# Writing Plans

## Quick Reference

Before implementing anything non-trivial: write a plan. Plans are ordered lists of concrete steps with clear acceptance criteria. Write them in a plan file, get user approval, then execute.

## When to Use

- Task involves 3+ steps or touches 3+ files
- Architectural decisions need to be made
- After brainstorming has converged on an approach
- User asks for a plan or implementation strategy
- Feature request that needs decomposition

## When NOT to Use

- Single-file, obvious changes
- Bug fixes (debug first, plan emerges from understanding)
- Tasks the user has already decomposed into explicit steps
- Trivial config or copy changes

## Core Process

### Step 1: Gather Context

Before writing anything:
1. Read relevant source files — understand the codebase's current state
2. Check for existing patterns, tests, and conventions
3. Identify dependencies and constraints
4. Review any brief from `brainstorming` if one exists

### Step 2: Write the Plan

Create a plan file at `docs/plans/<date>-<slug>.md`:

```markdown
---
date: YYYY-MM-DD
topic: <feature-name>
type: implementation-plan
status: draft
---

# <Feature Name>

## Goal
[One sentence: what this achieves]

## Context
[2-3 sentences: what exists now, why this change is needed]

## Steps

### 1. [Step Name]
- **Files**: `path/to/file.ts`
- **What**: [Concrete description of changes]
- **Acceptance**: [How to verify this step is done]

### 2. [Step Name]
...

## Out of Scope
- [Things explicitly NOT included]

## Risks
- [Known risks or unknowns, if any]
```

### Step 3: Scope Assessment

Evaluate the plan:

| Signal | Assessment |
|--------|-----------|
| Steps fit in one context window | Normal execution → `executing-plans` |
| Steps are independent and parallelizable | Use `subagent-driven-development` during execution |
| Too many steps for one session AND each step has pass/fail criteria AND clean iteration boundaries | Escalate to `ralph-loop` |

### Step 4: Present for Approval

Show the plan to the user. Wait for approval before implementing.

Keep the presentation concise — the plan file has the details, your message should summarize:
- What you'll do (3-5 bullet points)
- How many steps
- Estimated scope (files touched)
- Any decisions that need user input

### Plan Quality Checks

Before presenting:
- [ ] Every step has concrete files and acceptance criteria
- [ ] Steps are ordered by dependency (what must come first)
- [ ] No step is "and then do everything else"
- [ ] Out-of-scope section exists (prevents scope creep)
- [ ] Each step is independently verifiable

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Plans with vague steps ("set up the infrastructure") | Not actionable. Name the files and changes. |
| Plans without acceptance criteria | How do you know a step is done? |
| Over-planning trivial tasks | A 20-step plan for adding a button is waste. |
| Planning without reading the code | Your plan won't match reality. |
| Monolithic steps | Break "implement the feature" into actual steps. |
| Planning in your head | Write it down. Plans drift in memory. |

## Chaining

REQUIRED: syntaxninja-dojo:executing-plans (after user approves the plan)
OPTIONAL: syntaxninja-dojo:ralph-loop (when scope exceeds one context window)
