qt_add_executable(fire-safety
    main.cpp
)

qt_add_qml_module(fire-safety
    URI FireSafety
    VERSION 1.0
    QML_FILES
        Main.qml
        pages/DashboardPage.qml
        pages/AlarmsPage.qml
)

target_link_libraries(fire-safety PRIVATE QtShadcn Qt6::Gui Qt6::Quick Qt6::Qml Qt6::QuickControls2)

# macOS 大小写不敏感：模块输出目录 FireSafety/ 与可执行文件 fire-safety 撞名(EISDIR)，
# 可执行文件统一输出到 build/bin/（与 showcase 同款处理）
set_target_properties(fire-safety PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)
