---
title: Optimize Package Imports (Next.js)
impact: CRITICAL
impactDescription: reduces import cost with Next.js optimizePackageImports
tags: nextjs, bundle, imports, optimizePackageImports
---

## Optimize Package Imports (Next.js)

Use Next.js optimizePackageImports to keep ergonomic barrel imports while avoiding large re-export graphs.

**Alternative (Next.js 13.5+):**

```js
// next.config.js - use optimizePackageImports
module.exports = {
  experimental: {
    optimizePackageImports: ['lucide-react', '@mui/material']
  }
}

// Then you can keep the ergonomic barrel imports:
import { Check, X, Menu } from 'lucide-react'
// Automatically transformed to direct imports at build time
```

Reference: [How we optimized package imports in Next.js](https://vercel.com/blog/how-we-optimized-package-imports-in-next-js)
