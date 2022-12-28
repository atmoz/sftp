#!/bin/bash
# Permit scp
case $SSH_ORIGINAL_COMMAND in
 'scp'*)
    $SSH_ORIGINAL_COMMAND
    ;;
 *)
    echo "Access Denied"
    ;;
esac