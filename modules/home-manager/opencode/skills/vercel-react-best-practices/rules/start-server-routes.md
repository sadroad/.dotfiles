---
title: Server Route Handlers (TanStack Start)
impact: MEDIUM
impactDescription: ensures proper HTTP semantics and parameter handling
tags: start, tanstack, server-routes, handlers, response
---

## Server Route Handlers

Use `createFileRoute` server handlers with proper Response objects and parameter handling.

**Basic server route:**

```ts
// routes/hello.ts
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/hello')({
  server: {
    handlers: {
      GET: async ({ request }) => {
        return new Response('Hello, World!')
      },
    },
  },
})
```

**JSON responses:**

```ts
// routes/hello.ts
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/hello')({
  server: {
    handlers: {
      GET: async ({ request }) => {
        return Response.json({ message: 'Hello, World!' })
      },
    },
  },
})
```

**Parameter handling:**

```ts
// routes/users/$id.ts
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/users/$id')({
  server: {
    handlers: {
      GET: async ({ params }) => {
        const { id } = params
        return new Response(`User ID: ${id}`)
      },
    },
  },
})
```

**Middleware integration:**

```tsx
// routes/hello.ts
import { createFileRoute } from '@tanstack/react-router'

export const Route = createFileRoute('/hello')({
  server: {
    handlers: ({ createHandlers }) =>
      createHandlers({
        GET: {
          middleware: [loggerMiddleware],
          handler: async ({ request }) => {
            return new Response('Hello, World! from ' + request.url)
          },
        },
      }),
  },
})
```

Reference: [https://tanstack.com/start/latest/docs/framework/react/guide/server-routes](https://tanstack.com/start/latest/docs/framework/react/guide/server-routes)
