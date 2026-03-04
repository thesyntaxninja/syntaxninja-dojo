---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing — requires running verification commands and confirming output before making any success claims
tags: [gate, verification, quality]
triggers: [done, complete, fixed, passing, ready, finished, works now]
chains_to: [self-review]
priority: gate
gate: true
---

# Verification Before Completion

## Quick Reference

Before claiming ANYTHING is done: run the verification commands, read the output, confirm success. Evidence before assertions. Always.

## When to Use

- About to say "done", "fixed", "works now", "tests pass"
- About to commit, push, or create a PR
- About to hand off work to the user
- After ANY implementation, no matter how small

## When NOT to Use

- Never. This skill is a gate. It always applies when claiming completion.

## Core Process

### Step 1: Identify verification commands

Based on the project and the work done, determine the right verification:

| Work Type | Commands |
|-----------|----------|
| Rust code | `cargo build --workspace`, `cargo clippy --workspace -- -D warnings`, `cargo test --workspace`, `cargo fmt --all -- --check` |
| TypeScript | `npm run build`, `npm run lint`, `npm run test` |
| Python | `python -m pytest`, `mypy .`, `ruff check .` |
| Any code | Project-specific commands from CLAUDE.md |
| Bug fix | The exact reproduction steps that demonstrated the bug |
| Config | Restart/reload and verify the change took effect |

Always check the project's CLAUDE.md for project-specific verification commands.

### Step 2: Run the commands

Run each verification command. Do not skip any.

### Step 3: Read the output

Read ALL output. Not just the exit code. Look for:
- Warnings treated as errors
- Skipped tests
- Partial failures
- Deprecation notices that indicate future breakage

### Step 4: Confirm or fix

- **All pass**: Proceed to claim completion. Chain to `syntaxninja-dojo:self-review`.
- **Any fail**: Fix the issue. Return to Step 2. Do not claim completion.

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| "Tests should pass" | Run them. Know they pass. |
| "I didn't change anything that would break tests" | Butterfly effect. Run them. |
| "The build succeeded so it's fine" | Build != lint != test != format. Run all. |
| Claiming "fixed" after editing but before verifying | The edit might have introduced new issues. |
| Skipping verification for "trivial" changes | Trivial changes cause production incidents. |

## The Rule

**Evidence before assertions. Always.**

If you cannot run verification commands (no test suite, no build), explicitly state: "I cannot verify this because [reason]. Here's what I'd check: [list]."

## Chaining

REQUIRED: syntaxninja-dojo:self-review (after verification passes)
