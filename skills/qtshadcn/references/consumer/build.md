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
7. **不需要设 `QML_IMPORT_PATH`**：链接 `QtShadcn` 后 `import QtShadcn` 直接可用（模块内容在库资源里，qmldir 是 `prefer :/qt/qml/QtShadcn/`）。只有不链接库、纯靠 import 路径加载时才需要，那时指向**含 `QtShadcn/` 模块目录的父路径**（`$(BUILD_DIR)/third_party/qtshadcn/src`）
8. 可执行文件输出到 `$(BUILD_DIR)/bin/$(APP)`，与 Makefile 的 `BIN` 一致
9. 库已支持安装导出：作为源码子项目引入时不要写 `find_package(QtShadcn)`（那种场景走 `add_subdirectory`）；用预编译前缀时才 `find_package(QtShadcn 0.2 REQUIRED)` + 链接 `QtShadcn::QtShadcn`

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
# 工程若在网络盘（SMB/NFS，如 /Volumes/xxx）上：构建目录必须放本机，
# 否则 CMake 生成的 .qt/<app>_qml.cmake、CMakeFiles/Makefile2 编译时「找不到」
# （make 报 No rule to make target 'all' / include could not find requested file）
LOCAL_BUILD ?= $(HOME)/dev/qt/$(notdir $(CURDIR))-build
BUILD_DIR   ?= $(LOCAL_BUILD)
APP       ?= myapp
BIN        = $(BUILD_DIR)/bin/$(APP)
JOBS      ?= $(shell sysctl -n hw.ncpu 2>/dev/null || echo 4)
# 只在「不链接库、纯 import 路径加载」时用（如单独跑 .qml、给 qmllint 指路）；
# 正常链接 QtShadcn 的应用不需要 QML_IMPORT_PATH
QML_IMPORT ?= $(CURDIR)/$(BUILD_DIR)/third_party/qtshadcn/src

.PHONY: build run clean fresh info

build:
	cmake -S . -B $(BUILD_DIR) -DCMAKE_PREFIX_PATH="$(QT_PREFIX)" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
	cmake --build $(BUILD_DIR) -j$(JOBS)

run: build
	$(BIN)

clean:
	rm -rf $(BUILD_DIR)

fresh: clean build

info:
	@echo "Qt:    $(QT_PREFIX)"
	@echo "Build: $(BUILD_DIR)"
	@echo "Bin:   $(BIN)"
	@echo "QML:   $(QML_IMPORT)"
```

## 无头预览/截图验证（没屏幕时怎么「看」界面）

迭代样式别靠猜，抓一张渲染图再量：

1. **离屏跑必须开 `QTSHADCN_SCREENSHOT=1`**：卡片阴影走 `layer` + `MultiEffect`（GPU 特效），offscreen 软件渲染下**卡片内容整块空白**，只剩表格/自绘 Rectangle 正常。看到「卡片没了」先怀疑这个，不是布局坏了。
2. **抓图只能在 C++ 里做**：QML 端没暴露 `grabWindow()` / `grabToImage()`（报 `Property 'grabWindow' ... is not a function`）。main.cpp 加 env 开关：

```cpp
if (qEnvironmentVariableIsSet("MYAPP_GRAB"))
    QTimer::singleShot(2600, &app, [&engine]() {
        auto *win = qobject_cast<QQuickWindow *>(engine.rootObjects().first());
        if (win) qInfo() << win->grabWindow().save("/tmp/shot.png");
    });
```

```bash
MYAPP_GRAB=1 QTSHADCN_SCREENSHOT=1 QT_QPA_PLATFORM=offscreen ./app
```

3. **没有视觉模型时用像素分析兜底**：PNG 纯 stdlib（`zlib` + 反 filter）解码后做「墨迹密度图 + 横/竖线扫描 + 区域平均色」，能客观量出框线在不在、卡片贴不贴内容、哪块是空白（自绘卡片底 ≈247、窗口底 ≈252、描边与底差约 10 亮度 → 扫描阈值要降到 ~6）。

## 布局改动前先量

改完不要只说「好了」：把 `x/y/w/h` 打印出来（`console.log` 或 C++ 抓图后像素扫描），确认「标题同行同高 / 框线同起点 / 无横向溢出」——用户验收就是看这些数字对不对得上。

**RowLayout 里「一列填满、一列被居中」的坑**：同一 RowLayout 下的两列，如果只有一列的子项写了 `Layout.fillHeight: true`（或该列内容高小于行高），另一列**单靠自身 `Layout.fillHeight: true` 不会把自己撑开**，RowLayout 会把它按内容高**垂直居中** → 两列顶边差 `(行高 − 内容高)/2`（实例：差 66px，左列 y=264、右列 y=330）。修法：给内容高较小的那列显式 `Layout.alignment: Qt.AlignTop`。判据就是打印几何看两列 y 是否相等。

Linux 把 `macos` 改成 `gcc_64`；Homebrew 用 `QT_PREFIX=$(brew --prefix qt)`。
