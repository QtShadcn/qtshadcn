export default defineNuxtConfig({
  extends: ['docus'],
  icon: {
    // .navigation.yml 的侧边栏菜单图标（i-lucide-*）不被 Nuxt Icon 扫描进 bundle，
    // 运行时 fallback 到 Iconify API 会报 "failed to load icon"（被墙）。
    // 显式列进 client bundle 即可本地打包。
    clientBundle: {
      icons: [
        'lucide:rocket',
        'lucide:blocks',
        'lucide:drafting-compass',
        'lucide:puzzle',
      ],
    },
  },
  content: {
    build: {
      markdown: {
        highlight: {
          langs: ['qml', 'cpp', 'c'],
        },
      },
    },
  },
})
