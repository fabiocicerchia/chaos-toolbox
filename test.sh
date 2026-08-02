#!/usr/bin/env sh
# Smoke tests: duration rail enforced; cpu stress runs; netem applies and
# cleans up after itself (needs NET_ADMIN).
set -eu
IMAGE="${1:?usage: test.sh <image:tag>}"
if docker run --rm "$IMAGE" cpu 2>/dev/null; then
  echo "FAIL: missing --duration was accepted" >&2; exit 1
fi
docker run --rm "$IMAGE" cpu --duration 2s --workers 1 >/dev/null
docker run --rm --cap-add NET_ADMIN --entrypoint bash "$IMAGE" -c '
  chaos delay --duration 2s --ms 100 &
  sleep 1
  tc qdisc show dev eth0 | grep -q netem || { echo "netem not applied" >&2; exit 1; }
  wait
  tc qdisc show dev eth0 | grep -q netem && { echo "netem not cleaned" >&2; exit 1; }
  echo netem-ok
'
echo PASS
