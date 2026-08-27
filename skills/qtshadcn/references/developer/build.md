---
name: developer-build
description: QtShadcn 本仓库构建运行、QML 静态验证、qmlcache 机制、组件截图与 showcase 结构。
---

# 构建与验证（本仓库）

```bash
make build    # cmake + 增量构建
make run      # 构建并跑 showcase（GUI，需真实桌面）
make clean    # 删构建目录
make fresh    # clean + build
make info     # 打印 Qt / 产物路径
```

- Qt 要求 **6.5+**（本仓库 Makefile 默认 `$(HOME)/Qt/6.11.1/macos`，**不是自动探测**）
- 覆盖前缀：`make build QT_PREFIX=/path/to/qt` 或环境变量 `QT_PREFIX`
  - macOS 安装器：`~/Qt/<ver>/macos`
  - Linux 安装器：`~/Qt/<ver>/gcc_64`
  - Homebrew：`$(brew --prefix qt)`
- 产物：`build/src/QtShadcn`（QML 模块）+ `build/bin/showcase`
- 库文件名随平台：`libQtShadcn.dylib`（macOS）/ `.so`（Linux）/ `.dll`（Windows）
- **沙箱 shell 跑不了 GUI**，`make run` 让用户在自己的终端执行

## QML 静态验证（无窗口，本仓库 showcase）

```bash
QT_QPA_PLATFORM=offscreen \
QML_IMPORT_PATH="$(pwd)/build/src:$(pwd)/build/examples/showcase" \
./build/bin/showcase
# 3 秒无 stderr（error/warning/Cannot）即视为 OK
```

- offscreen 下 Flickable/TextEdit 不执行完整布局，滚动交互无法验证，需 GUI 目测

> ⚠️ **验证必须让二进制真正跑起来**。本机 `timeout` 命令不存在，
> `timeout 12 ./build/bin/showcase` 会直接 `command not found` 然后脚本退出，
> 后续 `grep` 拿到空输出被误判为「无错误」（假阴性）。正确做法二选一：
> 1. 后台进程 + sleep + kill：`./build/bin/showcase > /tmp/t.log 2>&1 & sleep 8; kill %1`
>    （Hermes 终端不限 `&`，用 `terminal(background=true)` 起进程，再 sleep 后读日志）
> 2. 用 `QML_IMPORT_TRACE=1` 跑，grep `not a type|unavailable` 确认类型真的被解析
>    （`resolveType: "...TableView" => "QQuickTableView" TYPE` 即成功）

## 坑：Qt 6 的 TableView 属于 QtQuick，不在 QtQuick.Controls

`TableView` 在 Qt 6 是 **`QtQuick` 模块的原生类型**（`QQuickTableView`），
**不是** `QtQuick.Controls` 的成员。`QtQuick.Controls` 里只有 `TableViewDelegate`。

- ❌ `import QtQuick.Controls as QQC` 后写 `QQC.TableView { }` → `QQC.TableView is not a type`
- ✅ 直接用 `TableView { }`（文件顶部已有 `import QtQuick` 即可，无需 alias）
- 验证：`QML_IMPORT_TRACE=1` 应出现 `resolveType: "TableView" => "QQuickTableView" TYPE`
- 注意：`qt_add_qml_module` 的 `DEPENDENCIES` 仍应含 `QtQuick` / `QtQuick.Controls`（控件如
  `QQC.ComboBox` 在 Controls 里），但 `TableView` 本身来自 QtQuick。

## 坑：qmlcache AOT 下 TableView.onClicked 不可用

qmlcache 预编译（AOT）对原生 `QQuickTableView` 的 `clicked` 信号暴露不全，
写 `TableView { onClicked: ... }` 会报 `Cannot assign to non-existent property "onClicked"`。

- ❌ `TableView { onClicked: function(pos){...} }`
- ✅ 用 `TapHandler` 包裹捕获点击（AOT 友好）：
```qml
TableView {
    TapHandler {
        onTapped: function(p) {
            var r = view.rowAt(p.position.x, p.position.y)
            if (r >= 0) { currentRow = r; rowClicked(r) }
        }
    }
}
```

## 坑：独立 qml 工具无法加载本库插件（macOS 签名）

`Qt/6.11.1/macos/bin/qml` 是 Qt 官方签名的独立启动器，与本地编译的
`build/src/QtShadcn/libQtShadcnplugin.dylib` **Team ID 不同**，dlopen 会被
系统拒绝：`code signature ... not valid for use in process: mapping process and
mapped file have different Team IDs`。

- ❌ 不要指望用 `qml xxx.qml` + `QML_IMPORT_PATH` 来离线验证本库 QML
- ✅ 验证本库 QML 模块/组件，直接跑**同签名的 showcase 二进制**（编译时已链接该
  dylib）：`QT_QPA_PLATFORM=offscreen ./build/bin/showcase`，3 秒无 stderr 即 OK
- ✅ 纯 QML 语法/类型错误会在 `make build` 的 qmlcache 编译期直接报错，等价于一次
  离线校验

## 坑：Qt 6 移除 QVariant::operator<

`QVariant a, b; if (a < b)` 在 Qt 6 **编译失败**（运算符已删）。任何 QVariant
比较（如表格按列排序）改用静态函数：

```cpp
// ❌ Qt5 写法，Qt6 硬失败
std::sort(rows.begin(), rows.end(), [&](const QVariant &a, const QVariant &b){
    return cellOf(a, key) < cellOf(b, key);
});
// ✅ Qt6 写法
std::sort(rows.begin(), rows.end(), [&](const QVariant &a, const QVariant &b){
    bool less = QVariant::compare(cellOf(a, key), cellOf(b, key)) == QPartialOrdering::Less;
    return ascending ? less : !less;
});
```

注：clang LSP 对 `QVariant::compare` 可能仍误报，以真实编译器为准（信编译器不信 LSP）。

## 关键：QML 编译进动态库

- QtShadcn 的 QML 经 `qt_add_qml_module` 编进库（qmlcache），**不是从源码目录热加载**
- 跑二进制前必须先 `make build`，否则加载旧 qmlcache
- 改 QML 源后必须重新 `make build` 才生效

## 组件截图（本仓库文档效果图）

实现：`scripts/screenshot.sh` 调 showcase `--screenshot <Page.qml> --output <png> [--crop x,y,w,h]`。
流程：切到目标页 → 等渲染 → **`grabWindow()` 整窗** → 可选 `QImage::copy` 裁剪 → 保存退出。
**不是** `grabToImage`，也 **不是** 只 grab `contentStack`。

```bash
make build
bash scripts/screenshot.sh                    # 全量（默认 CROP=190,0,790,704 裁掉左侧菜单）
bash scripts/screenshot.sh button select      # 只截指定 slug 或 Page 名
CROP="" bash scripts/screenshot.sh            # 不裁剪（整窗）
CROP="x,y,w,h" bash scripts/screenshot.sh     # 自定义裁剪
SHOT_DELAY_MS=2000 SLEEP=1 bash scripts/screenshot.sh   # 复杂页更稳
SKIP_OVERVIEW=1 bash scripts/screenshot.sh    # 跳过 form 等非纯组件页
```

- 输出：`docs/public/images/components/<slug>.png`（kebab-case，与文档 slug 对齐）
- 环境：`QT_QPA_PLATFORM=offscreen`、`QTSHADCN_SCREENSHOT=1`（关 MultiEffect 等 GPU 特效，否则 Card 等空白）
- `SHOT_DELAY_MS` 默认 1200；`SLEEP` 默认 0.6
- offscreen 下 `grabWindow` 走软件渲染，沙箱可跑

## showcase 结构

- `examples/showcase/Main.qml`：左侧菜单 + 右侧 StackLayout
- 每组件一页：`examples/showcase/pages/<Component>Page.qml`
- 新增 page 同步 3 处：`Main.qml` 菜单 + StackLayout + `showcase/CMakeLists.txt` 的 `QML_FILES`
- 总览 `OverviewPage.qml` 卡片 `available: true` 点亮
