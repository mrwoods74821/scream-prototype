# 08 — Session Flow Map (Phase 1)

Recovered 2026-09-24 from the 100% decompilation (1026/1026 .luc files via
luc_stock.py in-place transform + unluac). All facts cited from
`lua/fcl/...` (boot.fcl layer) and `lua/quick/...` (quick.bundle layer).

## Platform selection (NetworkManager:create_lobby, NetworkManager.lua:227-287)

On WIN32 (`SystemInfo:platform() == "WIN32"`), the lobby stack is:

- `group = NetworkGroupLobbyRDV:new()` — the 19K main lobby state machine
- `matchmake = NetworkMatchMakingNew:new()`
- `generic = NetworkGeneric:new()`
- `systemlink = NetworkSystemLinkNew:new()` — LAN/direct-path server browser
- `account = use_steam and NetworkAccountSteam:new() or NetworkAccountNew:new()`
- `friends/voice_chat = Blank/Disabled`

`use_steam` (NetworkManager.lua:241):

```lua
local use_steam = not Application:dedicated_server()
    and Global.use_steam and Global.steam_init_success
```

## The Steam gate (where MP lives or dies)

- `mainmenu.lua:19` — `Global.use_steam = true` by default; only `-nosteam` argv clears it.
- `MenuSetup.lua:104` —
  `Global.steam_init_success = not Application:dedicated_server() and Steam and
  Steam:init() and Steam:logged_on() and Steam:client_running()`
- Under Goldberg: `Steam:init()` succeeds (emu), `logged_on()` and
  `client_running()` are Goldberg stubs that return true. The gate SHOULD pass.
  **Verification of all three return values under the deployed Goldberg build is
  Phase 2 step 0.**

NOTE: `use_steam` only selects the *account* manager. The group/matchmake/
systemlink objects are created unconditionally on WIN32 — the Steam-specific
friends/invites layer (SteamManager.lua `_on_join_lobby_request`,
`Global.join_gameserver`) is additive on top.

## Host/join entry points

1. **Menu path**: `MenuPageManager.lua:194-268` (`join_game_selected_callback`,
   `Global.join_gameserver` handling at :442) → `MultiplayerScreen.lua:2384`
   `managers.network.matchmake:join_game(game_id, private)`.
2. **Server list**: `MenuServerListNode.lua:269`
   `managers.network.systemlink:join_game(game._game_id)` — the LAN/system-link
   path via NetworkSystemLinkNew (`Network:broadcast(port):lan_search()`,
   `rpc:lan_serverinfo_req()`; port 26011 per NetworkManager:determine_port:288).
3. **Steam invite**: `SteamManager.lua:161-176` sets `Global.join_gameserver`
   from a lobby-join request; `MenuPageManager:442` consumes it after intro.
4. **Dedicated**: `Application:dedicated_server()` + `-dedicated` argv
   (mainmenu.lua:27) — dedicated server branch exists (NetworkManager:228
   building_file_order path installs Blank matchmaking).

## Wire flow (from NetworkSystemLinkNew + Gametype.lua:562-574)

- Discovery: UDP broadcast on port 26011, `lan_search(chk_val)` → server
  replies `join_session` → client `lan_serverinfo_req` → server list UI.
- Join: `join_game(id)` → handshake → server responds
  `from_server_level_and_gamemode(level, gamemode, success_id, motd)`;
  rejection codes: `bad_connection`, `banned`, `server_full` (NetworkLookup
  category "join_game").

## Open questions for Phase 2

1. Does Goldberg satisfy `Steam:logged_on()`/`client_running()`? (Probe in-game
   via console/dev script; else patch MenuSetup to force the flag.)
2. Is the MultiplayerScreen reachable in the shipped menu (button hidden?), or
   must we jump straight to `managers.network.matchmake:join_game()` from a
   script hook?
3. Port 26011 UDP must be distinct per instance on one machine (Goldberg
   `listen_port.txt` + this engine port).
