#!/bin/sh

set -e

BASEDIR="$(cd "$(dirname "$0")" && pwd)"
cd "$BASEDIR"
VERSION=$1

if [ -d docker ]; then
  cd docker
  git fetch
else
  git clone https://git@github.com/docker/docker
  cd docker
fi

if [ "$VERSION" ]; then
  git checkout "$VERSION"
else
  echo "Usage: build.sh VERSION"
  echo
  echo "VERSIONS:"

  tags="$(git tag | sort -V)"
  echo $tags
  exit
fi

make DOCKER_CLIENTONLY=1 binary

cd "$BASEDIR"
path="docker/bundles/latest/binary/docker"
real=$(readlink "$path")
cp "$path" "$real"

if type upx >/dev/null 2>&1; then
  [ -f "$real-upx" ] && rm "$real-upx"
  upx -9 "$real" -o "$real-upx"
fi
