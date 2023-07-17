#!/bin/bash
set -x
export TZ=Etc/UTC

mkdir artifacts

export LATEST_VERSION="$(date)"
echo "${LATEST_VERSION}" > artifacts/LATEST_VERSION

mkdir tmp
git clone https://github.com/ytdl-org/youtube-dl tmp/ytdl --depth=1
cd tmp/ytdl

# remake version.py
echo "from __future__ import unicode_literals

__version__ = '${LATEST_VERSION}'
" > youtube_dl/version.py

git apply ../../patches/*.diff
make youtube-dl youtube-dl.tar.gz

cd ../../
mv tmp/ytdl/youtube-dl artifacts
mv tmp/ytdl/youtube-dl.tar.gz artifacts

rm -rf tmp

FILEHASH_BIN="$(sha256sum artifacts/youtube-dl | awk '{print $1}')"
FILEHASH_TAR="$(sha256sum artifacts/youtube-dl.tar.gz | awk '{print $1}')"

echo '{"versions":{}}' | jq ".latest=\"${LATEST_VERSION}\"" \
  | jq ".versions[\"${LATEST_VERSION}\"].bin=[\"https://nao20010128nao.github.io/ytdl-patched/youtube-dl\",\"${FILEHASH_BIN}\"]" \
  | jq ".versions[\"${LATEST_VERSION}\"].tar=[\"https://nao20010128nao.github.io/ytdl-patched/youtube-dl.tar.gz\",\"${FILEHASH_TAR}\"]" \
  | tee artifacts/versions.json
