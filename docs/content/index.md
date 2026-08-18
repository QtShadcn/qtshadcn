---
seo:
  title: QtShadcn — Qt 6 / QML 可组合 UI 组件库
  description: A modern, composable UI component library for Qt 6 / QML, inspired by shadcn/ui. Design Token 驱动的 QML 组件库，复用 Qt Quick Controls 基础行为。
---

::u-page-hero
#title
QtShadcn

#description
A modern, composable UI component library for **Qt 6 / QML**, inspired by [shadcn/ui](https://ui.shadcn.com).

Design Token → Component → Composition → Theme。QML 管 UI，C++ 管能力，复用 Qt Quick Controls 的键盘导航与无障碍。

#links
  :::u-button
  ---
  color: neutral
  size: xl
  to: /getting-started/introduction
  trailing-icon: i-lucide-arrow-right
  ---
  快速开始
  :::

  :::u-button
  ---
  color: neutral
  icon: simple-icons-github
  size: xl
  to: https://github.com/QtShadcn/qtshadcn
  variant: outline
  ---
  GitHub
  :::
::

::u-page-section
#title
设计哲学

#features
  :::u-page-feature
  ---
  icon: i-lucide-palette
  ---
  #title
  Design Token 驱动
  
  #description
  语义化颜色 / 圆角 / 间距 token，`theme.mode = "dark"` 全局随动，所有组件绑定自动刷新。
  :::

  :::u-page-feature
  ---
  icon: i-lucide-blocks
  ---
  #title
  可组合组件
  
  #description
  组件像积木一样组合：Card = CardHeader / CardContent / CardFooter，对齐 shadcn/ui 的组合方式。
  :::

  :::u-page-feature
  ---
  icon: i-lucide-keyboard
  ---
  #title
  复用 Quick Controls
  
  #description
  键盘导航、Focus、无障碍开箱即得。只替换视觉与组件 API，不重新发明基础行为。
  :::

  :::u-page-feature
  ---
  icon: i-lucide-cpu
  ---
  #title
  C++ 能力层
  
  #description
  Theme 引擎、Icon 注册、Model 等能力层落在 C++，不退化成一个「QML 样式库」。
  :::
::

::u-page-section
#title
组件状态

#features
  :::u-page-feature
  ---
  icon: i-lucide-check-circle-2
  ---
  #title
  Theme（M1 ✅）
  
  #description
  Design Token 系统：light/dark 两套 token，声明式 `QtShadcnTheme` 入口。
  :::

  :::u-page-feature
  ---
  icon: i-lucide-check-circle-2
  ---
  #title
  Button 系列（M2 ✅）
  
  #description
  ShadcnButton（6 variant × 5 size）+ ButtonGroup / Toggle / ToggleGroup / Spinner。
  :::

  :::u-page-feature
  ---
  icon: i-lucide-circle-dashed
  ---
  #title
  M3+（计划中）
  
  #description
  Input / Card / Badge / Switch / Tabs / Dialog；Icon 系统、Models / Table、WindowManager。
  :::
::
