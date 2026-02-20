import { defineConfig } from 'astro/config';
import sitemap from '@astrojs/sitemap';

export default defineConfig({
  site: 'https://must-read.github.io',
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
