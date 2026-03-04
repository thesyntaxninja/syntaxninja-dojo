---
name: zustand
type: library
library: zustand
severity: p2
file-globs: ["*.ts", "*.tsx"]
detect: ["from 'zustand'", "from \"zustand\"", "import { create }"]
signatures: ["create<", "create(", "set((", "useStore(", "getState()"]
tags: [state-management, react]
autofix: ""
---

# Zustand Pattern

## Preferred Pattern

```typescript
// src/<domain>/store.ts
import { create } from "zustand";

interface AuthState {
  user: User | null;
  isLoading: boolean;
  login: (credentials: Credentials) => Promise<void>;
  logout: () => void;
}

export const useAuthStore = create<AuthState>((set) => ({
  user: null,
  isLoading: false,

  login: async (credentials) => {
    set({ isLoading: true });
    try {
      const user = await api.login(credentials);
      set({ user, isLoading: false });
    } catch {
      set({ isLoading: false });
      throw error;
    }
  },

  logout: () => set({ user: null }),
}));
```

## Rules

- One store per domain concept (auth, cart, preferences — not one global store)
- Export the hook directly: `export const useAuthStore = create<...>(...)`
- Type the state interface explicitly — no `any`, no inferred-only types
- Colocate the store with its domain: `src/<domain>/store.ts`
- Keep actions inside the store (not as separate functions)
- Use `set` with partial state objects, not `get` + `set` for simple updates

## Selectors

For stores with many fields, export selectors to prevent unnecessary re-renders:

```typescript
// Prefer: select specific fields
const user = useAuthStore((state) => state.user);

// Avoid: selecting the entire store
const store = useAuthStore();
```

## Anti-Patterns

```typescript
// BAD: One giant global store
const useStore = create((set) => ({
  user: null,
  cart: [],
  theme: "light",
  notifications: [],
  // ... 50 more fields from unrelated domains
}));

// BAD: Actions outside the store
const login = async (credentials: Credentials) => {
  useAuthStore.setState({ isLoading: true });
  // ...
};

// BAD: No type annotation
const useAuthStore = create((set) => ({
  user: null, // What type is user? Unknown.
}));

// BAD: Selecting entire store when you need one field
function UserName() {
  const { user } = useAuthStore(); // Re-renders on ANY store change
  return <span>{user?.name}</span>;
}
```

## When to Apply

- Creating new zustand stores
- Refactoring existing stores
- Code review of PRs touching state management
- Moving from other state management to zustand
