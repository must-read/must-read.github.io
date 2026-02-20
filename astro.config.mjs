import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://must-read.org',
  output: 'static',
  outDir: './docs',
  build: {
    format: 'directory',
  },
  markdown: {
    shikiConfig: { theme: 'css-variables' },
  },
  integrations: [sitemap()],
});
