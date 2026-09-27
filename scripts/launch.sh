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
# DLL contract (verified 2026-09-26, see docs/11): the Proton/Steam path REQUIRES
# the Goldberg emulator (md5 ac41be5a...). The Valve original (md5 d1953334...)
# makes the engine print "Steam must be running!" — the 2026-09-26 regression.
CUR="$(md5sum "$GAME/steam_api.dll" | cut -d' ' -f1)"
if [ "$CUR" != "ac41be5ab9ae5715b2f93897c75eb23a" ]; then
    echo "launch.sh: ERROR - game/steam_api.dll md5 is $CUR; the Proton path needs the Goldberg build (steam_api_gbe.dll). Refusing to launch." >&2
    echo "Fix: cp steam_api_gbe.dll steam_api.dll   (or use scripts/launch_root.sh for bare Wine with the Valve original)" >&2
    exit 1
fi
exec "$PROTON" waitforexitandrun ./scream_win32_public_dev.exe "$@"
