# Scream Prototype — Development-Ready State Plan

> **Goal:** Close the loop `edit Lua source → boot → see the change in the running game`, so we can add and iterate on real, visible features.
>
> **Date:** 2026-09-26, v3 (added "3. Next up" execution sequence). Author: D0G. Status markers: `[DONE]` = verified by execution this session, `[TODO]` = work to do.

---

## 1. Definition of done

"Development ready" = all four of the following are simultaneously true:

1. **Read:** every gameplay script is readable and editable as Lua source (`lua/` tree — DONE, 1026/1026).
2. **Compile:** an edited Lua source becomes a `.luc` the running engine loads, with no per-file manual steps (scripted pipeline).
3. **Boot:** a repeatable launch command boots the game from the loose dev tree, reaches the **menu**, and stays alive.
4. **Proven:** at least one authored, visible in-game change (text/behavior) is observed in the running game from our edited source.

Until all four are true, the game is playable, and that is the extent of it.

## 2. Current state (verified 2026-09-26)

| Item | Status | Evidence |
|---|---|---|
| Bundled play build (Proton/Goldberg) | `[DONE]` boots to menu, window + ~130% CPU, no `crash.txt` | `scripts/launch.sh`, this session |
| Decompilation of all scripts | `[DONE]` 1026/1026 `.luc` → readable Lua | `lua/` tree |
| Loose db compile at boot | `[DONE]` engine writes `compile_report.xml` + 78 `.xmb` + `index.bdb` | `devroot/compile_report.xml`, 17:47 |
| Loose `.luc` scripts execute | `[DONE]` pre-existing bug in decompiled source fired at runtime | crashlog `MenuServerInformation:637 ... server_settings (a nil value)` |
| Menu-crash patch in dev tree | `[DONE]` `patch_mcbn.py` output deployed | `devroot/compiled/win32_fcl/.../MenuControllerBindNode.luc`, 0 GETTABLE at nil sites |
| GRIN → stock transform | `[DONE]` idempotent 1026/1026 | `tools/luc_stock.py` |
| **Float32 Lua 5.1 compiler** | `[TODO]` the compile-back gap (Phase 1) | all 1,364 extracted `.luc` have `snum=4`; stock `luac5.1` emits `snum=8` |
| **Loose boot to menu** | `[TODO]` **Both runners now die at the same wall: `Archive.cpp:265 null data store` (Renderer thread).** The old bare-Wine split (clean zero-write exit, or `datacompiler.cpp:656` cannot-load-database) was the *empty index* talking: the datacompiler rebuilt `index.bdb` from the 61-byte stub `index.xml` files into an 8-byte empty index → datacompiler could not load the database (bare-Wine, Goldberg DLL) / Renderer read a null data store (Proton, Goldberg DLL). Seeding the real 402KB FCL `index.bdb` (`extracted/boot_fcl/boot/compiled/win32/index.bdb`) into `devroot/compiled/win32_fcl/` **before** each loose boot makes the datacompiler keep it (byte-identical, verified) and both runners get past db load to the identical `Archive.cpp:265`. See §13 s4 appendix. | 2026-09-26 21:20–21:45, all four DLL×runner combos |
| Stock→GRIN inverse transform | `[TODO]` pure opcode math (Phase 2); only needed if the float32 compiler is emitted stock-style | engine opcode table verified in exe |
| Steam shortcut icon | `[TODO]` stale path `~/Downloads/ScreamPrototype/extracted/images/.../hud_stealth_icon.png` | `shortcuts.vdf` |

### Hard facts that constrain the design

- **`game/steam_api.dll` must be the Goldberg emulator** (md5 `ac41be5a...` == `steam_api_gbe.dll`) for any Proton/Steam launch. The Valve original (`steam_api.dll.valve`, md5 `d1953334...`) is only for bare-Wine, where Goldberg's hook crashes Wine 10 with DbgBreakPoint. Swapping without remembering which launch path uses which is how the "Steam must be running!" regression happened (this session, fixed).
- **The engine's Lua dialect is stock Lua 5.1 with float32 constants.** Every `.luc` in the depot has header `1B 4C 75 61 51 00 01 04 04` (snum=4). The dev exe's opcode table contains **both** stock `FORPREP/TFORLOOP` and GRIN `TFORCALL/TESTNIL` (verified in `scream_win32_public_dev.exe`), so the VM accepts both loop encodings; the constant width is the hard constraint.
- **Loose boot needs CWD at the tree that contains `context.xml`**, plus `-d <dir> -o context.xml -s` (`-d` paths are CWD-relative). With CWD=`devroot/` and `-d .`, the db compiler runs to completion.
- **`devroot/` loose files are real files** (the `compiled/win32_fcl/...` `.luc` files), which makes per-file swap-and-restore safe.
- **The engine has a built-in compile-from-source path:** `context.xml` `<compile xml="true" scripts="true">` makes it read loose XML **and** compile scripts at boot; the depot itself ships 26 plain `.lua` files (`extracted/quick/core/utils/tcp_monkey/...`), proving the engine loads `.lua` source. This is a viable alternative to a Python compiler (Phase 2 test).

## 3. Next up (execution sequence)

The order below is the next session's work queue. Steps 1 and 2 are independent and can run in parallel; the decision gate at step 3 picks the path forward.

**Step 1 (immediate, ~30 min): instrumented bare-Wine probe — Task 3.1**
- Run the bare-Wine loose boot with `WINEDEBUG=-all,fixme` and engine `-fl_boot` file logging; capture the last log line and the last file opened before the clean (code 0) exit.
- Deliverable: a one-line statement of the bail point (e.g. "exits after physics config, before opening its data dir").

**Step 2 (in parallel): build the float32luac compiler — Tasks 1.1 + 1.2**
- `tools/float32luac.py` with snum=4 output, GRIN-native loop emission, and the three verification fixtures (100-file golden round-trip, differential vs stock `luac5.1`, full 1,026-file corpus).
- Task 1.3 (engine acceptance) is deliberately deferred to the gate below: the previous marker experiment died in the Renderer phase before any script execution, so acceptance cannot be tested until the boot path resolves.

**Step 3 (decision gate): branch on what Step 1 found**
- **RESOLVED 2026-09-26 (s4): the exit point was the empty db index + the Steam-gate/remote-store pair, not PhysX.** Both runners converge on `Archive.cpp:265` (Goldberg's null data store); bare-Wine with the Valve DLL hits the "Steam must be running" modal. See §8.
- **Next:** pick the Phase 3 path per §8 decision (a) Goldberg non-null store patch / (b) bare-Wine Steam-gate bypass / (c) bundled-mode dev loop, then Task 3.3 `launch_dev.sh` → 1.3 acceptance → 3.4 `DOGE_MARKER.txt`.
- **Bare Wine stays unreachable after two attempts:** switch the launch path to a Goldberg-from-source build returning a non-null remote-storage data store (the Proton loose path), and re-run the acceptance gate there.

**Deferred (only after the loop is closed):** Phase 2.1 (stock→GRIN inverse, needed only if acceptance fails), Phase 2.2 (engine's own `.lua` compile probe), Phase 4.3 ergonomics, and Phase 5 (live console, editor).

**Constraint that never breaks:** the playable build stays green the entire time — `game/steam_api.dll` is Goldberg for every Proton/Steam run, and the bare-Wine launcher trap-restores the DLL swap on exit.

## 4. Target architecture

```
lua/<tree>/<path>.lua          (we edit this)
        |
        |  tools/dev_compile.py  (walks lua/ -> devroot/compiled/<platform>/<tree>/.luc)
        |    uses tools/float32luac.py (Lua 5.1 compiler, snum=4)
        v
devroot/compiled/win32_fcl/<tree>/<path>.luc     (engine reads these at boot, scripts=true)
        |
        |  scripts/launch_dev.sh  (boot from devroot, -d . -o context.xml -s; Wine/Proton path per Step 3 of "Next up")
        v
running game  ->  edit visible in-game
```

Design decisions:

- **Primary compile path = Python float32 compiler.** It reuses the only parser/writer we've proven byte-compatible with the engine's files, and it lets us emit GRIN-native loop opcodes directly (making the inverse transform a no-op) or stock opcodes (in which case Phase 2's inverse applies).
- **Fallback compile path = the engine's own `.lua` compilation** (Phase 2 test B). If the dev exe compiles a dropped-in `.lua` and runs it, the pipeline collapses to "edit `.lua`, place file, boot" — no Python compiler needed at all.
- **Primary launch path = a path that actually reaches script execution.** Bare Wine (Valve `steam_api.dll`) avoids the Goldberg null-store Renderer crash, but our 2026-09-26 run shows it **exits cleanly (code 0, ~3 min, zero files written to the prefix)** — i.e. it is not currently reaching the menu either. It is the more *promising* route only because its failure mode is a clean early exit, which is easy to instrument. Phase 3 must **first instrument that exit** (`-fl_boot` file log + `WINEDEBUG` + verify exe path/CWD/args) before investing in the PhysX prefix bootstrap; "just add PhysX" is a hypothesis to test first.
- The bundled Proton path stays exactly as-is for *playing* the game; the dev path is separate so a dev experiment can never break the playable build (single rule: `game/steam_api.dll` is always Goldberg).

---

## 5. Phase 0 — State hygiene (0.5 day)

### Task 0.1 — Lock the DLL contract

**Files:** `game/steam_api.dll`, `game/steam_api.dll.valve`, `game/steam_api_gbe.dll`, `scripts/launch_root.sh`

- Verify: `md5sum game/steam_api.dll game/steam_api_gbe.dll` are equal (`ac41be5ab9ae5715b2f93897c75eb23a`).
- Add a guard to `scripts/launch_root.sh` (the bare-Wine launcher):
  ```bash
  GBE=$(md5sum steam_api_gbe.dll | cut -d' ' -f1)
  CUR=$(md5sum steam_api.dll | cut -d' ' -f1)
  if [ "$CUR" != "$GBE" ]; then echo "note: steam_api.dll is Valve original (fine for bare Wine)"; fi
  ```
  and to `scripts/launch.sh` (Proton): fail with a clear message if `steam_api.dll != steam_api_gbe.dll`.
- Verify: `bash scripts/launch.sh` boots to window (bundled path green).

### Task 0.2 — Fix the Steam shortcut icon

**Files:** `~/.steam/debian-installation/userdata/160017001/config/shortcuts.vdf` (binary VDF — byte-precise edit; the existing re-point from the reorg is the reference for technique)

- Replace the stale icon path `.../ScreamPrototype/extracted/images/quick/db/texture/h/hud_stealth_icon.png` with a real extracted PNG, e.g. `~/projects/scream-prototype/extracted/quick/core/lib/core/utils/dev/ews/images/image_32x32.png`.
- Verify: Steam shows the shortcut with the new icon; LaunchOptions still empty.

### Task 0.3 — Dev tree preflight

- Confirm `devroot/db/index.xml` and `devroot/core/coredb/index.xml` exist (61-byte stubs; missing = silent `dsl::ErrorWithCStack` exit).
- Confirm `devroot/context.xml` has `<compile xml="true" scripts="true" .../>`.
- Reset `devroot/compile_report.xml` to a valid `</report>`-terminated file (truncated report = infinite recompile loop).
- Verify: one boot under Proton regenerates `compile_report.xml` cleanly (expected side effect: the null-store Renderer crash, which belongs to Phase 3).

---

## 6. Phase 1 — Float32 Lua 5.1 compiler (the critical path, 1–2 days)

Everything in this project's RE work hinges on the `.luc` format being fully understood; this phase adds the **write** half of that understanding.

### Task 1.1 — Float32 constants mode in `luc_stock.py`

**Files:** modify `tools/luc_stock.py`

- `Reader.f32()` exists; add a `parse_chunk(data, snum=4)` parameter so the validator accepts `snum=8` (stock files).
- `Writer` gains a `number()` that emits 8 bytes; existing `f32()` stays for GRIN output.
- `write_proto(w, p, snum)` emits each constant per `snum`.
- Verify: `luc_stock.py` parses a stock-compiled file (`luac5.1 -o x.luc some.lua`, header patched to `snum=8` accepted) and writes it back with both `snum=8` and `snum=4`; outputs re-parse with no trailing bytes.

### Task 1.2 — Pure-Python Lua 5.1 compiler (`tools/float32luac.py`)

**Files:** create `tools/float32luac.py`

- Scope: Lua 5.1 syntax as the game scripts use it — locals, upvalues, functions, `if/while/repeat/for (numeric + generic)`, string concat, table constructors, `require`, vararg. (The decompiled `lua/` tree is the corpus; any construct that appears there must be supported.)
- Output: Lua 5.1 chunk format, header `1B 4C 75 61 51 00 01 04 04 04 04 00` (snum=4), 4-byte int/size_t, little-endian, float32 constants.
- Loop emission: **GRIN-native by default** (`TFORCALL`+`TESTNIL`) to match the depot exactly; `--stock` flag emits `FORPREP`+`TFORLOOP` for Phase 2's inverse transform.
- Register allocator: the standard Lua 5.1 algorithm (peephole + register stack); it does not need to match GRIN's allocator — the VM accepts any valid register layout, and unluac's output proves it.
- Source name: keep the original path string (appears in runtime errors; the Sep-24 crashlog shows the engine reports chunk source names).
- Verification fixtures (all must pass):
  1. **Golden round-trip:** for 100 sampled originals: `orig.luc --(GRIN→stock)--> stock --(unluac)--> lua --(float32luac, GRIN loops)--> new.luc`. Assert: same instruction count, same opcode sequence (modulo the loop rewrite), same constant count, same source name, re-parseable with zero trailing bytes.
  2. **Differential:** compile the same source with (a) stock `luac5.1` and (b) `float32luac --stock`; assert identical instruction encoding after header normalization. This proves the compiler faithfully implements Lua 5.1 semantics.
  3. **Full corpus:** compile all 1,026 `lua/` files; 100% must compile and re-parse.

### Task 1.3 — Engine acceptance test

**Files:** `devroot/compiled/win32_fcl/data/lib/menu/menu_server_information/MenuServerInformationSteam.luc` (swap+restore; pattern used this session)

- Compile `lua/fcl/win32/data/lib/menu/menu_server_information/MenuServerInformationSteam.lua` with `float32luac` (GRIN loops) → swap into the loose tree → boot (any launch path that reaches script execution; if Phase 3 isn't done yet, use the Proton path and accept the Renderer crash as the end state — the assertion is that the game gets **past** script compilation, i.e. no `attempt to ...` errors from *our* file in `crashlog.txt`, and the file loads without a bytecode-version complaint).
- Restore the original after the test.
- Decision gate: if the engine rejects float32/`snum=4` files from an external compiler (e.g. it requires its own compiler's quirks), fall back to Phase 2's engine-compile path and re-scope.

---

## 7. Phase 2 — Compile pipeline + the engine's own compiler (0.5–1 day)

### Task 2.1 — Stock→GRIN inverse transform (`tools/luc_stock.py` extension)

**Files:** modify `tools/luc_stock.py`

- `inverse_proto(p)`: rewrite `FORPREP A B C` + `TFORLOOP A 0 C` into `TFORCALL A+3 B C+1` + `TESTNIL (A+3) sBx`, where `sBx` is the loop-exit `JMP`'s target re-based from the `TESTNIL` position (pure arithmetic; verified opcode table in the exe makes both forms valid).
- Round-trip property test: `inverse(transform(orig)) == orig` byte-identical for all 1,026 originals (the transform is a 2-instruction swap, so this must be exact).
- Use: only needed for `--stock` compiler output; the default GRIN-loop output makes this a no-op.

### Task 2.2 — Test the engine's own `.lua` compilation (the potential free lunch)

**Files:** `devroot/compiled/win32_fcl/data/lib/menu/menu_server_information/`

- Place a trivial `ProbeMarker.lua` (e.g. `print("DOG_MARKER_1"); io.open("PROBE_MARKER.txt","w"):write("ok")`) next to the scripts; boot; check for `PROBE_MARKER.txt` and for an auto-generated `ProbeMarker.luc` in the tree.
- If the engine compiles and runs it: the dev pipeline can optionally ship `.lua` directly (simplest possible workflow). Record which extension the compiler prefers and where it writes output.
- Restore/clean after the test.

### Task 2.3 — `tools/dev_compile.py`

**Files:** create `tools/dev_compile.py`

- Walks `lua/<platform>/<tree>/<path>.lua` → writes `devroot/compiled/<platform>_<fcl>/<tree>/<path>.luc` via `float32luac` (default GRIN loops) or `float32luac --stock` + `luc_stock.inverse`.
- Manifest mode: `dev_compile.py --changed` reads a list of edited files (git diff) and compiles only those — keeps iteration seconds-fast.
- `--all` for a full rebuild; verifies each output re-parses; reports count.
- Verify: `dev_compile.py --all` → 1,026 outputs, 1,026 re-parse; spot-check 5 against the Phase 1 fixtures.

---

## 8. Phase 3 — A launch path that reaches the menu (1–3 days)

**Status (2026-09-26, s4): the runner split is closed. Both bare-Wine and Proton loose boots now die at the same `Archive.cpp:265 null data store` (Renderer thread).** The historical divergence had two layers, both resolved:

1. **The `datacompiler.cpp:656` / "cannot load database" / clean-zero-write-exit states were all the empty `index.bdb` talking.** With the 61-byte stub `db/index.xml` + `core/coredb/index.xml`, the datacompiler rebuilt `compiled\win32\index.bdb` as an 8-byte empty index; a db built from that is unloadable. Seeding the real 402 KB FCL `index.bdb` (`extracted/boot_fcl/boot/compiled/win32/index.bdb`) into `devroot/compiled/win32_fcl/` before boot fixes this: the datacompiler rewrites it **byte-identical** (verified by size after run) and the database loads.
2. **The remaining bare-Wine gap is the Steam gate, not Wine itself.** With the **Valve-original** `steam_api.dll` (md5 `d1953334…`), bare-Wine `~/.wine-scream` reaches a **persistent "Fatal Error" modal: "Steam must be running to play this game!"** (screenshot `/tmp/fatal.png`, window persisting >60s at ~1% CPU). With the **Goldberg** DLL (md5 `ac41be5a…`) under bare-Wine, no modal appears and the run dies at `Archive.cpp:265` — the same crash the Proton/Goldberg loose path dies at. So `Archive.cpp:265` is **not** a Wine-vs-Proton divergence: it is the **Goldberg emulator returning a null data store** (the renderer's `dsl::Archive` `_store.get() == 0`), which happens identically on Proton and on bare-Wine. Live Steam (bundled `game/` launch) returns a non-null store and boots to the menu — the bundled path is green for exactly this reason.

**Decision for the loose dev path (next session):** pick one of
- **(a) Patch Goldberg** (`tools/emu-win/` source) so its `ISteamRemoteStorage` (or whichever store the renderer's `Archive` wraps) returns a non-null implementation. This is the only path that gives a *live* Steam-less loose boot on **both** runners. The bundled-mode proof (green boot, same exe, same engine, only the DLL's Steam init differs) is the evidence that a non-null store is sufficient.
- **(b) Bare-Wine + fake "Steam running"** — satisfy the Valve DLL's gate with a stub `steamclient.dll` (or `steamapps` registry / a fake `steam` process) so `SteamAPI_Init()` returns true, then see if the Valve DLL's *own* remote-storage store is non-null enough for the renderer. Cheaper if it works, but the Valve DLL under bare Wine has a separate known failure (DbgBreakPoint in its hooks — the original reason Goldberg was chosen).
- **(c) Accept bundled mode for `p4` verification** (the bundled boot is already green) and do the *edit → compile → boot* dev-loop against the bundled tree by overwriting files inside `quick.bundle`/`game.lhd` or via the `-d` override, if a true loose boot stays blocked.

Task 3.1 (instrument the bare-Wine exit) is **DONE** — the exit point is named (above). Task 3.2 becomes "make the store non-null on the chosen path".

### Task 3.1 — Instrument the bare-Wine early exit (do this first, before any prefix work)

**Files:** `scripts/launch_root.sh` (extend), fresh probe run into `~/.wine-scream`

- Re-run the bare-Wine loose boot with diagnostics on: `WINEDEBUG=-all,fixme`, engine `-fl_boot` (boot file-open log) + `-fl_linear`, and confirm exe path, CWD=`devroot/`, and args (`-d . -o context.xml -s`).
- Record the **last file it opens and the last log line** before the clean exit. That single line tells us which subsystem it bails in (early archive? a silent `steam_api`/registry probe? a DLL load the Proton prefix satisfies that the fresh wine prefix lacks?).
- Verify: we can name the exit point (e.g. "dies after opening `data/settings/physics_settings.xml`, before `renderer_settings.xml`") instead of guessing.

### Task 3.2 — Close the specific gap the instrument reveals

- If the exit point is **PhysX** (bails at/after physics config): bootstrap `~/.wine-scream` from the known-good Proton prefix — `cp -a .../compatdata/3378621997/pfx/drive_c ~/.wine-scream/drive_c` (brings PhysX 2.7.3–2.8.3 engine dirs, PhysXLoader.dll, registry state, game AppData), merge `user.reg`/`system.reg`/`userdef.reg`, run `game2/install/PhysX_8.05.26_SystemSoftware.exe /i` (or extract its 9.14 MSI) to add the legacy runtime, and clear `.../AppData/Local/scream/{data,saves,crashlog.txt,crash.txt}`. Verify: past `physics.cpp:273`.
- If the exit point is **not** PhysX: fix that specific gap (the instrument names it). Do not bulk-copy the Proton prefix on faith.

### Task 3.3 — `scripts/launch_dev.sh` (the dev boot command)

**Files:** create `scripts/launch_dev.sh`

- Sets: `WINEPREFIX=~/.wine-scream`, `DISPLAY=:0`, `WINEDEBUG=-all`; CWD = `devroot/`; swaps `game/steam_api.dll` → Valve original for the run (and **restores it on exit** via trap — the DLL swap is the single most regression-prone step in this project).
- Runs: `wine <abs path to game/scream_win32_public_dev.exe> -d . -o context.xml -s`.
- Prints a boot-status block on exit: window seen? process lifetime? last crashlog line? (this turns "did it work?" from a 45-second eyeball check into a one-line answer.)
- Verify: boot reaches the **"Scream Prototype" menu window** (xdotool `search --name Scream` returns a window; process alive > 60s; no new `crashlog.txt` entry).

### Task 3.4 — First end-to-end marker (the loop, closed)

- `echo 'io.open("DOGE_MARKER.txt","w"):write("LIVES")'` prepended to a copy of `lua/fcl/win32/data/lib/managers/menu/MenuTitleScreenNode.lua` → `float32luac` → `dev_compile.py --changed` → `launch_dev.sh` → boot.
- **Success = `devroot/DOGE_MARKER.txt` exists.** That single file is the proof: our edited source, compiled by our tool, executed by the running engine.
- Restore the original file; delete the marker.

---

## 9. Phase 4 — First visible in-game features (the payoff, 1–2 days)

Each item below must be *seen in the running game* (window observed via xdotool; screenshot if needed) before it counts.

### Task 4.1 — Visible text change (menu layer)

- Edit the press-`Enter` prompt in `lua/fcl/win32/data/lib/managers/menu/MenuTitleScreenNode.lua` (the `managers.localizer:text("lag_press_enter")` call site — replace with a literal like `"PRESS ENTER — D0G WAS HERE"`, or better, add a new entry to the localized strings XMB and reference it).
- Pipeline: `dev_compile.py --changed` → `launch_dev.sh` → observe the title screen.
- Restore (or keep, if Elijah wants the easter egg).
- **STAGED (2026-09-26):** edited the WIN32 branch to the literal `text = "PRESS ENTER  -  D0G WAS HERE"` (pure-Lua; no xmb surgery, so it compiles through `float32luac` with no string-table rebuild). Compiled + deployed to `devroot/compiled/win32_fcl/data/lib/managers/menu/MenuTitleScreenNode.luc` with `--srcname 'data\lib\managers\menu\MenuTitleScreenNode.lua'`. **Verified:** the output's header + srcname block is byte-identical to the depot original (`data\lib\...\MenuTitleScreenNode.lua`, 47-byte block); the constant table now carries `PRESS ENTER  -  D0G WAS HERE` and `lag_press_enter` is gone; `snum=4`, 9859 bytes. Live confirmation is blocked on the loose-boot launch path (s5) — the `.luc` is in place and will be seen on the first green loose boot.

### Task 4.2 — Gameplay behavior change

- Pick one small, safe, observable gameplay rule — e.g. a HUD/debug text element toggled by a new keybinding in `data/settings/default_controls`, or a modifier in one of the `scream_*` gamemodes' unit behavior (the 8 MP gamemodes + 84 unit XMLs are all data-driven and editable).
- Same pipeline; the change must be visible during a round, in the gameplay itself.

### Task 4.3 — Iteration ergonomics

- `scripts/dev_edit.sh <file>` — opens the decompiled source for a path, and on save runs the compile+boot pipeline automatically (edit → boot in one keystroke).
- Keep `game/` untouched by all of this; the dev tree is the only thing that mutates.

## 10. Phase 5 — Stretch: live debug + editor (optional, after the loop is proven)

- **ConsoleServer / wxConsole:** the dev exe embeds a socket console and Lua remote debugger (RE_REPORT §5.4; `HW12Dev/dslConsole` is the open-source client). A live REPL into the running engine beats restart-per-iteration for gameplay debugging. Task: find the console enable flag/port in the dev exe strings + `steam_settings`, wire a client, verify an `Application:debug`-style command runs live.
- **Editor context:** boot with `editor="true"` in `devroot/context.xml` (`core/levels/editor` + `data/lib/utils/dev/editor/` are in the depot). If it comes up, level/unit editing becomes visual.
- **PDB/IDA deep end:** only if a feature requires engine-level changes (new opcode, new C++ hook). The two 60 MB PDBs make that tractable but it's the last resort.

## 11. Risks and mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Engine rejects externally-compiled float32 `.luc` (needs its own compiler's quirks) | Medium | Phase 1.3 test catches it before we build the pipeline; fallback = Phase 2.2 engine-compile path |
| Loose dev boot dies at Goldberg's null data store (`Archive.cpp:265`) on every runner (confirmed 2026-09-26, s4) | High (confirmed) | §8 path (a): patch Goldberg for a non-null store; path (b) Valve-DLL Steam-gate bypass; path (c) bundled-mode dev loop |
| Float32 precision changes gameplay constants (float64→float32 rounding vs originals) | Low | The originals ARE float32; we round to the same width. Differential test (Task 1.2.2) bounds the error |
| The DLL swap regresses again | High (already happened once) | `launch_dev.sh` trap-restores it; `launch.sh` refuses to run with the wrong DLL; Phase 0.1 makes the contract explicit |
| unluac round-trips lose information (source names, some constant kinds) | Low | Fixtures assert source name + constant count; any mismatch is a named, fixable bug |

## 12. Open questions (research needed during execution)

1. What archive does the Renderer open that Goldberg stores as null? (Only needed if we ever want the Proton loose path; findable via `-fl_boot` file logging — the dev flag exists for this. `-fl_boot` after the s4 matrix shows the last opens are `core\settings\layers.xml` / `data\settings\renderer_settings.xml` — the store is likely the bundle/LHD-backed archive behind `index.bdb`, not a loose file.)
2. Does the engine's own `.lua` compiler write output back into the loose tree, and does it honor `snum=4`? (Task 2.2 answers it empirically.)
3. **RESOLVED (s4):** the bare-Wine "clean zero-write exit" was the empty db index aborting the datacompiler (now `datacompiler.cpp:656` in Goldberg-DLL runs; `database.cpp:720` in the pre-FCL-overlay state). With the FCL index seeded, the Valve DLL's first real complaint is the "Steam must be running" modal. Open sub-question: does the Valve DLL's remote-storage implementation work under bare Wine once that gate is bypassed?
4. Which `scream_*` gamemode is the best first feature target for a visible gameplay change? (Pick during Task 4.2 based on which unit XMLs are simplest.)

## 13. Session evidence appendix (2026-09-26)

- Bundled boot: window `115343363`, 131% CPU, no `crash.txt` (after Goldberg restore, 18:5x).
- Loose boot (Proton, CWD=devroot, `-d . -o context.xml -s`): `compile_report.xml` 327B, 78 `.xmb` + `index.bdb` written under `compiled/win32_fcl/`; death at `Archive.cpp:265 _store.get() != 0 [Archive]: null data store`, Renderer thread, crashlog entries 18:47/18:52/18:53/18:54.
- Loose boot (bare Wine, `~/.wine-scream`, Valve DLL): ran ~3 min at ~0.9–1.6% CPU, **exited cleanly (code 0), no window, zero files written to the prefix** (no `scream` AppData dir, no crashlog, no `renderer_settings.xml`; prefix user is `elijah`). A clean zero-write exit means it bailed before opening its data dir — the PhysX-missing hypothesis is unconfirmed; Phase 3.1 instruments the exit point.
- `luac5.1` output header: `1B 4C 75 61 51 00 01 04 08` (snum=8); depot `.luc` headers: all `snum=4` (1,364/1,364).
- Engine opcode table (from `scream_win32_public_dev.exe`, at file offset ~7,652,816): `... FORPREP, FORLOOP, TFORLOOP, ... TFORCALL, TESTNIL, VARARG ...` — both loop encodings present in the VM.
- Marker experiment (stock-compiled, snum=8, Proton path): marker file not written; boot died in the Renderer phase before script execution — inconclusive about loader acceptance, which is why Phase 1.3/3.4 re-test on a path that reaches scripts.
- Pre-existing script execution proof: crashlog 09-24 `MenuServerInformation:637 attempt to index local 'server_settings' (a nil value)` — line 637 region of `lua/fcl/win32/data/lib/menu/menu_server_information/MenuServerInformationSteam.lua` is real decompiled source.

### s4 appendix — the 2026-09-26 21:20–21:45 four-combo matrix (bare-Wine gate, closed)

Dev tree at the time: `devroot/compiled/win32_fcl/` = quick-compiled tree (3624 files) + FCL-compiled overlay (424) + FCL raw `core/db/data` overlay (4478 files); `compiled/win32 -> win32_fcl` symlink; `db -> db_fcl` (quick db + FCL db, 9423 files); `context.xml` `<compile xml="true" scripts="true">`; FCL `index.bdb` (402270 B) seeded into `win32_fcl/` before each run.

| # | runner | steam_api.dll | result |
|---|--------|---------------|--------|
| 1 | Proton | Goldberg `ac41be5a` | `Archive.cpp:265` null data store, Renderer thread. `-fl_boot` opens: `compiled\win32\data\settings\version.xmb`, `db\info.xml`, `compiled\win32\index.bdb`, `core\coredb\settings\texture_channels.xml`, `db\settings\l\light_intensities.xml`, `data\settings\renderer_settings.xml`, `core\settings\layers.xml`. No bundle/lhd open. |
| 2 | bare Wine `~/.wine-scream` | Goldberg `ac41be5a` | identical `Archive.cpp:265` — the old clean-zero-write exit is gone once the index is seeded |
| 3 | bare Wine `~/.wine-scream` | Valve `d1953334` | **persistent modal: "Fatal Error" / "Steam must be running to play this game!" / OK** (291×150 window, alive >60s @ ~1% CPU, no crash.txt). Screenshot `/tmp/fatal.png`. |
| 3b | bare Wine `~/.wine-scream` | Valve `d1953334` + `-nosteam` arg (longstanding `launch_root.sh` flag) | same "Fatal Error" modal today (21:4x). So `-nosteam` (engine-side skip of matchmaking/init) does **not** suppress the Valve DLL's `SteamAPI_Init` "Steam must be running" gate; `strings` shows no `-nosteam` literal in the exe, so if it is parsed at all it is parsed as an argument string at runtime. Path (b) must stub the client side (`steamclient.dll` / fake `steam` process / registry), not pass a flag |
| 4 | (history, pre-seed) | any | `datacompiler.cpp:656` cannot-load-database (bare-Wine) / `database.cpp:720` load_node (Proton, missing `texture_channels.xml` until the FCL raw core overlay was added) — all fixed by the FCL index.bdb seed + FCL raw file overlays |

Conclusions: (1) the datacompiler's 656/720 failures were the empty-index state, now closed; (2) `Archive.cpp:265` is runner-independent and DLL-dependent: it is the Goldberg emulator's null store, so **any** loose dev boot on the current DLL contract dies there; (3) the Valve DLL's only remaining complaint is the Steam-running gate — its remote-storage behavior past that gate is untested (next experiment under (b)); (4) bundled mode (live Steam, `game/`) is the only green boot and proves a non-null store is sufficient. DLL contract restored to Goldberg after each run (trap-verified, md5 `ac41be5a` standing).
