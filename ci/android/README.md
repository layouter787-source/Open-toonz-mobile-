# Android dependency preparation

## OpenCV Android SDK

The OpenToonz capture/stop-motion sources still use OpenCV. A desktop OpenCV installation cannot be reused for an Android NDK build: libraries must match the target ABI.

Fetch the pinned official OpenCV Android SDK:

```bash
bash ci/android/fetch-opencv-android-sdk.sh thirdparty/opencv-android-sdk
```

The script downloads OpenCV 4.14.0's official Android SDK release asset and checks its SHA-256 before extracting it:

- Asset: [opencv-4.14.0-android-sdk.zip](https://github.com/opencv/opencv/releases/download/4.14.0/opencv-4.14.0-android-sdk.zip)
- SHA-256: `e8cfaf2e51f2e2127a6ede91718d1ef7587f8b6e62db922816e7c33a1f1116a7`
- Expected CMake package: `thirdparty/opencv-android-sdk/sdk/native/jni/OpenCVConfig.cmake`

When an Android configure path is enabled, pass the SDK root through:

```bash
-DOPEN_TOONZ_ANDROID_OPENCV_ROOT="$PWD/thirdparty/opencv-android-sdk"
```

Alternatively, set `OPENCV_ANDROID_SDK_ROOT` to the same directory. Keep the downloaded SDK out of Git unless the project intentionally chooses to vendor that large binary.

## Current limits

This script only prepares OpenCV. It does not compile OpenToonz or supply the Android Qt kit. The repository now has an experimental opt-in native build and an `Android Tablet APK (OpenToonz ARM64)` workflow that attempts the original C++/Qt build and `androiddeployqt` packaging. It is not release-ready until that workflow succeeds, publishes an APK artifact, and the APK is installed and tested on an ARM64 Android tablet. The remaining third-party ABI, rendering, and runtime dependencies must be checked from the current CI logs.
