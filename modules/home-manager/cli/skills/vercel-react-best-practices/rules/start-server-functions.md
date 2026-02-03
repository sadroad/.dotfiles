---
title: Server Function Organization (TanStack Start)
impact: HIGH
impactDescription: improves maintainability and security of server functions
tags: start, tanstack, server-functions, validation, organization
---

## Server Function Organization

Organize server functions with static imports, proper validation, and built-in utilities like `redirect` and `notFound`.

**Static imports:**

```tsx
// ✅ Safe - build process handles environment shaking
import { getUser } from '~/utils/users.functions'

function UserProfile({ id }) {
  const { data } = useQuery({
    queryKey: ['user', id],
    queryFn: () => getUser({ data: { id } }),
  })
}
```

**Input validation:**

```tsx
const UserSchema = z.object({
  name: z.string().min(1),
  age: z.number().min(0),
})

export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(UserSchema)
  .handler(async ({ data }) => {
    // data is fully typed and validated
    return `Created user: ${data.name}, age ${data.age}`
  })
```

**Built-in utilities:**

```tsx
export const requireAuth = createServerFn().handler(async () => {
  const user = await getCurrentUser()

  if (!user) {
    throw redirect({ to: '/login' })
  }

  return user
})
```

```tsx
export const getPost = createServerFn()
  .inputValidator((data: { id: string }) => data)
  .handler(async ({ data }) => {
    const post = await db.findPost(data.id)

    if (!post) {
      throw notFound()
    }

    return post
  })
```

**File organization:**

```
src/utils/
├── users.functions.ts   # Server function wrappers (createServerFn)
├── users.server.ts      # Server-only helpers (DB queries, internal logic)
└── schemas.ts           # Shared validation schemas (client-safe)
```

Reference: [https://tanstack.com/start/latest/docs/framework/react/guide/server-functions](https://tanstack.com/start/latest/docs/framework/react/guide/server-functions)
