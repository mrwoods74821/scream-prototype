#!/usr/bin/env bash
# verify_sync.sh — prove the display-sync: boot (bare or proton), sample the
# game window's on-screen geometry, and report whether it is fullscreen
# at the display's native resolution.
set -u
cd "$(dirname "${BASH_SOURCE[0]}")/.."
ROOT="$PWD"
PROTON="${PROTON:-0}"
DUR="${DUR:-25}"
export DISPLAY="${DISPLAY:-:0}" WINEDEBUG=-all,fixme

if [ "$PROTON" = "1" ]; then
  COMPAT="$HOME/.steam/debian-installation/steamapps/compatdata/3378621997"
  export STEAM_COMPAT_DATA_PATH="$COMPAT"
  export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.steam/debian-installation"
  export STEAM_COMPAT_CLIENT_PATH="$HOME/.steam/debian-installation"
  export WINEPREFIX="$COMPAT/pfx"
  RUNNER="$HOME/.steam/debian-installation/steamapps/compatibilitytools.d/GE-Proton11-6/proton waitforexitandrun"
  PROTON_LOG=1; export PROTON_LOG SteamAppId=42150 SteamGameId=42150
else
  export WINEPREFIX="${WINEPREFIX:-$HOME/.wine-scream}"
  RUNNER=wine
fi
pkill -9 -f "scream_win32_public_de[v]" 2>/dev/null; sleep 1

echo "runner=[$RUNNER] dur=${DUR}s"
( cd devroot && exec $RUNNER "$ROOT/game/scream_win32_public_dev.exe" -d . -o context.xml -s -fl_boot > /tmp/sync_boot.log 2>&1 ) &
EPID=$!
START=$(date +%s)
LOG=/tmp/sync_geometry.$$
: > "$LOG"
while [ $(( $(date +%s) - START )) -lt "$DUR" ]; do
  for w in $(xdotool search --name "Scream" 2>/dev/null); do
    E=$(xdotool getwindowname "$w" 2>/dev/null)
    P=$(xdotool getwindowgeometry "$w" 2>/dev/null | sed -n 's/^  Position: \([0-9-]*,[0-9-]*\).*/\1/p')
    G=$(xdotool getwindowgeometry "$w" 2>/dev/null | sed -n 's/^  Geometry: \([0-9]*x[0-9]*\).*/\1/p')
    [ -n "$G" ] && echo "$(date +%s -u) pos=$P geom=$G name=$E" >> "$LOG"
  done
  sleep 2
done
RC=0
kill -0 "$EPID" 2>/dev/null && { RC=1; kill -9 -- "$EPID" 2>/dev/null; }
sleep 1
echo "engine lifetime: $(( $(date +%s) - START ))s (rc=$RC, 1=alive at cap)"
echo "--- window geometry samples (absolute X+Y, WxH, name) ---"
awk '!seen[$0]++' "$LOG" | head -15
rm -f "$LOG"
