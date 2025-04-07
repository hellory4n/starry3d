cmake_minimum_required(VERSION 3.15)
project(sandbox C)

set(CMAKE_C_STANDARD 99)

# change to be where you put starry3d
# "../../build" shouldn't be required in your own projects, so just remove that
add_subdirectory(.. ../../build)
add_executable(stellarthing src/main.c)
target_link_libraries(stellarthing PRIVATE starry3d)
