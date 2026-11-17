find_package(Qt6 COMPONENTS Test QuickTest REQUIRED)

qt_add_executable(shadcntablemodel_test
    model/shadcntablemodel_test.cpp
)
target_link_libraries(shadcntablemodel_test
    PRIVATE
        Qt6::Test
        QtShadcn
)
add_test(NAME shadcntablemodel_test COMMAND shadcntablemodel_test)

# C++ 逻辑层单测（M5 同期补充）：ThemeManager / IconRegistry
qt_add_executable(thememanager_test
    core/thememanager_test.cpp
)
target_link_libraries(thememanager_test
    PRIVATE
        Qt6::Test
        QtShadcn
)
add_test(NAME thememanager_test COMMAND thememanager_test)

qt_add_executable(iconregistry_test
    core/iconregistry_test.cpp
)
target_link_libraries(iconregistry_test
    PRIVATE
        Qt6::Test
        QtShadcn
)
add_test(NAME iconregistry_test COMMAND iconregistry_test)

# 命令面板过滤打分单测（issue #5）：CommandFilter 是纯函数，
# 直接在 C++ 里断言匹配/排序性质，不必拖起 QML 引擎。
qt_add_executable(commandfilter_test
    core/commandfilter_test.cpp
)
target_link_libraries(commandfilter_test
    PRIVATE
        Qt6::Test
        QtShadcn
)
add_test(NAME commandfilter_test COMMAND commandfilter_test)

# ── QML 组件测试（Qt Quick Test）───────────────────────────────
#
# 一个 runner 驱动多个 tst_*.qml：QUICK_TEST_MAIN 的 -input 接受单个文件，
# 因此每个用例文件在 ctest 里是独立一项，失败时能直接定位到组件。
#
# -import 指向构建目录的模块输出。运行时其实不靠它：QtShadcn 的 qmldir 是
# `prefer :/qt/qml/QtShadcn/`，QML 模块已编进库资源，测试 runner 链接了
# QtShadcn 就能 import。这里保留磁盘副本路径作为冗余保险（模块资源异常时
# 仍能找到），同时它也是 qmllint 解析组件类型时用的那个目录。
# 离屏跑：QT_QPA_PLATFORM=offscreen 无窗口；QTSHADCN_SCREENSHOT=1 关掉
# Card 的 layer + MultiEffect 阴影（GPU 特效在软件渲染下会让内容整块空白）。
qt_add_executable(qmltests
    qmltests_main.cpp
)
target_link_libraries(qmltests
    PRIVATE
        Qt6::QuickTest
        Qt6::Quick
        Qt6::Gui
        QtShadcn
)
set_target_properties(qmltests PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

file(GLOB QML_TEST_FILES CONFIGURE_DEPENDS
    RELATIVE "${CMAKE_CURRENT_SOURCE_DIR}/qml"
    "${CMAKE_CURRENT_SOURCE_DIR}/qml/tst_*.qml"
)

foreach(qml_test_file ${QML_TEST_FILES})
    get_filename_component(qml_test_name "${qml_test_file}" NAME_WE)
    add_test(NAME qml_${qml_test_name}
        COMMAND qmltests
            -import "${CMAKE_BINARY_DIR}/src"
            -input "${CMAKE_CURRENT_SOURCE_DIR}/qml/${qml_test_file}"
    )
    set_tests_properties(qml_${qml_test_name} PROPERTIES
        ENVIRONMENT "QT_QPA_PLATFORM=offscreen;QTSHADCN_SCREENSHOT=1"
        TIMEOUT 120
    )
endforeach()

list(LENGTH QML_TEST_FILES QML_TEST_COUNT)
message(STATUS "QML component tests: ${QML_TEST_COUNT}")
