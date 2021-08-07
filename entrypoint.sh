#!/bin/sh
set -e

if [ -f /usr/src/app/tmp/pids/server.pid ]; then
  rm -rf /usr/src/app/tmp/pids/server.pid
fi

exec bundle exec "$@"