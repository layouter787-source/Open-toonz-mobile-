cmake_minimum_required(VERSION 3.21)
project(ToonzTabAndroidGraphicsProbe LANGUAGES C CXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

include("${CMAKE_CURRENT_LIST_DIR}/../../../toonz/sources/cmake/AndroidLegacyGL.cmake")

add_executable(toonz_android_gl_probe main.cpp)
target_link_libraries(toonz_android_gl_probe PRIVATE
    ToonzAndroidGLU
    GL
    ${OPEN_TOONZ_EGL_LIBRARY}
)

# This is a native cross-link probe only. Do not execute the binary on the host:
# GL4ES initialization requires a live Android GLES context owned by Qt.
