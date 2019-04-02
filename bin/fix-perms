#!/bin/sh

# Copyright: Brandon Mitchell
# License: MIT

opt_h=0
opt_r=0

while getopts 'g:hru:' option; do
  case $option in
    g) opt_g="$OPTARG";;
    h) opt_h=1;;
    r) opt_r=1;;
    u) opt_u="$OPTARG";;
  esac
done
shift $(expr $OPTIND - 1)

if [ $# -lt 1 -o "$opt_h" = "1" -o \( -z "$opt_g" -a -z "$opt_u" \) ]; then
  echo "Usage: $(basename $0) [opts] path"
  echo " -g group_name: group name to adjust gid"
  echo " -h: this help message"
  echo " -r: recursively update uid/gid on root filesystem"
  echo " -u user_name: user name to adjust uid"
  echo "Either -u or -g must be provided in addition to a path. The uid and"
  echo "gid of the path will be used to modify the uid/gid inside the"
  echo "container. e.g.: "
  echo "  $0 -g app_group -u app_user -r /path/to/vol/data"
  [ "$opt_h" = "1" ] && exit 0 || exit 1
fi

if [ "$(id -u)" != "0" ]; then
  echo "Root required for $(basename $0)"
  exit 1
fi

if [ ! -e "$1" ]; then
  echo "File or directory does not exist, skipping fix-perms: $1"
  exit 0
fi

if ! type usermod >/dev/null 2>&1 || \
   ! type groupmod >/dev/null 2>&1; then
  if type apk /dev/null 2>&1; then
    echo "Warning: installing shadow, this should be included in your image"
    apk add --no-cache shadow
  else
    echo "Commands usermod and groupmod are required."
    exit 1
  fi
fi

set -e

# update the uid
if [ -n "$opt_u" ]; then
  OLD_UID=$(getent passwd "${opt_u}" | cut -f3 -d:)
  NEW_UID=$(stat -c "%u" "$1")
  if [ "$OLD_UID" != "$NEW_UID" ]; then
    echo "Changing UID of $opt_u from $OLD_UID to $NEW_UID"
    usermod -u "$NEW_UID" -o "$opt_u"
    if [ -n "$opt_r" ]; then
      find / -xdev -user "$OLD_UID" -exec chown -h "$opt_u" {} \;
    fi
  fi
fi

# update the gid
if [ -n "$opt_g" ]; then
  OLD_GID=$(getent group "${opt_g}" | cut -f3 -d:)
  NEW_GID=$(stat -c "%g" "$1")
  if [ "$OLD_GID" != "$NEW_GID" ]; then
    echo "Changing GID of $opt_g from $OLD_GID to $NEW_GID"
    groupmod -g "$NEW_GID" -o "$opt_g"
    if [ -n "$opt_r" ]; then
      find / -xdev -group "$OLD_GID" -exec chgrp -h "$opt_g" {} \;
    fi
  fi
fi

