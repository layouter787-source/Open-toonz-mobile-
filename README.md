# LayFrame Studio — Tablet Edition

**LayFrame Studio** is the working name for this community adaptation of the OpenToonz 2D animation engine, focused exclusively on Android tablets in landscape orientation.

> **Development status:** This repository currently contains the OpenToonz C++ source tree. The Android tablet port is not yet complete, and no installable Android APK is claimed by this README. Desktop components and dependencies still need to be audited and adapted before a tablet build can be considered functional.

## Project direction

- **Target:** Android tablets only; phones are intentionally out of scope.
- **UI:** landscape-first workspace, touch-friendly controls, drawing canvas, timeline/Xsheet, levels and panels sized for tablet displays.
- **Technology:** preserve the OpenToonz C++ animation core where possible and use Qt for the application UI and Android integration.
- **Build:** use a reproducible Android/Qt toolchain and CI to validate changes and publish an APK only after the Android target actually builds.
- **Identity:** use the working name LayFrame Studio for the adapted application. Keep upstream attribution and all applicable license notices.

## Roadmap

See [Tablet Port Roadmap](./doc/tablet_port_roadmap.md) for the staged migration plan and the current technical constraints.

## Upstream project

This project is based on [OpenToonz](https://github.com/opentoonz/opentoonz), an open-source 2D animation program published by DWANGO and based on Toonz technology. The upstream project was originally developed by Digital Video, Inc. and customized by Studio Ghibli.

The upstream source tree is retained as the foundation; this fork is an independent adaptation and is not an official OpenToonz release.

## Licensing

OpenToonz source files are subject to their existing license notices. Files outside the `thirdparty` and `stuff/library/mypaint brushes` directories are generally covered by the Modified BSD license; third-party components and brush libraries have their own terms. Read [LICENSE.txt](./LICENSE.txt) and the relevant notices before redistributing builds. Keep all required attribution and license files in any derivative distribution.

## Current limitation

A rename or a tablet-oriented README does not make the desktop application Android-compatible. The port must progressively remove or replace desktop-only assumptions, validate Qt Android support for required dependencies, adapt input and layout for touch/stylus, and build/test on a real tablet before it can be called usable.
