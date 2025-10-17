#!/usr/bin/env bash
set -euxo pipefail

exec /usr/local/sbin/nsd -N "$(nproc)"
