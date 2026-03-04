---
name: test-driven-development
description: Use when implementing any feature or bugfix where tests can be written first — write the test, see it fail, make it pass, refactor
tags: [process, testing, discipline]
triggers: [implement feature, add test, bugfix with regression test, TDD, test first, write tests]
chains_to: [verification-before-completion]
priority: core
gate: false
---

# Test-Driven Development

## Quick Reference

Write the test first. See it fail. Make it pass with the minimum code. Refactor. The test defines done — not your feeling about the code.

## When to Use

- Implementing a new feature with clear expected behavior
- Fixing a bug (write the regression test first)
- Adding behavior to existing code
- User asks for TDD or "test first" approach

## When NOT to Use

- Exploratory prototyping (test after, when the API stabilizes)
- Pure UI/visual changes (use visual verification instead)
- Config changes with no testable behavior
- The project has no test infrastructure and setting it up isn't part of the task

## Core Process

### Step 1: Understand the Contract

Before writing anything:
- What are the inputs?
- What are the expected outputs?
- What are the edge cases?
- What should NOT happen?

### Step 2: Write the Test

Write ONE test that captures the most important behavior:

```
test("should [expected behavior] when [condition]", () => {
  // Arrange: set up the inputs
  // Act: call the function/component
  // Assert: verify the output
})
```

Guidelines:
- Test behavior, not implementation
- One assertion per test (or tightly related assertions)
- Use descriptive test names: "should X when Y"
- Test the public API, not internal details

### Step 3: See It Fail (RED)

Run the test. It MUST fail. If it passes, either:
- The behavior already exists (you're done)
- The test is wrong (it's not testing what you think)

A test that passes without implementation is worthless.

### Step 4: Make It Pass (GREEN)

Write the **minimum code** to make the test pass. Not the "right" code. Not the "clean" code. The minimum code.

Rules:
- Only write code that the failing test demands
- Don't add features the test doesn't require
- Don't optimize
- Don't handle edge cases the test doesn't cover (yet)

### Step 5: Refactor (REFACTOR)

Now that the test passes, clean up:
- Remove duplication
- Improve naming
- Extract functions if needed
- Ensure the code matches project patterns

Run the test again after refactoring. It must still pass.

### Step 6: Repeat

Add the next test for the next behavior. Repeat the cycle:
RED → GREEN → REFACTOR

Priority order for tests:
1. Happy path (most common use case)
2. Edge cases (boundaries, empty inputs, nulls)
3. Error cases (invalid inputs, failures)

### Step 7: Verify All

After all tests are written and passing:
- Run the full test suite (not just your new tests)
- Chain to `verification-before-completion`

## Test Quality Checks

Before considering tests done:
- [ ] Tests fail when the implementation is removed
- [ ] Test names describe behavior, not implementation
- [ ] No test depends on another test's state
- [ ] Edge cases are covered
- [ ] Tests run fast (no unnecessary I/O or sleeps)

## Anti-Patterns

| Anti-Pattern | Why It's Wrong |
|--------------|----------------|
| Writing implementation first, tests after | Tests become verification of your code, not specification of behavior |
| Test that never fails | It doesn't test anything |
| Testing implementation details | Tests break on refactor, providing false negatives |
| Giant test with 10 assertions | One failure, unclear which behavior broke |
| Skipping the RED step | You don't know if your test actually works |
| "I'll add tests later" | You won't. Or they'll test the wrong thing. |
| Over-mocking | Mock boundaries, not collaborators. Test real behavior. |

## Chaining

REQUIRED: syntaxninja-dojo:verification-before-completion (after all tests pass)
