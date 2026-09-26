#!/usr/bin/env bash
# Launch the SECOND Scream instance (game2/) via Proton for two-process join
# testing. game2/ carries its OWN Proton prefix in game2/compatdata/, so this
# instance has a distinct Goldberg identity and binds its own ephemeral UDP
# ports. No Steam client required.
#
# Instance identity: identify which window belongs to which instance by
#   xdotool getwindowpid <win>  ->  readlink /proc/<pid>/cwd
# (both windows share the title "Scream Prototype").
#
# Reference: skills scream-prototype-multiplayer (two-instance-testing).
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GAME="$ROOT/game2"
PROTON="$HOME/.steam/debian-installation/steamapps/compatibilitytools.d/GE-Proton11-6/proton"

export STEAM_COMPAT_DATA_PATH="$GAME/compatdata"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.steam/debian-installation"
export STEAM_COMPAT_CLIENT_PATH="$HOME/.steam/debian-installation"
export WINEPREFIX="$GAME/compatdata/pfx"
export DISPLAY="${DISPLAY:-:0}"
export PROTON_LOG=1 SteamAppId=42150 SteamGameId=42150

cd "$GAME"
exec "$PROTON" waitforexitandrun ./scream_win32_public_dev.exe "$@"
