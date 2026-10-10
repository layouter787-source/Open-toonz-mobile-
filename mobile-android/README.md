# OpenToonz Mobile — Android foundation

This directory is a separate Android-native mobile client foundation alongside the original OpenToonz desktop source. It does not claim that the desktop Qt application already runs on Android.

## Direction
- Android phone and tablet UI, landscape-first editor with responsive portrait support.
- Touch drawing canvas, undo/redo and frame strip foundation.
- Compact tool rail, large canvas, bottom timeline, lasso/transform tools planned.
- Future hybrid workflow: frame-by-frame drawing + rigged/stick-segment animation in one project.
- Local project format and export pipeline to be added in later stages.

## Build
Open this directory as a Gradle project, or run Gradle 8.10.2:
```sh
gradle :app:assembleDebug
```

The GitHub Actions workflow builds this Android foundation. The original OpenToonz desktop source remains in the repository root.

## Technical boundary
OpenToonz is a C++/Qt desktop application with a large dependency stack. Android support requires a deliberate port of reusable core pieces and replacement of desktop-only UI/platform dependencies; changing the target SDK or wrapping the desktop executable is not enough. This first stage establishes the native mobile shell and input canvas, not feature parity with the desktop editor.

## Roadmap
1. Android shell, canvas gestures and drawing strokes.
2. Layers, frame cels, playback and timeline editing.
3. Lasso selection, transform handles, brush/eraser library and rulers.
4. Project save/load and image sequence export.
5. Port compatible OpenToonz C++ components behind JNI after dependency-by-dependency validation.
6. Hybrid rigging + hand-drawn frame editing, audio and video export.
7. Tablet/stylus pressure, performance and accessibility testing.
