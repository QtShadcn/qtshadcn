export default defineAppConfig({
  docus: {
    title: 'QtShadcn',
    description: 'A modern, composable UI component library for Qt 6 / QML, inspired by shadcn/ui.',
    image: '/logo.png',
    header: {
      title: 'QtShadcn',
      // 头部用纯图标 logo8.png，避免与 title 文字重复；
      // 带产品名横幅 logo.png 保留给 social share（image）
      logo: '/logo8.png',
      showLinkIcon: true,
      fluid: true,
    },
    main: {
      fluid: true,
      padded: true,
    },
    footer: {
      iconLinks: [
        {
          icon: 'i-simple-icons-github',
          href: 'https://github.com/QtShadcn/qtshadcn',
          ariaLabel: 'GitHub',
        },
      ],
    },
    github: {
      owner: 'QtShadcn',
      repo: 'qtshadcn',
      branch: 'main',
      main: true,
    },
  },
})
