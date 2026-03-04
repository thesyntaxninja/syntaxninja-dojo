---
name: structure-test-colocation
type: structure
severity: p3
file-globs: ["**/*"]
detect: []
signatures: []
tags: [testing, organization]
autofix: ""
---

# Test Colocation

## Preferred Structure

```
src/<domain>/
├── components/
│   └── UserProfile.tsx
├── hooks/
│   └── useUserPermissions.ts
├── store.ts
├── utils.ts
└── __tests__/
    ├── UserProfile.test.tsx
    ├── useUserPermissions.test.ts
    ├── store.test.ts
    └── utils.test.ts
```

## Rules

- **Tests live next to code**: `__tests__/` directory inside each domain folder
- **Mirror the source structure**: Test file names match source file names + `.test.`
- **One test file per source file**: `UserProfile.tsx` → `UserProfile.test.tsx`
- **Integration tests at domain level**: `__tests__/integration/` for cross-component tests within a domain
- **E2E tests are separate**: `e2e/` at the project root (not colocated)

## Naming Convention

```
<SourceFileName>.test.<ext>     # Unit tests
<SourceFileName>.spec.<ext>     # Also acceptable (pick one, be consistent)
```

Pick `.test.` or `.spec.` — never mix both in the same project.

## Anti-Patterns

```
// BAD: Top-level test directory mirroring src/
tests/
├── auth/
│   └── UserProfile.test.tsx   # Far from the source file
├── cart/
│   └── CartItem.test.tsx
└── ...
// When you rename/move a source file, you forget to move the test.

// BAD: Test files alongside source files (no __tests__ directory)
src/auth/
├── UserProfile.tsx
├── UserProfile.test.tsx        # Clutters the directory
├── UserAvatar.tsx
├── UserAvatar.test.tsx
└── ...
// 50% of files are tests. Hard to scan.

// BAD: One giant test file per domain
__tests__/auth.test.ts          # 2000 lines testing everything
// Split into one test file per source file.
```

## When to Apply

- Creating new test files
- Moving or renaming source files (move the test too)
- Setting up test infrastructure
- During sensei review when diff includes new files

**Do NOT apply during routine edits to existing test files.**
