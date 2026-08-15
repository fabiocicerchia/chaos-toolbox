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
# --to: the experiment must hit the named destination and nothing else. Both
# halves run against the same interface and the same gateway, so the only
# variable is whether the gateway is inside the filtered CIDR.
docker run --rm --cap-add NET_ADMIN --entrypoint bash "$IMAGE" -c '
  gw="$(ip route | awk "/^default/ {print \$3; exit}")"
  [ -n "$gw" ] || { echo "no default gateway to test against" >&2; exit 1; }
  rtt() { ping -c 3 -W 2 -q "$1" | awk -F/ "/rtt|round-trip/ {print int(\$5)}"; }

  base="$(rtt "$gw")"

  chaos delay --duration 6s --ms 300 --to "$gw/32" &
  sleep 1
  tc qdisc show dev eth0 | grep -q prio || { echo "scoped run did not build a prio tree" >&2; exit 1; }
  tc filter show dev eth0 | grep -q "flowid 1:4" || { echo "no u32 filter installed" >&2; exit 1; }
  inside="$(rtt "$gw")"
  wait
  [ "$inside" -gt $(( base + 150 )) ] || {
    echo "in-scope traffic was not delayed (base ${base}ms, scoped ${inside}ms)" >&2; exit 1; }

  # Same experiment, a CIDR the gateway is not in: it must be untouched.
  chaos delay --duration 6s --ms 300 --to 203.0.113.0/24 &
  sleep 1
  outside="$(rtt "$gw")"
  wait
  [ "$outside" -lt $(( base + 150 )) ] || {
    echo "out-of-scope traffic was delayed (base ${base}ms, got ${outside}ms)" >&2; exit 1; }

  tc qdisc show dev eth0 | grep -q "prio\|netem" && { echo "scoped rules not cleaned" >&2; exit 1; }
  echo scoped-netem-ok
'
# A malformed CIDR must be refused before anything is installed.
if docker run --rm --cap-add NET_ADMIN "$IMAGE" delay --duration 2s --to "not-a-cidr" 2>/dev/null; then
  echo "FAIL: invalid --to was accepted" >&2; exit 1
fi

# kill: the safety rails, exercised without a runtime attached. --target has no
# default and --duration is still mandatory, which are the two ways this
# experiment could take out more than intended.
if docker run --rm "$IMAGE" kill --duration 2s 2>/dev/null; then
  echo "FAIL: kill without --target was accepted" >&2; exit 1
fi
if docker run --rm "$IMAGE" kill --target web 2>/dev/null; then
  echo "FAIL: kill without --duration was accepted" >&2; exit 1
fi
docker run --rm --entrypoint bash "$IMAGE" -c '
  cat > /usr/local/bin/kubectl <<"SH"
#!/usr/bin/env bash
[[ "$1" == "get" ]] && printf "pod/web-1\n"
SH
  chmod +x /usr/local/bin/kubectl
  out="$(chaos kill --duration 2s --every 1s --mode k8s --target app=web --dry-run)"
  echo "$out" | grep -q "would kill pod/web-1" || { echo "dry-run did not resolve targets" >&2; exit 1; }
  echo "$out" | grep -q "0 kill(s)" || { echo "dry-run killed something" >&2; exit 1; }
  echo kill-ok
'
docker run --rm --entrypoint sh "$IMAGE" -c 'command -v kubectl >/dev/null && command -v docker >/dev/null' \
  || { echo "FAIL: kill mode tooling missing from the image" >&2; exit 1; }

echo PASS
