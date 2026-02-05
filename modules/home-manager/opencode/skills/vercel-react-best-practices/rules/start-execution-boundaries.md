---
title: Execution Boundaries (TanStack Start)
impact: HIGH
impactDescription: prevents runtime errors across server/client boundaries
tags: start, tanstack, execution, server-only, client-only, hydration
---

## Execution Boundaries

Use `createServerOnlyFn`, `createClientOnlyFn`, `ClientOnly`, and `useHydrated` to handle execution boundaries properly.

**Server and client execution boundaries:**

```tsx
import { createServerFn, createServerOnlyFn } from '@tanstack/react-start'

// RPC: Server execution, callable from client
const updateUser = createServerFn({ method: 'POST' })
  .inputValidator((data: UserData) => data)
  .handler(async ({ data }) => {
    // Only runs on server, but client can call it
    return await db.users.update(data)
  })

// Utility: Server-only, client crashes if called
const getEnvVar = createServerOnlyFn(() => process.env.DATABASE_URL)
```

**Client-only execution:**

```tsx
import { createClientOnlyFn } from '@tanstack/react-start'
import { ClientOnly } from '@tanstack/react-router'

// Utility: Client-only, server crashes if called
const saveToStorage = createClientOnlyFn((key: string, value: any) => {
  localStorage.setItem(key, JSON.stringify(value))
})

// Component: Only renders children after hydration
function Analytics() {
  return (
    <ClientOnly fallback={null}>
      <GoogleAnalyticsScript />
    </ClientOnly>
  )
}
```

**Hydration detection:**

```tsx
import { useHydrated } from '@tanstack/react-router'

function TimeZoneDisplay() {
  const hydrated = useHydrated()
  const timeZone = hydrated
    ? Intl.DateTimeFormat().resolvedOptions().timeZone
    : 'UTC'

  return <div>Your timezone: {timeZone}</div>
}
```

Reference: [https://tanstack.com/start/latest/docs/framework/react/guide/execution-model](https://tanstack.com/start/latest/docs/framework/react/guide/execution-model)
