---
title: Middleware Patterns (TanStack Start)
impact: MEDIUM
impactDescription: ensures predictable request processing and cross-cutting concerns
tags: start, tanstack, middleware, request-handling, chaining
---

## Middleware Patterns

Use middleware for cross-cutting concerns with proper chaining and execution order.

**Middleware creation and chaining:**

```tsx
import { createMiddleware } from '@tanstack/react-start'

const loggingMiddleware = createMiddleware().server(() => {
  //...
})

const authMiddleware = createMiddleware()
  .middleware([loggingMiddleware])
  .server(() => {
    //...
  })
```

**Middleware execution:**

```tsx
const loggingMiddleware = createMiddleware().server(async ({ next }) => {
  const result = await next()
  return result
})
```

**Function vs request middleware:**

```tsx
const loggingMiddleware = createMiddleware({ type: 'function' })
  .client(() => {
    //...
  })
  .server(() => {
    //...
  })
```

**Global middleware:**

```tsx
// src/start.ts
import { createStart } from '@tanstack/react-start'

const myGlobalMiddleware = createMiddleware().server(() => {
  //...
})

export const startInstance = createStart(() => {
  return {
    requestMiddleware: [myGlobalMiddleware],
  }
})
```

Reference: [https://tanstack.com/start/latest/docs/framework/react/guide/middleware](https://tanstack.com/start/latest/docs/framework/react/guide/middleware)
