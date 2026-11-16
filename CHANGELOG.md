# Changelog

版本唯一来源是根 `CMakeLists.txt` 的 `project(VERSION)`，git tag 必须与之一致（CI 有校验）。

## Unreleased

v0.2.0 发布后与 shadcn v4 base 的对齐，无 API 破坏。

### Changed

- **`ShadcnButton` 尺寸整体收紧一档到 shadcn v4 base 口径**（视觉变化，API 不变）：
  `ExtraSmall` 32→24(`h-6`) / `Small` 36→28(`h-7`) / `Medium` 40→32(`h-8`) /
  `Large` 44→36(`h-9`) / `Icon` 40→32(`size-8`)。横向内边距 `px-4`/`px-8` 改为
  `px-2.5`（xs 为 `px-2`），图标-文字间距 `gap-1`/`gap-1.5`，内联图标随尺寸
  12/14/16。旧值是 shadcn **v3** 口径，这正是「我们的按钮比官网大一圈」的根因
- **圆角统一从 `theme.radius` 派生**，不再写死像素。`QtShadcnTheme` 新增
  `radiusSm`(×0.6) / `radiusMd`(×0.8) / `radiusLg`(=radius) / `radiusXl`(×1.4)，
  对齐 v4 `@theme inline` 的 `--radius-*` 派生公式。按钮改绑 `radiusLg`/`radiusMd`，
  对话框（含 Content 与关闭钮）改绑 `radiusXl`/`radiusMd` —— 改主题 radius 时
  两者一起动，不再各自漂移（此前按钮 6、弹窗 14 就是漂移结果）
- **`ShadcnScrollBar` 不再在亚像素溢出时显示 thumb**：判定由 `size < 1.0` 改为
  「实际溢出像素 > 1px」。文本换行后的隐式高度常带小数（如 83.4），`size` 会变成
  0.996，导致「内容明明放得下」也画出一根几乎撑满全高的条
- **`ShadcnDialogContent` 高度向上取整**（`ceil`）：视口与 contentHeight 取整到同一
  整数，避免 0.4px 误差让滚动条常驻
- **`make run` 不再注入 `QML_IMPORT_PATH`**：QtShadcn 的 qmldir 是
  `prefer :/qt/qml/QtShadcn/`，模块已编译进库资源，链接上即可 import。
  该变量此前被当成硬性步骤，属于多余的坑
- **QML lint 债务清理**：清掉 8 处未使用 `import`（RadioGroup / DropdownMenuGroup /
  DropdownMenuContent / Table / KbdGroup / ButtonGroup），`UnusedImports` 因此
  升为阻塞级 —— 未使用的 import 是纯垃圾，删除零风险
- `ShadcnDialogContent` / `ShadcnAlert` / `ShadcnAvatar` 共 20 处补 `root.` 限定符
  （原本直接访问 root 自身属性，`_pad` / `_gap` / `_footerH` / `_radius` / `_useImage` / `variant`）
- `ShadcnCard` 把 `theme.mode === "dark"` 收敛为 `root._isDark`，描边与阴影复用同一判断
- `.qmllint.ini` 修正阻塞机制：不再逐类别设 `error`（该级别 Qt 6.9 才有，在 CI 的
  6.8.3 上会让 qmllint 以 `Invalid logging level` 直接 exit 255），改为靠
  `MaxWarnings=0` 达成同等阻塞效果，一份配置同时适配 6.8 与 6.11

### Docs

- `docs/content/2.components/1.button.md`：新增「尺寸对照」表（v4 的 height / padding /
  gap / 字号 / 内联图标五列），并说明圆角走 `theme.radiusLg` / `theme.radiusMd` 派生
- `docs/content/2.components/17.dialog.md`：圆角改为 `theme.radiusXl`；补「未实现背景
  模糊」的原因（试过 ShaderEffectSource 与 layer.effect 两条路，代价大于收益）
- `docs/content/1.getting-started/3.usage.md`：Theme 属性表补 `radiusSm/Md/Lg/Xl` 派生值
- `docs/content/4.development/1.component-workflow.md`：研究阶段补「从 registry JSON /
  style-nova.css 取数」的命令，并把圆角规则改为「抄刻度不抄像素」
- `docs/content/4.development/2.m3-components-spec.md`：圆角决策表按 v4 实际刻度重写
- `skills/qtshadcn*/references/*`：Button 尺寸表、Dialog 圆角、圆角决策同步到派生值口径
- `docs/content/2.components/5.card.md`：新增「布局」小节，说明内容容器是
  `ColumnLayout`、`Layout.fillHeight` 的用法，以及直接子项不能用 `x` / `y`
- `docs/content/2.components/14.select.md`：新增「数据模型」小节，列出 JS 数组 /
  对象数组 + textRole / ListModel / C++ 容器四种来源均可直接使用
- `docs/content/1.getting-started/5.milestones.md`：修正组件表格行首多余的 `|`
  （9 行，会渲染出空列）；M6 标记完成（v0.2.0 发布 + `find_package` 收口）
- `tests/CMakeLists.txt`：修正「库未安装，import 只能靠 -import 解析」的过时注释

## 0.2.0

破坏性版本：`ShadcnCard` 的内容容器换了类型，子组件宽度管理方式改变。

### Breaking

- **`ShadcnCard` 内容容器从 `Column` 改为 `ColumnLayout`**
  - 好处：卡片内子项现在支持 `Layout.fillWidth` / `Layout.fillHeight`，不用再手算
    「卡片高 − Header − Footer − 内边距」这类表达式
  - 影响：Card 直接子项若用 `x` / `y` 自由定位，位置会被 Layout 接管；改用
    `Layout.alignment: Qt.AlignCenter` 等布局属性
- **`ShadcnCardHeader` / `ShadcnCardContent` / `ShadcnCardFooter` 不再接受调用方设 `width`**
  - 宽度统一由 Card 的 ColumnLayout 通过 `Layout.fillWidth` 管理（此前是内部写
    `width: parent.width`），这三个组件只应在 `ShadcnCard` 内使用
- **`ShadcnCard` 显式声明 `Layout.minimumWidth: 0`**
  - 修复：此前 `implicitWidth: 320` 被 Layout 当成最小宽，一行放 4 张卡
    → 最小宽 1316px，把整个窗口顶宽、右侧被切

### Fixed

- `ShadcnSelect` 喂 C++ 模型（`QVariantList` / `QStringList`）且设了 `textRole` 时，
  下拉项显示字面量 `"undefined"`
  - 根因：用 `Array.isArray(model)` 分流，而 C++ 容器在 QML 里 `Array.isArray` 为 `false`
  - 改为统一从 delegate 注入的 `modelData` 取 `textRole` 字段，取不到才退回 `String(modelData)`
- `ShadcnSelect` delegate 用 `parent.parent._text` 链式访问属性，
  改为 `pragma ComponentBehavior: Bound` + `delegateRoot` id 显式引用
- `ShadcnSkeleton` 声明 `property int radius` 覆盖了 Rectangle 基类属性，
  导致文档里 `radius: 20` 画圆形的用法一直失效
- `ShadcnDropdownMenuShortcut` 缺少 `import QtQuick.Layouts`，且与 `anchors.verticalCenter`
  混用（容器是 RowLayout，anchors 在 Layout 中非法）

### Added

- **`find_package(QtShadcn)` 支持**（M6 收口）：`cmake --install` 后可被外部工程
  按 `<prefix>/lib/cmake/QtShadcn` 找到，导出的目标是 `QtShadcn::QtShadcn`
  - 链接该目标即可 `import QtShadcn`，**运行时无需 `QML_IMPORT_PATH`**
    （qmldir 里是 `prefer :/qt/qml/QtShadcn/`，QML 模块已编译进库资源）
  - 另装一份磁盘副本到 `<prefix>/lib/qml/QtShadcn`（含 qmldir / qmltypes / .qml / 插件），
    供 qmllint、qmlls、Qt Designer 使用；CMake 变量 `QtShadcn_QML_IMPORT_PATH` 指过去
  - 只作为顶层项目构建时安装；被 FetchContent / add_subdirectory 引入时不装
  - `tests/consumer/` 是消费方冒烟工程，CI 每次安装后用它验证
    `find_package → 链接 → 实例化组件` 全链路（`make consumer-smoke` 本地同款）

### Internal

- 新增 `VariantSpec`（`src/qml/Theme/VariantSpec.qml`）：variant → token 映射的具名类型，
  替代 `VariantTokens` 里的内联 `QtObject`，让 `vt.button[i].bg` 这类访问可被静态解析，
  字段拼错变成阻塞级错误
- 新增 `.qmllint.ini` 分级门禁 + `make lint` + CI lint 步骤，QML 警告基线为 **0**
- **新增 QML 组件测试**（`tests/qml/tst_*.qml`，11 个用例，由 `tests/qmltests_main.cpp`
  的 Qt Quick Test runner 驱动，`ctest` 里每个组件是独立一项）
  - 覆盖：Card / Select / Skeleton / Button / Badge / Switch / Checkbox / Progress /
    DropdownMenuItem / Input / Alert
  - 断言锁的是行为而非实现：4 张卡在 640 宽的行里平分为 154、`Layout.fillHeight`
    真的撑满、C++ `QVariantList` + `textRole` 的下拉项文本、Skeleton `radius` 生效、
    快捷键在 RowLayout 中右对齐
  - runner 通过 context property 注入 C++ `QVariantList`，复现「`Array.isArray`
    为 false」这一纯 QML 造不出的输入形态
  - 用例做过变异验证：把 Card 容器改回 `Column`、Select 改回 `model[textRole]`、
    Shortcut 去掉 `import QtQuick.Layouts`、Skeleton 默认圆角改成 2，
    对应用例全部失败
- **示例收敛为 2 个**：只留 `showcase`（组件视觉基线 + 截图验证入口）和
  `ai-dashboard`（真实消费者，最能暴露 API 设计缺陷）。`fire-safety` / `bms-eol`
  已从仓库移除，需要时按 tag 从 git 历史取回
