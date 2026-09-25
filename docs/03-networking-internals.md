# 03 — Networking Internals (complete inventory)

All from PDB symbols (verbatim names). File paths in the original source tree given where recoverable. This is the map of what already exists — the P2P plan (05) restores and drives this machinery.

## Compile-time configuration

`-DNETWORK_USE_STEAM_SOCKETS -DNETWORK_SEND_HASH -DUSE_STEAM` — Steam P2P is the compiled-in transport; every mangled packet signature addresses peers via `SocketAddress@steam@network@dsl` (SteamID-keyed). Packet integrity hashes on (RPC_*_WITH_HASH variants). A plain/LAN path exists in parallel (`dsl::network::Socket`, `set_plaintext_network`).

## Network manager — `engine/application/source/network/network.cpp`

85 methods. Roles: `Network::is_server/is_client/is_disconnected/multiplayer/set_multiplayer`, state via `ClientServerState` enum (DISCONNECTED/SERVER/CLIENT).

- **Handshake**: `server_hello(steam::SocketAddress)`, `client_hello`, `update_hello`, `handshake`. Hello packets: I_AM_SERVER_PACKET / I_AM_CLIENT_PACKET (+ `IAmServerPacketPing` variant), WANTS_TO_SEND_ORDERED / CANNOT_RECEIVE_ORDERED / ACKNOWLEDGE flow-control messages.
- **Clients**: vector of `Network::Client` {address, last_hello, connection, position, ping_only}. `add_client/remove_client/find_client/clients/clients_except/all/all_except`. Interest management: `clients_within_distance`, `set_client_position`, `time_since_position_ack`.
- **Join-in-progress**: `drop_in`, `SavedGameLoader` {total_size, segments, received, num_received} with SaveGameSegmentPacket/SaveGameReceivedPacket — segmented world-state push to late joiners.
- **Ownership**: `owner(Unit*)` → SteamID address, `take_ownership`, `resign_ownership` (per-unit authority migration — host migration primitive).
- **QoS/shaping**: `set_server_kbps`, `set_uplink_kbps`, `set_throttling_disabled`, `send_shaped_data`, `TrafficShaper::set_kbps`; `qos` returns a LuaTable to scripts; `register_ping_watch`, `get_pings`.
- **Downloads**: `FileDownloader`, `Network::download/download_status/download_read_bytes/remove_download` — over-the-wire file transfer.
- **Auth**: `using_steam`, `authentication_session_start/notification`, `cancel_authentication_session` → `dsl::network::steam::AuthenticationSessionHandler` (GetAuthSessionTicket/BeginAuthSession/EndAuthSession, GSClientApprove/Deny/Kick callbacks, AUTH_SESSION_BLOB_SIZE).
- **Debug/test**: `add_fake_clients`, `simulate`, `packet_interceptor` (thread-safe injected-message queue: PacketInterceptor::pull_outgoing_packet, MTProtector-guarded), `send_debug_string` (DEBUG_STRING_PACKET), `_socket_log/_packet_log/_rpc_log/_synchronizer_log` log toggles.

## Replication — Synchronizer (`network/synchronizer.cpp`)

Bespoke unit-synchronizer; NO Replica/NetVar/snapshot-delta system (zero hits).

- Unit lifecycle RPCs: `request_create_unit(idstring, Vector3, GQuat, CreateUnitOptions)`, `create_unit_on_client`, `client_load_spawn`, `remote_unspawn`, `request_delete_unit`, `delete_unit_data`, `delete_all_units`, `add_unit_synchronization`, `add_bodies_synchronization`.
- Full-state sync on connect: `send_server_unit_synchronization`, `send_client_unit_synchronization` (locals: sync_units, sync_bodies, sync_tables), `drop_in`.
- IDs: `next_unit_id` (u16), `unassigned_client_id`, `unit_for_unassigned_client_id`, `unit_for_id`; bit-packed via `dsl::IntPacker`; constants MAX_UNIT_ID, MAX_UNITS_PER_UNIT_PACKET, MAX_UNITS_PER_BODY_PACKET, MAX_BODIES_PER_UNIT_IN_BODY_PACKET.
- Position sync: `UnitPositionSynchronizer` (per-Unit map), `CharacterPositionSynchronizer` (`remote_data(Vector3, GQuat, float)`) — interpolation on the remote side.
- Physics bodies: BodyPacket with per-field packers (`_velocity_packer`, `_angular_velocity_packer`) — quantized rigid-body state for sync="bodies" units.

## Wire protocol — 31 packet types (PacketType enum, verbatim)

PING, I_AM_SERVER, I_AM_CLIENT, WANTS_TO_SEND_ORDERED, CANNOT_RECEIVE_ORDERED, ACKNOWLEDGE, RELIABLE_ID, ORDERED_SEQNO, SPAWN_UNIT, UNIT_SPAWNED, SPAWN_UNIT_ON_CLIENT, CLIENT_SPAWN_UNIT, CLIENT_UNSPAWN_UNIT, ASSIGN_CLIENT_UNIT_ID, UNIT, UNIT_POSITION, BODY, SERVER_TABLE, CLIENT_TABLE, RPC_UNRELIABLE, RPC_RELIABLE, RPC_ORDERED (+ each WITH_HASH/WITHOUT_HASH), SAVE_GAME_SEGMENT, SAVE_GAME_RECEIVED, AUTH_SESSION, AUTH_SESSION_RESULT, DEBUG_STRING, XBOX_VOICE (360 legacy).

Base class `Packet` {type, delivery, generate, extract, receive, write_to_stream, wants_ack, wants_bundle_ack, acked, lost}; `PacketFactory`; serialization via `dsl::BytePacker`. SERVER_TABLE/CLIENT_TABLE carry script-table state (dirty-checked via `TablePacket::differs_from`).

## Reliability layer (`network/connection.cpp`)

- `Connection`: `begin_send_frame`, `send_one_bundle`, `send_unreliable_data`, `add_packet(s)`, `receive`, `can_send`, `bad`, `qos`, `set_timeout_if_no_hello_for`.
- Senders: `PacketSender` → `UnreliablePacketSender`, `ReliablePacketSender` (resend tracking, PendingAck). Receivers: `Unreliable/Reliable/OrderedPacketReceiver`. Bundle layer: `TransmissionPacket(s)` with ack/timeout/retention.

## RPC system (`network/rpc.cpp`)

- Declarations are DATA: `data/settings/network.xml` (message name, delivery reliable/unreliable, check none/hash, typed params with quantization `step`). Engine loads via `RPC::load`, `RPCTable::read/write`, `RPC::index_of_table_with_name`.
- Wire: `RPCParentPacket` → RPCUnreliable/Reliable/OrderedPacket. Delivery: `RPCParam::pack/unpack` per type (string, float w/ step, vector3 w/ step...).
- Lua bridge: `RPCCaller` script object — `rpc_method_call(int, LuaArgs)` invokes Lua RPC handlers by table index; peer enumeration `num_peers/script_peer_at_index/peer_ip_at_index/peer_name_at_index/ping_at_index`. `RPCReceiver::process_queue` with `ReceiveQueueMessage`.
- Per-unit variable sync declared in Lua: `Unit::script_network_sync`, `unit_database::UnitData::script_network_sync` (Lua name `network_sync`) — each unit type declares which Lua values replicate; carried by TABLE packets. (Inference: values, methods and flows are data-defined; the exe only provides transport + dispatch.)

## Transports

1. **Steam P2P (primary, compiled in)**: `dsl::network::steam::UDPSocket` {bind, send, receive, update, pop_received, make_address/broadcast/loopback, load_settings, set_client_server_state} + `steam::Socket` session manager {sendto, recvfrom, has_connection_to, failed_connection, disconnect, close_all_sessions, get_connection_details; P2PSessionRequest_t/P2PSessionConnectFail_t callbacks; SocketStatusCallback_t}. Network-condition simulation built in: `simulate_bandwidth/packet_loss/latency/out_of_order`. NAT traversal delegated entirely to Steam P2P.
2. **Raw sockets (parallel path)**: `dsl::network::Socket` BSD layer (bind/listen/accept/connect/select/send/recv, blocking mode, interfaces). Selected when NOT using Steam — `set_plaintext_network` Lua member exists.

## Session/lobby layer — `fs::` (all Lua-exposed)

- `fs::Steam` singleton (create_lobby/join_lobby/lobby/friends/gameserver_*/client_running/logged_on/local_userid/local_username/username_by_id/overlay_*).
- Lobby object model: `ScriptSteamLobby` (id, key_value, member_limit, num_members, on_lobby_data_update, owned), `ScriptSteamLobbyBrowser` (lobbies, cancel, filters), `ScriptSteamLobbyHandler` (get/set/delete lobby data, member list), async handlers on LobbyCreated_t / LobbyEnter_t.
- Invites: GameLobbyJoinRequested_t → `on_join_request`; `ScriptSteamUser::invite` → InviteUserToLobby; members `joinable`, `join_by`.
- Dedicated-server browser: `ScriptGSBrowser` (ISteamMatchmakingServerListResponse) + `ScriptGSQuery` (ping/players/rules) — the Lead and Gold server-browser path.
- Full lobby API imports: CreateLobby, JoinLobby, LeaveLobby, RequestLobbyList + 6 list filters, Get/SetLobbyData, Get/SetLobbyGameServer, SetLobbyJoinable, GetLobbyOwner, member enumeration, InviteUserToLobby.

## What does NOT exist (important negatives)

- No GameState/GameMode/GameSession engine classes — all in Lua/data.
- No rich presence, no engine NAT-punchthrough (Steam handles it), no Valve-style snapshot delta compression.
- No engine Join/Host menu classes — the menu flow is Lua (NetworkSystemLinkRDV.luc and menu scripts in boot.fcl, to be recovered in the toolchain phase).
