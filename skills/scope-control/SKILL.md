---
name: scope-control
description: Use when any task is received — silently enforces smallest viable change set and proposes decomposition for large tasks
tags: [gate, scope, discipline]
triggers: [always]
chains_to: [ralph-loop, writing-plans]
priority: gate
gate: true
---

# Scope Control

Three rules. No essays. Applied silently.

1. **Prefer smallest viable change set.**
2. **If task is large** — propose: split into steps | ralph loop | worktree.
3. **If scope grows during work** — pause, re-scope with user.
