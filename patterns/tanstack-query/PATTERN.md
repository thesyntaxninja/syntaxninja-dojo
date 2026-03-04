---
name: tanstack-query
type: library
library: "@tanstack/react-query"
severity: p2
file-globs: ["*.ts", "*.tsx"]
detect: ["from '@tanstack/react-query'", "from \"@tanstack/react-query\"", "from '@tanstack/query-core'"]
signatures: ["useQuery(", "useMutation(", "queryKey:", "queryFn:", "useQueryClient(", "QueryClient"]
tags: [data-fetching, react, async]
autofix: ""
---

# TanStack Query Pattern

## Preferred Pattern

```typescript
// src/<domain>/queries.ts
import { useQuery, useMutation, useQueryClient } from "@tanstack/react-query";

// Keys: colocated, typed, factory pattern
export const userKeys = {
  all: ["users"] as const,
  lists: () => [...userKeys.all, "list"] as const,
  list: (filters: UserFilters) => [...userKeys.lists(), filters] as const,
  details: () => [...userKeys.all, "detail"] as const,
  detail: (id: string) => [...userKeys.details(), id] as const,
};

// Query: thin wrapper around useQuery
export function useUser(id: string) {
  return useQuery({
    queryKey: userKeys.detail(id),
    queryFn: () => api.getUser(id),
  });
}

// Mutation: invalidates related queries on success
export function useUpdateUser() {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (data: UpdateUserInput) => api.updateUser(data),
    onSuccess: (_data, variables) => {
      queryClient.invalidateQueries({ queryKey: userKeys.detail(variables.id) });
      queryClient.invalidateQueries({ queryKey: userKeys.lists() });
    },
  });
}
```

## Rules

- Colocate queries with their domain: `src/<domain>/queries.ts`
- Use query key factories — never inline string arrays
- Keep `queryFn` thin — call an API function, don't inline fetch logic
- Invalidate related queries in `onSuccess` — not manually in components
- Let TanStack Query manage loading/error state — don't duplicate it in zustand
- One custom hook per query — components call hooks, not `useQuery` directly

## Query Key Factory

Always use a key factory. It prevents typos and makes invalidation reliable:

```typescript
// Keys are hierarchical: invalidating "users" invalidates all sub-keys
queryClient.invalidateQueries({ queryKey: userKeys.all });
// Invalidates: ["users"], ["users", "list", ...], ["users", "detail", ...]
```

## Anti-Patterns

```typescript
// BAD: Inline query keys
useQuery({ queryKey: ["users", id], queryFn: ... });
// Typo risk. Impossible to invalidate reliably.

// BAD: Fetch logic inside queryFn
useQuery({
  queryKey: userKeys.detail(id),
  queryFn: async () => {
    const res = await fetch(`/api/users/${id}`);
    if (!res.ok) throw new Error("Failed");
    return res.json();
  },
});
// Extract to an API module. queryFn should be one line.

// BAD: Duplicating server state in zustand
const useUserStore = create((set) => ({
  user: null,
  isLoading: false,
  fetchUser: async (id) => { ... },
}));
// TanStack Query IS your server state. Don't duplicate it.

// BAD: Manual refetching instead of invalidation
onClick={() => {
  await updateUser(data);
  refetch(); // Fragile. What about other components showing this data?
}}
// Use mutation onSuccess + invalidateQueries instead.
```

## When to Apply

- Any component fetching server data
- Adding new API endpoints with UI consumption
- Refactoring manual fetch/useEffect patterns
- Code review of data-fetching code
