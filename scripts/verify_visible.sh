#!/usr/bin/env bash
# verify_visible.sh — Scream Prototype Phase 4 visible-verification capture helper
# (built 2026-09-26). Finds the live game window by name, waits for it, and
# screenshots JUST that window to an out-file. The D0G agent then reads the
# PNG with its vision tool and reports the on-screen text verbatim.
#
#   verify_visible.sh [--name <substr>] [--wait <sec>] <out.png>
#
#   --name <substr>  case-insensitive substring to match the window name
#                    (default: "Scream Prototype")
#   --wait <sec>     max seconds to wait for the window to appear (default 20)
#
# Prints "CAPTURED <out.png>" on success, non-zero exit if the window never
# appears. The game must be running (via scripts/launch.sh, launch_root.sh, or
# scripts/launch_dev.sh).

set -uo pipefail
NAME="Scream Prototype"
WAIT=20
OUT=""
while [ $# -ge 1 ]; do
  case "$1" in
    --name) NAME="$2"; shift 2 ;;
    --wait) WAIT="$2"; shift 2 ;;
    -h|--help) sed -n '2,17p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) OUT="$1"; shift ;;
  esac
done
[ -n "$OUT" ] || { echo "usage: verify_visible.sh [--name S] [--wait N] <out.png>" >&2; exit 1; }
export DISPLAY="${DISPLAY:-:0}"

# find the window id matching the name (first match)
find_window() {
  local id
  for id in $(xdotool search --onlyvisible --name "$NAME" 2>/dev/null); do
    local nm; nm="$(xdotool getwindowname "$id" 2>/dev/null)"
    case "$(printf '%s' "$nm" | tr '[:upper:]' '[:lower:]')" in
      *"$NAME"*|*"$(printf '%s' "$NAME" | tr '[:upper:]' '[:lower:]')"*)
        echo "$id"; return 0 ;;
    esac
  done
  return 1
}

WID=""
for ((i=0; i<WAIT; i++)); do
  if WID="$(find_window)"; then break; fi
  sleep 1
done
if [ -z "$WID" ]; then
  echo "verify_visible: no window matching '$NAME' within ${WAIT}s" >&2
  exit 2
fi
echo "window: $WID ($(xdotool getwindowname "$WID"))" >&2

# give the renderer a beat to settle, then capture just this window
sleep 2
if import -window "$WID" "$OUT" 2>/dev/null; then
  echo "CAPTURED $OUT"
elif maim -i "$WID" "$OUT" 2>/dev/null; then
  echo "CAPTURED $OUT"
else
  echo "verify_visible: capture failed (import/maim) for window $WID" >&2
  exit 3
fi
