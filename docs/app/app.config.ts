export default defineAppConfig({
  // docus 5 配置为顶层结构（旧版包在 docus:{} 里的 header/logo 等写法已废弃，不会生效）
  header: {
    title: 'QtShadcn',
    // docus 5 的 header.logo 必须是对象 { light, dark }（string 不生效 → hasLogo=false，
    // 只显示 title 文字）。用纯图标 logo8.png，避免与 title 文字重复；
    // 带产品名横幅 logo.png 保留给 social share（seo.image）
    logo: {
      light: '/logo8.png',
      dark: '/logo8.png',
      alt: 'QtShadcn',
    },
  },
  seo: {
    title: 'QtShadcn',
    titleTemplate: '%s - QtShadcn',
    description: 'A modern, composable UI component library for Qt 6 / QML, inspired by shadcn/ui. Design Token 驱动的 QML 组件库，复用 Qt Quick Controls 基础行为。',
    image: '/logo.png',
  },
  github: {
    url: 'https://github.com/QtShadcn/qtshadcn',
    branch: 'main',
  },
  socials: {
    github: 'https://github.com/QtShadcn/qtshadcn',
  },
  docus: {
    locale: 'en',
    colorMode: '',
  },
  ui: {
    colors: {
      primary: 'blue',
      neutral: 'slate',
    },
  },
  // 图标用 svg 模式直接渲染内联 SVG（css 模式输出 span.iconify 依赖 iconify web
  // component 运行时，未随包加载时图标为空白）
  icon: {
    mode: 'svg',
  },
})
