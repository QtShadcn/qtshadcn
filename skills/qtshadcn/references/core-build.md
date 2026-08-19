---
name: build
description: QtShadcn 构建、运行与 QML 静态验证流程。
---

# 构建与验证

## 构建

```bash
make build    # 自动探测 Qt 路径（~/Qt/6.11.1/macos），cmake + build
```

- Qt 6.11.1 @ `~/Qt/6.11.1/macos`（arm64）
- `make` 探测逻辑在 `Makefile`，无需手动设置 `CMAKE_PREFIX_PATH`

## 运行

```bash
make run      # 运行 showcase（GUI 窗口，需真实桌面环境）
```

- **沙箱 shell 跑不了 GUI 窗口**，GUI 目测由用户在终端执行

## QML 静态验证（无窗口）

```bash
QT_QPA_PLATFORM=offscreen \
QML_IMPORT_PATH="$(pwd)/build/src:$(pwd)/build/examples/showcase" \
./build/bin/showcase
# 3 秒无 stderr（error/warning/Cannot）即视为 OK
```

- offscreen 下 Flickable/TextEdit 不执行完整布局，滚动交互无法验证，需 GUI 目测

## 关键：QML 编译进 dylib

- QtShadcn 模块的 QML 经 `qt_add_qml_module` 编译进 `libQtShadcn.dylib`（qmlcache），**不是从目录热加载**
- **直接跑 `build/bin/showcase` 前必须先 `make build`**，否则加载旧 qmlcache（报旧错误）
- 改 QML 源后必须重新 `make build` 才生效

## 组件截图（生成文档效果图）

```bash
make build
bash scripts/screenshot.sh                    # 全量（默认裁掉左侧菜单 190px）
bash scripts/screenshot.sh button select      # 只截指定组件（slug 或 Page 名）
CROP="" bash scripts/screenshot.sh            # 不裁剪（整窗 980×720）
CROP="x,y,w,h" bash scripts/screenshot.sh     # 自定义裁剪矩形
```

- showcase 支持 `--screenshot <Page文件名> --output <png> [--crop x,y,w,h]`：
  切到目标页面 → 等渲染 → `grabWindow()` 整窗截图 → 可选 `QImage::copy` 裁剪 → 保存 → 退出
- `scripts/screenshot.sh` 遍历所有 `*Page.qml` 批量出图到 `docs/public/images/components/<slug>.png`
- `CROP` 环境变量默认 `190,0,790,704`（裁掉左侧 190px 菜单）；`CROP=""` 整窗；裁剪坐标可自行指定
- 可调参数：`SHOT_DELAY_MS`（渲染等待，默认 1200ms）、`SLEEP`（张间间隔，默认 0.6s）
- offscreen 平台 `grabWindow` 走软件渲染，无需 GUI

## showcase 结构

- 主界面 `examples/showcase/Main.qml`：左侧菜单（可滚动）+ 右侧 StackLayout 页面
- 每个组件一个独立 page：`examples/showcase/pages/<Component>Page.qml`
- 新增组件 page 需同步 3 处：`Main.qml` 菜单项 + StackLayout + `showcase/CMakeLists.txt` 的 `QML_FILES`
- 总览页 `OverviewPage.qml` 组件卡片（`available: true` 点亮）
