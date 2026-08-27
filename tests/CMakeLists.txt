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
