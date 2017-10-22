#!/bin/bash
set -e

# Paths
userConfPath="/etc/sftp/users.conf"
userConfPathLegacy="/etc/sftp-users.conf"
userConfFinalPath="/var/run/sftp/users.conf"

# Extended regular expression (ERE) for arguments
reUser='[A-Za-z0-9._][A-Za-z0-9._-]{0,31}' # POSIX.1-2008
rePass='[^:]{0,255}'
reUid='[[:digit:]]*'
reGid='[[:digit:]]*'
reDir='[^:]*'
reArgs="^($reUser)(:$rePass)(:e)?(:$reUid)?(:$reGid)?(:$reDir)?$"
reArgsMaybe="^[^:[:space:]]+:.*$" # Smallest indication of attempt to use argument
reArgSkip='^([[:blank:]]*#.*|[[:blank:]]*)$' # comment or empty line

function log() {
    echo "[entrypoint] $@"
}

function validateArg() {
    name="$1"
    val="$2"
    re="$3"

    if [[ "$val" =~ ^$re$ ]]; then
        return 0
    else
        log "ERROR: Invalid $name \"$val\", do not match required regex pattern: $re"
        return 1
    fi
}

function createUser() {
    log "Parsing user data: \"$@\""

    IFS=':' read -a args <<< $@
    index=0

    user="${args[0]}"; validateArg "username" "$user" "$reUser" || return 1
    pass="${args[1]}"; validateArg "password" "$pass" "$rePass" || return 1

    if [ "${args[2]}" == "e" ]; then
        chpasswdOptions="-e"
        index=1
    fi

    uid="${args[$[$index+2]]}"; validateArg "UID" "$uid" "$reUid" || return 1
    gid="${args[$[$index+3]]}"; validateArg "GID" "$gid" "$reGid" || return 1
    dir="${args[$[$index+4]]}"; validateArg "dirs" "$dir" "$reDir" || return 1

    if getent passwd $user > /dev/null; then
        log "WARNING: User \"$user\" already exists. Skipping."
        return 0
    fi

    useraddOptions="--no-user-group"

    if [ -n "$uid" ]; then
        useraddOptions="$useraddOptions --non-unique --uid $uid"
    fi

    if [ -n "$gid" ]; then
        if ! getent group $gid > /dev/null; then
            groupadd --gid $gid "group_$gid"
        fi

        useraddOptions="$useraddOptions --gid $gid"
    fi

    useradd $useraddOptions $user
    mkdir -p /home/$user
    chown root:root /home/$user
    chmod 755 /home/$user

    # Retrieving user id to use it in chown commands instead of the user name
    # to avoid problems on alpine when the user name contains a '.'
    uid="$(id -u $user)"

    if [ -n "$pass" ]; then
        echo "$user:$pass" | chpasswd $chpasswdOptions
    else
        usermod -p "*" $user # disabled password
    fi

    # Add SSH keys to authorized_keys with valid permissions
    if [ -d /home/$user/.ssh/keys ]; then
        cat /home/$user/.ssh/keys/* >> /home/$user/.ssh/authorized_keys
        chown $uid /home/$user/.ssh/authorized_keys
        chmod 600 /home/$user/.ssh/authorized_keys
    fi

    # Make sure dirs exists
    if [ -n "$dir" ]; then
        IFS=',' read -a dirArgs <<< $dir
        for dirPath in ${dirArgs[@]}; do
            dirPath="/home/$user/$dirPath"
            if [ ! -d "$dirPath" ]; then
                log "Creating directory: $dirPath"
                mkdir -p $dirPath
                chown -R $uid:users $dirPath
            else
                log "Directory already exists: $dirPath"
            fi
        done
    fi
}

# Allow running other programs, e.g. bash
if [[ -z "$1" || "$1" =~ $reArgsMaybe ]]; then
    startSshd=true
else
    startSshd=false
fi

# Backward compatibility with legacy config path
if [ ! -f "$userConfPath" -a -f "$userConfPathLegacy" ]; then
    mkdir -p "$(dirname $userConfPath)"
    ln -s "$userConfPathLegacy" "$userConfPath"
fi

# Create users only on first run
if [ ! -f "$userConfFinalPath" ]; then
    mkdir -p "$(dirname $userConfFinalPath)"

    # Append mounted config to final config
    if [ -f "$userConfPath" ]; then
        cat "$userConfPath" | grep -v -E "$reArgSkip" > "$userConfFinalPath"
    fi

    # Append users from STDIN to final config
    # DEPRECATED on 2017-10-08, DO NOT USE
    # TODO: Remove code after 6-12 months
    if [ ! -t 0 ]; then
        while IFS= read -r user || [[ -n "$user" ]]; do
            echo "$user" >> "$userConfFinalPath"
        done
    fi

    if $startSshd; then
        # Append users from arguments to final config
        for user in "$@"; do
            echo "$user" >> "$userConfFinalPath"
        done
    fi

    # Check that we have users in config
    if [[ -f "$userConfFinalPath" && "$(cat "$userConfFinalPath" | wc -l)" > 0 ]]; then
        # Import users from final conf file
        while IFS= read -r user || [[ -n "$user" ]]; do
            createUser "$user"
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
        fi
    done
    unset f
fi

if $startSshd; then
    log "Executing sshd"
    exec /usr/sbin/sshd -D -e
else
    log "Executing $@"
    exec "$@"
fi
