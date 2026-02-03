---
title: Defer Search Params Reads (Next.js)
impact: MEDIUM
impactDescription: avoids unnecessary subscriptions in Next.js navigation
tags: nextjs, rerender, searchParams, navigation
---

## Defer Search Params Reads (Next.js)

Avoid subscribing to `useSearchParams()` when you only need the value inside a callback.

**Incorrect (subscribes to all searchParams changes):**

```tsx
function ShareButton({ chatId }: { chatId: string }) {
  const searchParams = useSearchParams()

  const handleShare = () => {
    const ref = searchParams.get('ref')
    shareChat(chatId, { ref })
  }

  return <button onClick={handleShare}>Share</button>
}
```
