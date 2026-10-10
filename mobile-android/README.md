# ToonzTab — OpenToonz tablet port

ToonzTab is the working name for an Android-tablet adaptation project based on the OpenToonz repository. The Android app lives in this separate `mobile-android/` directory so the original desktop source tree remains intact.

## Current status

This branch contains an early Android/Compose interaction prototype, not a completed port of the OpenToonz engine. The prototype demonstrates a tablet-landscape workspace, frame-specific sketch strokes, basic undo/redo, a frame strip, playback at approximately 12 FPS, and a simple previous-frame onion-skin overlay.

The pencil and eraser are the only implemented drawing tools. Lasso, Move, and Hand are visual placeholders. Artwork is held in memory only and is lost when the process is closed. Native OpenToonz project files, levels, scenes, rendering, import/export, stylus pressure, and the C++ engine are not yet integrated.

## Build the Android prototype

From this directory, with JDK 17 and Gradle 8.10.2 available:

```sh
gradle --no-daemon :app:assembleDebug
```

The GitHub Actions workflow `.github/workflows/android-mobile.yml` attempts to build a debug APK and publish it as the `toonz-tab-tablet-debug` artifact.

## Porting roadmap

1. Establish a repeatable Android build and test pipeline for the prototype.
2. Add persistent project storage and a documented interchange format for early tablet sketches.
3. Introduce a native C++/NDK integration boundary and inventory the upstream OpenToonz dependencies.
4. Port or replace platform-specific desktop services incrementally; do not claim OpenToonz scene/level compatibility until tested against real files.
5. Implement tablet input, stylus pressure, selection/transforms, layers, timeline exposure sheets, audio, rendering, and export.
6. Validate on Android tablets with a smallest width of at least 600 dp.

## Important constraints

- Tablet-focused landscape UI; phones are intentionally excluded from the manifest's supported screen sizes.
- The original desktop OpenToonz source is preserved.
- This is a porting project, not a wrapper around a remote desktop application.
- Do not describe the Android prototype as feature-complete or as running the full OpenToonz engine until that is actually implemented and verified.
