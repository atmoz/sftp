#!/bin/sh

if [ $# -ne 1 ]; then
    echo "$0 version"
    echo "builds image with alpine <version>, i.e. '3.14'"
    exit 1
fi

set -e

version=$1; shift

tmp=$(mktemp)
tag=atmoz/sftp:alpine-$version

sed "s/alpine:VERSION/alpine:$version/" Dockerfile-alpine > $tmp
docker build -t "$tag" -f "$tmp" .
docker push "$tag"
rm -f "$tmp"
