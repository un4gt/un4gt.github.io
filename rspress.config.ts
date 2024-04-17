import * as path from 'path';
import { defineConfig } from 'rspress/config';

export default defineConfig({
  root: path.join(__dirname, 'docs'),
  title: 'jennier',
  description: 'personal blogs',
  icon: './docs/public/avatar.ico',
  themeConfig: {
    socialLinks: [
      { icon: 'github', mode: 'link', content: 'https://github.com/jennier0107'},
    ],
  },
});
