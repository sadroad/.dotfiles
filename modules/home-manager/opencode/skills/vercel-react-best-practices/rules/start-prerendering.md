---
title: Static Prerendering Configuration (TanStack Start)
impact: HIGH
impactDescription: optimizes SEO and performance for static content
tags: start, tanstack, prerendering, static, seo
---

## Static Prerendering Configuration

Configure static prerendering using the built-in prerender configuration.

**Prerendering configuration:**

```ts
// vite.config.ts

import { tanstackStart } from '@tanstack/react-start/plugin/vite'
import viteReact from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [
    tanstackStart({
      prerender: {
        // Enable prerendering
        enabled: true,

        // Enable if you need pages to be at `/page/index.html` instead of `/page.html`
        autoSubfolderIndex: true,

        // If disabled, only the root path or the paths defined in the pages config will be prerendered
        autoStaticPathsDiscovery: true,

        // How many prerender jobs to run at once
        concurrency: 14,

        // Whether to extract links from the HTML and prerender them also
        crawlLinks: true,

        // Filter function takes the page object and returns whether it should prerender
        filter: ({ path }) => !path.startsWith('/do-not-render-me'),

        // Number of times to retry a failed prerender job
        retryCount: 2,

        // Delay between retries in milliseconds
        retryDelay: 1000,

        // Maximum number of redirects to follow during prerendering
        maxRedirects: 5,

        // Fail if an error occurs during prerendering
        failOnError: true,

        // Callback when page is successfully rendered
        onSuccess: ({ page }) => {
          console.log(`Rendered ${page.path}!`)
        },
      },
      // Optional configuration for specific pages
      // Note: When autoStaticPathsDiscovery is enabled (default), discovered static
      // routes will be merged with the pages specified below
      pages: [
        {
          path: '/my-page',
          prerender: { enabled: true, outputPath: '/my-page/index.html' },
        },
      ],
    }),
    viteReact(),
  ],
})
```

Reference: [https://tanstack.com/start/latest/docs/framework/react/guide/static-prerendering](https://tanstack.com/start/latest/docs/framework/react/guide/static-prerendering)
