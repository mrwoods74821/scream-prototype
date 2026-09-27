#!/usr/bin/env bash
# wine_boot_probe.sh - instrumented bare-Wine loose boot of the Scream dev exe.
# Purpose (plan Task 3.1): name WHERE the bare-Wine path bails. It exits cleanly
# (code 0) without reaching the menu and writes zero files to the prefix, so we
# capture the last engine log lines + WINEDEBUG + the -fl_boot file-open log to
# find the bail point (archive? data dir? PhysX? config?).
#
# Usage: tools/wine_boot_probe.sh [seconds]      (default 90s cap)
#   stdout+stderr  -> /tmp/wine_boot.log
#   engine -fl_boot log (if the engine writes one) lands in devroot/ and is dumped below.
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export WINEPREFIX="$HOME/.wine-scream"
export WINEDEBUG="-all,fixme"
export DISPLAY="${DISPLAY:-:0}"
export PROTON_LOG=1 SteamAppId=42150 SteamGameId=42150
LIMIT="${1:-90}"
OUT=/tmp/wine_boot.log
: > "$OUT"

echo "probe: WINEPREFIX=$WINEPREFIX"
echo "probe: exe CWD=$ROOT/game  args: -d $ROOT/devroot -o context.xml -s -fl_boot"
echo "probe: steam_api.dll md5=$(md5sum "$ROOT/game/steam_api.dll" | cut -d' ' -f1)"
cd "$ROOT/game" || exit 1
wine ./scream_win32_public_dev.exe -d "$ROOT/devroot" -o context.xml -s -fl_boot >"$OUT" 2>&1 &
PID=$!
( sleep "$LIMIT"; kill "$PID" 2>/dev/null; kill "$PID".wine 2>/dev/null ) &
WATCHER=$!
wait "$PID" 2>/dev/null
RC=$?
kill "$WATCHER" 2>/dev/null
wait "$WATCHER" 2>/dev/null
echo "probe: engine exit code = $RC  (0 = clean early exit we are hunting)"
echo
echo "=================== /tmp/wine_boot.log (last 120 lines) ==================="
tail -120 "$OUT"
echo
echo "=================== -fl_boot / boot log files written in devroot ==================="
find "$ROOT/devroot" -newermt "-3 minutes" -type f \( -iname "*boot*" -o -iname "*.log" -o -iname "*trace*" \) 2>/dev/null | while read -r f; do
  echo "---- $f (last 40 lines) ----"; tail -40 "$f"
done
echo
echo "=================== files written to the wine-scream prefix in last 3 min ==================="
find "$WINEPREFIX" -newermt "-3 minutes" -type f 2>/dev/null | head -40
echo
echo "probe: steam_api.dll md5 after = $(md5sum "$ROOT/game/steam_api.dll" | cut -d' ' -f1)"
