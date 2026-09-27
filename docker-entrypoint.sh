#!/bin/sh
set -eu

# The build user is created in the image with USER_ID/GROUP_ID build args.
# When the container is started as root (the default), drop to that user.
if [ "$(id -u)" -eq 0 ]; then
    mkdir -p /ccache
    export HOME="$(getent passwd build | cut -d: -f6)"
    exec setpriv --reuid="$(id -u build)" \
                 --regid="$(id -g build)" \
                 --init-groups \
                 "$@"
fi

exec "$@"
