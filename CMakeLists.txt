cmake_minimum_required(VERSION 3.24)
project(QtShadcn VERSION 0.1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Quick Qml QuickControls2 Svg Network)

qt_standard_project_setup(REQUIRES 6.5)
# ↑ 已自动开启 AUTOMOC/AUTORCC/AUTOUIC，无需手动 set

# QTP0004 NEW：qt_add_qml_module 自动为 QML 子目录生成 qmldir
qt_policy(SET QTP0004 NEW)

add_subdirectory(src)
add_subdirectory(examples)
