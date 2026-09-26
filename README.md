# Scream Prototype — Reverse Engineering & Multiplayer Project

The 2011 Fatshark/GRIN **Scream** prototype (Dead by Daylight's ancestor, Steam depot
42151 v5, teraleak) reverse-engineered into a game-development-ready state on
Linux via Proton.

## What this is

A GRIN-era **Diesel engine** build on the Lead and Gold codebase, 32-bit Windows
(DX9, PhysX 2.8). The engine ships a complete P2P multiplayer stack (Steam
networking, unit replication, RPC, lobbies) — the work is restoring and plumbing
existing systems, not writing new netcode.

## Directory layout

| Path | What it is |
|---|---|
| `game/` | The running game. Depot contents: `scream_win32_public_dev.exe`, `bundles/`, `data/`, `context.xml`, runtime DLLs, PDBs. **This is the playable build** (Goldberg Steam API + PhysX). |
| `game2/` | Second instance for two-machine/two-process join testing: a copy of `game/` plus its own `compatdata/` Proton prefix. |
| `extracted/quick/` | Contents of `quick.bundle` (13,887 files: data, models, textures, scripts). |
| `extracted/stream/` | Contents of `stream.bundle` (646 audio: wav/ogg). |
| `extracted/boot_fcl/` | `boot.fcl` + `boot_common.fcl` (zlib patch containers) → `boot/` and `boot_common_1/` trees (menu scripts, settings). |
| `lua/` | Decompiled Lua 5.1 source: `quick/` (688) + `fcl/` (338) = 1,026 files. |
| `luc/` | GRIN→stock transformed `.luc` bytecode: `quick/` (688) + `fcl/` (338) = 1,026 files. |
| `devroot/` | Legacy loose-file boot tree (reference only; the game now runs in bundled mode). Symlinks into `extracted/`. |
| `tools/` | The reverse-engineering toolchain (see below). |
| `scripts/` | Launch and rebuild helpers. |
| `docs/` | Investigation reports 01–09 + this index. |
| `RE_REPORT.md` | The full baseline RE report (formats, asset coverage, engine map). |

## Toolchain (all in `tools/`)

- `bndl_extract.py` — BNDL v2 bundle parser/extractor (quick/stream).
- `fcl_extract.py` — FCL + LHD zlib patch-container extractor (boot.fcl).
- `luc_stock.py` — GRIN `.luc` ↔ stock Lua 5.1 bytecode transformer
  (TESTNIL/TFORCALL opcodes 38/39 → TFORLOOP/JMP).
- `unluac.jar` (+ `unluac-hw/`, `unluac-src/`, `uw/`, `luadec/`, `unluac-jmc.jar`)
  — decompilers: stock 5.1, and the source trees of their upstreams.
- `DieselFormats/` — Diesel binary format parsers (models, etc.).
- `emu-win/` (+ `emu-win.7z`) — Goldberg Steam API emulator build.
- `diesel2gltf.py` — Diesel → glTF/GLB model exporter.
- `patch_mcbn.py` — MenuControllerBindNode bytecode patch.
- `steam_gate_keepalive.py` — Goldberg gate helper for two-instance testing.

## Launching the game (playable build)

The game runs in **bundled mode** (shipped `context.xml`, no launch args) via the
Steam shortcut "SCREAM prototype" (pseudo-appid 3378621997, GE-Proton 11.6,
Goldberg Steam API, PhysX 2.8.1). Direct Proton launch without Steam:

```sh
scripts/launch.sh                 # primary instance (game/)
scripts/launch_instance2.sh       # second instance (game2/)
```

Requirements for a clean boot (verified, see `scripts/`): Goldberg `steam_api.dll`
in place, PhysX 2.8.1 DLLs next to the exe, legacy PhysX 9.14 MSI installed in the
prefix, `steam_appid.txt` = 42150.

## Rebuilding Lua after edits

The engine compiles `.luc` at boot from loose files, but the shipped build runs
bundled. To ship a modified script:

```sh
scripts/rebuild_luc.sh            # luc/ (transformed) -> decompile/inspect
# to turn an edited .lua back into a .luc the engine will load, use
# tools/unluac.jar in the reverse direction is NOT a compiler; the engine's own
# compiler is what produces .luc. See docs/06 for the full round-trip state.
```

## Documentation index

| File | Contents |
|---|---|
| `docs/README.md` | Mission + index of 01–09. |
| `docs/01-project-overview.md` | What the game is, depot facts, layout, runtime env. |
| `docs/02-engine-architecture.md` | Diesel engine map from the PDB. |
| `docs/03-networking-internals.md` | Full netcode inventory. |
| `docs/04-data-driven-netcode.md` | Unit `<network>` tags, RPC, gamemodes, husks. |
| `docs/05-p2p-multiplayer-plan.md` | Phased P2P revival plan. |
| `docs/06-toolchain-and-environment.md` | Tools, formats, Proton prefix, experiments. |
| `docs/07-research-sources.md` | Lead and Gold / Payday lineage citations. |
| `docs/08-session-flow.md` | Decompiled host/join session flow map. |
| `docs/09-phase2-test-log.md` | Phase 2: host proven, same-machine join blocked. |
| `docs/10-reorg-notes.md` | This reorganization: what moved, why, what's dangling. |

## Known gaps

- **2,422 dangling texture symlinks** in `devroot/db_fcl/texture/`. These point at
  `extracted/quick/db/texture/*` files that were never part of the `quick.bundle`
  extraction (they were dangling before the 2026-09-26 reorg, not caused by it).
  `devroot/` is a legacy loose-file boot reference, not on the active bundled
  launch path, so this does not affect the playable build.
- **`unluac-jmc.jar`** is a 0-byte artifact (failed download); the working
  decompiler is `unluac.jar`.

## Git policy

Text is tracked: `docs/`, `tools/` (scripts + small text), `scripts/`, `README.md`,
`RE_REPORT.md`, `.gitignore`. Large binaries are ignored: `game/`, `game2/`,
`extracted/`, `lua/`, `luc/`, `devroot/` (the ~6 GB of depot data and extracted
assets). The playable build is preserved on disk; git tracks the knowledge and
tooling around it.
