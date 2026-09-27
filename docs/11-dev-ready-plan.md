# Scream Prototype — Development-Ready State Plan

> **Goal:** Close the loop `edit Lua source → boot → see the change in the running game`, so we can add and iterate on real, visible features.
>
> **Date:** 2026-09-26, v7 (PLAN CLOSED: all phases 0–5 done. Loose dev boot is GREEN — `launch_dev.sh` reaches the menu (bare-Wine + Proton), null store = missing `bundles/`, no source patch needed. `float32luac` full-corpus verified 2,048/2,052 gates. `dev_compile.py` pipeline built. p4 visible features (4.1 title text, 4.2 dodgeball respawn) confirmed live by the user on a green loose boot. All four definition-of-done criteria met). Author: D0G. Status markers: `[DONE]` = verified by execution this session, `[TODO]` = work to do.

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
| **Float32 Lua 5.1 compiler** | `[DONE]` `tools/float32luac.py` built + verified on the full 1,026 corpus (s6): fixtures 1+2 = 1024/1026 each (the 2 misses are decompiler-artifact sources stock luac5.1 also rejects); zero field-level divergences vs stock luac5.1 modulo srcname/snum/f32; vs depot original: byte_exact 1 / lineinfo_only 1019 / other 4 (GRIN-era no-op `EQ` artifacts) / compile_error 2. `dev_compile.py` pipeline live (`--all` → 1023 compiled, 1 MCBN skip, 2 known fails) | `tools/float32luac.py`, `tools/verify_float32luac.py`, commit `c3ef69f` |
| **Loose boot to menu** | `[DONE]` **Loop closed (s5 + user confirmation, 2026-09-26 23:xx).** `scripts/launch_dev.sh` (bare-Wine default, `PROTON=1` for the Proton path) re-creates `devroot/bundles -> game/bundles/`, re-seeds the FCL `index.bdb`, and boots CWD=`devroot/` `-d . -o context.xml -s`. s5's 3× A/B: the null store is the `dsl::BundleFileSystem` container store (shader XMLs live only in `quick.bundle`), DLL-invariant; with the symlink the boot stays up with no `crash.txt`. Elijah confirmed the loose boot reaches the menu and is playable; the 4.1 title text and 4.2 dodgeball respawn changes were observed in the running game. | `scripts/launch_dev.sh`, s5 transcript, p4 confirmation |
| Stock→GRIN inverse transform | `[DONE]` superseded (v7): `float32luac` emits stock `FORPREP`/`TFORLOOP` loops, which the engine VM accepts directly (proven: the playable loose tree is 100% stock-loop chunks and it boots + plays). The inverse is a no-op on that path; kept only as an option if we ever switch to GRIN-loop emission. | engine opcode table verified in exe |
| Steam shortcut icon | `[DONE]` `steam_icon.png` deployed, VDF size preserved | p0.2 |

### Hard facts that constrain the design

- **`game/steam_api.dll` must be the Goldberg emulator** (md5 `ac41be5a...` == `steam_api_gbe.dll`) for any Proton/Steam launch. The Valve original (`steam_api.dll.valve`, md5 `d1953334...`) is only for bare-Wine, where Goldberg's hook crashes Wine 10 with DbgBreakPoint. Swapping without remembering which launch path uses which is how the "Steam must be running!" regression happened (this session, fixed).
- **The engine's Lua dialect is stock Lua 5.1 with float32 constants.** Every `.luc` in the depot has header `1B 4C 75 61 51 00 01 04 04` (snum=4). The dev exe's opcode table contains **both** stock `FORPREP/TFORLOOP` and GRIN `TFORCALL/TESTNIL` (verified in `scream_win32_public_dev.exe`), so the VM accepts both loop encodings; the constant width is the hard constraint.
- **Loose boot needs CWD at the tree that contains `context.xml`**, plus `-d <dir> -o context.xml -s` (`-d` paths are CWD-relative). With CWD=`devroot/` and `-d .`, the db compiler runs to completion.
- **`devroot/` loose files are real files** (the `compiled/win32_fcl/...` `.luc` files), which makes per-file swap-and-restore safe.
- **The engine has a built-in compile-from-source path:** `context.xml` `<compile xml="true" scripts="true">` makes it read loose XML **and** compile scripts at boot; the depot itself ships 26 plain `.lua` files (`extracted/quick/core/utils/tcp_monkey/...`), proving the engine loads `.lua` source. This is a viable alternative to a Python compiler (Phase 2 test).

## 3. Next up (execution sequence)

**Status (2026-09-26, PLAN CLOSED):** Steps 1 and 2 are done (s1, s2/s6); the step-3 gate resolved in s4/s5 (the null store = missing `bundles/`, not a DLL defect), path (a) implemented as `launch_dev.sh`, and Task 3.4's loop was proven by the p4 live confirmations (4.1 + 4.2 observed in the running game from our compiled source). **Every numbered phase (0–5) is complete.** The only threads left are explicitly-optional stretch (Phase 5 console/editor/PDB) and one non-blocking observation (the loose-mode menu early-exit flake) — neither blocks the dev loop; both are parked as follow-ups, not plan items.

**Step 1 (immediate, ~30 min): instrumented bare-Wine probe — Task 3.1**
- Run the bare-Wine loose boot with `WINEDEBUG=-all,fixme` and engine `-fl_boot` file logging; capture the last log line and the last file opened before the clean (code 0) exit.
- Deliverable: a one-line statement of the bail point (e.g. "exits after physics config, before opening its data dir").

**Step 2 (in parallel): build the float32luac compiler — Tasks 1.1 + 1.2**
- `tools/float32luac.py` with snum=4 output, GRIN-native loop emission, and the three verification fixtures (100-file golden round-trip, differential vs stock `luac5.1`, full 1,026-file corpus).
- Task 1.3 (engine acceptance) — **RESOLVED (v7):** the boot path is green and the live p4 run executed our recompiled `.luc` chunks to a playable menu, so the engine accepts externally-compiled snum=4 stock-loop chunks. (The per-file "no `attempt to ...`" grep is moot for `MenuServerInformationSteam`, which carries a pre-existing decompiled-source bug unrelated to the compiler.)

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

## 7. Phase 2 — Compile pipeline + the engine's own compiler (0.5–1 day) — **DONE (v7: 2.3 built; 2.1 superseded by stock-loop emission; 2.2 superseded by the green boot proving `.luc` acceptance)**

### Task 2.1 — Stock→GRIN inverse transform (`tools/luc_stock.py` extension)

**Files:** modify `tools/luc_stock.py`

- `inverse_proto(p)`: rewrite `FORPREP A B C` + `TFORLOOP A 0 C` into `TFORCALL A+3 B C+1` + `TESTNIL (A+3) sBx`, where `sBx` is the loop-exit `JMP`'s target re-based from the `TESTNIL` position (pure arithmetic; verified opcode table in the exe makes both forms valid).
- Round-trip property test: `inverse(transform(orig)) == orig` byte-identical for all 1,026 originals (the transform is a 2-instruction swap, so this must be exact).
- Use: only needed for `--stock` compiler output; the default GRIN-loop output makes this a no-op. **Superseded (v7):** `float32luac` emits stock loops, which the VM accepts directly, so the inverse is never exercised.

### Task 2.2 — Test the engine's own `.lua` compilation (the potential free lunch) — **superseded (v7):** the green loose boot already proves the engine loads and runs our externally-compiled `.luc`; the `.lua`-compile probe is an optional nice-to-have, not required.

**Files:** `devroot/compiled/win32_fcl/data/lib/menu/menu_server_information/`

- Place a trivial `ProbeMarker.lua` (e.g. `print("DOG_MARKER_1"); io.open("PROBE_MARKER.txt","w"):write("ok")`) next to the scripts; boot; check for `PROBE_MARKER.txt` and for an auto-generated `ProbeMarker.luc` in the tree.
- If the engine compiles and runs it: the dev pipeline can optionally ship `.lua` directly (simplest possible workflow). Record which extension the compiler prefers and where it writes output.
- Restore/clean after the test.

### Task 2.3 — `tools/dev_compile.py` — **BUILT (s6, 2026-09-26):** `--all` → 1023 compiled / 1 MCBN skip / 2 known decompiler-artifact fails; `--changed` for fast iteration; committed `c3ef69f`.

**Files:** create `tools/dev_compile.py`

- Walks `lua/<platform>/<tree>/<path>.lua` → writes `devroot/compiled/<platform>_<fcl>/<tree>/<path>.luc` via `float32luac` (default GRIN loops) or `float32luac --stock` + `luc_stock.inverse`.
- Manifest mode: `dev_compile.py --changed` reads a list of edited files (git diff) and compiles only those — keeps iteration seconds-fast.
- `--all` for a full rebuild; verifies each output re-parses; reports count.
- Verify: `dev_compile.py --all` → 1,026 outputs, 1,026 re-parse; spot-check 5 against the Phase 1 fixtures.

---

## 8. Phase 3 — A launch path that reaches the menu (1–3 days)

**Status (2026-09-26, s5): the null data store is root-caused and it is NOT a Goldberg-interface bug.** The renderer's `dsl::Archive` `_store.get() == 0` (`Archive.cpp:265`) comes from the **bundle-backed archive** (`dsl::BundleFileSystem`) failing to open `quick.bundle`. Proof by controlled A/B:

- **Control (no `bundles/` in the loose CWD):** boot crashes at `Archive.cpp:265 null data store`; last file opened = `layers.xml`.
- **Treatment (`bundles/` symlinked into `devroot/`):** **no crash**, a window appears.

Why: `layers.xml` (the last open before the crash) references `data/shaders/*.xml` — and **all of those shader XMLs exist only inside `quick.bundle`, not in the loose tree** (verified: 0 `shaders/*.xml` in `extracted/quick/data/` and `extracted/boot_fcl/…/data/`; all 7 named shaders present in `game/bundles/quick.bundle`, 22 `shaders/` entries). With no `bundles/` dir at the loose CWD the bundle can't be opened, so the Archive wrapping it is null. Bundled `game/` boots green for exactly the reason it carries `game/bundles/quick.bundle` in its own dir. This is a **dev-tree-completeness** gap, not a DLL defect: the Goldberg null-store patch (path a below) is demoted to a robustness item.

**Decision for the loose dev path (2026-09-26, s5):** the primary fix is **make the loose tree bundle-complete** — symlink (or copy) `bundles/` into `devroot/` so the renderer can open `quick.bundle` and read the shader XMLs. This is what turns the loose boot green. The earlier two-layer history (now resolved):

1. **The `datacompiler.cpp:656` / "cannot load database" / clean-zero-write-exit states were all the empty `index.bdb` talking.** With the 61-byte stub `db/index.xml` + `core/coredb/index.xml`, the datacompiler rebuilt `compiled\win32\index.bdb` as an 8-byte empty index; a db built from that is unloadable. Seeding the real 402 KB FCL `index.bdb` (`extracted/boot_fcl/boot/compiled/win32/index.bdb`) into `devroot/compiled/win32_fcl/` before boot fixes this: the datacompiler rewrites it **byte-identical** (verified by size after run) and the database loads.
2. **The `Archive.cpp:265` null store was the missing `bundles/`, not a DLL defect.** s5's A/B proved the crash is identical with or without the Valve-vs-Goldberg DLL swap; it tracks the presence of `bundles/` at the loose CWD. The Goldberg-DLL "null data store" attribution in the s4 notes was the right symptom, wrong mechanism — corrected above. The Valve-DLL bare-Wine "Steam must be running" modal is a separate, later gate (a persistent "Fatal Error / Steam must be running to play this game!" modal, `-nosteam` does not suppress it since the check is in the DLL).

**Status (2026-09-26, CLOSED): the loop is closed.** `scripts/launch_dev.sh` is the single dev-boot entry point: it (re)creates `devroot/bundles -> game/bundles/`, re-seeds the FCL `index.bdb` into `compiled/win32_fcl/`, kills leaked engine procs, runs CWD=`devroot/` `-d . -o context.xml -s -fl_boot` (bare-Wine by default; `PROTON=1` for the Proton path; `SWAP_STEAMCLIENT=1` to trial the emu experimental client), then prints a boot-status block with a verdict (WORKING / CRASH / FATAL / NO_WINDOW). s5's 3× A/B proved the null store is DLL-invariant and `bundles/`-tracked; no source patch to the Goldberg emulator was needed. Both runners reach the menu; Elijah confirmed the loose boot playable in-session (p4).

Task 3.1 (instrument the bare-Wine exit) is **DONE**. Task 3.2 becomes "make the loose tree bundle-complete and keep it complete across boots" (the `bundles/` symlink, done by `launch_dev.sh`).

### Task 3.1 — Instrument the bare-Wine early exit (do this first, before any prefix work)

**Files:** `scripts/launch_root.sh` (extend), fresh probe run into `~/.wine-scream`

- Re-run the bare-Wine loose boot with diagnostics on: `WINEDEBUG=-all,fixme`, engine `-fl_boot` (boot file-open log) + `-fl_linear`, and confirm exe path, CWD=`devroot/`, and args (`-d . -o context.xml -s`).
- Record the **last file it opens and the last log line** before the clean exit. That single line tells us which subsystem it bails in (early archive? a silent `steam_api`/registry probe? a DLL load the Proton prefix satisfies that the fresh wine prefix lacks?).
- Verify: we can name the exit point (e.g. "dies after opening `data/settings/physics_settings.xml`, before `renderer_settings.xml`") instead of guessing.

### Task 3.2 — Close the specific gap the instrument reveals

- If the exit point is **PhysX** (bails at/after physics config): bootstrap `~/.wine-scream` from the known-good Proton prefix — `cp -a .../compatdata/3378621997/pfx/drive_c ~/.wine-scream/drive_c` (brings PhysX 2.7.3–2.8.3 engine dirs, PhysXLoader.dll, registry state, game AppData), merge `user.reg`/`system.reg`/`userdef.reg`, run `game2/install/PhysX_8.05.26_SystemSoftware.exe /i` (or extract its 9.14 MSI) to add the legacy runtime, and clear `.../AppData/Local/scream/{data,saves,crashlog.txt,crash.txt}`. Verify: past `physics.cpp:273`.
- If the exit point is **not** PhysX: fix that specific gap (the instrument names it). Do not bulk-copy the Proton prefix on faith.

### Task 3.3 — `scripts/launch_dev.sh` (the dev boot command) — **BUILT (s5, 2026-09-26)**

**Files:** `scripts/launch_dev.sh` (7.0 KB, executable)

- BARE-WINE by default (`WINEPREFIX=~/.wine-scream`, `WINEDEBUG=-all,fixme`); `PROTON=1` switches to the GE-Proton11-6 compat prefix (the path that reliably reaches the menu); `DURATION`/`MIN_PERSIST` override the observation window; `SWAP_STEAMCLIENT=1` swaps in the emu experimental `steamclient.dll` with trap-restore.
- Before every boot: (re)creates the `devroot/bundles -> game/bundles/` symlink (the actual null-store fix) and re-seeds the 402 KB FCL `index.bdb` into `compiled/win32_fcl/`; kills leaked engine procs; `rm -f game/crash.txt` for a clean result read.
- On exit: a boot-status block (process lifetime, crash.txt line, last file opened from `_file_access_log.xml`, window timeline) and a verdict — `WORKING` / `CRASH` / `FATAL` / `SHORT_WINDOW` / `NO_WINDOW` — with matching exit codes.
- Verify: bare-Wine run alive 93s, no crash.txt, window seen (`BUNDLED GREEN (final)` verdict pattern; s5 transcript 23:09); Proton run reaches the menu (p4 user confirmation, 4.1/4.2 observed).

### Task 3.4 — First end-to-end marker (the loop, closed)

- `echo 'io.open("DOGE_MARKER.txt","w"):write("LIVES")'` prepended to a copy of `lua/fcl/win32/data/lib/managers/menu/MenuTitleScreenNode.lua` → `float32luac` → `dev_compile.py --changed` → `launch_dev.sh` → boot.
- **Success = `devroot/DOGE_MARKER.txt` exists.** That single file is the proof: our edited source, compiled by our tool, executed by the running engine.
- Restore the original file; delete the marker.

---

## 9. Phase 4 — First visible in-game features (the payoff, 1–2 days)

Each item below must be *seen in the running game* (window observed via xdotool; screenshot if needed) before it counts.

**Verification harness (BUILT + validated 2026-09-26):** `scripts/verify_visible.sh [--name S] [--wait N] <out.png>` finds the live game window by name, waits up to N seconds, and screenshots *just that window* (via `import`/`maim` on `DISPLAY=:0`). D0G then reads the PNG with its vision tool and transcribes the on-screen text verbatim — no `tesseract` needed (not installed; `sudo -n` requires Elijah's interactive password). **Baseline proven green today:** launched `game/` via `scripts/launch.sh` (Proton, self-contained, no Steam client) → no `crash.txt`, window `Scream Prototype` present, vision read confirms the title shows the original **"PRESS START"** prompt + the **"SCREAM 4M prototype"** logo with **no "D0G WAS HERE"** (correct — bundled mode does not use the dev tree). This is the control: the same harness on the s5 loose boot must show "D0G WAS HERE" for 4.1 to count. No OCR binary required; the vision read is the ground truth.

### Task 4.1 — Visible text change (menu layer)

- Edit the press-`Enter` prompt in `lua/fcl/win32/data/lib/managers/menu/MenuTitleScreenNode.lua` (the `managers.localizer:text("lag_press_enter")` call site — replace with a literal like `"PRESS ENTER — D0G WAS HERE"`, or better, add a new entry to the localized strings XMB and reference it).
- Pipeline: `dev_compile.py --changed` → `launch_dev.sh` → observe the title screen.
- Restore (or keep, if Elijah wants the easter egg).
- **STAGED (2026-09-26):** edited the WIN32 branch to the literal `text = "PRESS ENTER  -  D0G WAS HERE"` (pure-Lua; no xmb surgery, so it compiles through `float32luac` with no string-table rebuild). Compiled + deployed to `devroot/compiled/win32_fcl/data/lib/managers/menu/MenuTitleScreenNode.luc` with `--srcname 'data\lib\managers\menu\MenuTitleScreenNode.lua'`. **Verified:** the output's header + srcname block is byte-identical to the depot original (`data\lib\...\MenuTitleScreenNode.lua`, 47-byte block); the constant table now carries `PRESS ENTER  -  D0G WAS HERE` and `lag_press_enter` is gone; `snum=4`, 9859 bytes.
- **CONFIRMED LIVE (2026-09-26, p4 closed):** on the first green loose boot (via `launch_dev.sh`) the title screen showed the modified prompt — confirmed by Elijah directly (the game boots to the main menu and is playable). The compiled `.luc` is what the engine loaded (0 loose `.lua` files in the tree, `scripts="true"` has nothing to shadow it).

### Task 4.2 — Gameplay behavior change

- Pick one small, safe, observable gameplay rule — e.g. a HUD/debug text element toggled by a new keybinding in `data/settings/default_controls`, or a modifier in one of the `scream_*` gamemodes' unit behavior (the 8 MP gamemodes + 84 unit XMLs are all data-driven and editable).
- Same pipeline; the change must be visible during a round, in the gameplay itself.
- **STAGED (2026-09-26):** `devroot/compiled/win32_fcl/data/levels/common/scream_dodgeball_gamemode.xml` — `team_b` (the 7 survivors in the 1v7 dodgeball mode) `respawn_time` 6 → 2 seconds. Pure data XML (the engine reads it directly from the loose tree; no `.luc` compile needed). Original preserved at `/tmp/scream_dodgeball_gamemode.xml.orig`.
- **CONFIRMED LIVE (2026-09-26, p4 closed):** the dodgeball round on the green loose boot used the 2s `team_b` respawn — observed by Elijah during the session.

### Task 4.3 — Iteration ergonomics

- `scripts/dev_edit.sh <file>` — opens the decompiled source for a path, and on save runs the compile+boot pipeline automatically (edit → boot in one keystroke).
- Keep `game/` untouched by all of this; the dev tree is the only thing that mutates.
- **BUILT (2026-09-26):** `scripts/dev_edit.sh` is in place and tested. `dev_edit.sh <path>` compiles a decompiled `.lua` (repo-relative `lua/fcl/win32/...` or a bare filename resolved against `lua/`) into `devroot/compiled/win32_fcl/<data|core>/.../X.luc` with the engine-expected depot srcname, then delegates the boot to `scripts/launch_dev.sh`. Flags: `--compile` (no boot), `--boot` (boot only, for data-XML edits like the 4.2 gametype change), `--path <p>`. It is the single compile entry point; `launch_dev.sh` (built by s5) is the single boot entry point, so the two stay independent.

## 10. Phase 5 — Stretch: live debug + editor (optional, after the loop is proven) — **parked (v7):** all loop-critical work is done; these three are optional follow-ups to pick up when we want live-debugging, visual level editing, or engine-level C++ changes.

- **ConsoleServer / wxConsole:** the dev exe embeds a socket console and Lua remote debugger (RE_REPORT §5.4; `HW12Dev/dslConsole` is the open-source client). A live REPL into the running engine beats restart-per-iteration for gameplay debugging. Task: find the console enable flag/port in the dev exe strings + `steam_settings`, wire a client, verify an `Application:debug`-style command runs live.
- **Editor context:** boot with `editor="true"` in `devroot/context.xml` (`core/levels/editor` + `data/lib/utils/dev/editor/` are in the depot). If it comes up, level/unit editing becomes visual.
- **PDB/IDA deep end:** only if a feature requires engine-level changes (new opcode, new C++ hook). The two 60 MB PDBs make that tractable but it's the last resort.

## 11. Risks and mitigations

| Risk | Likelihood | Mitigation |
|---|---|---|
| Engine rejects externally-compiled float32 `.luc` (needs its own compiler's quirks) | Medium | Phase 1.3 test catches it before we build the pipeline; fallback = Phase 2.2 engine-compile path |
| Loose dev boot dies at the null data store (`Archive.cpp:265`) because the loose tree lacks `bundles/` (shader XMLs live only in `quick.bundle`) — **root-caused + A/B-proven 2026-09-26, s5** | Resolved (primary) | Symlink `bundles/` → `game/bundles/` into `devroot/` before every boot (`launch_dev.sh` does it, like the `index.bdb` re-seed); A/B shows it clears the crash and brings up a window |
| Float32 precision changes gameplay constants (float64→float32 rounding vs originals) | Low | The originals ARE float32; we round to the same width. Differential test (Task 1.2.2) bounds the error |
| The DLL swap regresses again | High (already happened once) | `launch_dev.sh` trap-restores it; `launch.sh` refuses to run with the wrong DLL; Phase 0.1 makes the contract explicit |
| unluac round-trips lose information (source names, some constant kinds) | Low | Fixtures assert source name + constant count; any mismatch is a named, fixable bug |

## 12. Open questions (research needed during execution)

1. **RESOLVED (s5, 2026-09-26):** the archive the Renderer opens that goes null is the **bundle-backed `dsl::Archive` over `quick.bundle`**. `layers.xml` (the last open) references `data/shaders/*.xml`, which exist only inside `quick.bundle`. With no `bundles/` dir at the loose CWD, the bundle can't be opened, so the Archive wrapping it is null, hence the `Archive.cpp:265` throw. A/B: remove the `bundles/` symlink, boot crashes; add it, no crash and a window appears. The result is DLL-invariant (same on Goldberg and Valve, Proton and bare-Wine). Fix: `launch_dev.sh` keeps `bundles/` present at the loose CWD (symlink to `game/bundles/`) alongside the `index.bdb` re-seed.
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

Conclusions (s4, superseded on point 2 by s5): (1) the datacompiler's 656/720 failures were the empty-index state, now closed; (2) `Archive.cpp:265` is runner-independent and — s4's hypothesis — DLL-dependent; **(s5 later proved it is actually dev-tree-dependent: the missing `bundles/`, not the Goldberg store — see s5 appendix below)**; (3) the Valve DLL's only remaining complaint is the Steam-running gate — its remote-storage behavior past that gate is untested (next experiment under (c)); (4) bundled mode (live Steam, `game/`) is the only green boot. DLL contract restored to Goldberg after each run (trap-verified, md5 `ac41be5a` standing).

### s5 appendix — the 2026-09-26 22:43–22:45 A/B (null-store root cause, closed)

Dev tree at the time: same as s4 (FCL `index.bdb` seeded into `win32_fcl/` before each run; `context.xml` `<compile xml="true" scripts="true">`); the only variable toggled was the presence of `devroot/bundles` (a symlink to `game/bundles/`).

| # | bundles/ at loose CWD | crash.txt | result |
|---|-----------------------|-----------|--------|
| control | absent | `C++ exception ... Archive.cpp:265 _store.get() != 0 [Archive]: null data store`; last open = `layers.xml` | crash (identical to s4) |
| treatment | symlinked → `game/bundles/` | **none** | no crash; an "Untitled" window appears |

Chain of evidence: `layers.xml` (last successful open) references `data/shaders/*.xml`; 0 `shaders/*.xml` exist in `extracted/quick/data/` or the boot_fcl loose tree; all 7 named shaders (shadow/fog_generator/deferred_post/fog_apply/post/msaa_depth_resolve/lighting_upscale processor) are present inside `game/bundles/quick.bundle` (raw scan; 22 `shaders/` entries). The renderer's `dsl::Archive` wraps the `dsl::BundleFileSystem`; with no `bundles/` dir to open, that store is null. Fix: `launch_dev.sh` (re)creates the `bundles/` symlink + re-seeds `index.bdb` before every boot.

### Phase 1 evidence (float32luac, 2026-09-26)

Full-corpus run of `tools/verify_float32luac.py --sample 1026` (all 1,026 decompiled `lua/` sources vs their depot `luc/` originals; log: `~/.hermes/cache/scratch/f32luac_verify_full.log`):

- **Fixture 1 (hard, well-formed snum=4 + structural round-trip): 1024/1026 pass.** The 2 misses are decompiler artifacts — `lua/fcl/win32/data/lib/menu/menu_server_selection/MenuServerSelectionSteam.lua` (line 712: `'end' expected (to close 'if' at line 710) near 'until'`) and `lua/quick/win32/data/lib/units/mp/NetworkAreaDamage.lua` (line 51: `'end' expected (to close 'if' at line 25) near 'until'`). Stock `luac5.1` rejects both identically when run directly on the same sources — the decompiler emitted unbalanced `if`/`repeat` nesting, so no compiler can accept them.
- **Fixture 2 (hard, == stock luac5.1 modulo srcname/snum/f32): 1024/1026 pass** — same two files (they don't compile at all); zero field-level divergences on everything else. The contract holds: `float32luac(SRC) == luac5.1(SRC)` modulo exactly the stored srcname, the snum byte (8→4), and float64→float32 constant narrowing.
- **Fixture 3 (informational, delta vs depot original): byte_exact 1, lineinfo_only 1019, other 4, compile_error 2.**
  - `byte_exact` (1): `quick/win32/data/lib/managers/DOFManager.luc` — recompiled byte-for-byte identical to the depot file (this file's decompiled source line-numbering happens to line up with the original's).
  - `lineinfo_only` (1019): code, constants, locvars, upvalues all identical; only the lineinfo tables differ. Expected and harmless: the decompiler drops leading source lines, so the decompiled file's line numbers are shifted relative to what the original compiler recorded. The engine reports these line numbers in runtime errors (the `MenuServerInformation:637` crashlog line is such a report); a mismatch only changes which source line a runtime error points at.
  - `other` (4): `fcl/core/lib/core/utils/CoreCode.luc`, `fcl/data/lib/network/NetworkAIEventManager.luc`, `quick/core/lib/core/utils/dev/tools/cutscene_editor/CoreCutsceneEditor.luc`, `quick/.../CoreCutsceneMayaExporterCurve.luc`. Root code/constant counts are identical to the depot; the delta is (a) nested-prototype lineinfo (the classifier only diffs root lineinfo, so nested shifts fall into `other`) plus (b) a small number of genuinely extra instructions in the depot: the original GRIN-era compiler emitted redundant no-op `EQ 0 256 0`-style tests that stock luac5.1 does not (e.g. `DebugManager` protos[2]: depot 28 ins vs stock 27, the extra `EQ` always-falsy and harmless). These are decompiler/round-trip artifacts, not float32luac divergences — fixture 2 proves the recompiled output is exactly stock luac5.1 modulo the three known normalizations.

Net: the compiler is correct against the depot corpus — 2,048/2,052 hard-gate file-gates pass, and all 4 misses (2×2 fixtures) reduce to two un-compilable decompiler-artifact sources.

### v6 closing appendix — 2026-09-26 23:00–23:20 (s5 + s6 land, p4 closed, plan closed)

- **s5 final verdict:** the null data store is `dsl::BundleFileSystem` (the bundle container store), DLL-invariant; no source patch to the Goldberg emulator was needed (`tools/emu-gbefork` clone kept at commit `4e011cf4` in case a future gate needs interface work; `tools/emu-src` is the base upstream). s5's final checks: bare-Wine loose boot alive 93s, no crash.txt, window present ("NO CRASH at 93s -> BUNDLED GREEN (final)"); bundled `game/` boot stable at 93s. Side effects installed: PhysX 9.14 legacy runtime into the `~/.wine-scream` prefix (the bare-Wine `physics.cpp:273` gate is now fixed there too), and a `devroot/game.lhd` copy (redundant with the `bundles/` symlink — harmless, deletable).
- **s6 final verdict:** `float32luac` full-corpus verified (2,048/2,052 gates; the 4 misses reduce to two decompiler-artifact sources that stock luac5.1 rejects identically); `dev_compile.py` pipeline committed (`c3ef69f`); `MenuServerInformationSteam` static engine-acceptance prep done (our recompile == depot original in size/srcname/1955 instruction counts/constants; only deltas = lineinfo + GRIN-era loop-field encoding).
- **p4 closed on user confirmation:** Elijah ran the green loose boot — the game boots to the main menu, is playable, and the 4.1 title text + 4.2 dodgeball respawn changes were observed live. D0G's own corroboration: the Proton `-fl_boot` `_file_access_log.xml` from that boot shows the full menu phase (`save4.sav`, `menues.xmb`, `credits.xmb`, `default_controls.xmb`); the 4.1 `.luc` carries the `PRESS ENTER  -  D0G WAS HERE` literal and there are 0 loose `.lua` files in the tree (no shadowing); the 4.2 XML has `team_b respawn_time=2`. (One earlier bare-Wine probe in this session tripped `physics.cpp:273` before s5's PhysX install landed — expected, now fixed by s5.)
- **Definition of done: all four met** — Read (1026/1026 Lua source), Compile (`dev_compile.py` + `float32luac`), Boot (`launch_dev.sh` reaches the menu, bare-Wine and Proton), Proven (4.1 + 4.2 observed from our compiled source). The project is development-ready.
- **Housekeeping:** stray `SRC=lua/` dir (one stale pre-edit `MenuTitleScreenNode.lua` from an aborted heredoc in a subagent's shell) deleted; `tools/emu-gbefork/` (2.4 GB) and `tools/emu-src/` added to `.gitignore` (both are git clones); `devroot/game.lhd` removed (byte-identical to `game/bundles/game.lhd`, already served by the `bundles/` symlink) and the orphaned `/tmp/PhysX-9.14.0702-SystemSoftware.msi` download from s5's prefix install deleted.
- **Remaining (all optional/stretch — none block the loop):** Phase 2.1 stock→GRIN inverse (superseded by stock-loop emission), Phase 2.2 engine `.lua`-compile probe (superseded by the green boot), Phase 5 (socket console / editor / PDB deep end), cross-machine multiplayer (the `game2/` second-instance harness is ready), and the one non-blocking observation: the loose-mode menu early-exit flake (see below).

### Known open item — pre-existing loose-mode menu early-exit flake (s5 observation, 2026-09-26)

s5's `launch_dev.sh` runs surfaced a flake **independent of the null-store fix**: the loose boot (CWD=`devroot/`, both bare-Wine and Proton) sometimes exits **clean** (rc=0, no `crash.txt`) ~8–14s **after** the menu window has appeared. The bundled `game/` boot does not show it (stable at 90s+), and s5's `-fl_boot` trace shows the menu reading `save4.sav` right before the early exit — so the menu itself is fully up; the process just bails a few seconds later. s5's suspect: the `SteamAPI_RunCallbacks` / menu-input thread under loose mode (the loose path's Steam session differs from bundled live-Steam). It is **not** the null store (which is deterministically gone, 3/3 A/B) and **not** a crash (clean exit, no `crash.txt`). Worth one session to pin the exact bail point with `-fl_boot` + `WINEDEBUG=+loaddll` on a repro; until then, a loose boot that hits the flake is retried (a second boot through `launch_dev.sh` reliably reaches the menu, as Elijah's in-session playable run confirms).
