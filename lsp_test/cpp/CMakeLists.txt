cmake_minimum_required(VERSION 3.15)
project(ClangdTest VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include_directories(include)

add_executable(clangd_test
    src/main.cpp
    src/core/Entity.cpp
    src/core/Component.cpp
    src/graphics/Renderer.cpp
    src/graphics/Shape.cpp
    src/utils/Logger.cpp
    src/utils/MathUtils.cpp
)
