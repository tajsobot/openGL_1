cmake_minimum_required(VERSION 3.30)
project(openGL_1)

set(CMAKE_CXX_STANDARD 20)

add_executable(openGL_1 src/main.cpp)

set(SOURCES
        src/main.cpp
        src/glad.c
)

#glfw
add_subdirectory(libs/glfw)
include_directories(libs/glfw/include/GLFW)

#glad
add_library(glad STATIC src/glad.c)
target_include_directories(glad PUBLIC libs/glad/include)

find_package(OpenGL REQUIRED)
target_link_libraries(openGL_1 glfw OpenGL::GL glad)

target_include_directories(openGL_1 PRIVATE libs/glfw/include)
target_include_directories(openGL_1 PRIVATE libs/glad/include)

target_link_libraries(openGL_1 glfw OpenGL::GL glad -static-libgcc -static-libstdc++)
