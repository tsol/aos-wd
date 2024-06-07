// vite.config.js
import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [
    vue(),
  ],
  resolve: {
    alias: {
      vue: 'vue/dist/vue.esm-bundler.js'
    }
  },
  build: {
    outDir: 'dist',
    assetsDir: '',
    rollupOptions: {
      input: './index.ts',
    },
    minify: 'terser',
    // sourcemap: true,
  },
  mode: 'production', 
  logLevel: 'warn', 
})