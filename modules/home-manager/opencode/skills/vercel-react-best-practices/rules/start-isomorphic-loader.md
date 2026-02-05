---
title: Isomorphic Loader Patterns (TanStack Start)
impact: HIGH
impactDescription: prevents server-only secrets from leaking in loaders
tags: start, tanstack, loader, isomorphic, server-functions
---

## Isomorphic Loader Patterns

Loaders run on both server and client by default. Use server functions for server-only operations.

**Incorrect (assuming loader is server-only):**

```tsx
// ❌ Assuming loader is server-only
export const Route = createFileRoute('/users')({
  loader: () => {
    // This runs on BOTH server and client!
    const secret = process.env.SECRET // Exposed to client
    return fetch(`/api/users?key=${secret}`)
  },
})
```

**Correct (use server function for server-only operations):**

```tsx
// ✅ Use server function for server-only operations
const getUsersSecurely = createServerFn().handler(() => {
  const secret = process.env.SECRET // Server-only
  return fetch(`/api/users?key=${secret}`)
})

export const Route = createFileRoute('/users')({
  loader: () => getUsersSecurely(), // Isomorphic call to server function
})
```

Reference: [https://tanstack.com/start/latest/docs/framework/react/guide/execution-model](https://tanstack.com/start/latest/docs/framework/react/guide/execution-model)
