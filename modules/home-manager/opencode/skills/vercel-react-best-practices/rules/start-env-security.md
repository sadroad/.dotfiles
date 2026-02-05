---
title: Environment Variable Security (TanStack Start)
impact: HIGH
impactDescription: prevents data leakage between server and client
tags: start, tanstack, environment, security, process.env
---

## Environment Variable Security

Separate server and client environment variables using `process.env` and `import.meta.env`.

**Server vs client environment variables:**

```typescript
// Server function - can access any environment variable
const getUser = createServerFn().handler(async () => {
  const db = await connect(process.env.DATABASE_URL) // ✅ Server-only
  return db.user.findFirst()
})

// Client component - only VITE_ prefixed variables
export function AppHeader() {
  return <h1>{import.meta.env.VITE_APP_NAME}</h1> // ✅ Client-safe
}
```

**Environment file order:**

```
.env.local          # Local overrides (add to .gitignore)
.env.production     # Production-specific variables
.env.development    # Development-specific variables
.env                # Default variables (commit to git)
```

**Static NodeEnv configuration:**

```ts
// vite.config.ts
import { defineConfig } from 'vite'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'
import viteReact from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [
    tanstackStart({
      server: {
        build: {
          // Replace process.env.NODE_ENV at build time (default: true)
          staticNodeEnv: true,
        },
      },
    }),
    viteReact(),
  ],
})
```

Reference: [https://tanstack.com/start/latest/docs/framework/react/guide/environment-variables](https://tanstack.com/start/latest/docs/framework/react/guide/environment-variables)
