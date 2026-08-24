qt_add_executable(bms-eol
    main.cpp
)

qt_add_qml_module(bms-eol
    URI BmsEol
    VERSION 1.0
    QML_FILES
        Main.qml
        pages/EolTestPage.qml
        pages/CellsPage.qml
)

target_link_libraries(bms-eol PRIVATE QtShadcn Qt6::Gui Qt6::Quick Qt6::Qml Qt6::QuickControls2)

# macOS 大小写不敏感：模块输出目录 BmsEol/ 与可执行文件 bms-eol 撞名(EISDIR)，
# 可执行文件统一输出到 build/bin/（与 showcase 同款处理）
set_target_properties(bms-eol PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)
