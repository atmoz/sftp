#!/bin/bash
mkdir keys
# runs the image and copies the keys out to use
docker run -it --rm -v $(pwd):/workdir yakworks/sftp \
cp /etc/ssh/ssh_host_ed25519_key* /etc/ssh/ssh_host_rsa_key* /workdir/keys