#!/bin/sh

# Copyright: Brandon Mitchell
# License: MIT

set -e

# default to a passing healthcheck
healthcheck_rc=0

. secret-vars

# source files ending in ".env"
for hc in /etc/healthcheck.d/*.env; do
  if [ -f "${hc}" ]; then
    echo "Sourcing: ${hc}"
    set -a && . "${hc}" && set +a
  fi
done

# run scripts ending in ".sh"
for hc in /etc/healthcheck.d/*.sh; do
  if [ -x "${hc}" ]; then
    echo "Running: ${hc}"
    "${hc}"
    if [ $? != 0 ]; then
      echo "FAILED: ${hc} (rc=$?)"
      healthcheck_rc=1
    fi
  fi
done

exit $healthcheck_rc

