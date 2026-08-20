cmake_minimum_required(VERSION 3.24)
project(QtShadcn VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 作为 third_party 子项目引入时默认不编 showcase；本仓库顶层构建仍编
if(CMAKE_SOURCE_DIR STREQUAL CMAKE_CURRENT_SOURCE_DIR)
    set(QTSHADCN_IS_TOPLEVEL ON)
else()
    set(QTSHADCN_IS_TOPLEVEL OFF)
endif()
option(QTSHADCN_BUILD_EXAMPLES "Build showcase" ${QTSHADCN_IS_TOPLEVEL})

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml QuickControls2 Svg Network)

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
