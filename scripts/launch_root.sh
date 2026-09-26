#!/bin/bash
# Scream Prototype (Fatshark, 2011) - Steam2 teraleak depot 42151 v5
#
# Launch notes (verified 2026-09-23):
# - Uses the game's ORIGINAL bundled steam_api.dll. On this launch path the old
#   flat Steam API (SteamAPI_Init era) does NOT hard-require a running Steam
#   client, so the game starts without "Steam must be running".
# - -nosteam tells the engine to skip Steam matchmaking/init entirely.
# - Uses the DEV exe: it is the one that actually stays running past boot
#   (the signed exe exits immediately under Wine).
# - Do NOT swap in a Goldberg/emu steam_api.dll: under Wine 10.0 (new-Wow64)
#   the emulator's hook crashes the process with a DbgBreakPoint on startup.
export WINEPREFIX="$HOME/.wine-scream"
export WINEDEBUG=-all
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT/game" || exit 1
exec wine scream_win32_public_dev.exe -nosteam "$@"
