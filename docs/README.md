# Scream Prototype — Reverse Engineering & P2P Multiplayer Plan

Status: investigation phase (2026-09-24). All facts below verified against local evidence (PDB symbols, bundle contents, executable imports) unless labeled otherwise.

## Mission

Make the 2011 Fatshark/GRIN "Scream" prototype (Dead by Daylight's ancestor, Steam depot 42151, teraleak) development-ready, then add one feature: peer-to-peer multiplayer, so two people running this game on their own machines can join each other.

## Executive summary

**The engine already contains a complete multiplayer stack.** The build defines recovered from the PDB prove it was compiled with `-DNETWORK_USE_STEAM_SOCKETS -DNETWORK_SEND_HASH -DUSE_STEAM`: the wire protocol runs over Steam P2P sockets addressed by SteamID, with packet integrity hashes. Eight shipped `scream_*` multiplayer gamemodes (vs, tag, catch, knife, dodgeball...) exist in the data, every player archetype has a network "husk" proxy unit, and the Lua layer exposes lobbies, RPCs and connection state to scripts.

The work is therefore **restoration and plumbing**, not writing netcode:

1. Rebuild the data toolchain (bundle extractor, Lua decompiler/recompiler — formats already documented).
2. Decompile the Lua menu/session flow to find the Host/Join path and why it is dormant.
3. Establish a working Steam API context. The game currently runs under the Goldberg emulator, which implements Steam P2P networking (`SendP2PPacket` etc.) over UDP — the most promising path for friend-to-friend play without owning appid 42150/42151.
4. Wire host/join end-to-end, first on one machine (two instances), then across machines.

## Document index

| File | Contents |
|---|---|
| `01-project-overview.md` | What the game is, depot facts, directory layout, verified runtime environment |
| `02-engine-architecture.md` | Diesel engine map from the PDB: main loop, Context, World/units, Lua layer, build config |
| `03-networking-internals.md` | Complete netcode inventory: Network manager, Synchronizer, 31 packet types, RPC system, transports |
| `04-data-driven-netcode.md` | Unit XML `<network>` tags, `network.xml` RPC declarations, gamemode configs, husk system |
| `05-p2p-multiplayer-plan.md` | The phased plan: approach options, risks, milestones, test ladder |
| `06-toolchain-and-environment.md` | Tools to rebuild, formats, Proton prefix, experiment procedures |
| `07-research-sources.md` | External research (Lead and Gold / Payday lineage, Diesel tooling) with citations |

## Ground rules (from Elijah)

- No assumptions; verify against local evidence; research unknowns externally.
- Git, no backup copies, for file operations.
- The game folder is `~/Downloads/ScreamPrototype/42151_5/` (raw depot; the old devroot/extracted trees are gone).
