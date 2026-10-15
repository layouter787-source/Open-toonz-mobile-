#!/usr/bin/env bash
# Fetch the official, version-pinned Boost release and install ONLY its headers.
#
# OpenToonz uses header-only Boost components (optional, range, iterator,
# multi_index, bimap, graph/BFS, container/flat_map, any, ptr_container,
# xpressive, operators, config...). No compiled Boost library is needed, so the
# same header tree is valid for any target ABI. It must never be replaced by the
# host Linux /usr/include/boost when cross-compiling for Android.
#
# Usage: bash ci/android/fetch-boost-headers.sh [destination-directory]
# Result: <destination>/boost/version.hpp exists; pass the destination as BOOST_ROOT.
set -euo pipefail

readonly BOOST_VERSION="1.82.0"
readonly BOOST_VERSION_UNDERSCORE="${BOOST_VERSION//./_}"
# SHA-256 of boost_1_82_0.tar.bz2, as published on https://www.boost.org/users/download/
readonly BOOST_ARCHIVE_SHA256="a6e1ab9b0860e6a2881dd7b21fe9f737a095e5f33a3a874afc6a345228597ee6"
readonly BOOST_ARCHIVE_NAME="boost_${BOOST_VERSION_UNDERSCORE}.tar.bz2"
readonly BOOST_URLS=(
  "https://archives.boost.io/release/${BOOST_VERSION}/source/${BOOST_ARCHIVE_NAME}"
  "https://sourceforge.net/projects/boost/files/boost/${BOOST_VERSION}/${BOOST_ARCHIVE_NAME}/download"
)

DESTINATION="${1:-${OPEN_TOONZ_ANDROID_BOOST_ROOT:-thirdparty/boost-android-headers}}"

if [[ -f "${DESTINATION}/boost/version.hpp" ]]; then
  echo "Boost headers already present at ${DESTINATION}"
  exit 0
fi

if [[ -d "${DESTINATION}" ]] && [[ -n "$(find "${DESTINATION}" -mindepth 1 -maxdepth 1 -print -quit)" ]]; then
  echo "Destination exists and is not a Boost header tree: ${DESTINATION}" >&2
  exit 2
fi

for tool in curl sha256sum tar find; do
  command -v "${tool}" >/dev/null 2>&1 || {
    echo "Required tool not found: ${tool}" >&2
    exit 127
  }
done

WORK_DIR="$(mktemp -d)"
trap 'rm -rf "${WORK_DIR}"' EXIT
ARCHIVE="${WORK_DIR}/${BOOST_ARCHIVE_NAME}"
mkdir -p "${DESTINATION}"

downloaded=0
for url in "${BOOST_URLS[@]}"; do
  echo "Downloading Boost ${BOOST_VERSION} from ${url}"
  if curl --fail --location --retry 3 --retry-delay 2 "${url}" --output "${ARCHIVE}"; then
    if echo "${BOOST_ARCHIVE_SHA256}  ${ARCHIVE}" | sha256sum --check -; then
      downloaded=1
      break
    fi
    echo "Checksum mismatch for ${url}; trying next mirror" >&2
  else
    echo "Download failed for ${url}; trying next mirror" >&2
  fi
done

if [[ "${downloaded}" -ne 1 ]]; then
  echo "Could not obtain a checksum-verified Boost ${BOOST_VERSION} archive." >&2
  exit 3
fi

# Only the headers are needed (header-only usage); skip libs/, doc/, tools/.
tar -xjf "${ARCHIVE}" -C "${DESTINATION}" --strip-components=1 "boost_${BOOST_VERSION_UNDERSCORE}/boost"

if [[ ! -f "${DESTINATION}/boost/version.hpp" ]]; then
  echo "Boost extraction did not produce boost/version.hpp" >&2
  exit 4
fi

echo "Boost ${BOOST_VERSION} headers installed at: ${DESTINATION}"
echo "Configure OpenToonz with -DBOOST_ROOT=${DESTINATION} -DBoost_INCLUDE_DIR=${DESTINATION}"
