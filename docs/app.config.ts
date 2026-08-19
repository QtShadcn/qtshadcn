export default defineAppConfig({
  docus: {
    title: 'QtShadcn',
    description: 'A modern, composable UI component library for Qt 6 / QML, inspired by shadcn/ui.',
    image: '/logo.png',
    header: {
      title: 'QtShadcn',
      // docus 5 的 header.logo 必须是对象 { light, dark }（string 不生效 → hasLogo=false，
      // 只显示 title 文字）。用纯图标 logo8.png，避免与 title 文字重复；
      // 带产品名横幅 logo.png 保留给 social share（image）
      logo: {
        light: '/logo8.png',
        dark: '/logo8.png',
      },
      showLinkIcon: true,
      fluid: true,
    },
    main: {
      fluid: true,
      padded: true,
    },
    github: {
      owner: 'QtShadcn',
      repo: 'qtshadcn',
      branch: 'main',
      main: true,
    },
  },
})
