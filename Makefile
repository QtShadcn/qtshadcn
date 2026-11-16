# QtShadcn 快捷命令
# 用法:
#   make build   配置 + 增量构建（默认 showcase）
#   make run     构建并运行 showcase（前台，Ctrl+C 退出）
#   make test    配置(开测试) + 构建测试 + 运行 ctest
#   make lint    QML lint 门禁（需先 build，配置见 .qmllint.ini）
#   make clean   清理构建产物
#   make fresh   删除构建目录后完整重建（Qt 模块/缓存异常时用）
#   make info    显示当前配置

QT_PREFIX ?= $(HOME)/Qt/6.11.1/macos
BUILD_DIR ?= build
JOBS      ?= $(shell sysctl -n hw.ncpu 2>/dev/null || echo 4)
# qmllint 门禁可执行文件（优先用 Qt 自带，避免 homebrew 版本与 Qt 版本不一致）
QML_LINT  ?= $(QT_PREFIX)/bin/qmllint

# 动态扫描 examples 下所有包含 CMakeLists.txt 的子项目
EXAMPLES_DIR := examples
EXAMPLES     := $(patsubst $(EXAMPLES_DIR)/%/,%,\
                   $(dir $(wildcard $(EXAMPLES_DIR)/*/CMakeLists.txt)))

# 通过 f 变量指定项目名，未指定时默认为 showcase
TARGET ?= $(if $(f),$(f),showcase)
BIN     = $(BUILD_DIR)/bin/$(TARGET)
QML_IMPORT = $(CURDIR)/$(BUILD_DIR)/src:$(CURDIR)/$(BUILD_DIR)/examples/$(TARGET)

.PHONY: build run test lint clean fresh info list

build:
	@if [ ! -d "$(EXAMPLES_DIR)/$(TARGET)" ]; then \
		echo "❌ 项目 '$(TARGET)' 不存在！可用项目："; \
		echo "   $(EXAMPLES)"; \
		exit 1; \
	fi
	cmake -S . -B $(BUILD_DIR) -DCMAKE_PREFIX_PATH="$(QT_PREFIX)" -DCMAKE_EXPORT_COMPILE_COMMANDS=ON
	cmake --build $(BUILD_DIR) -j$(JOBS)

run: build
	QML_IMPORT_PATH="$(QML_IMPORT)" $(BIN)

# 开 QTSHADCN_BUILD_TESTS，关 examples 以聚焦测试、缩短构建
test:
	cmake -S . -B $(BUILD_DIR) -DCMAKE_PREFIX_PATH="$(QT_PREFIX)" \
		-DQTSHADCN_BUILD_TESTS=ON -DQTSHADCN_BUILD_EXAMPLES=OFF \
		-DCMAKE_EXPORT_COMPILE_COMMANDS=ON
	cmake --build $(BUILD_DIR) -j$(JOBS)
	ctest --test-dir $(BUILD_DIR) --output-on-failure

# QML lint 门禁（.qmllint.ini 分级：真错误类阻塞，风格类只记录）
# 需要先 build 一次：-I 指向 $(BUILD_DIR)/src，qmllint 靠它解析 QtShadcn 模块
lint:
	@if [ ! -d "$(BUILD_DIR)/src/QtShadcn" ]; then \
		echo "❌ 需要先 make build（qmllint 要用 $(BUILD_DIR)/src 解析 QtShadcn 模块）"; \
		exit 1; \
	fi
	@echo "linting $$(find src/qml -name '*.qml' | wc -l | tr -d ' ') QML files"
	@find src/qml -name '*.qml' -print0 | xargs -0 "$(QML_LINT)" -I "$(BUILD_DIR)/src" && echo "✅ lint 通过"

clean:
	rm -rf $(BUILD_DIR)

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
	@echo "QML:      $(QML_IMPORT)"
	@echo "Examples: $(EXAMPLES)"
