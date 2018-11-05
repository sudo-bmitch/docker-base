#!/bin/sh

if [ "$(id -u)" = "0" ]; then
  fix-perms -r -u app -g app /usr/share/nginx/html
fi

