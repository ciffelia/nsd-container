#!/usr/bin/env bash
set -euxo pipefail

exec /usr/local/sbin/nsd -c /var/nsd/chroot/etc/nsd/nsd.conf -N "$(nproc)"
