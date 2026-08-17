# QML 模块：URI = QtShadcn
qt_add_qml_module(QtShadcn
    URI QtShadcn
    VERSION 0.1.0
    OUTPUT_DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/QtShadcn"
    SOURCES
        core/thememanager.h
        core/thememanager.cpp
    QML_FILES
        qml/Theme/QtShadcnTheme.qml
)

# 类型注册文件通过 <thememanager.h> 引用头文件，需暴露 core 目录
# BUILD_INTERFACE：仅构建期可见；将来 find_package 导出时自动剔除
target_include_directories(QtShadcn PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/core>
)

# 显式声明 Qt 依赖（语义清晰，同时帮助 CMake Tools 生成 IntelliSense 配置；
# 与 qt_add_qml_module 内部链接重复的部分由 CMake 自动去重）
target_link_libraries(QtShadcn
    PUBLIC
        Qt6::Core
        Qt6::Gui
        Qt6::Quick
        Qt6::Qml
)

# ── M6 TODO: find_package(QtShadcn) 支持 ──────────────────────────
# 1. install(TARGETS QtShadcn EXPORT QtShadcnTargets ...) + NAMESPACE QtShadcn::
# 2. QML 模块文件 install(DIRECTORY ...) → <prefix>/lib/QtShadcn
#    （Qt 6.11 qt_add_qml_module 不处理安装，qt6_target_install_qml_module 不存在，
#     需手动装 qmldir/*.qml/*.qmltypes/plugin）
# 3. QtShadcnConfig.cmake.in + write_basic_package_version_file + configure_package_config_file
#    模板见 src/cmake/QtShadcnConfig.cmake.in（M6 时恢复）
