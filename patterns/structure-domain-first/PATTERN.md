---
name: structure-domain-first
type: structure
severity: p3
file-globs: ["**/*"]
detect: []
signatures: []
tags: [organization, architecture]
autofix: ""
---

# Domain-First Organization

## Preferred Structure

```
src/
├── <domain>/
│   ├── components/
│   │   ├── UserProfile.tsx
│   │   └── UserAvatar.tsx
│   ├── hooks/
│   │   └── useUserPermissions.ts
│   ├── store.ts              # Zustand store (if needed)
│   ├── queries.ts            # TanStack Query hooks
│   ├── types.ts              # Domain types
│   ├── utils.ts              # Domain utilities
│   ├── index.ts              # Public API — the ONLY import path for outsiders
│   └── __tests__/
│       ├── UserProfile.test.tsx
│       └── useUserPermissions.test.ts
├── shared/
│   ├── components/           # Truly shared UI (Button, Modal, etc.)
│   ├── hooks/                # Truly shared hooks (useMediaQuery, etc.)
│   ├── lib/                  # Shared utilities
│   └── types/                # Shared type definitions
└── app/
    ├── layout.tsx
    ├── routes/
    └── providers/
```

## Rules

- **Domain folders over type folders**: `src/auth/components/` not `src/components/auth/`
- **Maximum nesting: 3 levels** from `src/` — `src/auth/components/LoginForm.tsx`
- **Public API via index.ts**: Cross-domain imports ONLY through `<domain>/index.ts`
- **Shared means shared**: Only put something in `shared/` if 2+ domains use it
- **Colocate what changes together**: If UserProfile always changes with UserAvatar, keep them in the same domain folder

## When a File Belongs in `shared/`

Ask: "If I deleted this domain, would other domains break?"
- **Yes** → It belongs in `shared/`
- **No** → It belongs in the domain

## Cross-Domain Communication

```typescript
// GOOD: Import via public API
import { UserAvatar } from "@/auth";
import type { User } from "@/auth";

// BAD: Import domain internals
import { UserAvatar } from "@/auth/components/UserAvatar";
import { useAuthStore } from "@/auth/store";
```

## Anti-Patterns

```
// BAD: Type-first organization (dumping ground)
src/
├── components/
│   ├── UserProfile.tsx        # Auth domain
│   ├── CartItem.tsx           # Cart domain
│   ├── NotificationBell.tsx   # Notifications domain
│   └── ... 50 more unrelated files
├── hooks/
│   ├── useAuth.ts
│   ├── useCart.ts
│   └── ... mixing every domain
└── utils/
    └── ... everything in one pile

// BAD: Deep nesting
src/auth/features/login/components/forms/fields/EmailField.tsx
// 6 levels deep. Max 3.

// BAD: Importing domain internals from outside
// In src/cart/components/Checkout.tsx:
import { useAuthStore } from "@/auth/store";  // Reaching into auth internals
// Should be: import { useCurrentUser } from "@/auth";
```

## When to Apply

- Creating new files or directories
- Moving or renaming files
- During sensei review when diff includes path changes
- Setting up a new project or module

**Do NOT apply during routine edits to existing files.**
