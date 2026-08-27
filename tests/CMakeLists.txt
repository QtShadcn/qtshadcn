find_package(Qt6 COMPONENTS Test REQUIRED)

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
