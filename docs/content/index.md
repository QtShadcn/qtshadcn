---
seo:
  title: QtShadcn — Qt 6 / QML 可组合 UI 组件库
  description: A modern, composable UI component library for Qt 6 / QML, inspired by shadcn/ui. Design Token 驱动的 QML 组件库，复用 Qt Quick Controls 基础行为。
---

<!-- 首页用 HTML + Tailwind 布局（docus 5 不渲染 u-page-hero/u-page-section 等旧演示组件） -->

<div class="py-16 text-center">

  <img src="/logo8.png" alt="QtShadcn" class="mx-auto mb-6 h-16 w-16" />

  <h1 class="bg-gradient-to-r from-gray-900 to-gray-600 bg-clip-text text-4xl font-extrabold tracking-tight text-transparent dark:from-white dark:to-gray-400">
    QtShadcn
  </h1>

  <p class="mx-auto mt-4 max-w-2xl text-lg text-gray-500 dark:text-gray-400">
    A modern, composable UI component library for <strong class="text-gray-700 dark:text-gray-200">Qt 6 / QML</strong>, inspired by <a href="https://ui.shadcn.com" class="font-medium underline decoration-gray-300 underline-offset-4 hover:decoration-gray-500 dark:decoration-gray-700" target="_blank">shadcn/ui</a>.
  </p>

  <p class="mx-auto mt-3 max-w-2xl text-gray-500 dark:text-gray-400">
    Design Token → Component → Composition → Theme。QML 管 UI，C++ 管能力，复用 Qt Quick Controls 的键盘导航与无障碍。
  </p>

  <div class="mt-8 flex flex-wrap items-center justify-center gap-4">
    <a href="/getting-started/introduction"
       class="inline-flex items-center gap-2 rounded-lg bg-gray-900 px-5 py-2.5 text-base font-medium text-white transition-colors hover:bg-gray-700 dark:bg-white dark:text-gray-900 dark:hover:bg-gray-200">
      快速开始
      <Icon name="i-lucide-arrow-right" class="size-5" aria-hidden="true"></Icon>
    </a>
    <a href="/components/button"
       class="inline-flex items-center gap-2 rounded-lg border border-gray-300 px-5 py-2.5 text-base font-medium text-gray-900 transition-colors hover:bg-gray-50 dark:border-gray-700 dark:text-white dark:hover:bg-gray-800">
      <Icon name="i-lucide-blocks" class="size-5" aria-hidden="true"></Icon>
      组件文档
    </a>
    <a href="https://github.com/QtShadcn/qtshadcn" target="_blank"
       class="inline-flex items-center gap-2 rounded-lg border border-gray-300 px-5 py-2.5 text-base font-medium text-gray-900 transition-colors hover:bg-gray-50 dark:border-gray-700 dark:text-white dark:hover:bg-gray-800">
      <Icon name="i-simple-icons-github" class="size-5" aria-hidden="true"></Icon>
      GitHub
    </a>
  </div>
</div>

## 设计哲学

<div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">

  <div class="rounded-xl border border-gray-200 bg-gray-50/50 p-6 dark:border-gray-800 dark:bg-gray-900/50">
    <Icon name="i-lucide-palette" class="size-6 text-gray-700 dark:text-gray-300" aria-hidden="true"></Icon>
    <h3 class="mt-3 text-base font-semibold text-gray-900 dark:text-white">Design Token 驱动</h3>
    <p class="mt-2 text-sm leading-6 text-gray-500 dark:text-gray-400">语义化颜色 / 圆角 / 间距 token，`theme.mode = "dark"` 全局随动，所有组件绑定自动刷新。</p>
  </div>

  <div class="rounded-xl border border-gray-200 bg-gray-50/50 p-6 dark:border-gray-800 dark:bg-gray-900/50">
    <Icon name="i-lucide-blocks" class="size-6 text-gray-700 dark:text-gray-300" aria-hidden="true"></Icon>
    <h3 class="mt-3 text-base font-semibold text-gray-900 dark:text-white">可组合组件</h3>
    <p class="mt-2 text-sm leading-6 text-gray-500 dark:text-gray-400">组件像积木一样组合：Card = CardHeader / CardContent / CardFooter，对齐 shadcn/ui 的组合方式。</p>
  </div>

  <div class="rounded-xl border border-gray-200 bg-gray-50/50 p-6 dark:border-gray-800 dark:bg-gray-900/50">
    <Icon name="i-lucide-keyboard" class="size-6 text-gray-700 dark:text-gray-300" aria-hidden="true"></Icon>
    <h3 class="mt-3 text-base font-semibold text-gray-900 dark:text-white">复用 Quick Controls</h3>
    <p class="mt-2 text-sm leading-6 text-gray-500 dark:text-gray-400">键盘导航、Focus、无障碍开箱即得。只替换视觉与组件 API，不重新发明基础行为。</p>
  </div>

  <div class="rounded-xl border border-gray-200 bg-gray-50/50 p-6 dark:border-gray-800 dark:bg-gray-900/50">
    <Icon name="i-lucide-cpu" class="size-6 text-gray-700 dark:text-gray-300" aria-hidden="true"></Icon>
    <h3 class="mt-3 text-base font-semibold text-gray-900 dark:text-white">C++ 能力层</h3>
    <p class="mt-2 text-sm leading-6 text-gray-500 dark:text-gray-400">Theme 引擎、Icon 注册、Model 等能力层落在 C++，不退化成一个「QML 样式库」。</p>
  </div>

</div>