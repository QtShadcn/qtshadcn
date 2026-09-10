---
name: qtshadcn-dev
description: Use when adding, modifying, or aligning components inside the QtShadcn library repo itself, or when changing its theme tokens, showcase pages, docs, or component screenshots.
---

# QtShadcn — 库开发（贡献者）

对齐 shadcn/ui 设计哲学的 Qt Quick 组件库：**QML 管 UI、C++ 管能力**，复用 Qt Quick Controls 的键盘导航与无障碍。组件带 `Shadcn` 前缀（与 QQC 基类区分）。

**本 skill 只讲「扩展/维护本仓库」。** 接入本库写业务 App → 用 `qtshadcn` skill。

## 铁律：先研究参考实现，禁止凭印象写组件

凭印象写组件会漏 variant、尺寸错一档、细节丢失（M2 实测偏差教训）。任何组件开发前：

1. 抓 shadcn 官方文档 + 源码（Base UI 为对齐基准）
2. 输出**规范对照表**（属性 / 尺寸像素 / 颜色 / 圆角 → token / 交互状态）→ **用户确认后**才写代码
3. 实现 → showcase 全状态页 → offscreen 静态验证

**权威基准 = 用户贴的 Base UI 默认 DOM**（如 Slider thumb 12px 正圆、Dialog content 384px）。

| shadcn 文档 tab | 取舍 |
|---|---|
| `bases/base/ui`（Base UI） | **对齐基准** |
| `bases/aria/ui`（React Aria） | 不跟其 `rounded-4xl`(26px) 大圆角 |
| Radix | legacy，忽略 |

完整流程（含 `gh api` 抓源码路径、样式表位置、对照表模板）见 [workflow](references/workflow.md)。

## 架构要点

- 组件 = QQC 基类 + 视觉覆盖（`background` / `contentItem` / `indicator`）；键盘导航、Focus、无障碍白拿，不要重造
- 颜色**只经 token**：`theme.tokens["primary"]`（动态索引 → `tokensChanged` 触发重算）；**禁止把颜色值存进 JS 数组/对象**（会静态化，明暗切换不刷新）
- variant → token 映射放独立 QtObject（如 `VariantTokens.qml`），数组下标 = 枚举值，组件查表 `vt.button[root.variant] ?? vt.button[0]`
- `QQuickStyle::setStyle("Basic")` 是前提（macOS native style 拒绝自定义 contentItem/background）
- 库内 QML 经 `qt_add_qml_module` 编进 dylib（qmlcache）：**改 QML 后必须重新 `make build`**
- token 契约（`ThemeManager` / `QtShadcnTheme` / 明暗 / 运行时主色 / warning·success）：单一来源在 `qtshadcn` skill 的 `references/common/core-theme.md`，本 skill 不复制。Hermes 里读：`skill_view(name='qtshadcn', file_path='references/common/core-theme.md')`

## 构建与验证（摘要）

```bash
make build     # 产物 build/src/QtShadcn（QML 模块）+ build/bin/showcase
QT_QPA_PLATFORM=offscreen \
  QML_IMPORT_PATH="$(pwd)/build/src:$(pwd)/build/examples/showcase" ./build/bin/showcase   # 3 秒无 stderr 即 OK
bash scripts/screenshot.sh button select      # 组件效果图 → docs/public/images/components/<slug>.png
```

- **验证必须让二进制真正跑起来**：本机无 `timeout` 命令，`timeout 12 ./showcase` 会 `command not found`，后续 grep 拿空输出 → 假阴性。用后台进程 + sleep + kill
- 沙箱 shell 跑不了 GUI，`make run` 交给用户自己执行
- 独立 `qml` 工具无法加载本库插件（Qt 官方签名 vs 本地编译 Team ID 不同，dlopen 被拒）→ 只用 showcase 验证

更多（TableView 归属、qmlcache AOT、`QVariant::compare`、截图裁剪参数、showcase 三处同步）见 [build](references/build.md)。

## 开发坑（务必先读）

| 坑 | 说明 |
|----|------|
| override QQC 子组件丢定位 | `handle` / `indicator` / `background` 的几何在默认模板内部，override 后须自带定位 |
| 水平居中责任转移 | contentItem 被拉伸到内容区全宽 → `Item` 包装 + `RowLayout { anchors.centerIn: parent }` |
| readonly property 引用子对象 | 创建期立即求值 → null，放惰性绑定里 |
| layer FBO 尺寸为 0 | `layer.enabled: true` 时 Rectangle 无显式 width/height → 离屏 FBO 0×0 → 内容不可见 |
| 子组件覆盖内置属性 | 自定义 `property bool enabled` 覆盖 `Item.enabled` → 信号错乱 |
| QQC.ToolTip 不自动触发 | 它是手动 API，不随父 hover 显示；须 `Item` + 向上找 hover 祖先 + `QQC.Popup` 声明式实现 |
| HoverHandler.target 需动态绑定 | 组件创建时 `parent` 可能为 null → 用 `onParentChanged` + `Component.onCompleted` 设置 |
| Text.implicitHeight 只读 | 不能赋值；需 `Item` 包裹再设 `implicitHeight` |
| ScrollView 内取 implicitHeight | 被视口裁剪取不到 → 固定 `height: implicitHeight` |
| TextArea 内部滚动 | QQC.TextArea 无 Flickable、TextEdit 不响应滚轮 → Flickable + TextEdit + ScrollBar |
| contentHeight 早期 undefined | Math.min/max 遇 NaN 传播 → `> 0` 兜底 |
| SF Mono 字体不存在 | macOS 上不在系统字体列表（触发 ~108ms 加载警告 + 构建字体别名表）→ 用 `Menlo`（`Qt.platform.os === "osx"` 判定） |

## 新增组件后必做

1. `examples/showcase/pages/<Component>Page.qml`（**全部 variant × size × 状态**）
2. 三处同步：`Main.qml` 菜单 + `StackLayout` + `showcase/CMakeLists.txt` 的 `QML_FILES`
3. `OverviewPage.qml` 卡片 `available: true` 点亮
4. docs `docs/content/2.components/<n>.<slug>.md` 用法文档 + 效果图（`scripts/screenshot.sh`）
5. 本项目 skills 同步：`qtshadcn` 的组件索引表 + `references/consumer/component-*.md`；有新坑补本 skill「开发坑」
6. 修 bug / 加组件走 issue 驱动（先 `gh issue create` → 实现 → 验证 → commit + push → `gh issue close` 附验证摘要）

## References

| 主题 | 参考 |
|------|------|
| 组件开发全流程（抓规范 → 对照表 → 实现 → showcase → 截图） | [workflow](references/workflow.md) |
| 本仓库构建 / offscreen 验证 / qmlcache / 截图 / showcase 结构 | [build](references/build.md) |
| M6 七个组件的 shadcn/ui 对齐修复记录与坑（DropdownMenu / Alert / Kbd） | [m6-compliance-fix](references/m6-compliance-fix.md) |
| 主题与 token 契约（跨 skill，在 `qtshadcn`） | `skill_view(name='qtshadcn', file_path='references/common/core-theme.md')` |
| 通用「shadcn/ui → QML」移植方法论（抓规范技巧、QQC 定制、验证手法、长期坑） | `qml-component-library-dev` skill |
