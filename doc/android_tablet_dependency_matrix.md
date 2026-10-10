# Android tablet port — dependency matrix

Date: 2026-10-10  
Status: source audit; no Android APK build is claimed.

## Known blockers before removing the Android CMake guard

| Component | What the repository currently does | Android issue | Required port work |
|---|---|---|---|
| Qt Serial Port | The top-level Qt module list now adds `SerialPort` only for non-Android targets. `stopmotionserial.cpp` provides a no-device fallback when `Q_OS_ANDROID` is set; desktop builds retain the original `QSerialPort` implementation. | Qt 5.15 for Android does not support the Qt Serial Port module, so external serial lighting/controllers do not operate in the Android build yet. | Later add and test an Android-compatible USB/serial backend if external stop-motion controllers are required. |
| Qt Print Support | The CMake module list and `print.cpp` are now selected only for non-Android targets. Xsheet PDF export remains in `exportxsheetpdf.cpp` and uses `QPdfWriter` from Qt Gui. | Qt Print Support is unavailable on Android in the documented Qt module set, and the traditional print dialog is a desktop workflow. | Keep Android independent of `QPrinter` / `QPrintDialog`; validate PDF generation separately and use the Android share/save workflow if export is retained. |
| Qt Multimedia Widgets | The top-level Qt module list now adds `MultimediaWidgets` only for non-Android targets; the application target's explicit link to it was already limited to the Apple branch. | Qt 5.15 Android platform notes say Qt Multimedia Widgets is not supported on Android. | Verify the Android source path contains no direct widget-module headers; design a supported camera-preview path before enabling a full stop-motion video view. |
| Main application graphics startup | The Android branch of `main.cpp` now configures `QSurfaceFormat` for OpenGL ES and does not run the desktop GLUT/`QGLFormat` startup block. | This does not port the renderer itself: other OpenToonz rendering and tool code still depends on legacy OpenGL APIs and has not been compiled or tested against the Android GLES stack. | Trace the rendering call graph, replace incompatible desktop-only APIs where needed, and compile/test a native Android ABI before enabling the full target. |
| Desktop OpenGL libraries | The Unix-like branch searches for `GL`, `GLU`, and `GLUT`, then links them into the desktop executable. | Android uses EGL/OpenGL ES and does not provide the same desktop library/link assumptions. | Add a dedicated Android graphics/link configuration and verify the rendering code against the Android Qt/OpenGL ES path. |
| Android OpenCV package | The CMake hook accepts `OPEN_TOONZ_ANDROID_OPENCV_ROOT` or `OPENCV_ANDROID_SDK_ROOT` and resolves the package at `sdk/native/jni`. A script fetches official OpenCV 4.14.0 Android SDK and verifies its SHA-256 before extraction. | Stop-motion webcam code still uses OpenCV, so the package must match the chosen Android ABI. This does not resolve the other native graphics/dependency blockers. | Keep the version and checksum pinned, pass the SDK root to CMake, and link-test with the Android toolchain. |
| Native image/math dependencies | Desktop branches locate TIFF, PNG, JPEG, GLEW, SuperLU, LZ4, LZO, TurboJPEG, OpenCV, FreeType, MyPaint, USB and related libraries. The Android branch now excludes the legacy MOV/3GP proxy sources that call an external 32-bit helper, and `tiio.cpp` skips QuickTime helper registration on Android while retaining FFmpeg registration when available. | These native libraries cannot be assumed to exist as host-system libraries for an Android NDK target; libraries must be Android/ABI-compatible, and several hardware/codec features may be unavailable. | Classify each library as required/optional, cross-compile required components for the chosen ABI, and conditionally exclude optional desktop/hardware features. Test MOV/3GP only when the packaged FFmpeg build supports the formats. |
| Android pencil-test capture UI | The Android app target selects `penciltestpopup_qt.cpp` and `cameracapturelevelcontrol_qt.cpp`, which use Qt's video-surface API instead of the OpenCV-based desktop pencil-test implementation. The source now requests `android.permission.CAMERA` at runtime when the user selects a camera and links Qt Android Extras for this purpose. The stop-motion webcam subsystem remains OpenCV-backed. | Camera permissions, Qt Multimedia's Android backend, and the camera pipeline still require physical-device validation. | Test denied/granted permission paths, camera capture and frame saving on a tablet; keep desktop 64-bit capture sources unchanged. |
| Main executable linking | `toonz/sources/toonz/CMakeLists.txt` contains explicit link branches for MSVC, Apple and Unix-like environments. The Android default build now excludes the LZO CLI helpers and the separate `tcleanupper`, `tcomposer`, `tconverter`, and farm-controller/server executables while leaving their targets available for future port work. | `BUILD_ENV_ANDROID` still lacks an Android-specific `target_link_libraries` branch, and editor features that depend on separate desktop helper processes are not available in the Android baseline. | Add a deliberate Android target/link branch and port or replace helper-process-dependent features only after the compatible native dependencies are defined. |
| Qt Android packaging | A Qt 5.15-based `toonz/sources/toonz/android/AndroidManifest.xml` template now preserves the `androiddeployqt` placeholders, requests landscape orientation, uses the `com.toonz.tab` application ID and ToonzTab label, and excludes small-screen devices. The app CMake records `ANDROID_PACKAGE_SOURCE_DIR` and includes an Android executable creation branch. | The top-level Android fail-fast guard prevents CMake reaching this target, and no Android-specific `target_link_libraries` branch or successful APK build exists yet. | Finish the Android dependency/link branches first, then validate manifest/package name, ABI, SDK/NDK/JDK and build APK with Qt Creator/`androiddeployqt`. |

## Relevant source locations

- [Image I/O CMake](../toonz/sources/image/CMakeLists.txt): excludes the legacy desktop MOV/3GP proxy sources from Android.
- [Image I/O registration](../toonz/sources/image/tiio.cpp): avoids QuickTime helper registration on Android and can use FFmpeg format handlers when present.
- [Desktop print command](../toonz/sources/toonz/print.cpp): not compiled into the Android target because it depends on `QPrinter` and `QPrintDialog`; Xsheet PDF export is a separate path.

- [Top-level source CMake](../toonz/sources/CMakeLists.txt): Qt module requirements, platform branches and third-party dependency selection.
- [Application CMake](../toonz/sources/toonz/CMakeLists.txt): Windows/Apple/Unix link branches and source selection.
- [Application entry point](../toonz/sources/toonz/main.cpp): desktop application startup and platform-specific tablet input.
- [Android package manifest](../toonz/sources/toonz/android/AndroidManifest.xml): Qt deployment template set to landscape for tablet screens; packaging is not yet enabled because the native target is unfinished.

## Qt 5.15 documentation consulted

- [Qt for Android module/platform support](https://qthub.com/static/doc/qt5/qtdoc/android.html)
- [Qt Android platform notes — Multimedia Widgets](https://qthub.com/static/doc/qt5/qtdoc/android-platform-notes.html)
- [Qt Android deployment and APK packaging](https://qthub.com/static/doc/qt5/qtdoc/deployment-android.html)

## Safe completion rule

Do not remove the Android fail-fast guard simply to make CMake proceed. Remove it only when unsupported module references are gated/replaced, the Android graphics and native-library link branches exist, required OpenCV/GLEW alternatives are validated, and a real Android toolchain configures and links the original application target.
