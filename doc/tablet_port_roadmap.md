# ToonzTab — Port of the original OpenToonz application to Android tablets

## Non-negotiable project direction

This project must adapt the existing OpenToonz application and its C++/Qt source tree for Android tablets. It must not replace OpenToonz with a newly written drawing app, a Kotlin-only editor, or a UI mockup. The existing upstream source tree is the product foundation and must remain in the repository.

The Android adaptation should keep as much of the original animation engine and workflows as the platform permits: drawing tools and levels, scene model, Xsheet/timeline, onion skin, effects, compositing, rendering, and native project formats. Each feature must be verified before claiming compatibility.

## Findings in the current branch

- The original native application entry point is in `toonz/sources/toonz/main.cpp`.
- The native build configuration is in `toonz/sources/CMakeLists.txt` and the application target configuration is in `toonz/sources/toonz/CMakeLists.txt`.
- The existing CMake configuration detects the Android NDK, but currently stops with a fatal error before building the full application. That guard exists because the native dependency/link path is incomplete.
- The separate `mobile-android/` Kotlin/Compose project is only an experimental UI scaffold. It is not the port and must not be used as evidence that the OpenToonz engine runs on Android.
- No working Android build of the complete OpenToonz engine has been verified yet.

## Porting work must happen in the original native codebase

### 1. Build and dependency audit

Start from `toonz/sources/CMakeLists.txt`, `toonz/sources/toonz/CMakeLists.txt`, and the original target's dependency graph. Inventory every Qt module, third-party library, codec, plugin, desktop OS API, file dialog, filesystem assumption, and OpenGL/GLEW path. Mark each dependency as Android-compatible, replaceable, or requiring a port. Keep upstream files and license notices.

### 2. Native Qt/NDK application target

Use a supported Qt-for-Android toolchain, Android SDK/NDK, CMake, and a tablet ABI. Adapt the existing native `OpenToonz` application target and startup path. Do not simply remove the Android guard and hope the desktop target compiles: first resolve the dependency and source-selection blockers that the guard documents.

### 3. Android platform adaptation

Replace desktop-only windowing, file access, dialogs, input and platform integrations with Android-compatible equivalents. Keep the existing scene and animation systems wherever possible. Use Android document access for opening and saving projects. Make graphics/rendering code work with the Android-supported graphics stack.

### 4. Tablet interaction design

Adapt the original editor to landscape tablets, with touch-sized tools, stylus input, a large canvas, timeline/Xsheet, levels and properties panels. This is a redesign of the original application's UI and interaction—not a separate replacement editor. Preserve keyboard and shortcut workflows where tablet keyboards are available.

### 5. Validation

Build the actual native application, package it as an Android APK, install it on a physical tablet, and verify startup, stylus drawing, editing, saving/reopening native projects, playback, effects and rendering/export. Only features tested end-to-end may be described as working.

## Acceptance criteria

The project is not considered an OpenToonz Android port merely because an APK or a Kotlin drawing canvas exists. The acceptance target is the original OpenToonz application and engine adapted to run on Android tablets, with the new app identity and tablet-appropriate interaction.

## Honest status

The original OpenToonz source tree is present. The complete native Android port is not finished, and no successful APK containing the full engine has been verified. The next implementation work must modify and build the native C++/Qt application and its dependencies, not expand the standalone Kotlin scaffold.
