#!/bin/bash
set -eo pipefail

# Git reference
ref="${1:-HEAD}"

# Number of required signatures
required="${2:-"1"}"

# Options passed to git
git_options="${*:3}"


# GitHub Actions fix
if [ -e "/github/home/" ]; then
    cp -r /root/.gnupg /github/home/
fi

# Show imported public keys
gpg --list-keys --keyid LONG

# Check signatures
raw_gpg_status=$(
    # shellcheck disable=SC2086
    git $git_options verify-commit --raw "$ref" 2>&1
    tags="$(git tag --points-at "$ref")"

    if [ -n "$tags" ]; then
        # shellcheck disable=SC2046,SC2086
        git $git_options verify-tag --raw $tags 2>&1
    fi
)

goodsig=0
readarray -t status_line <<<"$raw_gpg_status"
#    read -r -a info <<<"$status"
for status in "${status_line[@]}"; do
    #readarray -t -d" " info <<<"$status"
    read -r -a info <<<"$status"

    case "${info[1]}" in
        "GOODSIG")
            echo "Verified signature from ${info[2]}"
            ((goodsig++)) || true
            ;;

        "NO_PUBKEY")
            echo "WARNING: Missing public key for ${info[2]}"
            ;;
    esac
done

echo "RESULT: Found $goodsig good signatures"

if [ "$goodsig" -lt "$required" ]; then
    echo "FAIL: Not enough signatures ($required was required)"
    exit 1
else
    exit 0
fi
