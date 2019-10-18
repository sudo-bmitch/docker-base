#!/bin/sh

if [ "$(id -u)" = "0" -a -d /usr/share/nginx/html ]; then
  fix-perms -r -u app -g app /usr/share/nginx/html
fi

