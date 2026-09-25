# 02 — Engine Architecture (from PDB symbols)

Source: `scream_win32_public_dev.pdb` strings dump (514,784 lines). All symbols below seen verbatim; interpretation labeled where it is inference.

## Build identity

- MSVC 9.0 (VS2008), 32-bit, `-O2 -Ob2 -Oi -Ot -GT`, `NDEBUG` + `DEV_BUILD`.
- Defines: `PROJECT_NAME=Scream`, `USE_STEAM`, `NETWORK_USE_STEAM_SOCKETS`, `NETWORK_SEND_HASH`.
- Include paths: `C:\exe_build\libsvn\steamworks_1_8\public` (Steamworks SDK 1.8), `C:\exe_build\scream\engine\dieselx`, `C:\exe_build\scream\engine\lua\src`.
- Engine source tree layout (inferred from file strings): `engine/application/source/network/*.cpp` (netcode), `engine/network/steam/*`, `engine/network/{udpsocket,tcpsocket}.cpp`, `engine/lua/` (Lua 5.1 source vendored).

## Process architecture

- Entry `WinMain` → `Application` class (~180 methods) is the composition root: `init`, `run`, `update`, `destroy`, `exec_program`, `load_program`, `setup_scenes`, `update_network` (called per-frame from app update), `setup_script_environment`, `save_data/load_data`, `load_dlc_databases`.
- Script getters on Application: `dedicated_server`, `no_rendering`, `using_steam`, `mode`, `script_host_name`, `script_pause_streaming`/`script_unpause_streaming`. A dedicated-server mode exists in the exe (consistent with Lead and Gold shipping standalone dedicated servers).
- `Context` (54 methods) is the config-driven factory: `get_network(XMLNode)`, `get_unit_data`, `get_levels_base`, `get_game_name`, `load_version`. The `network` object is created from XML config — `AppEnv::network_config_file` names the config file (the `data/settings/network.xml` shipped in the bundle).

## Lua layer

- Lua 5.1 vendored and modified by GRIN (float32 constants; custom opcodes 38/39 TESTNIL/TFORCALL — see skill diesel-luc-decompile).
- Engine objects are scriptable through a common interface: `push_var`, `add_members`, `is_type`, `type_id`, `set_receiver`, `script_new`. The `Network` object itself is Lua-visible (`network___idstring`).
- `level_load_unit` is a Lua-serializable function — level loading crosses the Lua serializer.
- Game-mode logic has NO engine classes: zero hits for GameState/GameMode/GameSession/AppLayer. Menus, gamemodes, and session flow live entirely in Lua/data. This is why the bundle/Lua toolchain is the critical path.

## World / units

- `World::load_from_xml`, `xml_load_scene`, `setup_world`, `spawn_unit`, `spawn_unit_without_extensions`, `preload_unit`, `delete_unit`, `unload_all_units`.
- `UnitDatabase::xml_load_unit` — unit types are XML-declared (the 84 `<network>`-tagged XMLs, see 04).
- `MassUnitManager` (crowd/mass system): `set_level`, `load_unit_xml`, `spawn_unit`, `can_spawn_unit`, `read_config`.
- Rendering: D3D9 (`d3d9.dll`, `d3dx9_38`), DXVK-translated under Proton. Audio: OpenAL (`OpenAL32.dll`, `wrap_oal.dll`). Physics: PhysX 2.8.1 (AGEIA-era, `PhysXLoader`/`NxCooking` imports).

## Diesel namespaces (map of the engine)

| Namespace | Role |
|---|---|
| `dsl::network` | Raw BSD socket layer (UDP/TCP, select, interfaces) — LAN/plain path |
| `dsl::network::steam` | Steam P2P transport: Socket, UDPSocket, SocketAddress (SteamID-keyed), PingHandler, AuthenticationSessionHandler |
| `dsl` (core) | BytePacker, IntPacker, Deque, MTProtector, LuaArgs/LuaTable, AutoCreatedSingleton, idstring |
| `fs::` | Game-level script-facing layer: Steam singleton, all Script* wrappers |
| Engine root | Network, Synchronizer, Connection, Packet*, RPC*, TrafficShaper, FileDownloader, PacketInterceptor, World, Application, Context |

## Key singletons

- `dsl::AutoCreatedSingleton<Synchronizer>` — unit replication manager (see 03).
- `fs::Steam` — Steam singleton: `create_lobby`, `join_lobby`, `lobby`, `friends`, `gameserver_start/stop/id`, `client_running`, `logged_on`, `local_userid`, `local_username`, `username_by_id`, `update`, `init`, overlay listeners.
- `Network` — created by Context from XML; roles via `ClientServerState` enum: DISCONNECTED / SERVER / CLIENT.
