# QtShadcn 快捷命令
# 用法:
#   make build   配置 + 增量构建
#   make run     构建并运行 showcase（前台，Ctrl+C 退出）
#   make clean   清理构建产物
#   make fresh   删除构建目录后完整重建（Qt 模块/缓存异常时用）
#   make info    显示当前配置

QT_PREFIX ?= $(HOME)/Qt/6.11.1/macos
BUILD_DIR ?= build
BIN        = $(BUILD_DIR)/bin/showcase
JOBS      ?= $(shell sysctl -n hw.ncpu 2>/dev/null || echo 4)
QML_IMPORT  = $(CURDIR)/$(BUILD_DIR)/src:$(CURDIR)/$(BUILD_DIR)/examples/showcase

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
