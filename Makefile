# QtShadcn 快捷命令
# 用法:
#   make build   配置 + 增量构建（默认 showcase）
#   make run     构建并运行 showcase（前台，Ctrl+C 退出）
#   make test    配置 + 构建 + 运行 ctest（与 build 共用一组配置参数，不翻转状态）
#   make lint    QML lint 门禁（需先 build，配置见 .qmllint.ini）
#   make consumer-smoke  安装到本地前缀 + 用独立工程验证 find_package(QtShadcn)
#   make clean   清理构建产物
#   make fresh   删除构建目录后完整重建（Qt 模块/缓存异常时用）
#   make info    显示当前配置

QT_PREFIX ?= $(HOME)/Qt/6.11.1/macos
BUILD_DIR ?= build
JOBS      ?= $(shell sysctl -n hw.ncpu 2>/dev/null || echo 4)

# CMake 配置参数（唯一来源，build / test 共用）
#
# 为什么必须显式传这两个开关：CMake 的 option() 只在**首次** configure 时
# 生效，之后一律以 CMakeCache.txt 为准。若某个目标只单向设置状态，
# 后续目标不传，cache 就会停在那个状态上——症状是「明明没改代码，
# `make build` 却不产出 build/bin/showcase」，因为 examples 早被关掉了。
# 现在两个目标传同一组值，状态永远确定，也不会来回增删 target 造成重建。
BUILD_EXAMPLES ?= ON
BUILD_TESTS    ?= ON
CMAKE_OPTS      = -DCMAKE_PREFIX_PATH="$(QT_PREFIX)" \
                  -DCMAKE_EXPORT_COMPILE_COMMANDS=ON \
                  -DQTSHADCN_BUILD_EXAMPLES=$(BUILD_EXAMPLES) \
                  -DQTSHADCN_BUILD_TESTS=$(BUILD_TESTS)
# qmllint 门禁可执行文件（优先用 Qt 自带，避免 homebrew 版本与 Qt 版本不一致）
QML_LINT  ?= $(QT_PREFIX)/bin/qmllint

# 动态扫描 examples 下所有包含 CMakeLists.txt 的子项目
EXAMPLES_DIR := examples
EXAMPLES     := $(patsubst $(EXAMPLES_DIR)/%/,%,\
                   $(dir $(wildcard $(EXAMPLES_DIR)/*/CMakeLists.txt)))

# 通过 f 变量指定项目名，未指定时默认为 showcase
TARGET ?= $(if $(f),$(f),showcase)
BIN     = $(BUILD_DIR)/bin/$(TARGET)

.PHONY: build run test lint consumer-smoke clean fresh info list

build:
	@if [ ! -d "$(EXAMPLES_DIR)/$(TARGET)" ]; then \
		echo "❌ 项目 '$(TARGET)' 不存在！可用项目："; \
		echo "   $(EXAMPLES)"; \
		exit 1; \
	fi
	cmake -S . -B $(BUILD_DIR) $(CMAKE_OPTS)
	cmake --build $(BUILD_DIR) -j$(JOBS)

# 不再注入 QML_IMPORT_PATH：QtShadcn 的 qmldir 是 `prefer :/qt/qml/QtShadcn/`，
# QML 模块全部编译进库资源，链接上即可 import（0.2.0 起验证过）。示例自身
# 的 QML 同样在资源里，因此运行时无需任何导入路径。
run: build
	$(BIN)

# 跑 ctest（配置参数与 build 一致，见 CMAKE_OPTS 上方注释）
# 想只跑测试、不建 examples：make test BUILD_EXAMPLES=OFF
test:
	cmake -S . -B $(BUILD_DIR) $(CMAKE_OPTS)
	cmake --build $(BUILD_DIR) -j$(JOBS)
	ctest --test-dir $(BUILD_DIR) --output-on-failure

# QML lint 门禁（.qmllint.ini 分级：真错误类阻塞，风格类只记录）
# 需要先 build 一次：-I 指向 $(BUILD_DIR)/src，qmllint 靠它解析 QtShadcn 模块
# 覆盖范围：组件库 src/qml + 测试用例 tests/qml
lint:
	@if [ ! -d "$(BUILD_DIR)/src/QtShadcn" ]; then \
		echo "❌ 需要先 make build（qmllint 要用 $(BUILD_DIR)/src 解析 QtShadcn 模块）"; \
		exit 1; \
	fi
	@echo "linting $$(find src/qml tests/qml -name '*.qml' 2>/dev/null | wc -l | tr -d ' ') QML files"
	@find src/qml tests/qml -name '*.qml' -print0 | xargs -0 "$(QML_LINT)" -I "$(BUILD_DIR)/src" && echo "✅ lint 通过"

# 安装 + 消费方冒烟：验证 find_package(QtShadcn) 这条路真的能用
# （装到本地前缀 → 用 tests/consumer 这个独立工程构建 → 离屏跑一次）
# CI 会跑同一套流程，这里方便本地改完打包规则后立刻验证
consumer-smoke: build
	rm -rf "$(BUILD_DIR)-install" "$(BUILD_DIR)-consumer"
	cmake --install $(BUILD_DIR) --prefix "$(CURDIR)/$(BUILD_DIR)-install"
	cmake -S tests/consumer -B "$(BUILD_DIR)-consumer" \
		-DCMAKE_PREFIX_PATH="$(CURDIR)/$(BUILD_DIR)-install;$(QT_PREFIX)"
	cmake --build "$(BUILD_DIR)-consumer" -j$(JOBS)
	QT_QPA_PLATFORM=offscreen QTSHADCN_SCREENSHOT=1 \
		ctest --test-dir "$(BUILD_DIR)-consumer" --output-on-failure
	@echo "✅ find_package(QtShadcn) 可用"

clean:
	rm -rf $(BUILD_DIR) "$(BUILD_DIR)-install" "$(BUILD_DIR)-consumer"

fresh: clean build

# 列出所有可用项目
list:
	@echo "可用项目："
	@for d in $(EXAMPLES); do echo "  - $$d"; done

info:
	@echo "Qt:       $(QT_PREFIX)"
	@echo "Build:    $(BUILD_DIR)"
	@echo "Target:   $(TARGET)"
	@echo "Bin:      $(BIN)"
	@echo "Examples: $(EXAMPLES)"
	@echo "Flags:    EXAMPLES=$(BUILD_EXAMPLES) TESTS=$(BUILD_TESTS)"
	@echo "Lint:     $(QML_LINT) -I $(BUILD_DIR)/src"
