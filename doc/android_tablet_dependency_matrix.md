# Android tablet port — dependency matrix

Date: 2026-10-10  
Status: source audit; no Android APK build is claimed.

## Known blockers before removing the Android CMake guard

| Component | What the repository currently does | Android issue | Required port work |
|---|---|---|---|
| Qt Serial Port | The top-level Qt module list now adds `SerialPort` only for non-Android targets. `stopmotionserial.cpp` provides a no-device fallback when `Q_OS_ANDROID` is set; desktop builds retain the original `QSerialPort` implementation. | Qt 5.15 for Android does not support the Qt Serial Port module, so external serial lighting/controllers do not operate in the Android build yet. | Later add and test an Android-compatible USB/serial backend if external stop-motion controllers are required. |
| Qt Multimedia Widgets | The top-level Qt module list now adds `MultimediaWidgets` only for non-Android targets; the application target's explicit link to it was already limited to the Apple branch. | Qt 5.15 Android platform notes say Qt Multimedia Widgets is not supported on Android. | Verify the Android source path contains no direct widget-module headers; design a supported camera-preview path before enabling a full stop-motion video view. |
| Desktop OpenGL libraries | The Unix-like branch searches for `GL`, `GLU`, and `GLUT`, then links them into the desktop executable. | Android uses EGL/OpenGL ES and does not provide the same desktop library/link assumptions. | Add a dedicated Android graphics/link configuration and verify the rendering code against the Android Qt/OpenGL ES path. |
| Native image/math dependencies | Desktop branches locate TIFF, PNG, JPEG, GLEW, SuperLU, LZ4, LZO, TurboJPEG, OpenCV, FreeType, MyPaint, USB and related libraries. | These cannot be assumed to exist as host-system libraries for an Android NDK target; libraries must be Android/ABI-compatible, and several device-specific features may be unnecessary. | Classify each library as required/optional, cross-compile required components for the chosen ABI, and conditionally exclude optional desktop/hardware features. |
| Main executable linking | `toonz/sources/toonz/CMakeLists.txt` contains explicit link branches for MSVC, Apple and Unix-like environments. | `BUILD_ENV_ANDROID` does not enter any of those branches, so simply deleting the top-level guard would not create a properly linked Android application. | Add a deliberate Android target/link branch only after its Qt modules and native dependencies are defined. |
| Qt Android packaging | No Android package source directory or tested APK deployment configuration is present in this repository. | A successful native link alone is not an APK. | Add a Qt Creator / `androiddeployqt` packaging path, manifest, orientation and ABI settings after an Android application target can be built. |

## Relevant source locations

- [Top-level source CMake](../toonz/sources/CMakeLists.txt): Qt module requirements, platform branches and third-party dependency selection.
- [Application CMake](../toonz/sources/toonz/CMakeLists.txt): Windows/Apple/Unix link branches and source selection.
- [Application entry point](../toonz/sources/toonz/main.cpp): desktop application startup and platform-specific tablet input.

## Qt 5.15 documentation consulted

- [Qt for Android module/platform support](https://qthub.com/static/doc/qt5/qtdoc/android.html)
- [Qt Android platform notes — Multimedia Widgets](https://qthub.com/static/doc/qt5/qtdoc/android-platform-notes.html)
- [Qt Android deployment and APK packaging](https://qthub.com/static/doc/qt5/qtdoc/deployment-android.html)

## Safe completion rule

Do not remove the Android fail-fast guard simply to make CMake proceed. Remove it only when the unsupported module references are gated/replaced, the Android-specific library and link branches exist, and a real Android toolchain configures and links the original application target.
