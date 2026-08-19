---
name: workflow
description: 给 QtShadcn 添加新组件的标准流程：先研究 shadcn/ui 官方规范再实现。
---

# 组件开发流程

## 铁律流程

1. **抓 shadcn/ui 官方文档**（curl 走代理 7897）+ 源码：
   - 文档页：`https://ui.shadcn.com/docs/components/<name>`
   - 源码：`gh api repos/shadcn-ui/ui/contents/apps/v4/registry/bases/base/ui/<name>.tsx`
   - 样式 CSS：`apps/v4/registry/styles/style-luma.css`（拿 cn-* 类的具体像素/颜色值）
2. **写规范对照表**（组件属性 / 尺寸 / 颜色 / 圆角 → token）→ 用户确认 → 实现
3. **showcase 全状态展示验证**（新建 `<Component>Page.qml`）
4. offscreen 静态验证（无 stderr）

## 对齐基准（重要）

shadcn 文档每个组件有 Base UI / React Aria / Radix 三个 tab：

- 默认 `bases/base/ui` = **Base UI**（QtShadcn 对齐基准）
- `bases/aria/ui` = React Aria 独立变体（`rounded-4xl` 大圆角 + `p-6`，**不跟其大圆角**）
- Radix = legacy（忽略）

**权威基准 = 用户贴的 Base UI 默认 DOM**（如 Slider thumb 12px 正圆、Dialog content 384px）。

## 组件命名

- 组件带 `Shadcn` 前缀（`ShadcnButton`），与 QQC 基类区分
- 组合子组件：`ShadcnCard` + `ShadcnCardHeader/Title/Description/Content/Footer`

## 组件模板

```qml
import QtQuick
import QtQuick.Controls.Basic
import QtShadcn

// 注释：对齐规范说明 + 用法示例
T.SomeControl {   // 或直接 QQC 基类
    id: root
    QtShadcnTheme { id: theme }

    // 公开 API（variant/size 等 enum + property）

    // 视觉：background/contentItem/indicator 等
}
```

## 圆角决策

- 控件 6px（`rounded-md`）/ 容器 8px / Badge 胶囊
- Dialog overlay 圆角 14px（`rounded-xl`，刻意大于 M2 容器，shadcn overlay > inline 惯例）
- 不跟 luma `rounded-4xl`(26px)

## 新增组件后必做

1. `examples/showcase/pages/<Component>Page.qml`（全状态 + QML 用法）
2. `Main.qml` 菜单 + StackLayout + `showcase/CMakeLists.txt` 三处同步
3. `OverviewPage.qml` 点亮 `available: true`
4. docs `content/2.components/<name>.md` 用法文档 + 效果图
5. 本 skills 的 `SKILL.md` 表格 + 对应 reference 更新

## 生成组件效果图（截图）

```bash
make build
bash scripts/screenshot.sh <new-component-slug>   # 只截新增组件（如 bash scripts/screenshot.sh accordion）
# 或全量刷新：
bash scripts/screenshot.sh
# 更慢更稳（复杂页面）：
SHOT_DELAY_MS=2000 SLEEP=1 bash scripts/screenshot.sh
```

- 脚本自动遍历 `examples/showcase/pages/*Page.qml`，调用 showcase 的 `--screenshot` 模式，
  输出到 `docs/public/images/components/<slug>.png`（kebab-case，与文档 slug 对齐）
- 截图只截右侧内容区（grab `contentStack.itemAt(currentIndex)`，不含左侧菜单）
- offscreen 平台下 `grabToImage` 走软件渲染，无需 GUI（沙箱可跑）
- 文档引用：`![<组件> 效果展示](/images/components/<slug>.png)`
- 新增组件 Page 后，重跑脚本即可刷新对应图（无需手动处理命名）

