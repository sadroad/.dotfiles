---
title: Build Configuration (TanStack Start)
impact: LOW
impactDescription: ensures proper development experience and build optimization
tags: start, tanstack, build, vite, typescript
---

## Build Configuration

Configure Vite plugins in the correct order and use proper TypeScript settings for TanStack Start projects.

**Plugin order:**

```ts
// vite.config.ts
import { defineConfig } from 'vite'
import tsConfigPaths from 'vite-tsconfig-paths'
import { tanstackStart } from '@tanstack/react-start/plugin/vite'
import viteReact from '@vitejs/plugin-react'

export default defineConfig({
  server: {
    port: 3000,
  },
  plugins: [
    tsConfigPaths(),
    tanstackStart(),
    // react's vite plugin must come after start's vite plugin
    viteReact(),
  ],
})
```

**TypeScript configuration:**

```json
{
  "compilerOptions": {
    "jsx": "react-jsx",
    "moduleResolution": "Bundler",
    "module": "ESNext",
    "target": "ES2022",
    "skipLibCheck": true,
    "strictNullChecks": true
  }
}
```

> [!NOTE]
> Enabling `verbatimModuleSyntax` can result in server bundles leaking into client bundles. It is recommended to keep this option disabled.

Reference: [https://tanstack.com/start/latest/docs/framework/react/build-from-scratch](https://tanstack.com/start/latest/docs/framework/react/build-from-scratch)
