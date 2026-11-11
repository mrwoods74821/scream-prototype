# Scream Prototype Netcode Audit

Binary: `game/scream_win32_public_dev.exe` (x86-32, base 0x00400000, 8.5 MB)
Companion symbols: `scream_win32_public_dev.pdb` (60.6 MB, full demangling).
Tooling: Ghidra 12.1.4, project `/home/elijah/ghidra_projects/scream_netcode`,
ghidra-mcp on 127.0.0.1:8089. Decompile date 2026-09-27.
Supporting docs in this directory: `netcode-function-inventory.md`,
`packet-type-enum.md`, `netcode-pipeline.md`, `netcode-rpc.md`,
`netcode-lua-api.md`, `netcode-synchronizer.md`.

## Architecture (verified)

```
                        ┌────────────────────────────── per frame ─────────────────────────────┐
 Lua script layer       │  NetworkManager (lua)          Synchronizer (C++ singleton)          │
 ───────────────────────┼──────────────────────────────┼───────────────────────────────────────┤
 set_client_send_cb ────┼─► _flush_all_unit_rpcs()     │ send_server_unit_synchronization()     │
 (per frame, server)    │    rpc_caller["name"](unit,  │   bodies: round-robin, byte-budgeted  │
 set_receiver(name,cb) ─┼─► named receiver tables      │   units: every frame                  │
 (action/gametype/...)  │                              │   tables: versioned delta, owner-gate │
 RPCCaller.__index ─────┼─► lua_rpc_index: name→id    │ send_client_unit_synchronization()     │
 (name→message_id)      │                              │   (client prediction, own units only) │
                        └──────────────┬───────────────┴──────────────────┬────────────────────┘
                                       │ RPCCaller::rpc_method_call       │ Connection::add_packet(s)
                                       │  RPCParentPacket (hash,id,params)│
                        ┌──────────────▼──────────────────────────────────▼────────────────────┐
                        │ Connection (per peer, 0xac): 4 senders (handshake/unreliable/        │
                        │  reliable/ordered, unacked-ID retransmit), 3 receivers (unreliable/ │
                        │  reliable w/ Seen dedup / ordered w/ seqno reorder), QoS monitor    │
                        │  (send window, throttling, kbps), _can_receive_ordered              │
                        └──────────────┬───────────────────────────────────────────────────────┘
                                       │  bundle = 1 UDP datagram:
                                       │  u16 bundle_id, N×[u8 reliable,u8 type,u16 id,payload]
                        ┌──────────────▼───────────────────────────────────────────────────────┐
                        │ Steam P2P UDP (steam_api.dll)  +  broadcast socket                   │
                        │  PingHandler (listening/socket/send/cleanup)  +  auth session        │
                        └───────────────────────────────────────────────────────────────────────┘
```

## Numbers (all verified against decompilation)

| item | value | source |
|---|---|---|
| netcode classes | 14 | namespace walk (inventory doc) |
| netcode functions | 187 | namespace walk |
| `Network` Lua-bound methods | 57 | `add_members` @ 0x607140 |
| `RPCCaller` Lua-bound methods | 10 + `__index` | `add_members` @ 0x6087e0 |
| packet types on wire | **29** (0x00–0x1c) | `make_packet` @ 0x5fc480 |
| RPC messages declared | 287 (275 data + 12 core XML) | `network.xml` ×2 |
| RPC message ID space | u8 (≤ 255 usable) | `rpc_method_call` assert |
| RPC tables (table-schema) | 5 | `network.xml` |
| RPC param types | 15 (int, unit, string, bool, vector3, float, xuid, body, rotation, table, cue, xnaddr, xsessioninfo, object3d, longstring) | `network.xml` |
| delivery distribution | 208 ordered / 17 reliable / 62 unreliable | `network.xml` |
| unit-sync classification | type 2/3 → bodies, 4/5 → units (field @Unit+400) | `send_server_unit_synchronization` |
| body budget | `Connection::_traffic_shaper.max_body_bytes` per frame per peer | same |
| table delta | `_table_version` + `needs_to_send`, ≤ 3000 B, owner-gated | same / `send_client_unit_synchronization` |
| body dead-reckoning | pos + velocity, quat × GQuat.Rotate(axis=normalize(angvel), angle=|angvel|) | `Synchronizer::receive` @ 0x5de550 |
| staleness gate | bundle-id delta > 9999 && age < 300 ms → skip | same |
| RPC wire format | [u32 hash if send_hash] u8 message_id, typed params | `generate`/`extract` |
| self-port bypass for direction checks | peer.port == 0x4d (77) | `RPCReceiver::receive` |
| max concurrent connections | 50 (stalest evicted at 51) | `handle_bad_addresses` @ 0x5feea0 |
| hello heartbeat | 0.5 s; drop on `last_hello > _timeout_if_no_hello_for` | `update_hello` @ 0x5fbc70 |

## Corrections to earlier assumptions

1. **Packet types are 29, not 31.** `make_packet` switches on 0x00–0x1c
   inclusive (29 distinct values); everything else returns null and logs
   `[PacketFactory] Cannot make packets of type <n>`.
2. **`Context.network.send_hash` gates a payload hash, not the type byte.**
   In `generate`/`extract` it conditionally writes/reads a u32 `_rpc_hash`
   at the head of the RPC payload — a registry-version checksum. The RPC wire
   *type* bytes are the constant 0x1a/0x1b/0x1c: `Connection::receive` passes
   the raw type byte straight to `make_packet`, whose switch only handles
   0x00–0x1c, and working multiplayer proves RPC packets do resolve. The
   earlier "renumbers to 0x68/0x69/0x6a" observation (prior session) is
   therefore not a make_packet-level phenomenon; if it is real it lives in
   some other packet-id space (unconfirmed).
3. **The registry cap is not hit in practice.** The loaded registry is a
   single file: `context.xml` sets `<network settings="/data/settings/network.xml" />`
   (`data/settings/network.xml` = 275 messages; `core/settings/network.xml`
   = 12 more is *not* on this path). `lua_rpc_index` assigns IDs by
   declaration order; `rpc_method_call` asserts `index <= 255`. So messages
   256–275 are unreachable from Lua — and verified by inspection, all 20 are
   editor-only: `enveditor_*` (env editor tools), `run_simulation`,
   `position_camera`, `load_world`, `bwc_*` (benchmark watch),
   `set_working_unit`, and the `*_unitsm` simulation tools. Nothing in the
   shipped MP set (gametypes, units, lobby) lands past the cap.
   (The `Network._hash` version checksum is the MD5 of the *whole parsed
   XML document* — root tag, all attributes, all children, names and values —
   computed in `load_settings` and logged as `[Network] Hash <u32>`; it is
   not a hash of just the `<rpc>` section.)

## Design observations

- **Three independent reliability channels** on one datagram framing:
  unreliable (fire-and-forget, ID-acked), reliable (Seen-set dedup,
  retransmit by sender until acked), ordered (seqno reorder buffer,
  `deliver_delayed` at datagram end). QoS gates *all* sends on a per-peer
  send window (`_unacknowledged.size < _send_window`, or
  `_throttling_disabled`), with `set_server_kbps`/`set_uplink_kbps` setting
  the budget and `set_throttling_disabled` removing it.
- **Replication is server-authoritative with client prediction**: the server
  snapshots all units every frame and bodies round-robin under a byte
  budget; the client's own units (and the body it drives, `_driving == 2`)
  are additionally snapshotted client→server. Tables (script state) are
  versioned deltas sent only to the owning client.
- **RPC is a thin name→(id, delivery, check, receiver, typed params)
  registry loaded from XML**, with the Lua layer supplying both the call
  sites (`rpc_caller[name](...)` via `__index`) and the receiver tables
  (`set_receiver`). The C++ dispatch validates direction (`_check`
  client-to-server / server-to-client), buffers reliable/ordered messages
  when no default receiver exists yet (drained in `Network::update`), and
  calls the named Lua method with a reply `RPCCaller` as arg 1.
- **Steam P2P underneath**: `steam_api.dll` (Goldberg v5 in this build)
  provides the UDP transport; the engine adds its own bundle framing,
  handshake, QoS, and an `AuthSessionPacket` (0x418) path on top.
  `using_steam()` exposes the backend choice to Lua.

## Open items (if continued)

Resolved 2026-09-27: the registry load path.
`app_run (0x92a860) → Network::init (0x54cb10) → load_settings (0x604410)`,
which parses the file named by `context.xml`
(`<network settings="/data/settings/network.xml" />`, 275 messages) and
computes `Network._hash = MD5(entire document)`. `core/settings/network.xml`
(12 messages, env editor) is not loaded on this path; all 20 messages past
the 255 cap are editor-only, so the cap is benign for shipped MP.

Resolved 2026-09-27 (round 2):
- `RPCParam::pack` (0x5f4d60) — full per-type bit layout (see `netcode-rpc.md`);
  named-reference types travel as shared-registry indices; XUID/XNADDR/
  XSessionInfo throw on non-xbox.
- `update_hello` (0x5fbc70) — 0.5 s heartbeat. In a session
  (`_client_server_state != 0`) the client sends `IAmClientPacket`; the server
  sends `IAmServerPacket` (or `IAmServerPacketPing` under `ping_only`) to each
  client. Then any peer whose `last_hello` exceeds `_timeout_if_no_hello_for`
  is dropped (enforced only after `_timeout_set_time` arms the timer).
- `handle_bad_addresses` (0x5feea0, called from `update` @ 0x60a520) —
  phase 1 drains `PacketInterceptor` bad-socket lists on `_socket` and
  `_broadcast_socket` (logs "[Network] Connection lost: socket <addr> reported
  as bad"); phase 2 collects every `Connection::bad()` peer; phase 3, while the
  connection map has >= 51 entries, evicts the **stalest** peer (max
  `wall_running - last_activity`, ping-only and real clients tracked
  separately; logs "[Network] Connection lost -- too many connections").
  Collected connections all flow through `lost_connection`. Hard cap: 50.
- `Connection::bad` (0x5ed1a0) — timeout detector: wall clock vs the
  last-activity/timeout fields; queries the senders for a bad state;
  short-circuits "not bad" while `_can_send_ordered` is set.

Resolved 2026-09-27 (round 3 — audit complete):
- `Network::handshake` (0x5ed370) — parses `"address[:port]"` (Lua int arg
  overrides the port), resolves the name via `UDPSocket::make_address` to a
  SteamID address, binds `_socket` to `port` and `_broadcast_socket` to
  `port+1` (the source of the sequential ephemeral ports at runtime), and
  returns a new `RPCCaller` (0x4c) for that peer. The ordered-transport
  negotiation is a packet, not a handshake flag: see below.
- `Connection::send_one_bundle` (0x5f4180) — increments the u16 `_bundle_id`
  (skipping IDs claimed by `PacketInterceptor`s), writes the `u16 bundle_id`
  header, injects `WantsToSendOrderedPacket` into the handshake channel while
  `_can_send_ordered` is unset (peer port != 0x4d), then packs all four
  sender queues (handshake/unreliable/reliable/ordered) into one ≤ 1200-byte
  buffer (0x4b0) and transmits it as a single datagram — the exact mirror of
  `Connection::receive`'s frame. Details in `netcode-pipeline.md` §§6-7.

Remaining (runtime-only; needs two machines, so out of scope for the docs):
- Confirm Goldberg v5's `SteamNetworkingSockets_*` coverage end-to-end
  across two real machines (the Phase-3 test from the multiplayer plan).
  Everything up to the wire is now documented; this is the last unverified
  link and it is a test, not an analysis.
