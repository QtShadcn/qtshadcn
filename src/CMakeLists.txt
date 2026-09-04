# QML 模块：URI = QtShadcn
file(GLOB QML_FILES
    "${CMAKE_CURRENT_SOURCE_DIR}/qml/Theme/*.qml"
    "${CMAKE_CURRENT_SOURCE_DIR}/qml/Icons/*.qml"
    "${CMAKE_CURRENT_SOURCE_DIR}/qml/Components/*.qml"
)

qt_add_qml_module(QtShadcn
    URI QtShadcn
    VERSION 0.1.0
    OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/QtShadcn"
    DEPENDENCIES
        QtQuick
        QtQuick.Controls
    SOURCES
        core/thememanager.h
        core/thememanager.cpp
        core/iconregistry.h
        core/iconregistry.cpp
        core/models/shadcntablemodel.h
        core/models/shadcntablemodel.cpp
    QML_FILES
        ${QML_FILES}
)

# 图标资源：qt_add_qml_module 的 RESOURCES 会把 qrc 当单个文件嵌套进
# /qt/qml/QtShadcn/ 前缀（运行时 :/icons/*.svg 不存在）；AUTORCC 对模块 target 也不生效。
# 用 qt_add_resources 直接把 svg 以 /icons/<name>.svg 编译进 target（IconRegistry 枚举 :/icons）。
# 注意 BASE 必须指向 icons/ 目录本身，否则资源路径会变 :/icons/icons/<name>.svg（双前缀）
file(GLOB ICON_SVGS "${CMAKE_CURRENT_SOURCE_DIR}/assets/icons/*.svg")
qt_add_resources(QtShadcn "icons"
    PREFIX "/icons"
    BASE "${CMAKE_CURRENT_SOURCE_DIR}/assets/icons"
    FILES ${ICON_SVGS}
)

# 类型注册文件通过 <thememanager.h> 引用头文件，需暴露 core 目录
# BUILD_INTERFACE：仅构建期可见；将来 find_package 导出时自动剔除
target_include_directories(QtShadcn PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/core>
)

# 模型子目录：使 models/ 对模型自身 #include "shadcntablemodel.h" 可见
target_include_directories(QtShadcn PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/core/models>
)

# 显式声明 Qt 依赖（语义清晰，同时帮助 CMake Tools 生成 IntelliSense 配置；
# 与 qt_add_qml_module 内部链接重复的部分由 CMake 自动去重）
target_link_libraries(QtShadcn
    PUBLIC
        Qt6::Core
        Qt6::Gui
        Qt6::Quick
        Qt6::Qml
        Qt6::Svg
        Qt6::Network
)

# ── M6 TODO: find_package(QtShadcn) 支持 ──────────────────────────
# 1. install(TARGETS QtShadcn EXPORT QtShadcnTargets ...) + NAMESPACE QtShadcn::
# 2. QML 模块文件 install(DIRECTORY ...) → <prefix>/lib/QtShadcn
#    （Qt 6.11 qt_add_qml_module 不处理安装，qt6_target_install_qml_module 不存在，
#     需手动装 qmldir/*.qml/*.qmltypes/plugin）
# 3. QtShadcnConfig.cmake.in + write_basic_package_version_file + configure_package_config_file
#    模板见 src/cmake/QtShadcnConfig.cmake.in（M6 时恢复）
