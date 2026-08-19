---
seo:
  title: QtShadcn — Qt 6 / QML 可组合 UI 组件库
  description: A modern, composable UI component library for Qt 6 / QML, inspired by shadcn/ui. Design Token 驱动的 QML 组件库，复用 Qt Quick Controls 基础行为。
---

<!-- 首页用 HTML + Tailwind 布局（docus 5 不渲染 u-page-hero/u-page-section 等旧演示组件） -->

<div class="py-14 text-center">

  <h1 class="text-4xl font-extrabold tracking-tight text-gray-900 dark:text-white">
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
      <span class="iconify i-lucide-arrow-right size-5" aria-hidden="true"></span>
    </a>
    <a href="/components/button"
       class="inline-flex items-center gap-2 rounded-lg border border-gray-300 px-5 py-2.5 text-base font-medium text-gray-900 transition-colors hover:bg-gray-50 dark:border-gray-700 dark:text-white dark:hover:bg-gray-800">
      <span class="iconify i-lucide-blocks size-5" aria-hidden="true"></span>
      组件文档
    </a>
    <a href="https://github.com/QtShadcn/qtshadcn" target="_blank"
       class="inline-flex items-center gap-2 rounded-lg border border-gray-300 px-5 py-2.5 text-base font-medium text-gray-900 transition-colors hover:bg-gray-50 dark:border-gray-700 dark:text-white dark:hover:bg-gray-800">
      <span class="iconify i-simple-icons-github size-5" aria-hidden="true"></span>
      GitHub
    </a>
  </div>
</div>

## 设计哲学

<div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-4">

  <div class="rounded-xl border border-gray-200 bg-gray-50/50 p-6 dark:border-gray-800 dark:bg-gray-900/50">
    <span class="iconify i-lucide-palette size-6 text-gray-700 dark:text-gray-300" aria-hidden="true"></span>
    <h3 class="mt-3 text-base font-semibold text-gray-900 dark:text-white">Design Token 驱动</h3>
    <p class="mt-2 text-sm leading-6 text-gray-500 dark:text-gray-400">语义化颜色 / 圆角 / 间距 token，`theme.mode = "dark"` 全局随动，所有组件绑定自动刷新。</p>
  </div>

  <div class="rounded-xl border border-gray-200 bg-gray-50/50 p-6 dark:border-gray-800 dark:bg-gray-900/50">
    <span class="iconify i-lucide-blocks size-6 text-gray-700 dark:text-gray-300" aria-hidden="true"></span>
    <h3 class="mt-3 text-base font-semibold text-gray-900 dark:text-white">可组合组件</h3>
    <p class="mt-2 text-sm leading-6 text-gray-500 dark:text-gray-400">组件像积木一样组合：Card = CardHeader / CardContent / CardFooter，对齐 shadcn/ui 的组合方式。</p>
  </div>

  <div class="rounded-xl border border-gray-200 bg-gray-50/50 p-6 dark:border-gray-800 dark:bg-gray-900/50">
    <span class="iconify i-lucide-keyboard size-6 text-gray-700 dark:text-gray-300" aria-hidden="true"></span>
    <h3 class="mt-3 text-base font-semibold text-gray-900 dark:text-white">复用 Quick Controls</h3>
    <p class="mt-2 text-sm leading-6 text-gray-500 dark:text-gray-400">键盘导航、Focus、无障碍开箱即得。只替换视觉与组件 API，不重新发明基础行为。</p>
  </div>

  <div class="rounded-xl border border-gray-200 bg-gray-50/50 p-6 dark:border-gray-800 dark:bg-gray-900/50">
    <span class="iconify i-lucide-cpu size-6 text-gray-700 dark:text-gray-300" aria-hidden="true"></span>
    <h3 class="mt-3 text-base font-semibold text-gray-900 dark:text-white">C++ 能力层</h3>
    <p class="mt-2 text-sm leading-6 text-gray-500 dark:text-gray-400">Theme 引擎、Icon 注册、Model 等能力层落在 C++，不退化成一个「QML 样式库」。</p>
  </div>

</div>

## 组件总览

<div class="grid grid-cols-1 gap-4 sm:grid-cols-2 lg:grid-cols-3">

  <a href="/components/button" class="group rounded-xl border border-gray-200 p-6 transition-colors hover:border-gray-300 hover:bg-gray-50/50 dark:border-gray-800 dark:hover:border-gray-700 dark:hover:bg-gray-900/50">
    <span class="iconify i-lucide-mouse-pointer-click size-6 text-gray-700 dark:text-gray-300" aria-hidden="true"></span>
    <h3 class="mt-3 text-base font-semibold text-gray-900 dark:text-white">Button 系列 <span class="ml-1 align-middle text-xs font-medium text-green-600 dark:text-green-400">M2 ✅</span></h3>
    <p class="mt-2 text-sm leading-6 text-gray-500 dark:text-gray-400">ShadcnButton（6 variant × 5 size + 图标）+ ButtonGroup / Toggle / ToggleGroup / Spinner。</p>
    <span class="mt-3 inline-flex items-center gap-1 text-sm font-medium text-gray-700 transition-colors group-hover:text-gray-900 dark:text-gray-300 dark:group-hover:text-white">查看文档 <span class="iconify i-lucide-arrow-right size-4" aria-hidden="true"></span></span>
  </a>

  <a href="/components/input" class="group rounded-xl border border-gray-200 p-6 transition-colors hover:border-gray-300 hover:bg-gray-50/50 dark:border-gray-800 dark:hover:border-gray-700 dark:hover:bg-gray-900/50">
    <span class="iconify i-lucide-type size-6 text-gray-700 dark:text-gray-300" aria-hidden="true"></span>
    <h3 class="mt-3 text-base font-semibold text-gray-900 dark:text-white">表单控件 <span class="ml-1 align-middle text-xs font-medium text-green-600 dark:text-green-400">M3 ✅</span></h3>
    <p class="mt-2 text-sm leading-6 text-gray-500 dark:text-gray-400">Input / InputGroup / Textarea / Checkbox / RadioGroup / Switch / Slider / Progress / Select。</p>
    <span class="mt-3 inline-flex items-center gap-1 text-sm font-medium text-gray-700 transition-colors group-hover:text-gray-900 dark:text-gray-300 dark:group-hover:text-white">查看文档 <span class="iconify i-lucide-arrow-right size-4" aria-hidden="true"></span></span>
  </a>

  <a href="/components/card" class="group rounded-xl border border-gray-200 p-6 transition-colors hover:border-gray-300 hover:bg-gray-50/50 dark:border-gray-800 dark:hover:border-gray-700 dark:hover:bg-gray-900/50">
    <span class="iconify i-lucide-credit-card size-6 text-gray-700 dark:text-gray-300" aria-hidden="true"></span>
    <h3 class="mt-3 text-base font-semibold text-gray-900 dark:text-white">布局与反馈 <span class="ml-1 align-middle text-xs font-medium text-green-600 dark:text-green-400">M3 ✅</span></h3>
    <p class="mt-2 text-sm leading-6 text-gray-500 dark:text-gray-400">Card（Header/Content/Footer）、Badge（6 variant 胶囊）、Dialog（Base UI 规格 + 可滚动 body）。</p>
    <span class="mt-3 inline-flex items-center gap-1 text-sm font-medium text-gray-700 transition-colors group-hover:text-gray-900 dark:text-gray-300 dark:group-hover:text-white">查看文档 <span class="iconify i-lucide-arrow-right size-4" aria-hidden="true"></span></span>
  </a>

  <a href="/components/tabs" class="group rounded-xl border border-gray-200 p-6 transition-colors hover:border-gray-300 hover:bg-gray-50/50 dark:border-gray-800 dark:hover:border-gray-700 dark:hover:bg-gray-900/50">
    <span class="iconify i-lucide-layout-grid size-6 text-gray-700 dark:text-gray-300" aria-hidden="true"></span>
    <h3 class="mt-3 text-base font-semibold text-gray-900 dark:text-white">导航 <span class="ml-1 align-middle text-xs font-medium text-green-600 dark:text-green-400">M3 ✅</span></h3>
    <p class="mt-2 text-sm leading-6 text-gray-500 dark:text-gray-400">Tabs（TabsList / TabsTrigger / TabsContent，default / line 双 variant）。</p>
    <span class="mt-3 inline-flex items-center gap-1 text-sm font-medium text-gray-700 transition-colors group-hover:text-gray-900 dark:text-gray-300 dark:group-hover:text-white">查看文档 <span class="iconify i-lucide-arrow-right size-4" aria-hidden="true"></span></span>
  </a>

  <a href="/components/icon" class="group rounded-xl border border-gray-200 p-6 transition-colors hover:border-gray-300 hover:bg-gray-50/50 dark:border-gray-800 dark:hover:border-gray-700 dark:hover:bg-gray-900/50">
    <span class="iconify i-lucide-sparkles size-6 text-gray-700 dark:text-gray-300" aria-hidden="true"></span>
    <h3 class="mt-3 text-base font-semibold text-gray-900 dark:text-white">Icon 系统 <span class="ml-1 align-middle text-xs font-medium text-green-600 dark:text-green-400">M4 ✅</span></h3>
    <p class="mt-2 text-sm leading-6 text-gray-500 dark:text-gray-400">ShadcnIcon + C++ IconRegistry：74 个 lucide 图标本地内置 + 远程兜底，随主题变色。</p>
    <span class="mt-3 inline-flex items-center gap-1 text-sm font-medium text-gray-700 transition-colors group-hover:text-gray-900 dark:text-gray-300 dark:group-hover:text-white">查看文档 <span class="iconify i-lucide-arrow-right size-4" aria-hidden="true"></span></span>
  </a>

  <div class="rounded-xl border border-dashed border-gray-300 p-6 dark:border-gray-700">
    <span class="iconify i-lucide-circle-dashed size-6 text-gray-400 dark:text-gray-500" aria-hidden="true"></span>
    <h3 class="mt-3 text-base font-semibold text-gray-900 dark:text-white">Animations / Models</h3>
    <p class="mt-2 text-sm leading-6 text-gray-500 dark:text-gray-400">预置动画封装、C++ Models / Table、WindowManager（M4~M5 规划中）。</p>
  </div>

</div>
