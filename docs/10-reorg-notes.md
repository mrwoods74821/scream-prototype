# 10. Reorganization Notes (2026-09-26)

The project was re-rooted from `~/Downloads/ScreamPrototype/` to
`~/projects/scream-prototype/` to put all RE artifacts in one development-ready
home and to consolidate the `~/scream_re_keep/` backup superset into it.

## What moved where

| Old path | New path | Notes |
|---|---|---|
| `~/Downloads/ScreamPrototype/42151_5/` | `game/` | Playable build. Steam VDF updated to match. |
| `~/Downloads/ScreamPrototype/instance2/` | `game2/` | Second instance + own `compatdata/` prefix. |
| `~/Downloads/ScreamPrototype/extracted_quick/` | `extracted/quick/` | 13,887 files from quick.bundle. |
| `~/Downloads/ScreamPrototype/extracted_stream/` | `extracted/stream/` | 646 audio files. |
| `~/Downloads/ScreamPrototype/fcl_extracted/` | `extracted/boot_fcl/` (+ `boot/`, `boot_common_1/` trees) | boot.fcl + boot_common.fcl. |
| `~/Downloads/ScreamPrototype/lua_src/` | `lua/` | Decompiled Lua (quick/ + fcl/). |
| `~/Downloads/ScreamPrototype/luc_patched/` | `luc/` | GRIN→stock transformed bytecode. |
| `~/scream_re_keep/devroot/` | `devroot/` | Legacy loose-file boot tree (reference). |
| `~/scream_re_keep/tools/*` | `tools/` | Toolchain superset. |
| `~/scream_re_keep/scripts/*` | `scripts/` | Launch/rebuild helpers. |
| `~/scream_re_keep/RE_REPORT.md` | `RE_REPORT.md` | Baseline report. |
| `~/scream_re_keep/diesel2gltf.py` | `tools/diesel2gltf.py` | Model exporter. |
| `~/scream_re_keep/steam_gate_keepalive.py` | `tools/steam_gate_keepalive.py` | Two-instance gate. |
| `~/Downloads/ScreamPrototype/docs/` | `docs/` | Investigation reports. |

## Symlinks

`devroot/` is a forest of relative symlinks into the extracted trees. After the
move, all absolute targets were rewritten to relative (`../../...`) form so the
tree is relocatable, then normalized (`normpath`) to drop `./` artifacts.

- Total devroot links: 11,842.
- Resolve: 9,057 (db_fcl) + the rest across db/ and data/.
- **Dangling: 2,422, all in `devroot/db_fcl/texture/`.** Verified pre-existing:
  the target files are absent from `extracted/quick/db/texture/` (0 of the 2,422
  basenames exist anywhere in that tree), and only directory renames occurred
  (no file deletions), so these were dangling before the reorg. `devroot/` is
  not on the active bundled launch path, so the playable build is unaffected.

## Launch path (unchanged contract, new locations)

- Steam shortcut "SCREAM prototype" (pseudo-appid 3378621997) → `game/` exe.
- `scripts/launch.sh` (primary) and `scripts/launch_instance2.sh` (game2) for
  direct Proton launches without the Steam client.
- All scripts resolve paths from their own location; no absolute paths remain.

## Verification performed

- Direct Proton launch of `game/` boots to menu (no new crash.txt delta).
- Tools run from new locations: bndl_extract, fcl_extract, luc_stock (1026/1026),
  unluac decompile spot-check, diesel2gltf import.
