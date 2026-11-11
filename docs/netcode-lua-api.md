# Lua `network` Table API (Network::add_members, 0x00607140, 2552 B)

The complete set of C++ methods exposed to Lua scripts on the `network`
object. Bound via `lua_pushcclosure` + `lua_setfield(L, -2, "<name>")`.
57 entries. This is the script-facing surface — everything else in the C++
`Network` class is internal.

| # | Lua name |
|---|----------|
| 1  | bind |
| 2  | unbind |
| 3  | set_receiver |
| 4  | set_client_send_callback |
| 5  | handshake |
| 6  | reset_connection |
| 7  | hostname |
| 8  | get_interfaces |
| 9  | send_debug_string |
| 10 | broadcast |
| 11 | set_disconnected |
| 12 | set_server |
| 13 | set_client |
| 14 | is_disconnected |
| 15 | is_server |
| 16 | is_client |
| 17 | multiplayer |
| 18 | set_multiplayer |
| 19 | add_client |
| 20 | add_ping_client |
| 21 | add_fake_clients |
| 22 | remove_client |
| 23 | cancel_authentication_session |
| 24 | set_server_kbps |
| 25 | set_uplink_kbps |
| 26 | drop_in |
| 27 | clients |
| 28 | server |
| 29 | self |
| 30 | all |
| 31 | clients_except |
| 32 | all_except |
| 33 | set_server_is_playing |
| 34 | playing |
| 35 | set_client_position |
| 36 | clients_within_distance |
| 37 | spawn_unit_on_client |
| 38 | detach_unit |
| 39 | owner |
| 40 | take_ownership |
| 41 | resign_ownership |
| 42 | set_timeout |
| 43 | timeout |
| 44 | qos |
| 45 | set_throttling_disabled |
| 46 | reset_all_timeouts |
| 47 | time_since_position_ack |
| 48 | download |
| 49 | download_status |
| 50 | remove_download |
| 51 | download_read_bytes |
| 52 | using_steam |
| 53 | authentication_session_start |
| 54 | dummy |
| 55 | register_ping_watch |
| 56 | get_pings |
| 57 | connection_details |

## Grouping

- **Lifecycle / role:** set_disconnected, set_server, set_client, is_server,
  is_client, is_disconnected, multiplayer, set_multiplayer, drop_in,
  reset_connection, using_steam, dummy
- **Client management:** add_client, add_ping_client, add_fake_clients,
  remove_client, clients, server, self, all, clients_except, all_except,
  set_client_position, clients_within_distance
- **Replication control:** spawn_unit_on_client, detach_unit, owner,
  take_ownership, resign_ownership, set_server_is_playing, playing
- **QoS / throttling:** set_server_kbps, set_uplink_kbps, qos,
  set_throttling_disabled, set_timeout, timeout, reset_all_timeouts,
  time_since_position_ack
- **Transport:** bind, unbind, broadcast, handshake, get_interfaces,
  hostname, connection_details, send_debug_string
- **RPC wiring:** set_receiver, set_client_send_callback
- **Authentication:** authentication_session_start, cancel_authentication_session
- **Download (save-game segment transfer):** download, download_status,
  remove_download, download_read_bytes
- **Pings:** register_ping_watch, get_pings

Note: the C++ `Network` class has methods **not** on the Lua table (internal
only): update, receive_data, update_hello, handle_bad_addresses,
send_interceptor_messages, send_shaped_data, load_settings,
load_save_game_segment, packet_interceptor, bind/unbind internals, the
`_client_send_callback` plumbing. The Lua table is the curated public API.
