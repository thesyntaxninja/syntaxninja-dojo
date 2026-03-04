---
name: receiving-code-review
description: Use when receiving code review feedback — requires technical verification of each suggestion before implementing, not blind agreement
tags: [review, discipline, quality]
triggers: [review feedback, PR comments, code review response, reviewer says, feedback received]
chains_to: [verification-before-completion]
priority: core
gate: false
---

# Receiving Code Review

## Quick Reference

When receiving review feedback: verify each suggestion technically before implementing. Don't blindly agree. Don't blindly reject. Understand, verify, then act.

## When to Use

- Received PR review comments
- Sensei returned findings to address
- User relays feedback from a reviewer
- Review agent findings need to be addressed

## When NOT to Use

- You're giving a review (use `requesting-code-review`)
- Feedback is about requirements, not code quality

## Core Process

### Step 1: Read All Feedback First

Read every comment/finding before responding to any. Understand the full picture — some comments may relate to each other.

### Step 2: Categorize Each Item

For each piece of feedback:

| Category | Action |
|----------|--------|
| **Clearly correct** (bug, security issue, missing test) | Fix it. No discussion needed. |
| **Technically sound suggestion** | Verify the suggestion works, then implement. |
| **Debatable** (style, approach, taste) | Understand the reasoning. If it improves the code, do it. If not, explain why. |
| **Incorrect** (misunderstood the code, wrong assumption) | Explain politely with evidence. Show the code that proves your point. |

### Step 3: Verify Before Implementing

For each suggestion you plan to implement:

1. **Understand** what the reviewer is asking for and why
2. **Check** if the suggestion is technically correct (will it break anything?)
3. **Implement** the change
4. **Verify** the change works (run tests, build, etc.)

**Never implement a suggestion you don't understand.** Ask for clarification instead.

### Step 4: Respond to Each Item

For items you implement:
> Done. [Brief description of the change.]

For items you disagree with:
> [Technical explanation with evidence — file:line, test output, docs reference.]

For items that need clarification:
> I want to make sure I understand: are you suggesting [interpretation]? Because [context].

### Step 5: Final Verification

After all changes:
1. Run full test suite
2. Chain to `verification-before-completion`
3. Confirm all findings are addressed

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| "Good point, fixed!" without verifying | The "fix" might introduce new bugs |
| Implementing every suggestion blindly | Some suggestions are wrong. Verify first. |
| Rejecting all feedback defensively | Review is about the code, not you |
| Bulk-fixing without understanding | You'll miss the learning opportunity |
| "I'll fix it later" | You won't. Fix it now. |
| Performative agreement | Saying "great catch" when you disagree helps nobody |

## The Rule

**Technical rigor over social compliance.** Verify the suggestion. If it's right, implement it. If it's wrong, explain why with evidence. Never agree just to be agreeable.

## Chaining

REQUIRED: syntaxninja-dojo:verification-before-completion (after all fixes applied)
