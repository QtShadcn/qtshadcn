---
name: consumer-build
description: 消费方接入 QtShadcn：vendor 到 third_party、最小 CMake / main.cpp / Makefile 脚手架与铁律清单。
---

# 消费方脚手架（给用户写项目时必做）

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
