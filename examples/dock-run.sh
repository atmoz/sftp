#!/bin/bash

# run this from the root project

# docker build -t yakworks/sftp .
docker stop sftp || true && docker rm sftp || true

docker run --name sftp --cap-add=SYS_ADMIN \
  -p 30022:22 \
  -e DATA_MOUNT_NAME=ninebox \
  -v $(pwd)/examples/users.conf:/etc/sftp/users.conf \
  -v $(pwd)/examples/sftp-data:/data \
  -d yakworks/sftp