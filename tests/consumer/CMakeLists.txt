cmake_minimum_required(VERSION 3.24)
project(QtShadcnConsumer LANGUAGES CXX)

# 消费方冒烟工程：只走 `find_package(QtShadcn)` 这一条路，
# 用来证明安装出来的包能被人正常使用（CI 每次都会跑）。
#
# 手动跑：
#   cmake --install build --prefix "$PWD/_install"
#   cmake -S tests/consumer -B build-consumer -DCMAKE_PREFIX_PATH="$PWD/_install;$HOME/Qt/6.11.1/macos"
#   cmake --build build-consumer -j8
#   QT_QPA_PLATFORM=offscreen ./build-consumer/bin/consumer

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)
qt_standard_project_setup(REQUIRES 6.5)

find_package(QtShadcn 0.2 REQUIRED)

message(STATUS "QtShadcn_VERSION=${QtShadcn_VERSION}")
message(STATUS "QtShadcn_QML_IMPORT_PATH=${QtShadcn_QML_IMPORT_PATH}")

qt_add_executable(consumer main.cpp)
qt_add_qml_module(consumer
    URI Consumer
    VERSION 1.0
    QML_FILES Main.qml
)
target_link_libraries(consumer PRIVATE QtShadcn::QtShadcn Qt6::Quick)

# macOS 大小写不敏感：QML 模块输出目录 Consumer/ 与可执行文件 consumer
# 同名时，链接器写 consumer 会撞上目录 → "ld: open() failed, errno=21"
set_target_properties(consumer PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin"
)

# 库装在前缀里（不在系统路径），让构建目录里的可执行文件直接能跑：
# rpath 指向 QtShadcn 实际安装位置，省掉 DYLD_LIBRARY_PATH
get_target_property(_qtshadcn_location QtShadcn::QtShadcn IMPORTED_LOCATION_RELEASE)
if(NOT _qtshadcn_location)
    get_target_property(_qtshadcn_location QtShadcn::QtShadcn IMPORTED_LOCATION)
endif()
if(_qtshadcn_location)
    get_filename_component(_qtshadcn_libdir "${_qtshadcn_location}" DIRECTORY)
    set_target_properties(consumer PROPERTIES BUILD_RPATH "${_qtshadcn_libdir}")
endif()

enable_testing()
add_test(NAME consumer_smoke COMMAND consumer)
set_tests_properties(consumer_smoke PROPERTIES
    ENVIRONMENT "QT_QPA_PLATFORM=offscreen;QTSHADCN_SCREENSHOT=1"
    TIMEOUT 60
)
