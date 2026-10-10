# Android tablet port — source audit

Date: 2026-10-10  
Repository branch: `master`  
Scope: initial source-level audit; no Android build is claimed.

## Findings verified in this source tree

1. The main application is configured from `toonz/sources/CMakeLists.txt`.
2. The project identifies only Windows, Apple, and Unix-like build environments. Android currently falls into the generic Unix-like path instead of having a dedicated Android target configuration.
3. The existing CMake configuration requires a broad desktop Qt 5 module set: Core, Gui, Network, OpenGL, Svg, Xml, Script, Widgets, PrintSupport, LinguistTools, Multimedia, MultimediaWidgets, SerialPort, and UiTools.
4. On 64-bit non-Apple builds, the configuration requires OpenCV. Additional third-party native dependencies and platform assumptions must also be checked for Android compatibility.
5. The main app entry point `toonz/sources/toonz/main.cpp` includes desktop UI and graphics components and the `kis_tablet_support_win8.h` tablet-support header. That header and any related Windows-specific code must be isolated behind platform checks or replaced with Qt Android input handling.
6. The repository's existing documented build paths target Windows, macOS, Linux, and BSD; they do not provide an Android/Qt Creator APK build path.

## Implementation progress — 2026-10-10

The top-level CMake configuration has now been changed to detect `ANDROID` before the generic `UNIX` branch and set dedicated `BUILD_TARGET_ANDROID` / `BUILD_ENV_ANDROID` flags. Until an Android-specific Qt and native-dependency set exists, configuration stops with a clear fatal message before requesting the desktop Qt module bundle. This is a guardrail and a platform-detection fix only; it does **not** mean that OpenToonz builds or runs on Android yet.

The GitHub Actions source audit now checks that this Android branch and fail-fast guard remain present.

## Consequence

The current full OpenToonz target should not be sent directly to an Android NDK build and described as a tablet app. It is likely to fail configuration or compilation before reaching the application because the CMake platform selection and required Qt/dependency set are desktop-oriented.

## Next implementation sequence

- Pin and validate a compatible Qt-for-Android version, SDK/NDK, JDK, and ABI; then replace the current fail-fast guard with a tested Android-specific configuration.
- Audit each required Qt module and third-party library against that toolchain; replace or disable unsupported optional modules only when the code permits it.
- Separate Windows-only tablet support from generic Qt tablet/stylus input.
- Adapt the application shell for landscape tablets with touch-sized tools, canvas, layers/properties, and timeline/Xsheet.
- Integrate the original animation core incrementally, resolving compile and runtime blockers in order.
- Add CI to produce an APK only when the actual Android target configures and builds successfully.

## Completion criteria

An Android artifact is not considered a working port until it installs and launches on a physical tablet and supports drawing, project save/reopen, frame navigation/playback, and export. A desktop build, a static UI, or a placeholder APK is not sufficient.
