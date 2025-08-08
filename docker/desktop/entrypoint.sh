#!/usr/bin/env bash

# Remove xrdp PID file if there is one
rm -f /var/run/xrdp/xrdp-sesman.pid

# Start xrdp sesman service
/usr/sbin/xrdp-sesman

# Run xrdp in foreground if no commands specified
if [ -z "$1" ]; then
    /usr/sbin/xrdp --nodaemon
else
    /usr/sbin/xrdp
    exec "$@"
fi
