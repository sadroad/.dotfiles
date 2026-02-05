---
title: Next.js Fetch Memoization Note
impact: LOW
impactDescription: clarifies Next.js fetch deduplication vs React.cache
tags: nextjs, fetch, cache, memoization
---

## Next.js Fetch Memoization

In Next.js, the `fetch` API is automatically extended with request memoization. Requests with the same URL and options are automatically deduplicated within a single request, so you don't need `React.cache()` for `fetch` calls. However, `React.cache()` is still essential for other async tasks:

- Database queries (Prisma, Drizzle, etc.)
- Heavy computations
- Authentication checks
- File system operations
- Any non-fetch async work

Use `React.cache()` to deduplicate these operations across your component tree.

Reference: [React.cache documentation](https://react.dev/reference/react/cache)
