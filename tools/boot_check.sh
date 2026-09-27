#!/usr/bin/env bash
# boot_check.sh - objective discriminator: FATAL DIALOG vs GAME RUNNING vs CRASH.
#
# Lesson (2026-09-26): "process alive" and "window appeared once" are NOT
# proof of a working boot. Three distinct end states must be told apart:
#
#   FATAL:<lines>     - modal fatal dialog appeared ("Fatal Error" title,
#                       e.g. "Steam must be running to play this game!")
#   CRASH:<detail>    - game window appeared but the process died with a
#                       fresh crashlog entry (e.g. Archive.cpp:265 null store)
#   WORKING:<title>   - game window PERSISTED >= MIN_PERSIST seconds AND no
#                       fatal dialog AND no fresh crashlog entry
#   NO_WINDOW         - nothing seen; check stdout/crashlog
#
# Usage: tools/boot_check.sh <seconds> <log-prefix> [extra exe args...]
# Env: WINEPREFIX, RUNNER (default 'wine'), MIN_PERSIST (default 15)
# The engine runs in its own process group (setsid) and is killed on every
# verdict path, so a leaked modal can never block the next run.
set -u
DUR="${1:-100}"
PREFIX="${2:-/tmp/bootcheck}"
shift 2 2>/dev/null || true
MIN_PERSIST="${MIN_PERSIST:-15}"
START=$(date +%s)
: > "$PREFIX.windows"

# clear leaked engine processes from earlier runs
pkill -f scream_win32_public_dev 2>/dev/null
sleep 1

# fresh crashlog mtime at run start (so we can tell new entries from old)
CL="$PREFIX.crashlog_mtimes"
: > "$CL"
find "$HOME/.wine-scream/drive_c" "$HOME/.steam/debian-installation/steamapps/compatdata" \
     -iname "crashlog.txt" -o -iname "crash.txt" 2>/dev/null | while read -r f; do
  printf "%s %s\n" "$(stat -c %Y "$f" 2>/dev/null)" "$f" >> "$CL"
done

cd "$(dirname "${BASH_SOURCE[0]}")/../game" || exit 1   # exe dir: DLL search needs it
export WINEPREFIX="${WINEPREFIX:-$HOME/.wine-scream}"
export WINEDEBUG="${WINEDEBUG:--all,fixme}"
export DISPLAY="${DISPLAY:-:0}"
RUNNER="${RUNNER:-wine}"
PROBE=$(md5sum ../game/steam_api.dll | cut -d' ' -f1)
echo "boot_check: probe=$PROBE runner=$RUNNER prefix=$WINEPREFIX dur=${DUR}s min_persist=${MIN_PERSIST}s"
setsid "$RUNNER" ../game/scream_win32_public_dev.exe "$@" > "$PREFIX.stdout" 2>&1 &
EPID=$!          # pid == pgid (setsid makes it a session leader)
echo "engine pid=$EPID pgid=$EPID"

(
  while :; do
    NOW=$(date +%s)
    [ $((NOW - START)) -ge "$DUR" ] && break
    ALIVE=""; kill -0 "$EPID" 2>/dev/null && ALIVE="1"
    xdotool search --name "." getwindowname %@ 2>/dev/null | sed "s/^/${NOW} ${ALIVE} /" >> "$PREFIX.windows"
    sleep 3
  done
) &
MON=$!

# wait for the engine to exit on its own; if it outlives DUR, force-kill its
# whole process group (kills leaked modal dialogs / hung render threads).
while kill -0 "$EPID" 2>/dev/null; do
  sleep 1
  [ $(( $(date +%s) - START )) -ge "$DUR" ] && break
done
RC=0
if kill -0 "$EPID" 2>/dev/null; then
  RC=1
fi
kill -- -"$EPID" 2>/dev/null
kill -9 -- -"$EPID" 2>/dev/null
sleep 1
kill "$MON" 2>/dev/null; wait "$MON" 2>/dev/null
echo "boot_check: engine rc=$RC (1 = had to be force-killed at ${DUR}s)"

echo "=== window timeline (unique, in order) ==="
awk '!seen[$0]++' "$PREFIX.windows" | head -40
FATAL=$(grep -iE "fatal|steam must|subscrib|sound card|another instance" "$PREFIX.windows" | head -3)
# window persistence: first and last timestamp where a Scream window existed
FIRST=$(grep -i "scream" "$PREFIX.windows" | head -1 | awk '{print $1}')
LAST=$(grep -i "scream" "$PREFIX.windows" | tail -1 | awk '{print $1}')
PERSIST=""
if [ -n "$FIRST" ] && [ -n "$LAST" ]; then
  PERSIST=$((LAST - FIRST))
  echo "scream window first=${FIRST} last=${LAST} persisted=${PERSIST}s (min ${MIN_PERSIST}s)"
fi
# fresh crashlog entries?
echo "=== fresh crashlog entries since run start ($START) ==="
while read -r m f; do
  [ "$m" -gt "$START" ] && { echo "FRESH: $f ($(date -d @"$m"))"; tail -6 "$f"; }
done < "$CL"
FRESH=$(awk -v s="$START" '$1 > s {print $2}' "$CL" | head -3)

if [ -n "$FATAL" ]; then
  echo; echo "VERDICT: FATAL"
  echo "$FATAL"
  for w in $(xdotool search --name "Fatal" 2>/dev/null); do xdotool key --window "$w" Return 2>/dev/null; done
  exit 10
elif [ -n "$FRESH" ]; then
  echo; echo "VERDICT: CRASH (window appeared${PERSIST:+ for ${PERSIST}s} but a fresh crashlog entry exists)"
  exit 11
elif [ -n "$FIRST" ] && [ -n "$PERSIST" ] && [ "$PERSIST" -ge "$MIN_PERSIST" ]; then
  echo; echo "VERDICT: WORKING (game window persisted ${PERSIST}s, no fatal, no fresh crash)"
  exit 0
elif [ -n "$FIRST" ]; then
  echo; echo "VERDICT: SHORT_WINDOW (window lasted ${PERSIST}s < ${MIN_PERSIST}s; process rc=$RC)"
  exit 12
else
  echo; echo "VERDICT: NO_WINDOW (rc=$RC; inspect $PREFIX.stdout + crashlog)"
  exit 20
fi
