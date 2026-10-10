# Android tablet port — source audit

Date: 2026-10-10  
Repository branch: `master`  
Scope: initial source-level audit; no Android build is claimed.

## Findings verified in this source tree

1. The main application is configured from `toonz/sources/CMakeLists.txt`.
2. The original configuration treated Android as a generic Unix-like target. The current patch adds explicit `BUILD_TARGET_ANDROID` / `BUILD_ENV_ANDROID` detection; the complete Android application target and dependency configuration remain unfinished.
3. The CMake Qt module list now conditionally excludes `MultimediaWidgets` and `SerialPort` for Android while retaining them for desktop targets. The remaining Qt modules and their use by the full application still need validation with the selected Android Qt kit.
4. On 64-bit non-Apple builds, the configuration requires OpenCV. Additional third-party native dependencies and platform assumptions must also be checked for Android compatibility.
5. The main app entry point `toonz/sources/toonz/main.cpp` includes desktop UI and graphics components. The Windows 8 tablet-support header is guarded by `_WIN32`, its source is selected only for Windows, and the legacy `QGLPixelBuffer` include is guarded for Android. Existing `QTabletEvent` and touchscreen gesture code still needs validation on Android hardware.
6. A Qt 5.15 Android manifest template and `ANDROID_PACKAGE_SOURCE_DIR` hook now exist, but there is still no tested Android toolchain configuration or successful APK build path.

## Implementation progress — 2026-10-10

The top-level CMake configuration detects `ANDROID` before the generic `UNIX` branch and sets dedicated `BUILD_TARGET_ANDROID` / `BUILD_ENV_ANDROID` flags. Until an Android-specific graphics and native-library link path exists, configuration stops with a fatal message before building the desktop application. The remaining blocker includes OpenCV, GLEW/desktop OpenGL assumptions, and other native libraries—not just the Qt modules that were already gated.

The application CMake now adds the Windows Pointer Input adapter only to Windows targets. On Android, the startup path maximizes the window instead of restoring desktop coordinates and skips the desktop-only maximize/layout workaround. The legacy `QGLPixelBuffer` include is also guarded for Android while remaining available to desktop builds. The top-level Qt module list omits `SerialPort` and `MultimediaWidgets` for Android, and `stopmotionserial.cpp` provides a no-device Android implementation while preserving the original desktop serial implementation. See the [dependency matrix](android_tablet_dependency_matrix.md) for the remaining work. These are compatibility steps; they do **not** mean that OpenToonz builds or runs on Android yet.

The GitHub Actions source audit checks Android platform detection, the fail-fast guard, the Windows-only pen adapter, Android Qt-module exclusions, the serial fallback, and the dependency matrix.

## Consequence

The current full OpenToonz target should not be sent directly to an Android NDK build and described as a tablet app. It is likely to fail configuration or compilation before reaching the application because the CMake platform selection and required Qt/dependency set are desktop-oriented.

## Next implementation sequence

- Pin and validate a compatible Qt-for-Android version, SDK/NDK, JDK, and ABI; then replace the current fail-fast guard with a tested Android-specific configuration.
- Use [the dependency matrix](android_tablet_dependency_matrix.md) to gate unsupported Qt Serial Port / Multimedia Widgets uses, add Android-compatible native dependencies, and implement an Android-specific target/link branch before removing the CMake guard.
- Separate Windows-only tablet support from generic Qt tablet/stylus input.
- Adapt the application shell for landscape tablets with touch-sized tools, canvas, layers/properties, and timeline/Xsheet.
- Integrate the original animation core incrementally, resolving compile and runtime blockers in order.
- Add CI to produce an APK only when the actual Android target configures and builds successfully.

## Completion criteria

An Android artifact is not considered a working port until it installs and launches on a physical tablet and supports drawing, project save/reopen, frame navigation/playback, and export. A desktop build, a static UI, or a placeholder APK is not sufficient.
