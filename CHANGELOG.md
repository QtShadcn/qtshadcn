# Changelog

版本唯一来源是根 `CMakeLists.txt` 的 `project(VERSION)`，git tag 必须与之一致（CI 有校验）。

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
