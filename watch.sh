#!/bin/bash

arg=
owner=
group=
permission=
target=
instructions=

while [ $# -gt 0 ]; do
	arg="$1"; shift
	case "$arg" in
		--owner) owner="$1"; shift ;;
		--group) group="$1"; shift ;;
		--permission) permission="$1"; shift ;;
		*) target="$arg" ;;
	esac
done

if [ -n "$target" ]; then
	if [ ! -f "$target" -a ! -d "$target" ]; then
		echo "Target $target is not a file or directory."
		return
	fi
fi

[ -z "$owner" ] && owner="$(whoami)"
[ -z "$group" ] && group="$(groups | awk '{ print $1 }')"
[ -z "$permission" ] && permission='0755'

inotifywait -mrq -e create "$target" | \
	while read path action file; do \
		chmod "$permission" "$path$file"
		chown "$owner:$group" "$path$file"
	done
