# ToonzTab — OpenToonz for Android tablets

**ToonzTab** is the working name for this independent adaptation of the OpenToonz 2D animation project, focused exclusively on Android tablets in landscape orientation. The original OpenToonz source tree is retained as the long-term engine foundation.

> **Development status:** the Android app in `mobile-android/` is an early Kotlin/Compose interaction prototype. It is not yet the full OpenToonz C++ engine, does not open native OpenToonz scenes or levels, and must not be treated as a finished animation app. A successful installable Android build has not yet been verified.

## Product direction

- **Target:** Android tablets only; phones are intentionally out of scope.
- **Workspace:** landscape-first layout, a large drawing canvas, touch-sized tools, timeline/frame strip, and room for levels and panels.
- **Long-term engine:** preserve and progressively adapt the OpenToonz C++ animation core and its supported dependencies; do not replace the project with an unrelated drawing app.
- **Android prototype:** `mobile-android/` contains the separate Android UI prototype and its Gradle project.
- **Build validation:** `.github/workflows/android-mobile.yml` attempts to build a debug APK and upload it as a GitHub Actions artifact. The artifact is available only if the workflow succeeds.
- **Identity:** ToonzTab is a working name for this adaptation, not an official OpenToonz release.

## Current Android prototype

Implemented in the current branch: tablet-landscape shell, frame-specific sketch strokes, pencil/eraser drawing, basic per-frame undo/redo, frame selection, approximate 12 FPS playback, and a simple previous-frame onion-skin overlay.

Not implemented yet: persistent project files, lasso selection, transform/move tools, stylus pressure, layers, audio, import/export, rendering, native OpenToonz scene/level compatibility, and integration of the C++ engine. Read [the Android prototype status and roadmap](./mobile-android/README.md).

## Porting principles

1. Keep the upstream desktop source intact while isolating Android-specific work.
2. Audit upstream build scripts, third-party libraries, Qt modules, and platform assumptions before attempting an NDK port.
3. Add native integration incrementally and validate each dependency on Android; a Kotlin UI alone is not an OpenToonz port.
4. Publish an APK as a usable build only after CI succeeds and the app is tested on a real Android tablet.
5. Preserve upstream copyright notices, license files, and third-party attribution.

## Upstream and licensing

This project is based on [OpenToonz](https://github.com/opentoonz/opentoonz), an open-source 2D animation program published by DWANGO and based on Toonz technology. It is an independent adaptation, not an official OpenToonz release.

OpenToonz source files and bundled third-party components have their own license notices. Review [LICENSE.txt](./LICENSE.txt) and the relevant third-party notices before redistributing any source or binary. Keep all required attribution and license files in derivative distributions.
