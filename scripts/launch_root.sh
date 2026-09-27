#!/bin/bash
# Scream Prototype (Fatshark, 2011) - Steam2 teraleak depot 42151 v5
#
# Launch notes (verified 2026-09-23):
# - Uses the game's ORIGINAL bundled steam_api.dll. NOTE (2026-09-26, s4): the
#   Valve DLL's SteamAPI_Init DOES hard-require a running Steam client here —
#   it shows the "Steam must be running to play this game!" Fatal Error modal
#   (verified with the loose devroot tree). The 2026-09-23 "starts without
#   Steam must be running" observation was the pre-index-seed state, where the
#   engine aborted earlier in the datacompiler (empty index.bdb) and never
#   reached the Steam init.
# - -nosteam tells the engine to skip Steam matchmaking/init; it does NOT
#   suppress the DLL's own init gate (verified 2026-09-26).
# - Uses the DEV exe: it is the one that actually stays running past boot
#   (the signed exe exits immediately under Wine).
# - Do NOT swap in a Goldberg/emu steam_api.dll: under Wine 10.0 (new-Wow64)
#   the emulator's hook crashes the process with a DbgBreakPoint on startup.
#
# DLL contract (verified 2026-09-26, see docs/11):
#   this bare-Wine path REQUIRES the Valve original steam_api.dll (md5 d1953334...).
#   The Goldberg build (md5 ac41be5a...) is for the Proton/Steam path only.
export WINEPREFIX="$HOME/.wine-scream"
export WINEDEBUG=-all
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT/game" || exit 1
CUR="$(md5sum steam_api.dll | cut -d' ' -f1)"
if [ "$CUR" = "ac41be5ab9ae5715b2f93897c75eb23a" ]; then
    echo "launch_root: WARNING - steam_api.dll is the Goldberg build; bare-Wine needs the Valve original (steam_api.dll.valve). Restoring Valve original for this run."
    cp -f steam_api.dll.valve steam_api.dll
    trap 'cp -f steam_api.dll.valve steam_api.dll; echo "launch_root: restored Valve steam_api.dll"' EXIT
elif [ "$CUR" != "d1953334ed302b2be3c509336e5c53b3" ]; then
    echo "launch_root: ERROR - steam_api.dll md5 is $CUR (expected d1953334... Valve original). Refusing to launch." >&2
    exit 1
fi
exec wine scream_win32_public_dev.exe -nosteam "$@"
