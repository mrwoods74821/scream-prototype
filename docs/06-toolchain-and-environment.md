# 06 — Toolchain & Environment

## Runtime (verified working, 2026-09-24)

- Steam shortcut "SCREAM prototype" (appid 3378621997), GE-Proton11-6 or Proton Experimental, prefix `~/.steam/debian-installation/steamapps/compatdata/3378621997/pfx`, PhysX legacy 9.14 MSI installed in-prefix, no launch args (bundled mode). Details: Hermes skill `scream-prototype-steam-launch`.
- Direct Proton invocation for testing (Steam may be closed):
```
export STEAM_COMPAT_DATA_PATH=~/.steam/debian-installation/steamapps/compatdata/3378621997 \
  STEAM_COMPAT_CLIENT_INSTALL_PATH=~/.steam/debian-installation \
  STEAM_COMPAT_CLIENT_PATH=~/.steam/debian-installation \
  WINEPREFIX=$STEAM_COMPAT_DATA_PATH/pfx DISPLAY=:0
"$HOME/.steam/debian-installation/steamapps/compatibilitytools.d/GE-Proton11-6/proton" \
  waitforexitandrun ./scream_win32_public_dev.exe [args]
```
- Crash log: `42151_5/crash.txt`. Proton log: PROTON_LOG=1 → `~/steam-42150.log`. Network log toggles (engine members): `_socket_log`, `_packet_log`, `_rpc_log`, `_synchronizer_log` (set from Lua/console in dev build).
- Exe dev flags: `-d <dir>` boot dir, `-o <file>` context override, `-s` no-splash, `-q` quiet, `-u` unit-test, `-exitdetect -crash -wait -delayedstart`.

## Formats (all documented in Hermes skills — reload before working)

| Format | Skill | Status |
|---|---|---|
| BNDL v2 bundles | `diesel-bundle-extraction` | Documented, parser spec ready |
| FCL + LHD patch containers | `diesel-bundle-extraction` | Documented incl. one-entry-shift pitfall + validation rules |
| .luc Lua bytecode (GRIN dialect) | `diesel-luc-decompile` | Transform proven previously (617/688 decompiled once); tooling must be rebuilt (tools/ tree lost) |
| XMB binary XML | token-table format; reference impl: HW12Dev/DieselFormats (legacy XMB parser) | To build |
| .diesel models, .cok, .blb | not needed for MP feature | out of scope |

## Toolchain rebuild checklist (Phase 0)

1. `tools/bndl_extract.py` — BNDL v2 index parser + extractor (spec in skill; one-stream read pitfall).
2. `tools/fcl_extract.py` — FCL zlib-chunk stream + LHD manifest mapper with the i/i+1 shift pairing + magic validation (xml '<', xmb 'XML\x01', dds 'DDS ', luc '\x1bLuaQ').
3. `tools/luc_stock.py` — .luc → stock Lua 5.1 rewriter (float32 consts, TFORCALL/TESTNIL → TFORLOOP+JMP pair with target patching) and the reverse transform for recompile.
4. unluac jar (download) for decompile; luac (patched float32 or compile via engine loose mode) for recompile.
5. `tools/xmb2xml.py` — XMB token-table ↔ XML.
6. devroot/ loose boot dir with `context.xml` copy setting `xml="true" scripts="true"` so the engine recompiles loose .luc at boot; db index stubs (`db/index.xml`, `core/coredb/index.xml`) required (learned 2026-09-23: missing stubs = silent dsl::ErrorWithCStack exit).
7. Git repo over the game folder BEFORE first modification (Elijah's standing rule: git, no backup copies).

## Goldberg configuration notes (Phase 2/3)

- Active: `steam_api.dll` = Goldberg build (md5 ac41be5a...), Valve original at `steam_api.dll.valve`.
- Configure via `steam_settings/` (if absent, create): appid 42150, player name, `listen_port.txt` distinct per instance, `disable_lan_only.txt` for direct-IP internet tests, `ignorecontroller.txt` etc as needed.
- steam_interfaces.txt pins OLD interface versions (SteamNetworking003, SteamClient009, SteamMatchMaking008). Goldberg reads this file — verify its emulation covers these; if not, that is the prime patch point (build Goldberg from source with the old interfaces).

## Testing harnesses built into the engine

- `Network::add_fake_clients`, `Network::simulate`, `dsl::network::steam::UDPSocket::simulate_{bandwidth,packet_loss,latency,out_of_order}`.
- Two-instance single-machine: two Proton prefixes or one prefix + Goldberg per-instance port/name config; DISPLAY=:0 for both; verify via ps + xdotool window names.

## Reference: previous session's proven facts (2026-09-23, tree now lost)

- Loose-file boot achieved end-to-end once (db compiler, all scripts, renderer init) before the tree was deleted; the procedure and pitfalls (index.xml stubs, compile_report truncation, MenuControllerBindNode nil crash + patch) are recorded in Hermes skill `scream-prototype-re` (historical section) — those lessons still apply to the rebuild.
