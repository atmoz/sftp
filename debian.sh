#!/bin/sh

if [ $# -ne 1 ]; then
    echo "$0 version"
    echo "builds image with debian <version>, i.e. 'bullseye'"
    exit 1
fi

set -e

version=$1; shift

tmp=$(mktemp)
tag=atmoz/sftp:debian-$version

sed "s/debian:VERSION/debian:$version/" Dockerfile > $tmp
docker build -t "$tag" -f "$tmp" .
docker push "$tag"
rm -f "$tmp"
