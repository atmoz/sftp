#!/bin/bash

# run this from the root project

# docker build -t yakworks/sftp .

docker run --name sftp --rm --cap-add=SYS_ADMIN -p 30022:22 \
  -v $(pwd)/examples/users.conf:/etc/sftp/users.conf \
  -v $(pwd)/examples/sftp-data:/sftp-data \
  yakworks/sftp