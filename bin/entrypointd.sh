#!/bin/sh

# Copyright: Brandon Mitchell
# License: MIT

set -e

# strip off "/bin/sh -c" args from a string CMD
if [ $# -gt 1 ] && [ "$1" = "/bin/sh" ] && [ "$2" = "-c" ]; then
  shift 2
  eval "set -- $1"
fi

. secret-vars

# source files ending in ".env"
for ep in /etc/entrypoint.d/*.env; do
  if [ -f "${ep}" ]; then
    echo "Sourcing: ${ep}"
    set -a && . "${ep}" && set +a
  fi
done

# run scripts ending in ".sh"
for ep in /etc/entrypoint.d/*.sh; do
  if [ -x "${ep}" ]; then
    echo "Running: ${ep}"
    "${ep}"
  fi
done

# Default to the prior entrypoint if defined
if [ -n "$ORIG_ENTRYPOINT" ]; then
  set -- "$ORIG_ENTRYPOINT" "$@"
fi

# run a shell if there is no command passed
if [ $# = 0 ]; then
  if [ -x /bin/bash ]; then
    set -- /bin/bash
  else
    set -- /bin/sh
  fi
fi

# include tini if requested
if [ -n "${USE_INIT}" ]; then
  set -- tini -- "$@"
fi

# include gosu with user if requested
if [ -n "${RUN_AS}" ] && [ "$(id -u)" = "0" ]; then
  set -- gosu "${RUN_AS}" "$@"
fi

# run command with exec to pass control
echo "Running CMD: $@"
exec "$@"

