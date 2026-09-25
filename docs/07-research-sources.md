# 07 — External Research (sources & verification)

Compiled 2026-09-24 via web research subagent. VERIFIED = page fetched and read; UNVERIFIED = search snippet only.

## Engine lineage

- GRIN's Diesel engine dates to Ballistics (Nvidia/GeForce 3 collab). Overkill (ex-GRIN founders) used modified Diesel for Payday: The Heist; Payday 2/RAID on Diesel 2.0→3.0. — VERIFIED: https://en.wikipedia.org/wiki/Grin_(company)
- Fatshark (partially GRIN-owned) used Diesel for Lead and Gold. — UNVERIFIED (MobyGames/GamesIndustry.biz snippets)
- The Scream prototype: 4v1 survivors-vs-Ghostface multiplayer pitch, surfaced Aug 31 2026 in the Steam backend leak. — UNVERIFIED press snippets (Kotaku/Archyde); consistent with depot contents.

## Multiplayer model of Diesel games (the family pattern)

- Lead and Gold shipped standalone DEDICATED SERVERS (Fatshark Steam news, Jun 2010): server browser, map cycles, passwords, kick/ban by Steam ID, admin console; "dedicated exe runs without client, no steam account needed". — VERIFIED: https://steamcommunity.com/app/42120/allnews/
- Payday: The Heist / Payday 2 are P2P player-hosted: "it's a p2p game"; no host migration because host owns game state incl. RNG seed. — VERIFIED: https://steamcommunity.com/app/24240/discussions/0/3783625016031624289/ and app 218620 discussion threads (read)
- Payday 2 Lua layer (BLT/SuperBLT) exposes managers.network:session():peer() etc. — UNVERIFIED snippets: https://github.com/diesel-modding/PAYDAY2-SuperBLT-Lua/blob/master/lua/NetworkManager.lua
- Implication: the Scream prototype (Lead and Gold branch) inherits the client/listen-server + Steam-identity architecture; its own PDB confirms Steam P2P sockets compiled in.

## Diesel tooling ecosystem

- HW12Dev/DieselFormats (C++, MIT): parses legacy (Ballistics→Lead and Gold) AND modern bundle formats; includes legacy XMB→XML dumper. Most relevant external tooling. — VERIFIED README: https://github.com/HW12Dev/DieselFormats
- HW12Dev/EWS: experimental reimplementation of the "Bringer of Worlds" Diesel level editor (matches the CoreNetEWS/NetEWSServer editor-network scripts in this depot). — VERIFIED listing
- simon-wh/DieselEngineFormats (C#, 2017): Diesel file type read/write library. — VERIFIED via GitHub API
- diesel-modding org: SuperBLT (engine-level Lua hook for Payday 2, includes Lua-Lua P2P networking for mods — precedent that Diesel session layer is hookable). — UNVERIFIED snippet: https://github.com/diesel-modding
- Luffyyy/Diesel-Bundle-Modder: bundle repacking. — UNVERIFIED snippet
- perry519/pd2-x64-converter (Rust): PD2 → Diesel 3.0 asset conversion. — VERIFIED listing

## Netcode RE literature

None exists publicly for any Diesel game (no packet captures, protocol write-ups, or network-layer RE found in any search). All protocol knowledge must come from the local PDB — which is exactly what docs 02–04 do.

## Multiplayer revival precedents

- Goldberg Emu: re-implements Steamworks incl. P2P networking + lobbies for LAN/direct play; the standard community approach for dead/DRM-locked Steam games. Already active in this depot.
- Master-server emulators / LAN revival projects for 2010-era games: established pattern (not Diesel-specific research in this pass).
