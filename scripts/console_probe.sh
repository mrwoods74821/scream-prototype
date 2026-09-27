#!/usr/bin/env bash
# console_probe.sh — instrumented boot to (a) find the ConsoleServer port,
# (b) measure the early-exit timing, (c) capture the boot-file log.
#
# Usage:
#   scripts/console_probe.sh            # bare-wine, no -wait, 15s poll
#   scripts/console_probe.sh -wait 30   # extra args passed through to the exe
#
# Outputs:
#   /tmp/consprobe_stdout.log   raw engine stdout+stderr
#   /tmp/consprobe_ports.log    per-second listener snapshots (delta marked)
#   devroot/_file_access_log.xml  (written by the engine via -fl_boot)
set -u
ROOT="/home/elijah/projects/scream-prototype"
EXE="$ROOT/game/scream_win32_public_dev.exe"
DEVROOT="$ROOT/devroot"
PREFIX="$HOME/.wine-scream"
DISPLAY=:0
WINEDEBUG="-all,fixme"

EXTRA_ARGS=("${@:-}")   # e.g. -wait 30

# make sure the dev tree is boot-ready (same as launch_dev.sh)
[ -e "$DEVROOT/bundles/quick.bundle" ] || ln -sfn "$ROOT/game/bundles" "$DEVROOT/bundles"
if [ -f "$ROOT/extracted/boot_fcl/boot/compiled/win32/index.bdb" ]; then
  cp "$ROOT/extracted/boot_fcl/boot/compiled/win32/index.bdb" "$DEVROOT/compiled/win32_fcl/index.bdb"
fi

pkill -f "scream_win32_public_de[v]" 2>/dev/null; sleep 1
rm -f "$ROOT/game/crash.txt"
: > "$DEVROOT/_file_access_log.xml"

ss -ltn 2>/dev/null | awk '{print $4}' | sort -u > /tmp/cp_base.txt
echo "console_probe: launching ($*) prefix=$PREFIX"

START=$(date +%s)
( cd "$DEVROOT" && exec wine "$EXE" -d . -o context.xml -s -fl_boot "${EXTRA_ARGS[@]:-}" \
    > /tmp/consprobe_stdout.log 2>&1 ) &
EPID=$!

# 1s polling: port deltas + liveness + window presence
for i in $(seq 1 40); do
  NOW=$(date +%s); T=$((NOW - START))
  [ $T -gt 40 ] && break
  ss -ltn 2>/dev/null | awk '{print $4}' | sort -u > /tmp/cp_now.txt
  NEW=$(comm -13 /tmp/cp_base.txt /tmp/cp_now.txt | tr '\n' ' ')
  ALIVE=0; kill -0 "$EPID" 2>/dev/null && ALIVE=1
  WIN=$(xdotool search --name "Scream" getwindowname %@ 2>/dev/null | head -1)
  echo "$T alive=$ALIVE win=[${WIN:-none}] new_ports=[${NEW:-}]" >> /tmp/consprobe_ports.log
  sleep 1
done

LIFETIME=$(( $(date +%s) - START ))
echo
echo "=== console_probe results ==="
echo "process lifetime: ${LIFETIME}s"
echo "crash.txt: $([ -f "$ROOT/game/crash.txt" ] && sed -n '2p' "$ROOT/game/crash.txt" || echo none)"
echo "last file opened: $(tail -1 "$DEVROOT/_file_access_log.xml" 2>/dev/null | sed 's/.*path="\([^"]*\)".*/\1/')"
echo "new ports over run: $(sort -u /tmp/consprobe_ports.log | grep -oE 'new_ports=\[[^]]*\]' | grep -v 'new_ports=\[\] ' | sort -u | tr '\n' ' ')"
echo "tail of engine stdout:"
tail -12 /tmp/consprobe_stdout.log
kill -0 "$EPID" 2>/dev/null && { kill "$EPID"; pkill -f "scream_win32_public_de[v]"; }
exit 0
