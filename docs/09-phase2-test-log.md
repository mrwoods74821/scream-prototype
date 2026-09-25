# 09 — Phase 2 Test Log (single machine)

Session date: 2026-09-24. Everything below verified live unless noted.

## Proven working

1. **Steam gate under Goldberg** — all three MenuSetup checks
   (Steam:init / logged_on / client_running) pass; MP menus open.
   `WIN32PlatformManager:is_online()` is hardcoded true.
2. **Host path end-to-end** — PLAY GAME → GAME PREFERENCE (EXPOSE THE
   KILLER) → CREATE GAME (public) / CREATE PRIVATE → SERVER LOBBY with chat,
   SURVIVORS/GHOSTFACE team slots → START GAME loads a complete solo round
   (evidence pickups 0/3, timer, [E] prompts, HUD).
3. **Two instances coexist** — freeze cause was two exclusive-fullscreen DX9
   windows; fixed by windowed mode via each prefix's
   `AppData/Local/scream/data/settings/renderer_settings.xml`
   (host 1600x900, client 1280x720).
4. **Goldberg config decoded (this gbe build)**:
   - `steam_settings/configs.main.ini` — `[main::connectivity] listen_port`,
     `[user::general] account_name`. Legacy player_name.txt / listen_port.txt
     are IGNORED (default name "gse orca", default port 47584).
   - Persistent per-user override: `AppData/Roaming/GSE Saves/settings/configs.user.ini`.
   - `custom_broadcasts.txt` supported (string present in DLL).
   - Verified live: fresh host boot showed Elijah_Host in SERVER LOBBY.

## Crash found (prototype bug)

`MenuServerInformationSteam` `_setup_lobby_handler` indexes nil
`self._server_information_values` when the GamePreference page is skipped
(ESC path). Reproduced on both instances (crash.txt, MenuS...:637).
Workaround: navigate forward only; never ESC past GamePreference.

## The definitive same-machine blocker

gbe_fork binds its listen port exclusively. When the second instance requests
an occupied port it AUTO-INCREMENTED (asked 26011, got 26012 — observed via
ss). LAN lobby discovery is per-port, so two instances on one machine can
never see each other's lobbies; `custom_broadcasts.txt 127.0.0.1` does not
bridge the split. Server browser on the client is therefore always empty in
a same-machine test. This is an emulator architecture limit, not a game bug.

## Instance2 setup (reusable for the LAN client machine)

- `~/Downloads/ScreamPrototype/instance2/`: game copy + compatdata prefix
  (copied from host compatdata INCLUDING `tracked_files`, `version`,
  `config_info` — GE-Proton's update_builtin_libs requires them or the
  prefix copy dies with FileNotFoundError).
- Wiped `AppData/Local/scream/{data,saves}` for clean state.
- Launch: GE-Proton11-6 directly with
  STEAM_COMPAT_DATA_PATH=instance2/compatdata, WINEPREFIX=.../pfx.

## Next: LAN cross-machine (test ladder step 7)

- Host: this machine via Steam. Client: second machine, copy instance2 (or
  fresh install + prefix with PhysX per skill scream-prototype-steam-launch).
- BOTH on default Goldberg port (remove configs.main.ini or leave absent);
  discovery via UDP broadcast on the LAN — no port collision across machines.
- Fallback if lobby browser still empty: the engine's own LAN path
  (NetworkSystemLinkNew:find_game → Network:broadcast(26011) lan_search,
  separate from Steam lobbies) — probe with a UDP listener on 26011 to see
  whether the server browser's GSBrowser refresh emits LAN queries.
- Internet play after that: direct IP via custom_broadcasts + port forward.
