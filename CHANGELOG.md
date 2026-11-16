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

### Internal

- 新增 `VariantSpec`（`src/qml/Theme/VariantSpec.qml`）：variant → token 映射的具名类型，
  替代 `VariantTokens` 里的内联 `QtObject`，让 `vt.button[i].bg` 这类访问可被静态解析，
  字段拼错变成阻塞级错误
- 新增 `.qmllint.ini` 分级门禁 + `make lint` + CI lint 步骤，QML 警告基线为 **0**
