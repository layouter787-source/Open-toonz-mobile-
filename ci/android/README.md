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

This script only prepares OpenCV. It does not compile OpenToonz, does not supply the Android Qt kit, and does not solve the existing OpenGL/GLEW/GLU/GLUT assumptions or the other ABI-specific libraries. The root CMake Android guard must remain until those are ported and the original application target can configure and link.
