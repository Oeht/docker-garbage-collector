#!/bin/sh
set -eu

PRUNE_MODE="${PRUNE_MODE:-safe}"
DRY_RUN="${DRY_RUN:-false}"
AGE_DAYS="${AGE_DAYS:-0}"
KEEP_LABELS="${KEEP_LABELS:-}"

echo "[docker-garbage-collector] $(date -Iseconds) start (mode=$PRUNE_MODE, dry-run=$DRY_RUN, age_days=$AGE_DAYS)"

run() {
  if [ "$DRY_RUN" = "true" ]; then
    echo "[DRY-RUN] $*"
  else
    sh -c "$*"
  fi
}

UNTIL_FILTER=""
if [ "$AGE_DAYS" -gt 0 ] 2>/dev/null; then
  if [ -x /usr/bin/date ]; then
    # Use GNU date from coreutils (installed at /usr/bin/date)
    UNTIL_DATE=$(/usr/bin/date -u -d "$AGE_DAYS days ago" +"%Y-%m-%dT%H:%M:%SZ") || true
    if [ -n "${UNTIL_DATE:-}" ]; then
      UNTIL_FILTER="--filter until=$UNTIL_DATE"
    fi
  fi

  # Fallback: use hours if RFC3339 failed (some Docker versions accept 168h)
  if [ -z "$UNTIL_FILTER" ]; then
    HOURS=$(( AGE_DAYS * 24 ))
    UNTIL_FILTER="--filter until=${HOURS}h"
  fi
fi

LABEL_NEG_FILTERS=""
if [ -n "$KEEP_LABELS" ]; then
  IFS=',' read -r -a _kls <<EOF
$KEEP_LABELS
EOF
  for _lab in "${_kls[@]}"; do
    _trimmed=$(echo "$_lab" | xargs)
    [ -n "$_trimmed" ] && LABEL_NEG_FILTERS="$LABEL_NEG_FILTERS --filter label!=$_trimmed"
  done
fi

if [ "$PRUNE_MODE" = "safe" ]; then
  run "docker container prune -f $UNTIL_FILTER"
  run "docker image prune -af $UNTIL_FILTER $LABEL_NEG_FILTERS"
  run "docker builder prune -af $UNTIL_FILTER"
  run "docker network prune -f $UNTIL_FILTER"
else
  run "docker container prune -f $UNTIL_FILTER"
  run "docker image prune -af $UNTIL_FILTER $LABEL_NEG_FILTERS"
  run "docker network prune -f $UNTIL_FILTER"
  run "docker builder prune -af $UNTIL_FILTER"
  run "docker volume prune -f"
fi

echo "[docker-garbage-collector] $(date -Iseconds) done"
