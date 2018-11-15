#!/bin/bash
set -Eeo pipefail

# shellcheck disable=2154
trap 's=$?; echo "$0: Error on line "$LINENO": $BASH_COMMAND"; exit $s' ERR

reArgsMaybe="^[^:[:space:]]+:.*$" # Smallest indication of attempt to use argument
reArgSkip='^([[:blank:]]*#.*|[[:blank:]]*)$' # comment or empty line

# Paths
userConfPath="/etc/sftp/users.conf"
userConfPathLegacy="/etc/sftp-users.conf"
userConfFinalPath="/var/run/sftp/users.conf"

function log() {
    echo "[$0] $*" >&2
}

# Allow running other programs, e.g. bash
if [[ -z "$1" || "$1" =~ $reArgsMaybe ]]; then
    startSshd=true
else
    startSshd=false
fi

# Backward compatibility with legacy config path
if [ ! -f "$userConfPath" ] && [ -f "$userConfPathLegacy" ]; then
    mkdir -p "$(dirname $userConfPath)"
    ln -s "$userConfPathLegacy" "$userConfPath"
fi

# Create users only on first run
if [ ! -f "$userConfFinalPath" ]; then
    mkdir -p "$(dirname $userConfFinalPath)"

    if [ -f "$userConfPath" ]; then
        # Append mounted config to final config
        grep -v -E "$reArgSkip" < "$userConfPath" > "$userConfFinalPath"
    fi

    if $startSshd; then
        # Append users from arguments to final config
        for user in "$@"; do
            echo "$user" >> "$userConfFinalPath"
        done
    fi

    if [ -n "$SFTP_USERS" ]; then
        # Append users from environment variable to final config
        IFS=" " read -r -a usersFromEnv <<< "$SFTP_USERS"
        for user in "${usersFromEnv[@]}"; do
            echo "$user" >> "$userConfFinalPath"
        done
    fi

    # Check that we have users in config
    if [ -f "$userConfFinalPath" ] && [ "$(wc -l < "$userConfFinalPath")" -gt 0 ]; then
        # Import users from final conf file
        while IFS= read -r user || [[ -n "$user" ]]; do
            create-sftp-user "$user"
        done < "$userConfFinalPath"
    elif $startSshd; then
        log "FATAL: No users provided!"
        exit 3
    fi

    # Generate unique ssh keys for this container, if needed
    if [ ! -f /etc/ssh/ssh_host_ed25519_key ]; then
        ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ''
    fi
    if [ ! -f /etc/ssh/ssh_host_rsa_key ]; then
        ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ''
    fi
fi

# Source custom scripts, if any
if [ -d /etc/sftp.d ]; then
    for f in /etc/sftp.d/*; do
        if [ -x "$f" ]; then
            log "Running $f ..."
            $f
        else
            log "Could not run $f, because it's missing execute permission (+x)."
        fi
    done
    unset f
fi

if $startSshd; then
    log "Executing sshd"
    exec /usr/sbin/sshd -D -e
else
    log "Executing $*"
    exec "$@"
fi
