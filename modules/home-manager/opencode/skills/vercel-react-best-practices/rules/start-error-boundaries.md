---
title: Error Boundaries (TanStack Start)
impact: MEDIUM
impactDescription: provides consistent error handling across routes
tags: start, tanstack, error-boundaries, error-handling, router
---

## Error Boundaries

Implement error boundaries at the route level using TanStack Router's built-in error handling.

**Router-level error boundary:**

```tsx
// src/router.tsx
import { createRouter, ErrorComponent } from '@tanstack/react-router'
import { routeTree } from './routeTree.gen'

export function getRouter() {
  const router = createRouter({
    routeTree,
    // Shown when an error bubbles to the router
    defaultErrorComponent: ({ error, reset }) => (
      <ErrorComponent error={error} />
    ),
  })
  return router
}
```

**Route-specific error boundaries:**

```tsx
// src/routes/posts.$postId.tsx
import { createFileRoute, ErrorComponent } from '@tanstack/react-router'
import type { ErrorComponentProps } from '@tanstack/react-router'

function PostError({ error, reset }: ErrorComponentProps) {
  return <ErrorComponent error={error} />
}

export const Route = createFileRoute('/posts/$postId')({
  component: PostComponent,
  errorComponent: PostError,
})
```

Reference: [https://tanstack.com/start/latest/docs/framework/react/guide/error-boundaries](https://tanstack.com/start/latest/docs/framework/react/guide/error-boundaries)
