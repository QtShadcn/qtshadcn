qt_add_executable(showcase
    main.cpp
)

qt_add_qml_module(showcase
    URI Showcase
    VERSION 1.0
    QML_FILES
        Main.qml
        pages/OverviewPage.qml
        pages/ThemePage.qml
        pages/ButtonPage.qml
        pages/ButtonGroupPage.qml
        pages/TogglePage.qml
        pages/SpinnerPage.qml
        pages/CardPage.qml
        pages/InputPage.qml
        pages/BadgePage.qml
        pages/SwitchPage.qml
        pages/TabsPage.qml
        pages/DialogPage.qml
        pages/IconPage.qml
        pages/TextareaPage.qml
        pages/CheckboxPage.qml
        pages/RadioPage.qml
        pages/SliderPage.qml
        pages/ProgressPage.qml
        pages/SelectPage.qml
        pages/InputGroupPage.qml
        pages/FormPage.qml
)

target_link_libraries(showcase PRIVATE QtShadcn Qt6::Gui Qt6::Quick Qt6::Qml Qt6::QuickControls2)

# macOS 大小写不敏感：模块输出目录 Showcase/ 与可执行文件 showcase 撞名(EISDIR)，
# 可执行文件统一输出到 build/bin/
set_target_properties(showcase PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)
