# QtShadcn 快捷命令
# 用法:
#   make build   配置 + 增量构建
#   make run     构建并运行 showcase（前台，Ctrl+C 退出）
#   make clean   清理构建产物
#   make fresh   删除构建目录后完整重建（Qt 模块/缓存异常时用）
#   make info    显示当前配置

QT_PREFIX ?= $(HOME)/Qt/6.11.1/macos
BUILD_DIR ?= build
JOBS      ?= $(shell sysctl -n hw.ncpu 2>/dev/null || echo 4)

# 动态扫描 examples 下所有包含 CMakeLists.txt 的子项目
EXAMPLES_DIR := examples
EXAMPLES     := $(patsubst $(EXAMPLES_DIR)/%/,%,\
                   $(dir $(wildcard $(EXAMPLES_DIR)/*/CMakeLists.txt)))

# 通过 f 变量指定项目名，未指定时默认为 showcase
TARGET ?= $(if $(f),$(f),showcase)
BIN     = $(BUILD_DIR)/bin/$(TARGET)
QML_IMPORT = $(CURDIR)/$(BUILD_DIR)/src:$(CURDIR)/$(BUILD_DIR)/examples/$(TARGET)

.PHONY: build run clean fresh info list

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