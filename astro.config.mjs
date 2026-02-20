import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://bedwards.github.io',
  base: '/must-read',
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
