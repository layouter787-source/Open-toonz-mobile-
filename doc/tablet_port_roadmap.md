# LayFrame Studio — Android Tablet Port Roadmap

## Product boundary

Build a tablet-only Android animation app from this repository's OpenToonz C++ codebase. The UI should be landscape-first and designed for touch and stylus. Phone layout is not a target.

## Important technical reality

OpenToonz is a desktop application with a large dependency graph. Qt supports Android applications, but that does not automatically make every OpenToonz module, plugin, codec, file dialog, or third-party library Android-compatible. A genuine port needs staged dependency and platform work; simply renaming the executable or changing the package metadata is insufficient.

## Stages

1. **Audit the source and build graph**
   - Identify the main Qt application target, Qt modules, platform-specific APIs, third-party dependencies, plugins, codecs, and desktop-only file handling.
   - Mark each dependency as Android-ready, replaceable, or requiring a port.
   - Keep upstream license notices and record all local changes.

2. **Establish an Android/Qt toolchain**
   - Select a Qt version with Android support, Android SDK/NDK, JDK, and matching ABI.
   - Create a minimal Android Qt application build first, then add compatible OpenToonz modules incrementally.
   - Do not publish a fake or placeholder APK as if it contained the animation engine.

3. **Tablet application shell**
   - Set landscape orientation and enforce a minimum usable workspace size.
   - Create a tablet UI with a central canvas, left tool strip, right properties/layers panel, and a bottom timeline/Xsheet.
   - Use larger touch targets, stylus pressure where supported, palm/touch separation where available, and keyboard shortcuts for tablets with keyboards.
   - Avoid copying desktop menu density directly onto a touch interface.

4. **Port core animation workflows**
   - Open/save projects through Android-compatible document access.
   - Drawing levels, brush input, timeline/Xsheet, onion skin, playback, camera, and render/export.
   - Replace unsupported desktop dialogs, filesystem assumptions, and platform APIs.
   - Keep rendering and editing responsive under tablet memory constraints.

5. **Continuous integration and validation**
   - Build only after the Qt Android toolchain and compatible dependency set are pinned.
   - Run configure/build checks and archive APK artifacts from successful builds.
   - Test install, startup, touch/stylus drawing, saving/reopening, playback, and export on a physical tablet.

## Definition of done

The port is not complete until a generated APK installs and launches on a real Android tablet, accepts touch/stylus input, edits and saves an animation project, plays frames, and exports a render. A successful desktop build or a UI mockup does not satisfy this requirement.

## Current status

This document records the intended port. It does not claim that the stages above have already been implemented.
