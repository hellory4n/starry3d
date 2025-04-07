cmake_minimum_required(VERSION 3.15)
project(starry3d C)

set(CMAKE_C_STANDARD 99)

add_subdirectory(vendor/glfw)

# c files go here
add_library(starry3d STATIC
    src/starry3d/core.c
)

target_include_directories(starry3d PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    vendor/glfw/include
	vendor/glfw/deps
)

target_link_libraries(starry3d PUBLIC glfw)
