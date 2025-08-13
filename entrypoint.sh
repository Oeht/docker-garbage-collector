#!/bin/sh
set -eu

: "${CRON_SCHEDULE:=0 3 * * *}"
: "${TZ:=Europe/Berlin}"

echo "$CRON_SCHEDULE /usr/local/bin/cleanup.sh >> /proc/1/fd/1 2>&1" > /etc/crontabs/root
echo "[docker-garbage-collector] Cron set: '$CRON_SCHEDULE' TZ=$TZ PRUNE_MODE=${PRUNE_MODE:-safe} DRY_RUN=${DRY_RUN:-false} AGE_DAYS=${AGE_DAYS:-0} KEEP_LABELS=${KEEP_LABELS:-<none>}"

sh /usr/local/bin/cleanup.sh || true

exec crond -f -L /dev/stdout
