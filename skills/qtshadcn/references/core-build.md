---
name: build
description: QtShadcn 构建、运行、消费方脚手架与 QML 静态验证流程。
---

# 构建与验证

## 本仓库构建

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

## 消费方脚手架（给用户写项目时必做）

目标项目约定布局（通用，别人也能照抄）：

```text
myapp/
├── CMakeLists.txt
├── Makefile
├── main.cpp
├── Main.qml
└── third_party/
    └── qtshadcn/          # git submodule 或 clone 本仓库
```

清单：

1. **没有 `Makefile` → 立刻新增**；已有则只补缺失的 `build` / `run` / `clean` / `fresh` / `info`，不覆盖用户已有 target
2. 最小文件：`CMakeLists.txt`、`main.cpp`、至少一个 QML、根 `Makefile`、`third_party/qtshadcn`
3. 获取库：`git submodule add https://github.com/QtShadcn/qtshadcn.git third_party/qtshadcn`（或同路径 clone）
4. `add_subdirectory(third_party/qtshadcn)` —— 作为子项目时默认不编 showcase（`QTSHADCN_BUILD_EXAMPLES=ON` 可打开）
5. `main.cpp` **必须** `QQuickStyle::setStyle("Basic")`
6. 窗口里先放 `QtShadcnTheme`
7. `QML_IMPORT_PATH` = **含 `QtShadcn/` 模块目录的父路径** = `$(BUILD_DIR)/third_party/qtshadcn/src`
8. 可执行文件输出到 `$(BUILD_DIR)/bin/$(APP)`，与 Makefile 的 `BIN` 一致
9. `find_package(QtShadcn)` **尚未提供**，不要写假的安装导入

### 最小 CMakeLists.txt

```cmake
cmake_minimum_required(VERSION 3.24)
project(MyApp VERSION 0.1.0 LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml QuickControls2 Svg Network)
qt_standard_project_setup(REQUIRES 6.5)

add_subdirectory(third_party/qtshadcn)

qt_add_executable(myapp main.cpp)
qt_add_qml_module(myapp
    URI MyApp
    VERSION 1.0
    QML_FILES Main.qml
)
target_link_libraries(myapp PRIVATE QtShadcn Qt6::Gui Qt6::Quick Qt6::Qml Qt6::QuickControls2)
set_target_properties(myapp PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)
```

把 `myapp` / `MyApp` 换成真实目标名。

### 最小 main.cpp

```cpp
#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQuickStyle>

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
    QQuickStyle::setStyle("Basic");   // token 自绘前提，必做

    QQmlApplicationEngine engine;
    engine.loadFromModule("MyApp", "Main");
    if (engine.rootObjects().isEmpty())
        return -1;
    return app.exec();
}
```

### 消费方 Makefile

`QT_PREFIX`：有环境变量就用；否则取 `~/Qt/6.*/macos` 中版本号最新的一项；再没有则回退默认路径。`BIN` 用本项目可执行文件，**不要抄 showcase**。

```makefile
# 快捷命令：make build / run / clean / fresh / info

QT_PREFIX ?= $(shell ls -d $(HOME)/Qt/6.*/macos 2>/dev/null | sort -V | tail -1)
ifeq ($(QT_PREFIX),)
  QT_PREFIX := $(HOME)/Qt/6.11.1/macos
endif
BUILD_DIR ?= build
APP       ?= myapp
BIN        = $(BUILD_DIR)/bin/$(APP)
JOBS      ?= $(shell sysctl -n hw.ncpu 2>/dev/null || echo 4)
# 含 QtShadcn 模块目录的父路径（third_party 布局）
QML_IMPORT ?= $(CURDIR)/$(BUILD_DIR)/third_party/qtshadcn/src

.PHONY: build run clean fresh info

build:
	cmake -S . -B $(BUILD_DIR) -DCMAKE_PREFIX_PATH="$(QT_PREFIX)" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
	cmake --build $(BUILD_DIR) -j$(JOBS)

run: build
	QML_IMPORT_PATH="$(QML_IMPORT)" $(BIN)

clean:
	rm -rf $(BUILD_DIR)

fresh: clean build

info:
	@echo "Qt:    $(QT_PREFIX)"
	@echo "Build: $(BUILD_DIR)"
	@echo "Bin:   $(BIN)"
	@echo "QML:   $(QML_IMPORT)"
```

Linux 把 `macos` 改成 `gcc_64`；Homebrew 用 `QT_PREFIX=$(brew --prefix qt)`。

## QML 静态验证（无窗口，本仓库 showcase）

```bash
QT_QPA_PLATFORM=offscreen \
QML_IMPORT_PATH="$(pwd)/build/src:$(pwd)/build/examples/showcase" \
./build/bin/showcase
# 3 秒无 stderr（error/warning/Cannot）即视为 OK
```

- offscreen 下 Flickable/TextEdit 不执行完整布局，滚动交互无法验证，需 GUI 目测

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
