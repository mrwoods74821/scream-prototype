#!/usr/bin/env bash
# Launch the Scream prototype (primary instance, game/) via Proton WITHOUT Steam.
# Resolves paths relative to this script so it works from anywhere.
#
# Requirements (verified 2026-09-24, see docs/06 + scripts/launch_instance2.sh):
#   - Goldberg steam_api.dll in game/ (it is: steam_api.dll == steam_api_gbe.dll)
#   - PhysX 2.8.1 DLLs next to the exe (shipped in game/)
#   - legacy PhysX 9.14 MSI installed into the Proton prefix
#   - steam_appid.txt = 42150 in game/
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GAME="$ROOT/game"
PROTON="$HOME/.steam/debian-installation/steamapps/compatibilitytools.d/GE-Proton11-6/proton"
COMPAT="$HOME/.steam/debian-installation/steamapps/compatdata/3378621997"

export STEAM_COMPAT_DATA_PATH="$COMPAT"
export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.steam/debian-installation"
export STEAM_COMPAT_CLIENT_PATH="$HOME/.steam/debian-installation"
export WINEPREFIX="$COMPAT/pfx"
export DISPLAY="${DISPLAY:-:0}"
export PROTON_LOG=1 SteamAppId=42150 SteamGameId=42150

cd "$GAME"
exec "$PROTON" waitforexitandrun ./scream_win32_public_dev.exe "$@"
