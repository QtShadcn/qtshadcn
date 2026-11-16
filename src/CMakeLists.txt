# QML 模块：URI = QtShadcn
# 注意：qt_add_qml_module 的 QML_FILES 必须是「相对路径」，否则 Qt 报
# absolute path / QT_RESOURCE_ALIAS 错误（见 Qt6CoreMacros.cmake:1843）。
# 用 RELATIVE 让 GLOB 结果保持相对形式，与旧的手写列表一致。
# 非递归 GLOB：只收当前目录，新增子目录需显式加一行。
file(GLOB QML_FILES RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}"
    "${CMAKE_CURRENT_SOURCE_DIR}/qml/Theme/*.qml"
    "${CMAKE_CURRENT_SOURCE_DIR}/qml/Icons/*.qml"
    "${CMAKE_CURRENT_SOURCE_DIR}/qml/Components/*.qml"
)

qt_add_qml_module(QtShadcn
    URI QtShadcn
    # qmldir 只认 MAJOR.MINOR，从顶层 project() 派生，避免两处版本漂移
    VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
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
# BUILD_INTERFACE：仅构建期可见；INSTALL_INTERFACE：find_package 后可见（头文件装到 include/QtShadcn）
target_include_directories(QtShadcn PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/core>
    $<INSTALL_INTERFACE:include/QtShadcn>
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

# ── 安装 / find_package(QtShadcn) ─────────────────────────────────
#
# 只在作为顶层项目构建时安装：被 FetchContent / add_subdirectory 引入时
# 是别人的子项目，不该往对方 prefix 里装东西。
#
# 关键前提（决定了这里为什么不需要摆弄 QML 导入路径）：qmldir 里有
# `prefer :/qt/qml/QtShadcn/`，qmlcache 产物与全部 .qml 都编译进了
# libQtShadcn 的资源。消费方只要链接 QtShadcn::QtShadcn，`import QtShadcn`
# 就能解析，运行时无需 QML_IMPORT_PATH —— 磁盘副本只服务工具链
# （qmllint / qmlls / Qt Designer）。
if(QTSHADCN_IS_TOPLEVEL)
    include(CMakePackageConfigHelpers)
    include(GNUInstallDirs)

    # 库本体
    install(TARGETS QtShadcn
        EXPORT QtShadcnTargets
        RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
        ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    )

    # C++ 侧公开类型（ThemeManager / IconRegistry / ShadcnTableModel）
    # 头文件之间是平级 #include，装到同一目录
    install(FILES
        core/thememanager.h
        core/iconregistry.h
        core/models/shadcntablemodel.h
        DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}/QtShadcn
    )

    # QML 模块的磁盘副本 + 插件：qmldir 里 `optional plugin QtShadcnplugin`，
    # 插件要和 qmldir 同目录，否则按 qmldir 找插件时解析不到
    install(DIRECTORY "${CMAKE_CURRENT_BINARY_DIR}/QtShadcn/"
        DESTINATION ${CMAKE_INSTALL_LIBDIR}/qml/QtShadcn
        FILES_MATCHING
            PATTERN "qmldir"
            PATTERN "*.qmltypes"
            PATTERN "*.qml"
    )
    install(TARGETS QtShadcnplugin
        LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}/qml/QtShadcn
        RUNTIME DESTINATION ${CMAKE_INSTALL_LIBDIR}/qml/QtShadcn
    )

    # Config / Version / 导出目标
    set(QTSHADCN_CMAKE_INSTALL_DIR "${CMAKE_INSTALL_LIBDIR}/cmake/QtShadcn")

    configure_package_config_file(
        "${CMAKE_CURRENT_SOURCE_DIR}/cmake/QtShadcnConfig.cmake.in"
        "${CMAKE_CURRENT_BINARY_DIR}/QtShadcnConfig.cmake"
        INSTALL_DESTINATION "${QTSHADCN_CMAKE_INSTALL_DIR}"
        # 配置里要用绝对路径指向磁盘版 QML 目录（工具链用）
        PATH_VARS CMAKE_INSTALL_LIBDIR
    )

    write_basic_package_version_file(
        "${CMAKE_CURRENT_BINARY_DIR}/QtShadcnConfigVersion.cmake"
        VERSION ${PROJECT_VERSION}
        COMPATIBILITY SameMajorVersion
    )

    install(EXPORT QtShadcnTargets
        FILE QtShadcnTargets.cmake
        NAMESPACE QtShadcn::
        DESTINATION "${QTSHADCN_CMAKE_INSTALL_DIR}"
    )
    install(FILES
        "${CMAKE_CURRENT_BINARY_DIR}/QtShadcnConfig.cmake"
        "${CMAKE_CURRENT_BINARY_DIR}/QtShadcnConfigVersion.cmake"
        DESTINATION "${QTSHADCN_CMAKE_INSTALL_DIR}"
    )
endif()

