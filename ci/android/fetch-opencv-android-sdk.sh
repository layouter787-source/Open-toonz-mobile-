#!/usr/bin/env bash
# Fetch the official, version-pinned OpenCV Android SDK and verify its SHA-256.
# Usage: ci/android/fetch-opencv-android-sdk.sh [destination-directory]
set -euo pipefail

readonly OPENCV_VERSION="4.14.0"
readonly OPENCV_ASSET_SHA256="e8cfaf2e51f2e2127a6ede91718d1ef7587f8b6e62db922816e7c33a1f1116a7"
readonly OPENCV_ASSET_URL="https://github.com/opencv/opencv/releases/download/${OPENCV_VERSION}/opencv-${OPENCV_VERSION}-android-sdk.zip"

DESTINATION="${1:-${OPENCV_ANDROID_SDK_ROOT:-thirdparty/opencv-android-sdk}}"

if [[ -f "${DESTINATION}/sdk/native/jni/OpenCVConfig.cmake" ]]; then
  echo "OpenCV Android SDK already present at ${DESTINATION}"
  exit 0
fi

if [[ -d "${DESTINATION}" ]] && [[ -n "$(find "${DESTINATION}" -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
  echo "Destination exists and is not an OpenCV Android SDK: ${DESTINATION}" >&2
  exit 2
fi

for tool in curl sha256sum unzip find; do
  command -v "${tool}" >/dev/null 2>&1 || {
    echo "Required tool not found: ${tool}" >&2
    exit 127
  }
done

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT
ARCHIVE="${WORK_DIR}/opencv-android-sdk.zip"
EXTRACT_DIR="${WORK_DIR}/unpacked"
mkdir -p "${EXTRACT_DIR}" "${DESTINATION}"

echo "Downloading OpenCV ${OPENCV_VERSION} Android SDK..."
curl --fail --location --retry 3 --retry-delay 2 "${OPENCV_ASSET_URL}" --output "${ARCHIVE}"

echo "${OPENCV_ASSET_SHA256}  ${ARCHIVE}" | sha256sum --check -
unzip -q "${ARCHIVE}" -d "${EXTRACT_DIR}"

CONFIG_FILE="$(find "${EXTRACT_DIR}" -path '*/sdk/native/jni/OpenCVConfig.cmake' -print -quit)"
if [[ -z "${CONFIG_FILE}" ]]; then
  echo "The verified archive did not contain sdk/native/jni/OpenCVConfig.cmake" >&2
  exit 3
fi

SDK_ROOT="${CONFIG_FILE%/sdk/native/jni/OpenCVConfig.cmake}"
cp -a "${SDK_ROOT}/." "${DESTINATION}/"

if [[ ! -f "${DESTINATION}/sdk/native/jni/OpenCVConfig.cmake" ]]; then
  echo "OpenCV extraction did not produce the expected CMake package." >&2
  exit 4
fi

echo "OpenCV Android SDK ${OPENCV_VERSION} installed at: ${DESTINATION}"
echo "Configure OpenToonz with -DOPEN_TOONZ_ANDROID_OPENCV_ROOT=${DESTINATION}"
