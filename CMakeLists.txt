cmake_minimum_required(VERSION 3.24)
# 库版本唯一来源。发版纪律：改这里 → commit → git tag v<VERSION>（CI 校验二者一致，
# FetchContent/CPM 按 tag 拉取）。QML 模块版本由 src/CMakeLists.txt 引用本值派生。
project(QtShadcn VERSION 0.2.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 作为 third_party 子项目引入时默认不编 showcase；本仓库顶层构建仍编
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    set(QTSHADCN_IS_TOPLEVEL ON)
else()
    set(QTSHADCN_IS_TOPLEVEL OFF)
endif()
option(QTSHADCN_BUILD_EXAMPLES "Build showcase" ${QTSHADCN_IS_TOPLEVEL})
option(QTSHADCN_BUILD_TESTS "Build QtShadcn unit tests" OFF)

# Qt 版本下限 6.5。这里不用 REQUIRED，是为了在版本不够时给出可读的原因，
# 而不是让 CMake 抛一行 "Could not find a configuration file ... compatible
# with requested version 6.5"。版本下限的来源：
#   required property（6.0）、pragma ComponentBehavior: Bound（6.5）、
#   MultiEffect（6.5）、Qt 6 重写后的 TableView（6.0，与 Qt5 那套 API 不兼容）。
# 不支持 Qt 5，评估过程见 https://github.com/QtShadcn/qtshadcn/issues/12
find_package(Qt6 6.5 QUIET COMPONENTS Core Gui Quick Qml QuickControls2 Svg Network)
if(NOT Qt6_FOUND)
    set(_qtshadcn_found_version "<未找到 Qt6>")
    if(Qt6_VERSION)
        set(_qtshadcn_found_version "${Qt6_VERSION}")
    endif()
    message(FATAL_ERROR
        "\nQtShadcn 需要 Qt 6.5 或更高版本，当前找到的是 ${_qtshadcn_found_version}。\n\n"
        "  不支持 Qt 5：required property / ComponentBehavior Bound / MultiEffect /\n"
        "  重写后的 TableView 在 Qt 5.15 上都没有等价物，不是条件编译能绕开的。\n"
        "  背景见 https://github.com/QtShadcn/qtshadcn/issues/12\n\n"
        "  若本机装了多个 Qt 版本，用 -DCMAKE_PREFIX_PATH=<Qt 6.5+ 安装路径> 指定。\n")
endif()

if(QTSHADCN_IS_TOPLEVEL)
    qt_standard_project_setup(REQUIRES 6.5)
    # ↑ 已自动开启 AUTOMOC/AUTORCC/AUTOUIC，无需手动 set
endif()

# QTP0004 NEW：qt_add_qml_module 自动为 QML 子目录生成 qmldir
qt_policy(SET QTP0004 NEW)

add_subdirectory(src)
if(QTSHADCN_BUILD_EXAMPLES)
    add_subdirectory(examples)
endif()

if(QTSHADCN_BUILD_TESTS)
    enable_testing()
    add_subdirectory(tests)
endif()
