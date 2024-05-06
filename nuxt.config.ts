// https://nuxt.com/docs/api/configuration/nuxt-config

import vuetify, { transformAssetUrls } from 'vite-plugin-vuetify'
//import string from 'vite-plugin-string'

import { readFileSync } from 'fs'
import { resolve } from 'path'


export default defineNuxtConfig({
  ssr: false,
  devtools: { enabled: true },
  build: {
    transpile: ['vuetify'],
  },
  modules: [
    '@pinia/nuxt',
    '@pinia-plugin-persistedstate/nuxt',
    (_options, nuxt) => {
      nuxt.hooks.hook('vite:extendConfig', (config) => {
        // @ts-expect-error
        config.plugins.push(vuetify({ autoImport: true }))
      })
    },
    //...
  ],
  vite: {
    resolve: {
      alias: {
        vue: 'vue/dist/vue.esm-bundler.js'
      }
    },
    plugins: [
      // string({
      //   include: '**/*.lua',
      // }),

      {
        name: 'load-lua',
        load(id) {
          if (id.endsWith('.lua')) {
            const filePath = resolve(__dirname, id)
            const fileContents = readFileSync(filePath, 'utf-8')
            return `export default ${JSON.stringify(fileContents)}`
          }
        },
      },

    ],

    vue: {
      template: {
        transformAssetUrls,
      },
    },
  },
})
