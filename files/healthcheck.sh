#!/bin/bash

# 1. Check if the sshd process is actually running
pgrep sshd > /dev/null || exit 1

# 2. Try to open a TCP connection to the SSH port locally
# -z: scan for listening daemons without sending data
# -w 2: timeout after 2 seconds
nc -z -w 2 127.0.0.1 22 || exit 1

exit 0

