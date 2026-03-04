---
name: systematic-debugging
description: Use when encountering any bug, test failure, unexpected behavior, or error message — before proposing any fix
tags: [gate, debugging, process]
triggers: [bug, error, fail, unexpected, broken, crash, wrong output, exception, panic]
chains_to: [test-driven-development, verification-before-completion]
priority: gate
gate: true
---

# Systematic Debugging

## Quick Reference

Before fixing anything: reproduce, isolate, understand. Only then fix. Verify the fix doesn't break anything else.

## When to Use

- Any error, bug, test failure, or unexpected behavior
- User reports something isn't working
- Build or CI failure
- Runtime exception or panic

## When NOT to Use

- This always applies when there's a bug. No exceptions.

## Core Process

### Phase 1: Reproduce

1. **Get the exact error.** Copy the full error message, stack trace, or unexpected output.
2. **Identify the reproduction steps.** What triggers the bug?
3. **Reproduce it yourself.** Run the failing command/test. See the failure with your own eyes.

If you cannot reproduce: state that clearly. Do not guess at fixes for bugs you cannot see.

### Phase 2: Isolate

1. **Read the error carefully.** File, line number, error type — what is it actually telling you?
2. **Trace the execution path.** From the entry point to the failure. Read the relevant code.
3. **Form a hypothesis.** Based on what you read, what's the most likely cause?
4. **Verify the hypothesis.** Find evidence in the code that confirms or denies it.

Do NOT:
- Jump to the first thing that looks wrong
- Change multiple things at once
- Apply a fix without understanding the root cause

### Phase 3: Fix

1. **Make the minimal change** that addresses the root cause.
2. **One fix at a time.** If you think there are multiple issues, fix one, verify, then the next.

### Phase 4: Verify

1. **Run the original failing test/command.** It must pass now.
2. **Run the full test suite.** The fix must not break other things.
3. **Check for edge cases.** Does the fix handle related scenarios?

Chain to `syntaxninja-dojo:verification-before-completion`.

### Phase 5: Reflect

After the fix is verified:
- Was this a systemic issue? Could the same class of bug exist elsewhere?
- Should a test be added to prevent regression?
- Is this worth documenting as a learning?

## Decision Tree

```
Error encountered
│
├─ Can I reproduce it?
│   ├─ YES → Read the error. Trace the code. Form hypothesis.
│   │   ├─ Hypothesis confirmed → Minimal fix → Verify → Done
│   │   └─ Hypothesis wrong → New hypothesis → Repeat
│   └─ NO → State that. Ask for more context. Do not guess.
│
├─ Is it a test failure?
│   └─ Read the test. Read the code. Understand the contract.
│       ├─ Code is wrong → Fix code
│       └─ Test is wrong → Fix test (rare — verify carefully)
│
└─ Is it a build/compile error?
    └─ Read the error message. It usually tells you exactly what's wrong.
```

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| "Let me try this..." (no hypothesis) | Shotgun debugging wastes time |
| Changing 5 things at once | You won't know which one fixed it |
| "It works now" (no understanding) | You'll hit the same class of bug again |
| Fixing symptoms instead of root cause | The bug will resurface |
| Ignoring the full error message | The answer is usually in the error |
| Adding defensive code instead of fixing the bug | Band-aids hide problems |

## Chaining

OPTIONAL: syntaxninja-dojo:test-driven-development (when a regression test is needed)
REQUIRED: syntaxninja-dojo:verification-before-completion (after fix)
