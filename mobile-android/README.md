# ToonzTab — OpenToonz for Android tablets

ToonzTab is the working product name for an Android-tablet adaptation project based on the OpenToonz codebase. The Motion Studio concept is discontinued and is not part of this project.

## Product scope
- Android tablets only; no phone-focused layout or phone support is intended.
- Tablet-first landscape workspace, stylus/touch input and a large drawing canvas.
- Professional 2D animation workflow as the target: levels/layers, frame-by-frame drawing, timeline, playback, selection/transforms, project save/load and export.
- Preserve the upstream OpenToonz desktop source in the repository while Android-specific code lives under `mobile-android/`.

## Current status
The Android folder is an early native UI/build foundation with a touch-drawing canvas and a preliminary frame strip. It is not yet a port of the full OpenToonz engine and must not be represented as feature-complete. The tablet-only manifest filtering and product identity are initial configuration, not a substitute for testing on real tablets.

## Build
Use JDK 17 and Gradle 8.10.2:
```sh
gradle :app:assembleDebug
```
Run the `Android tablet foundation` GitHub Actions workflow to build a debug APK artifact.

## Required porting work
OpenToonz is a C++/Qt desktop application with substantial platform dependencies. A genuine Android port needs a dependency audit, Android-compatible replacements for desktop UI/platform layers, and selective reuse of portable C++ core components via the Android NDK/JNI where practical. The current Compose editor is scaffolding, not the OpenToonz renderer or animation engine.

## Roadmap
1. Tablet-only product configuration and landscape-first workspace.
2. Proper canvas model, stylus pressure, zoom/pan/rotate, lasso selection and transform.
3. Real animation levels/cels, layers, timeline editing and playback.
4. Native project save/load, import and export.
5. Port reusable OpenToonz engine components after auditing dependencies.
6. Hardware performance, tablet/stylus testing and APK validation.
