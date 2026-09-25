# 01 — Project Overview

## What this game is

- "Scream" prototype: a 4v1 asymmetrical multiplayer game — survivors vs Ghostface — pitched by Fatshark (~2011) on the GRIN-era Diesel engine, built on the Lead and Gold: Gangs of the Wild West codebase. It is the direct ancestor of Dead by Daylight's design (survivors + killer archetype, hide-and-chase loop).
- Provenance: Steam depot 42151 v5, surfaced in the August 2026 Steam backend ("teraleak"). The depot contains a dev build exe WITH full debug PDBs — the single biggest RE advantage.
- External press coverage of the leak exists (Kotaku etc., see 07) but no public netcode analysis exists anywhere. Everything protocol-level must come from local RE.

## Depot facts (verified on disk 2026-09-24)

Directory: `~/Downloads/ScreamPrototype/42151_5/`

| Artifact | Notes |
|---|---|
| `scream_win32_public_dev.exe` (8.5M) | 32-bit PE, MSVC 9.0, dev build, runs under Proton |
| `scream_win32_public_dev.pdb` (60.6M) | FULL debug symbols — class/method/file names |
| `scream_win32_public.pdb` (59.4M) | Symbols for the unsigned exe |
| `scream_win32_public_unsigned[_signed].exe` | Alternate builds, same era |
| `bundles/quick.bundle` (1.1G) | BNDL v2: 13,887 files — xml 5659, dds 2292, diesel models 1871, cok 1843, luc 688, xmb 672, blb 420, level 58 |
| `bundles/stream.bundle` (366M) | 646 audio files (wav/ogg) |
| `bundles/boot.fcl` + `boot_common.fcl` (7M each) | FCL patch containers (zlib chunk streams + LHD manifests) — hold the boot/menu Lua layer |
| `bundles/*.fcl` (fort, mine, mountain, prairie, ranch, town, train, the_hill_scavenge) | Per-level patch containers (~105B each — grammar probes) |
| `bundles/game.lhd` (60K) | Loose-file manifest for the FCL layer |
| `context.xml`, `dieselx.cfg`, `game.ver` (1.0.0) | Engine config; bundled mode: `<compile xml="false" scripts="false" .../>` |
| `install/` | Lead and Gold manual, PhysX 8.05.26 installer (old, WISE), vcredist, NSI scripts |
| PhysX DLLs | NxCooking.dll (2.8.1.4 AGEIA) shipped; PhysXLoader/Core/Device added 2026-09-24 from NVIDIA 9.14 legacy MSI (see skill scream-prototype-steam-launch) |

## Steam integration state

- `steam_appid.txt` = 42150. `steam_interfaces.txt` lists the 2010-era interface versions (SteamClient009, SteamNetworking003, SteamMatchMaking008, SteamGameServer010...).
- Build defines (from PDB compiler strings): `-DPROJECT_NAME=Scream -DUSE_STEAM -DNETWORK_USE_STEAM_SOCKETS -DNETWORK_SEND_HASH -DDEV_BUILD -DNDEBUG`, Steamworks SDK 1.8, source root `C:\exe_build\scream\engine\`.
- The exe imports the full multiplayer API surface: SteamNetworking, SteamGameServerNetworking, SteamMatchmaking(+Servers), SteamGameServer, SteamFriends, plus `SendP2PPacket/ReadP2PPacket/IsP2PPacketAvailable/AcceptP2PSessionWithUser/CloseP2PSessionWithUser/GetP2PSessionState`.
- Current runtime: Goldberg emulator (`steam_api.dll` == `steam_api_gbe.dll`, md5 ac41be5a...; Valve original preserved as `steam_api.dll.valve`). Goldberg implements Steam P2P networking over LAN/UDP — this is the backbone the restoration will ride on.

## Working runtime environment (verified 2026-09-24)

- Steam non-Steam shortcut "SCREAM prototype" (pseudo-appid 3378621997), GE-Proton11-6 (also verified on Proton Experimental), prefix `~/.steam/debian-installation/steamapps/compatdata/3378621997/pfx`, legacy PhysX MSI installed in-prefix.
- Boots to menu in bundled mode with NO launch arguments. Any `-d <dir>` loose-file args currently fail (`Could not load context.xml`) because the loose dev tree does not exist — that tree must be rebuilt by the toolchain phase.
- Game crash log lands at `42151_5/crash.txt` (CWD-relative); Proton log at `~/steam-42150.log` with PROTON_LOG=1.

## Levels

Eight levels ship as per-level FCL containers: fort, mine, mountain, prairie, ranch, town, train, the_hill_scavenge. Levels are single XML scenes (`World::xml_load_scene`) — no region streaming. A level load in multiplayer is synchronized unit creation (Synchronizer), see 03.
