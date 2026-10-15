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

# OpenToonz' top-level project still has a 3.10 minimum. The GL4ES target is
# created in a FetchContent subdirectory and linked from this parent directory.
cmake_policy(SET CMP0079 NEW)

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
find_library(OPEN_TOONZ_EGL_LIBRARY EGL REQUIRED)
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
# OpenToonz uses GLUT only for stroke-font rendering; Qt still owns the
# Android window and EGL context. Build just FreeGLUT's portable font geometry,
# plus a small adapter that avoids glutInit()/window creation.
FetchContent_Declare(
    opentoonz_freeglut
    GIT_REPOSITORY https://github.com/freeglut/freeglut.git
    GIT_TAG 69ac8824f003dd813ceb14b11fb4efaa38cb4aa9
)
FetchContent_GetProperties(opentoonz_freeglut)
if(NOT opentoonz_freeglut_POPULATED)
    FetchContent_Populate(opentoonz_freeglut)
endif()

add_library(ToonzAndroidGLUTFonts STATIC
    "${opentoonz_freeglut_SOURCE_DIR}/src/fg_font_data.c"
    "${opentoonz_freeglut_SOURCE_DIR}/src/fg_stroke_roman.c"
    "${opentoonz_freeglut_SOURCE_DIR}/src/fg_stroke_mono_roman.c"
    "${CMAKE_CURRENT_LIST_DIR}/../common/tgl/android_glut_fonts.c"
)
target_include_directories(ToonzAndroidGLUTFonts
    PUBLIC "${opentoonz_freeglut_SOURCE_DIR}/include"
    PRIVATE "${opentoonz_freeglut_SOURCE_DIR}/src"
)
target_compile_definitions(ToonzAndroidGLUTFonts PRIVATE
    FREEGLUT_STATIC
    FREEGLUT_GLES
    TARGET_HOST_ANDROID
)
# The upstream Android private header uses C's bool type without including
# stdbool.h when compiling its stroke-font data as C.
target_compile_options(ToonzAndroidGLUTFonts PRIVATE -include stdbool.h)
target_link_libraries(ToonzAndroidGLUTFonts PUBLIC GL)
set_target_properties(ToonzAndroidGLUTFonts PROPERTIES
    POSITION_INDEPENDENT_CODE ON
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib/opentoonz"
)

include_directories(BEFORE SYSTEM
    "${CMAKE_CURRENT_LIST_DIR}/../../../thirdparty/glut/3.7.6/include"
    "${opentoonz_freeglut_SOURCE_DIR}/include"
)

set(GL_LIB GL)
set(GLU_LIB ToonzAndroidGLU)
set(GLUT_LIB ToonzAndroidGLUTFonts)
set(GLEW_LIB "")
set(OPEN_TOONZ_ANDROID_LEGACY_GL_READY TRUE)

message(STATUS "ToonzTab: configured pinned GL4ES + Android GLU compatibility libraries")

# ---------------------------------------------------------------------------
# glShaderSource prototype compatibility between GL4ES and the NDK's GLES2.
#
# Qt for Android includes <GLES2/gl2.h> (Khronos: const GLchar *const *string)
# while OpenToonz includes GL4ES' <GL/gl.h> through tgl.h. Both end up in the
# same translation unit (e.g. toonzlib/imagebuilders.cpp). The CI log of run
# 38208792779 showed GL4ES' include/GL/glext.h declaring both the
# PFNGLSHADERSOURCEPROC typedef (line 5594) and glShaderSource (line 5500) with
# `const GLchar **`, which conflicts with the NDK header.
#
# The pinned GL4ES headers are NOT edited in the fetched source tree (GL4ES
# itself is compiled against them). Instead, only when the offending
# `const GLchar **` form is actually present, a patched COPY of the include
# directory is created in the build tree and put first on the include path for
# the OpenToonz modules. If nothing needs patching, nothing changes.
# The relevant lines are printed so the CI log shows the real header text.
# ---------------------------------------------------------------------------
set(OPEN_TOONZ_GL4ES_GLEXT "${opentoonz_gl4es_SOURCE_DIR}/include/GL/glext.h")
if(EXISTS "${OPEN_TOONZ_GL4ES_GLEXT}")
    file(STRINGS "${OPEN_TOONZ_GL4ES_GLEXT}" _ot_ss_lines
        REGEX "PFNGLSHADERSOURCEPROC|glShaderSource[ \t]*\\(")
    message(STATUS "ToonzTab: GL4ES glShaderSource declarations: ${_ot_ss_lines}")

    file(READ "${OPEN_TOONZ_GL4ES_GLEXT}" _ot_glext_text)
    set(_ot_glext_patched "${_ot_glext_text}")
    string(REGEX REPLACE
        "(glShaderSource[ \t]*\\([^;]*const[ \t]+GLchar[ \t]*)\\*[ \t]*\\*"
        "\\1*const *" _ot_glext_patched "${_ot_glext_patched}")
    string(REGEX REPLACE
        "(PFNGLSHADERSOURCEPROC[ \t]*\\)[^;]*const[ \t]+GLchar[ \t]*)\\*[ \t]*\\*"
        "\\1*const *" _ot_glext_patched "${_ot_glext_patched}")

    if(NOT "${_ot_glext_patched}" STREQUAL "${_ot_glext_text}")
        set(OPEN_TOONZ_GL4ES_PATCHED_INCLUDE
            "${CMAKE_BINARY_DIR}/opentoonz-gl4es-include")
        file(MAKE_DIRECTORY "${OPEN_TOONZ_GL4ES_PATCHED_INCLUDE}")
        file(COPY "${opentoonz_gl4es_SOURCE_DIR}/include/"
            DESTINATION "${OPEN_TOONZ_GL4ES_PATCHED_INCLUDE}")
        file(WRITE "${OPEN_TOONZ_GL4ES_PATCHED_INCLUDE}/GL/glext.h"
            "${_ot_glext_patched}")
        # Last BEFORE call wins: the patched GL headers are searched first by
        # every OpenToonz module added after this point.
        include_directories(BEFORE SYSTEM "${OPEN_TOONZ_GL4ES_PATCHED_INCLUDE}")
        message(STATUS "ToonzTab: patched GL4ES glShaderSource prototype for NDK GLES2 compatibility")
    else()
        message(STATUS "ToonzTab: GL4ES glShaderSource prototype needs no patch")
    endif()
else()
    message(WARNING "ToonzTab: GL4ES glext.h not found at ${OPEN_TOONZ_GL4ES_GLEXT}")
endif()

# ---------------------------------------------------------------------------
# Inter-module link graph for Android.
#
# The per-module CMakeLists only link the sibling OpenToonz libraries inside
# MSVC / Apple / UNIXLIKE branches. Android matches none of them, so e.g.
# libtnzbase.so was linked without libtnzcore.so and failed with hundreds of
# undefined references (TIStream, TFilePath, TRaster, ...). Android shared
# libraries are linked with --no-undefined, so every dependency must be explicit.
#
# This is deferred to the end of the current directory so that all module
# targets already exist. Only sibling OpenToonz targets are added here; third
# party libraries (JPEG, LZ4, TIFF, PNG, SuperLU, OpenBLAS, MyPaint, ...) are
# NOT provided by this block and still need real Android builds.
#
# NOTE: dependencies are passed as separate function arguments. An earlier
# version stored them in a CMake list of strings such as "tnzext|tnzcore;tnzbase";
# since ';' is the list separator even inside quotes, the outer list was split
# and `list(GET ... 1 ...)` failed with "index: 1 out of range".
# ---------------------------------------------------------------------------
if(CMAKE_VERSION VERSION_LESS 3.19)
    message(FATAL_ERROR "The Android link graph requires CMake 3.19+ (cmake_language(DEFER)).")
endif()

function(opentoonz_android_link_siblings target)
    if(NOT TARGET ${target})
        message(STATUS "ToonzTab: link graph skipped, target not present: ${target}")
        return()
    endif()
    foreach(dep IN LISTS ARGN)
        if(NOT TARGET ${dep})
            message(FATAL_ERROR "Android link graph: missing target ${dep} required by ${target}")
        endif()
        # Plain signature: matches how the module files call it.
        target_link_libraries(${target} ${dep})
    endforeach()
endfunction()

function(opentoonz_android_link_module_graph)
    opentoonz_android_link_siblings(tnzbase tnzcore)
    opentoonz_android_link_siblings(tnzext tnzcore tnzbase)
    opentoonz_android_link_siblings(toonzlib tnzcore tnzbase tnzext)
    opentoonz_android_link_siblings(image tnzcore tnzbase toonzlib)
endfunction()

cmake_language(DEFER CALL opentoonz_android_link_module_graph)
