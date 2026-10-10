# Android compatibility backend for OpenToonz' legacy fixed-function OpenGL.
#
# This module is intentionally opt-in until the full application dependency
# graph is Android-ready. GL4ES implements most OpenGL 1.5 calls on GLES2;
# the companion GLU library provides tessellation and the remaining GLU helpers.
# Both upstream dependencies are pinned to immutable commits.

if(NOT ANDROID)
    message(FATAL_ERROR "AndroidLegacyGL.cmake may only be used for an Android target.")
endif()

if(CMAKE_VERSION VERSION_LESS 3.14)
    message(FATAL_ERROR "The Android legacy-GL backend requires CMake 3.14 or newer for FetchContent.")
endif()

include(FetchContent)

# GL4ES is MIT-licensed and translates the legacy OpenGL fixed-function API
# used throughout OpenToonz into GLES2 calls. It relies on Qt to own EGL/context
# creation, so NOEGL and NOX11 are enabled and initialization is explicit.
set(STATICLIB ON CACHE BOOL "Build GL4ES as a static library" FORCE)
set(NOX11 ON CACHE BOOL "Do not use X11 in Android GL4ES" FORCE)
set(NOEGL ON CACHE BOOL "Use the Qt-owned current GLES context" FORCE)
set(NO_GBM ON CACHE BOOL "Disable GBM on Android" FORCE)
set(NO_INIT_CONSTRUCTOR ON CACHE BOOL "Initialize GL4ES from Qt after a context is current" FORCE)
set(DEFAULT_ES 2 CACHE STRING "Default GL4ES backend is GLES2" FORCE)
set(USE_ANDROID_LOG ON CACHE BOOL "Use Android logcat for GL4ES diagnostics" FORCE)

FetchContent_Declare(
    opentoonz_gl4es
    GIT_REPOSITORY https://github.com/ptitSeb/gl4es.git
    GIT_TAG ec16bedd8819c475326f4f1a3063772c6d986e06
)
FetchContent_MakeAvailable(opentoonz_gl4es)

if(NOT TARGET GL)
    message(FATAL_ERROR "GL4ES did not create its expected static GL target.")
endif()

find_library(OPEN_TOONZ_GLESV2_LIBRARY GLESv2 REQUIRED)
find_library(OPEN_TOONZ_ANDROID_LOG_LIBRARY log REQUIRED)
find_library(OPEN_TOONZ_ANDROID_LIBRARY android REQUIRED)

# GL4ES' CMake file derives output paths from CMAKE_SOURCE_DIR. Override its
# target properties so no generated archives are written into the source tree.
set_target_properties(GL PROPERTIES
    POSITION_INDEPENDENT_CODE ON
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib/opentoonz"
)
target_include_directories(GL PUBLIC "${opentoonz_gl4es_SOURCE_DIR}/include")
target_link_libraries(GL PUBLIC
    ${OPEN_TOONZ_GLESV2_LIBRARY}
    ${OPEN_TOONZ_ANDROID_LOG_LIBRARY}
    ${OPEN_TOONZ_ANDROID_LIBRARY}
)

# ptitSeb's Android GLU port is the same SGI/Mesa GLU implementation used by
# desktop OpenToonz. It preserves the GLU tessellator callbacks and hole/
# winding behavior required by the original vector engine.
FetchContent_Declare(
    opentoonz_android_glu
    GIT_REPOSITORY https://github.com/ptitSeb/GLU.git
    GIT_TAG 2fed2bda2b725d2b9e32c435b48d5141cc95827f
)
FetchContent_GetProperties(opentoonz_android_glu)
if(NOT opentoonz_android_glu_POPULATED)
    FetchContent_Populate(opentoonz_android_glu)
endif()

file(GLOB_RECURSE OPEN_TOONZ_ANDROID_GLU_C_SOURCES CONFIGURE_DEPENDS
    "${opentoonz_android_glu_SOURCE_DIR}/src/libutil/*.c"
    "${opentoonz_android_glu_SOURCE_DIR}/src/libtess/*.c"
)
file(GLOB_RECURSE OPEN_TOONZ_ANDROID_GLU_CXX_SOURCES CONFIGURE_DEPENDS
    "${opentoonz_android_glu_SOURCE_DIR}/src/libnurbs/*.cc"
)

add_library(ToonzAndroidGLU STATIC
    ${OPEN_TOONZ_ANDROID_GLU_C_SOURCES}
    ${OPEN_TOONZ_ANDROID_GLU_CXX_SOURCES}
)
target_compile_definitions(ToonzAndroidGLU PRIVATE LIBRARYBUILD)
# The Android NDK's libc headers no longer expose LONG_MAX indirectly from
# older GLU translation units; include the standard limits header explicitly.
target_compile_options(ToonzAndroidGLU PRIVATE
    -include limits.h
    # The pinned SGI/Mesa GLU sources predate C++17 and use the removed
    # 'register' storage-class specifier. Keep this legacy dependency at C++14;
    # OpenToonz itself retains its configured language standard.
    $<$<COMPILE_LANGUAGE:CXX>:-std=gnu++14>
)
target_include_directories(ToonzAndroidGLU
    PUBLIC
        "${opentoonz_android_glu_SOURCE_DIR}/include"
        "${opentoonz_gl4es_SOURCE_DIR}/include"
    PRIVATE
        "${opentoonz_android_glu_SOURCE_DIR}/src/include"
        "${opentoonz_android_glu_SOURCE_DIR}/src/libnurbs/internals"
        "${opentoonz_android_glu_SOURCE_DIR}/src/libnurbs/interface"
        "${opentoonz_android_glu_SOURCE_DIR}/src/libnurbs/nurbtess"
)
target_link_libraries(ToonzAndroidGLU PUBLIC GL)
# This legacy Mesa GLU snapshot uses the pre-C++17 `register` keyword.
# Keep this third-party target at C++14 without lowering OpenToonz itself.
set_target_properties(ToonzAndroidGLU PROPERTIES
    CXX_STANDARD 14
    CXX_STANDARD_REQUIRED ON
    CXX_EXTENSIONS ON
    POSITION_INDEPENDENT_CODE ON
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib/opentoonz"
)

# Make the pinned compatibility headers win over nonexistent or desktop GL
# headers. The same include order is required for every OpenToonz sub-library.
include_directories(BEFORE SYSTEM
    "${opentoonz_android_glu_SOURCE_DIR}/include"
    "${opentoonz_gl4es_SOURCE_DIR}/include"
)

# Use the same variables expected by existing native OpenToonz targets.
set(GL_LIB GL)
set(GLU_LIB ToonzAndroidGLU)
set(GLUT_LIB "")
set(GLEW_LIB "")
set(OPEN_TOONZ_ANDROID_LEGACY_GL_READY TRUE)

message(STATUS "ToonzTab: configured pinned GL4ES + Android GLU compatibility libraries")
