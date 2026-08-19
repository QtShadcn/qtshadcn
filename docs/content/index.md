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
  size: xl
  to: /components/button
  trailing-icon: i-lucide-blocks
  ---
  组件文档
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
组件总览

#features
  :::u-page-feature
  ---
  icon: i-lucide-mouse-pointer-click
  to: /components/button
  ---
  #title
  Button 系列（M2 ✅）
  
  #description
  `ShadcnButton`（6 variant × 5 size + 图标）+ ButtonGroup / Toggle / ToggleGroup / Spinner。
  :::

  :::u-page-feature
  ---
  icon: i-lucide-type
  to: /components/input
  ---
  #title
  表单控件（M3 ✅）
  
  #description
  Input / InputGroup / Textarea / Checkbox / RadioGroup / Switch / Slider / Progress / Select。
  :::

  :::u-page-feature
  ---
  icon: i-lucide-credit-card
  to: /components/card
  ---
  #title
  布局与反馈（M3 ✅）
  
  #description
  Card（Header/Content/Footer）、Badge（6 variant 胶囊）、Dialog（Base UI 规格 + 可滚动 body）。
  :::

  :::u-page-feature
  ---
  icon: i-lucide-layout-grid
  to: /components/tabs
  ---
  #title
  导航（M3 ✅）
  
  #description
  Tabs（TabsList / TabsTrigger / TabsContent，default / line 双 variant）。
  :::

  :::u-page-feature
  ---
  icon: i-lucide-sparkles
  to: /components/icon
  ---
  #title
  Icon 系统（M4 ✅）
  
  #description
  `ShadcnIcon` + C++ `IconRegistry`：74 个 lucide 图标本地内置 + 远程兜底，随主题变色。
  :::

  :::u-page-feature
  ---
  icon: i-lucide-circle-dashed
  ---
  #title
  Animations / Models（规划中）
  
  #description
  预置动画封装、C++ Models / Table、WindowManager（M4~M5）。
  :::
::
