# Netcode Function Inventory (scream_win32_public_dev.exe)

Authoritative list of netcode methods resolved via PDB namespace demangling
(Ghidra 12.1.4, project `scream_netcode`). Function entry points are x86 32-bit
RVA (base 0x00400000). Sizes in bytes.

Resolved 2026-09-27 by walking the FunctionManager namespace tree and matching
parent-namespace names to the 14 netcode classes. The `__unwindfunclet$` symbols
carry the raw MSVC mangled name (`?method@Class@@sig`); the real function symbols
are demangled to bare method names under each class's namespace, which is the
join used here.

## Class map (14 classes, 187 functions)

- **Network** — top-level manager (Singleton). ~75 methods.
- **Synchronizer** — unit/body replication. ~35 methods.
- **Connection** — per-peer transport framing, bundle + QoS. ~20 methods.
- **ReliablePacketSender / ReliablePacketReceiver** — ACK/retransmit state.
- **OrderedPacketReceiver** — sequence-number reordering buffer.
- **PacketFactory** — `make_packet` dispatch (31 packet types).
- **RPCCaller / RPCReceiver / RPCParentPacket / RPCOrderedPacket** — RPC layer.
- **NetworkInfo / NetworkAPIScope** — introspection + scope guard.

## Network (manager) — entry points

| RVA     | size | method                          |
|---------|------|---------------------------------|
| 0060a520 | 1713 | update                          |
| 00604bd0 |  749 | receive_data                    |
| 005ed370 |  587 | handshake                       |
| 005ed5c0 |  307 | broadcast                       |
| 005ff9a0 |  607 | drop_in                         |
| 00604410 | 1970 | load_settings                   |
| 005fc150 |  803 | load_save_game_segment          |
| 005ffd20 |  198 | authentication_session_start    |
| 005fb970 |  391 | authentication_session_notification |
| 005ed9d0 |  226 | cancel_authentication_session   |
| 005fb640 |  631 | lost_connection                 |
| 005fbc70 | 1234 | update_hello                    |
| 005feea0 | 2182 | handle_bad_addresses            |
| 005f4990 |  473 | connection_details              |
| 005fb3e0 |  337 | get_interfaces                  |
| 005e8050 |  125 | hostname                        |
| 005ff740 |  600 | add_fake_clients                |
| 005f8e80 |  578 | add_client                      |
| 00602c90 |  330 | set_client                      |
| 005ed810 |  434 | remove_client                   |
| 005ddb30 |  398 | clients                         |
| 005ee0d0 |  460 | clients_within_distance         |
| 005eddb0 |  400 | playing                         |
| 005ee2a0 |  190 | owner                           |
| 005ee360 |  128 | take_ownership                  |
| 005ee3e0 |  121 | resign_ownership                |
| 005f9300 |   84 | qos                             |
| 005f9360 |  142 | set_throttling_disabled         |
| 005f8c20 |  181 | bind                            |
| 005f8ce0 |  167 | unbind                          |
| 005f8d90 |  119 | set_client_send_callback        |
| 005f8e10 |  107 | connection                      |
| 005f90d0 |  141 | set_timeout                     |
| 005f9160 |  412 | timeout                         |
| 005dce60 |  114 | reset_all_timeouts              |
| 005e8310 |  139 | register_ping_watch             |
| 005f4d40 |   28 | get_pings                       |
| 005fb8d0 |  149 | send_shaped_data                |
| 005fbb00 |  160 | send_to_clients                 |
| 005fbba0 |  203 | send_to_clients_except          |
| 005fb550 |  235 | send_debug_string               |
| 005ed700 |  268 | send_interceptor_messages       |
| 005d58c0 |   60 | packet_interceptor              |
| 005e7f90 |  182 | reset_connection                |
| 00607080 |  179 | set_receiver                    |
| 005f4900 |  133 | detach_unit                     |
| 005ffc00 |  283 | spawn_unit_on_client            |
| 005edf40 |  400 | set_client_position             |
| 005fad.. |      | (see full dump)                 |

## Synchronizer (unit/body replication) — entry points

| RVA     | size | method                          |
|---------|------|---------------------------------|
| 005de550 | 1376 | receive (main dispatch)         |
| 005f97e0 |  874 | add_unit_synchronization        |
| 00603030 | 1271 | add_bodies_synchronization      |
| 00604ec0 | 1739 | send_server_unit_synchronization|
| 00605600 |  939 | send_client_unit_synchronization|
| 005fcc20 |  780 | request_create_unit             |
| 005fcf30 |  599 | create_unit_on_client           |
| 005fd190 |  348 | request_delete_unit             |
| 005fd2f0 |  738 | drop_in                         |
| 005f02c0 |  337 | next_unit_id                    |
| 005ddf10 |  111 | unit_for_id                     |
| 005de4c0 |  137 | unit_for_unassigned_client_id   |
| 005dcee0 |  152 | unassigned_client_id            |
| 005dcf80 |  158 | update_synced_units             |
| 005deab0 |  193 | needs_to_send                   |
| 005f6940 |  247 | needs_to_send (overload)        |
| 005de420 |  154 | update_receive                  |
| 005d6310 |  154 | time_since_position_ack         |
| 005e86d0 |  202 | client_load_spawn               |
| 005f01d0 |   31 | remote_unspawn                  |
| 005efc70 |  415 | delete_all_units                |
| 005efe10 |  811 | delete_unit_data                |
| 005e8dd0 |  138 | owner                           |
| 005e8d10 |  191 | acked                           |
| 005f01f0 |  200 | acked (overload)                |
| 005e8600 |  199 | receive (overload)              |
| 005e87a0 |  149 | receive (overload)              |
| 005e8840 |  132 | receive (overload)              |
| 005e88d0 |  556 | receive (overload)              |
| 005e8b00 |  525 | receive (overload)              |
| 005f68b0 |  136 | receive (overload)              |
| 005f0140 |  134 | receive (overload)              |
| 005fd5e0 |  500 | receive (overload)              |
| 005e84e0 |  275 | Synchronizer (ctor)             |
| 0051c670 |  167 | ~Synchronizer                   |

## Connection (per-peer transport) — entry points

| RVA     | size | method                          |
|---------|------|---------------------------------|
| 00603e30 | 1503 | receive (frame parse)           |
| 005fabb0 |  703 | add_packet                      |
| 005fb160 |   67 | add_packets                     |
| 005f4180 |  959 | send_one_bundle                 |
| 005fb1b0 |  528 | begin_send_frame                |
| 005f8790 |  633 | Connection (ctor)               |
| 005e3590 |  215 | ~Connection                     |
| 005f8a50 |  378 | qos                             |
| 005f8a10 |   49 | send_unreliable_data            |
| 005d5c10 |   36 | can_send                        |
| 005d59c0 |  221 | set_timeout_if_no_hello_for     |
| 005ed1a0 |  441 | bad                             |
| 005fae70 |  721 | received_cannot_receive_ordered |
| 005ed090 |  259 | received_wants_to_send_ordered  |
| 005ddef0 |   31 | name                            |

## RPC layer — entry points

| RVA     | size | method                          |
|---------|------|---------------------------------|
| 006082a0 |  830 | RPCCaller::rpc_method_call      |
| 006087e0 |  699 | RPCCaller::add_members          |
| 005e83a0 |  313 | RPCCaller::add_peers_in_caller  |
| 005de1f0 |  314 | RPCCaller::remove_peers_in_caller |
| 005e7f00 |  131 | RPCCaller::script_peer_at_index |
| 005de150 |   79 | RPCCaller::peer_ip_at_index     |
| 005de1a0 |   79 | RPCCaller::peer_name_at_index   |
| 005f9790 |   73 | RPCCaller::ping_at_index        |
| 005d5c80 |   23 | RPCCaller::num_peers            |
| 005e0880 |  423 | RPCCaller::to_string            |
| 005e5320 |  225 | RPCCaller (ctor)                |
| 005e7e00 |  242 | RPCCaller (ctor overload)       |
| 00609d10 | 1104 | RPCReceiver::receive            |
| 0060a3f0 |  297 | RPCReceiver::process_queue      |
| 00602ab0 |  141 | RPCReceiver (ctor)              |
| 0060a160 |  655 | RPCParentPacket::receive        |
| 005efa10 |  498 | RPCParentPacket::extract        |
| 005f6040 |  386 | RPCParentPacket::generate       |
| 005f6010 |   46 | RPCParentPacket::write_to_stream|
| 005f5f50 |  146 | RPCParentPacket (ctor)          |
| 00608150 |  206 | RPCParentPacket (ctor overload) |
| 005f8bf0 |   18 | RPCOrderedPacket (ctor)         |
| 005f8c10 |    6 | RPCOrderedPacket::type          |

## Reliability / ordering
| RVA     | size | method                          |
|---------|------|---------------------------------|
| 00606a70 |  769 | ReliablePacketSender::gather_resend_packets |
| 00606d90 |  646 | ReliablePacketSender::send_packets |
| 005ecb40 |  267 | ReliablePacketSender::new_frame |
| 005daac0 |  221 | ReliablePacketSender::bad       |
| 005d5bd0 |   32 | ReliablePacketReceiver::receive |
| 005f8590 |  497 | OrderedPacketReceiver::deliver_delayed |
| 005ed040 |   79 | OrderedPacketReceiver::receive  |
| 00603d50 |  209 | OrderedPacketReceiver::set_seqno|

## Packet factory
| RVA     | size | method                          |
|---------|------|---------------------------------|
| 005fc480 | 1808 | PacketFactory::make_packet (31-type dispatch) |

## Introspection
| RVA     | size | method                          |
|---------|------|---------------------------------|
| 007b9d30 |  318 | NetworkInfo (ctor)              |
| 007b9e70 |  524 | NetworkInfo::get_wireless_signalstrength |
| 00882fb0 |  350 | NetworkAPIScope (ctor)          |
| 008733b0 |   47 | NetworkAPIScope (dtor)          |

## Notes
- `Network` methods `all`, `all_except`, `server`, `self`, `dummy`, `simulate`,
  `is_client`, `is_server`, `is_my_server`, `is_my_client`, `is_disconnected`,
  `multiplayer`, `set_multiplayer`, `set_client_server_state`, `set_server`,
  `set_disconnected`, `download_status`, `find_client`, `get_pings`, `bind`,
  `unbind`, `push_var`, `add_members` are present and resolved; full 187-line
  dump captured in the run log of 2026-09-27 15:09 MDT.
- `Network::add_members` (00607140, size 2552) is the largest Network method —
  likely the Lua-binding registration (maps C++ methods onto the `network`
  table for scripts). Cross-check with decompiled Lua before finalizing.
- Next: decompile `update` (0060a520), `receive_data` (00604bd0),
  `make_packet` (005fc480), `Synchronizer::receive` (005de550),
  `Connection::receive` (00603e30) to map the live pipeline.
