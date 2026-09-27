#!/usr/bin/env bash
# launch_dev.sh - LOOSE-FILE dev boot of the Scream Prototype dev exe.
#
# The dev exe (game/scream_win32_public_dev.exe) is launched from CWD=devroot with
# `-d . -o context.xml -s`. The renderer reads its shader/config layer through the
# dsl::BundleFileSystem store, which needs `bundles/` present in the loose CWD to
# reach quick.bundle/stream.bundle/game.lhd. WITHOUT that, the boot dies at
#   Archive.cpp:265  _store.get() != 0  [Archive]: null data store
# (the bundle store is null -> the Archive gets a null _store). The fix is the
# `devroot/bundles -> ../game/bundles` symlink created below.
#
# Root cause (verified 2026-09-26, 3x A/B): NOT a Steam-interface null. It is the
# bundle store. layers.xml (last successful open) references data/shaders/*.xml,
# which exist only inside quick.bundle; with no bundles/ dir in the CWD the
# BundleFileSystem store is null.
#
# Usage:
#   scripts/launch_dev.sh                 # bare wine (WINEPREFIX=$HOME/.wine-scream), 90s
#   PROTON=1 scripts/launch_dev.sh        # GE-Proton11-6 (the path that reaches the menu)
#   DURATION=120 scripts/launch_dev.sh    # override the observation window
#   SWAP_STEAMCLIENT=1 scripts/launch_dev.sh   # also point the exe at emu's experimental
#                                             #   steamclient.dll (auto-restored via trap)
#
# Output: a boot-status block (window seen? process lifetime? last crash.txt line?
# last file opened?) and a verdict:
#   WORKING      - Scream/Untitled window persisted >= MIN_PERSIST, no fresh crash
#   CRASH        - a fresh crash.txt appeared (line is printed)
#   FATAL        - a modal "Fatal ..." dialog appeared
#   NO_WINDOW    - nothing seen
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GAME="$ROOT/game"
DEVROOT="$ROOT/devroot"
EXE_NAME="scream_win32_public_dev.exe"
DUR="${DURATION:-90}"
MIN_PERSIST="${MIN_PERSIST:-15}"
PROTON="${PROTON:-0}"
RUNNER="wine"
COMPAT="$HOME/.steam/debian-installation/steamapps/compatdata/3378621997"
PROTON_BIN="$HOME/.steam/debian-installation/steamapps/compatibilitytools.d/GE-Proton11-6/proton"

export DISPLAY="${DISPLAY:-:0}"
export WINEDEBUG="${WINEDEBUG:--all,fixme}"
if [ "$PROTON" = "1" ]; then
    RUNNER="$PROTON_BIN waitforexitandrun"
    export STEAM_COMPAT_DATA_PATH="$COMPAT"
    export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.steam/debian-installation"
    export STEAM_COMPAT_CLIENT_PATH="$HOME/.steam/debian-installation"
    export WINEPREFIX="$COMPAT/pfx"
    export PROTON_LOG=1 SteamAppId=42150 SteamGameId=42150
else
    export WINEPREFIX="${WINEPREFIX:-$HOME/.wine-scream}"
fi

echo "launch_dev: runner=$RUNNER prefix=$WINEPREFIX dur=${DUR}s min_persist=${MIN_PERSIST}s"

# --- the actual fix: devroot/bundles -> game/bundles --------------------------
if [ ! -e "$DEVROOT/bundles/quick.bundle" ]; then
    ln -sfn "$GAME/bundles" "$DEVROOT/bundles"
    echo "launch_dev: created symlink devroot/bundles -> $GAME/bundles"
else
    echo "launch_dev: devroot/bundles already present"
fi

# --- re-seed the FCL index before every loose boot ----------------------------
if [ -f "$ROOT/extracted/boot_fcl/boot/compiled/win32/index.bdb" ]; then
    cp "$ROOT/extracted/boot_fcl/boot/compiled/win32/index.bdb" "$DEVROOT/compiled/win32_fcl/index.bdb"
    echo "launch_dev: re-seeded index.bdb"
fi

# --- optional: swap the depot steamclient for the emu experimental build ------
SWAPPED=""
if [ "${SWAP_STEAMCLIENT:-0}" = "1" ]; then
    cp "$GAME/steamclient.dll" /tmp/steamclient.depot.bak
    cp "$ROOT/tools/emu-win/release/steamclient_experimental/steamclient.dll" "$GAME/steamclient.dll"
    SWAPPED=1
    echo "launch_dev: swapped emu experimental steamclient.dll (backup /tmp/steamclient.depot.bak)"
fi
restore_steamclient() {
    if [ -n "$SWAPPED" ] && [ -f /tmp/steamclient.depot.bak ]; then
        cp /tmp/steamclient.depot.bak "$GAME/steamclient.dll"
        echo "launch_dev: restored original steamclient.dll"
    fi
}
trap restore_steamclient EXIT

# --- clear leaked engine processes --------------------------------------------
pkill -f "scream_win32_public_de[v]" 2>/dev/null
sleep 1

# --- run the engine in its own process group (CWD=devroot) --------------------
START=$(date +%s)
WINLOG=/tmp/launchdev_windows.$$
: > "$WINLOG"
rm -f "$GAME/crash.txt"
( cd "$DEVROOT" && exec $RUNNER "$GAME/$EXE_NAME" -d . -o context.xml -s -fl_boot \
    > /tmp/launchdev_stdout.$$ 2>&1 ) &
EPID=$!
echo "launch_dev: engine pid=$EPID"

# --- monitor: window names + process liveness ---------------------------------
(
  while :; do
    NOW=$(date +%s)
    [ $((NOW - START)) -ge "$DUR" ] && break
    ALIVE=""; kill -0 "$EPID" 2>/dev/null && ALIVE="1"
    xdotool search --name "." getwindowname %@ 2>/dev/null | sed "s/^/${NOW} ${ALIVE} /" >> "$WINLOG"
    sleep 3
  done
) &
MON=$!

# wait for the engine to exit, or the window cap
while kill -0 "$EPID" 2>/dev/null; do
    sleep 1
    [ $(( $(date +%s) - START )) -ge "$DUR" ] && break
done
RC=0
[ -n "$(kill -0 "$EPID" 2>/dev/null && echo x)" ] && RC=1
kill -- -"$EPID" 2>/dev/null; kill -9 -- -"$EPID" 2>/dev/null
sleep 1
kill "$MON" 2>/dev/null; wait "$MON" 2>/dev/null
LIFETIME=$(( $(date +%s) - START ))

# --- verdict ------------------------------------------------------------------
echo
echo "=================== BOOT STATUS ==================="
echo "runner            : $RUNNER"
echo "process lifetime  : ${LIFETIME}s (rc=$RC, 1=force-killed at cap)"
echo "crash.txt present : $([ -f "$GAME/crash.txt" ] && echo yes || echo no)"
if [ -f "$GAME/crash.txt" ]; then
    echo "crash.txt line 2: $(sed -n '2p' "$GAME/crash.txt")"
fi
LASTFILE="$(tail -1 "$GAME/_file_access_log.xml" 2>/dev/null | sed 's/.*path="\([^"]*\)".*/\1/')"
echo "last file opened  : ${LASTFILE:-<none>}"
echo "-----------------------------------------------"

FATAL=$(grep -iE "fatal|steam must|sound card|another instance" "$WINLOG" | head -3)
FIRST=$(grep -iE "scream|untitled" "$WINLOG" | head -1 | awk '{print $1}')
LAST=$(grep -iE "scream|untitled" "$WINLOG" | tail -1 | awk '{print $1}')
PERSIST=""
if [ -n "$FIRST" ] && [ -n "$LAST" ]; then
    PERSIST=$((LAST - FIRST))
    echo "window timeline   : first=${FIRST}s last=${LAST}s persisted=${PERSIST}s (min ${MIN_PERSIST}s)"
    awk '!seen[$0]++' "$WINLOG" | grep -iE "scream|untitled|fatal" | head -8
fi

echo "=================== VERDICT ====================="
if [ -n "$FATAL" ]; then
    echo "FATAL (modal dialog):"; echo "$FATAL"
    for w in $(xdotool search --name "Fatal" 2>/dev/null); do xdotool key --window "$w" Return 2>/dev/null; done
    EXIT=10
elif [ -f "$GAME/crash.txt" ]; then
    echo "CRASH (fresh crash.txt): $(sed -n '2p' "$GAME/crash.txt")"
    EXIT=11
elif [ -n "$FIRST" ] && [ -n "$PERSIST" ] && [ "$PERSIST" -ge "$MIN_PERSIST" ]; then
    echo "WORKING (window persisted ${PERSIST}s, no fatal, no fresh crash)"
    EXIT=0
elif [ -n "$FIRST" ]; then
    echo "SHORT_WINDOW (window lasted ${PERSIST}s < ${MIN_PERSIST}s)"
    EXIT=12
else
    echo "NO_WINDOW (inspect /tmp/launchdev_stdout.$$)"
    EXIT=20
fi
echo "verdict exit code: $EXIT"
echo "==================================================="
rm -f "$WINLOG"
exit "$EXIT"
