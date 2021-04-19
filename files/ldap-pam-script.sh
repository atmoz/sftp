#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

USER_GROUP=$(id -g ${PAM_USER})
USER_HOME="$(getent passwd ${PAM_USER} | cut -d ':' -f 6)"

do_session() {
  install -d -o root -g root -m 0755 ${USER_HOME}
  install -d -o $PAM_USER -g $USER_GROUP -m 0700 ${USER_HOME}/sftp
}

case "$PAM_TYPE" in
  session)
    do_session
    ;;
  *)
    true
    ;;
esac
