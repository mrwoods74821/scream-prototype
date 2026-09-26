# Scream Prototype — Reverse Engineering & Dev-Enablement Report

Date: 2026-09-22. Author: D0G. Scope: `~/projects/scream-prototype/game/` (Steam depot 42151 v5, teraleak; relocated from `~/Downloads/ScreamPrototype` on 2026-09-26).

## 1. What this actually is

A **GRIN-era Diesel engine** prototype, Fatshark, ~2011, built on the **Lead and Gold** codebase.
Evidence:
- `bundles/*.bundle` are `BNDL` magic + u32 version 2 (GRIN-era, literal paths — not the hashed Payday-era format).
- Engine self-identifies: window class `Grin Engine Game`, PDB source root `c:\exe_build\scream\engine\...`.
- Ships Lead and Gold's installer/manual and shares its PhysX/D3DX9_38/OpenAL runtime stack.
- App version 1.0.21136.13457. Renderer DX9 (threaded), 32-bit PE.

Content proves it is a **Dead by Daylight ancestor**: playable-unit XML for `editor_player_ghostface`, `editor_player_survivor_1`, `editor_player_gunslinger`; models `mp_player_ghostface.diesel`, `ghostface.diesel`; effects `ghostface_vanish`, `ghostface_attack`, `stalker_mode`. Asymmetric killer-vs-survivor archetypes on the L&G codebase.

## 2. Asset/data coverage (verified)

Bundles parse 100% with the BNDL v2 grammar (`01 01 <dir>`, `02 <u64 off><u32 len>`, `01 <name>`, `03` group-end).
- `quick.bundle`: 13,887 entries. 20 "bad" entries are zero-length editor `.cok` gizmo stubs pointing at EOF — harmless, nothing lost.
- `stream.bundle`: 646 entries (643 wav + 3 ogg), all clean.
- On-disk `extracted/` tree already holds everything, incl. 5,146 PNG pre-converted from DDS.

Inventory (extracted):
- 688 `.luc` gameplay scripts (6.8 MB) — Lua 5.1 bytecode (`1B 4C 75 61 51`, ver 0x51, 4-byte sizes)
- 1,893 unit definitions (`db/unit`), 266 effects, 31 levels
- 1,871 `.diesel` binary models, 2,292 DDS + 5,146 PNG textures
- `context.xml` / `context.xmb` boot descriptor, `game.lhd` loose-file manifest, per-level stub `.fcl` lists
- `debug_orders/boot.xml` + `bundled_files.xml`: the exact file-open order of a bundled boot (a map of the boot path)

## 3. Runtime reversal status — the important part

The game **boots from loose files**. This is the dev workflow unlocked.

- Exe flags (from `scream_win32_public_dev.exe` strings): `-d <dir>` start dir, `-o <file>` context override, `-s` no-splash, `-q` quiet, `-u` unit-test, `-fl_boot/-fl_level/-fl_bundle/-fl_linear` file-logging, `-exitdetect`, `-crash`, `-wait`, `-delayedstart`.
- `context.xml` has `<compile xml="false" scripts="false" .../>`. Setting `xml="true" scripts="true"` makes the engine read loose XML and compile `.luc` at boot.
- Built a `devroot/` (symlinks to extracted `core/ data/ db/ local/ startups/ compiled/win32`, plus edited `context.xml`). Booting the dev exe against it:
  - engine runs the data compiler (writes `compile_report.xml`, `compile_version.xml`, `context.xmb`, cooking info)
  - executes the real menu script `data/lib/managers/menu/MenuControllerBindNo...`
  - crashes at `:132 bad argument #1 to 'upper' (string expected, got nil)`

That crash is **pre-existing**, not caused by the loose-data path: the bundled boot (`-d` into `game/`) crashes identically. It is a menu controller-bind/localization edge (nil string passed to `upper()`), likely a missing gamepad binding or a lookup gap. It is a script-level bug — which means we are already executing inside the game's logic layer. Fixing it is ordinary Lua debugging once `.luc` is decompiled.

## 4. Toolchain I repaired / built

- **`diesel2gltf.py`** (was broken, now fixed):
  1. `images`/`texs` lists were never initialized → every export raised `NameError`. Fixed.
  2. GLB writer was spec-violating (wrote json length into total-length field, no per-chunk lengths) → files were not valid GLB. Rewrote the writer to proper GLB 2.0 framing.
  - Result: **1,771 / 1,817 models export (97.5%)**, all 1,771 outputs pass GLB structural validation (correct magic, total length, JSON+BIN chunk headers). Ghostface player model = 53 meshes. 46 failures are the remaining unhandled `.diesel` section variants.
  - Output: `extracted/models/**/*.gltf` (GLB). Import straight into Blender.

- **BNDL v2 parser** (Python, in-session) — validated both bundles. Available to re-run if you ever need a clean re-extract.

## 5. Paths to "actual game development" (ranked)

1. **Loose-file Lua/data modding — ready now.**
   Flip the compile flags (done in `devroot/context.xml`), decompile `.luc` to source, edit, boot with `-d devroot`. The engine recompiles scripts at boot, so iteration is edit→launch. This is the fastest route to changing gameplay, units, effects, levels.
   Blocker to clear first: the `MenuControllerBindNo:132` nil-`upper()` crash so the menu fully loads. Then decompile all 688 `.luc`.

2. **`.luc` decompilation — needed for comfortable editing.**
   Bytecode is standard Lua 5.1 (`1B4C7561 51`). Use a Lua 5.1 decompiler (unluac / luadec) matched to 4-byte int/size_t/number, little-endian. 26 plain `.lua` files already ship as source examples. Verify one decompile→recompile round-trip before bulk-converting.

3. **Asset pipeline — working.**
   `.diesel` → GLB (done, 97.5%). DDS → PNG (done). WAV/OGG native. Bink `.bik` → mp4 via ffmpeg. You can rebuild/author assets in Blender and re-export.

4. **Engine-level work — heavy but feasible.**
   Two 60 MB PDBs (`scream_win32_public.pdb`, `_dev.pdb`) with full symbols + source paths. Load the exe in IDA/Ghidra with the PDB for near-source reversing. The dev exe embeds a `ConsoleServer` (socket console), `LuaRemoteDebugger`, and `wxConsole` (`HW12Dev/dslConsole` is the open-source ancestor) — enabling the console gives a live REPL into the running engine.
   There is also a compiled in-game **editor** (`core/levels/editor/editor.luc/.xmb/.diesel`, plus `data/lib/utils/dev/editor/` and `editor_*` units) — worth trying to boot an editor context.

## 6. Existing community tooling (Diesel engine)
- `Luffyyy/DieselBundleViewer`, `Luffyyy/Diesel-Bundle-Modder` — Payday-era (hashed paths); will NOT read these GRIN bundles, parse directly instead.
- `kythyria/payday2-model-tool` — the shared-ancestor `.diesel` format research `diesel2gltf.py` is based on.
- `HW12Dev/dslConsole` — open-source wxConsole for the engine's console protocol.

## 7. Recommended next actions
1. Decompile `.luc` (Lua 5.1, 4-byte sizes) and fix the menu crash to get a clean boot to gameplay.
2. Try booting the editor context (`core/levels/editor`).
3. Bring up the `ConsoleServer`/wxConsole for live debugging.
4. Extend `diesel2gltf.py` to cover the 46 failing models (rigged/animated `.diesel` variants: `SkinBones`, `QuatLinearRot`, `LinearVector3` sections already have tag names mapped).
