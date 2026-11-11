# Scream Prototype — Netcode Pipeline (reverse-engineered)

Binary: `game/scream_win32_public_dev.exe` (x86-32, base 0x00400000)
Ghidra 12.1.4 project `scream_netcode`, PDB-loaded. All addresses are RVAs.
Decompiled 2026-09-27 via ghidra-mcp. Names demangled from PDB.

## 1. Transport model

Steam P2P UDP. Two sockets: `_socket` (unicast) + `_broadcast_socket`.
Each socket has a `_send_buffer` / `_receive_buffer` of `SocketItem{ address
(SteamID+port), data (SocketData) }`. A **bundle** = one UDP datagram that
carries a sequence of sub-packets; it has a `bundle_id` (u16).

Per-connection (`Connection`, 0xac) objects:
- `_peer` (SocketAddress: SteamID + port)
- `_quality_of_service_monitor` (QoS: `_unacknowledged` list, `_send_window`,
  `_throttling_disabled`, up/down byte `Snapshot`s)
- Four **senders**: `_handshake_sender`, `_unreliable_sender`, `_reliable_sender`,
  `_ordered_sender` — each tracks unacked packet IDs and retransmits.
- Three **receivers**: `_unreliable_receiver`, `_reliable_receiver`
  (with a `Seen` dedup set), `_ordered_receiver` (reorder buffer)
- `_can_receive_ordered` (negotiated flag)
- `_last_data_at`, `_delete_next_frame` (via Network)

## 2. Per-frame tick — `Network::update` (0x0060a520, 1713 B)

```
if pinghandler._active:
    PingHandler::process_listening_socket / process_socket / send_packets / cleanup_connections
delete_all(_delete_next_frame)                       # deferred connection removal
if _clear_socket_buffers: flush _socket + _broadcast_socket send/recv buffers
if _client_server_state == 0: return                 # not in client/server
RPCReceiver::process_queue(_rpc_receiver)            # drain queued RPCs
UDPSocket::send(_socket); UDPSocket::receive(_socket)
if _broadcast_socket: UDPSocket::update(_broadcast_socket)
update_hello(this)                                   # handshake/keepalive
receive_data(this)                                   # inbound -> Connection::receive
handle_bad_addresses(this)
if Synchronizer==null: Synchronizer::Synchronizer(...)
Synchronizer::update_receive(synchronizer)           # drain received replication
bVar12 = not(paused) and _synchronized and _client_server_state!=0
send_interceptor_messages(this)
# Fisher-Yates shuffle of _connections (randomize peer send order)
for each conn (shuffled):
    QoS::update(conn._quality_of_service_monitor)
    if throttling_disabled or |unacknowledged| < send_window:
        if bVar12:
            if is_my_client(conn):
                if _client_send_callback set: call Lua cb(conn RPCCaller)
                Synchronizer::send_server_unit_synchronization(conn)
            if _client_server_state==2 and server==conn.peer:
                Synchronizer::send_client_unit_synchronization(conn)
        send_shaped_data(this, conn)                 # flush QoS-shaped packets
UDPSocket::send(_socket); UDPSocket::receive(_socket)   # second pass
if _broadcast_socket: send/receive
if NetworkStats==null: NetworkStats(...)
```

## 3. Inbound — `Network::receive_data` (0x00604bd0, 749 B)

```
for socket in [_socket, _broadcast_socket]:
  while socket._receive_buffer non-empty:
    item = pop front
    (steam_id, port) = item.address
    run each _packet_interceptors[i](data, size, address)  # virtual; can consume
    conn = _connections[address]
    if conn == null: conn = new Connection(address)          # auto-create, 0xac
    Connection::receive(conn, item.data)
    socket.pop_received()
```

## 4. Datagram frame parse — `Connection::receive` (0x00603e30, 1503 B)

```
last_data_at = TimerManager.wall_running.time
QoS down_bytes.snapshot(size + 0x1c)              # datagram size + 28 B header
packer = BytePacker(data)
bundle_id = packer.read_u16()
ack_flag = 0; cannot_ordered_flag = 0
loop while bytes remain:
  reliable = packer.read_u8() != 0
  type     = packer.read_u8()
  pkt = PacketFactory::make_packet(type)
  if pkt == null: log "[Connection] Failed to make packet <type> in datagram <hex> sent from <addr>"; break
  pkt.unpack(packer, this)                         # vtable +0x0c
  tx = new TransmissionPacket{ pkt, bundle_id, RECEIVED }
  if not reliable:
      id = pkt->id
      handshake_sender.advance(id); unreliable_sender.advance(id)
      reliable_sender.advance(id); ordered_sender.advance(id)
      QoS.acknowledged(id)
  if reliable:
      seen = reliable_receiver.seen
      seen.advance_to(id); was_dup = seen.has(id); seen.add(id)
  if reliable:
      ordered_receiver.set_seqno(pkt->id)
  cls = pkt.reliability_class()                    # vtable +0x10
  if cls == 0:  unreliable_receiver.receive(tx, this)
  elif cls == 1: if can_receive_ordered: reliable_receiver.receive(tx, this) else cannot_ordered_flag=1
  elif cls == 2: if can_receive_ordered: ordered_receiver.receive(tx, this) else cannot_ordered_flag=1
  if pkt.needs_ack(): ack_flag = 1
end loop
ordered_receiver.deliver_delayed(this)
if ack_flag:         add_packet(AcknowledgePacket{ bundle_id })
if cannot_ordered_flag: log "[Network] Queueing (CannotReceiveOrdered) <addr>"; add_packet(CannotReceiveOrderedPacket)
```

**Wire format (authoritative):**
```
| u16 bundle_id | N × [ u8 reliable | u8 type | u16 id | <type payload> ] |
```
- `type` = one of the 29 `W4PacketType` values (see packet-type-enum.md, 0x00–0x1c).
- `id` = per-packet sequence number (u16) used by the senders/receivers for
  ack, dedup, and ordering.
- Reliability is carried **both** by the leading `reliable` byte and by the
  packet's own `reliability_class()`; the receiver routes on `reliability_class()`.
- Unreliable → delivered out-of-order immediately, ID acked in all senders.
- Reliable → deduped via `Seen` set (retransmitted IDs dropped), then delivered.
- Ordered → rebuffered by seqno, `deliver_delayed` flushes at end of datagram.

## 5. Unit/body replication — `Synchronizer::receive` (0x005de550, 1376 B)

Handles `BodyPacket` (the largest per-frame payload). `BodyPacket._unit_data`
is an array of `UnitDatum` (0x1c = 28 B each); each `UnitDatum` has `unit_id`
(u16) + a `body_data` array of `BodyDatum` (0x38 = 56 B each).

`BodyDatum` fields read: `body_id`, `position (Vector3)`, `rotation (GQuat)`,
`velocity (Vector3)`, `angular_velocity (Vector3)`.

```
for each unit in packet._unit_data:
  unit = _unit_map[unit_id]
  for each body in unit.body_data:
    body = resolve Body from unit._actor (body_id)
    if body._motion_state == 1 (dynamic) and body._actor != null:
      # staleness gate
      dt_bundle = peer.bundle_id - body._sync.bundle_id  (mod 0x10000)
      if body._sync.t > 0 and dt_bundle > 9999:
          age = game_time - body._sync.t
          if age < 300.0ms: skip this body (stale)
      # dead-reckoning extrapolation
      pos   = bodyDatum.position
      axis  = normalize(bodyDatum.angular_velocity)
      angle = |bodyDatum.angular_velocity|
      qRot  = GQuat.Rotate(axis, angle)
      quat  = bodyDatum.rotation * qRot        # apply accumulated spin
      Body::synchronize(body, pos, quat, velocity, angular_velocity, game_time, peer)
      SceneModel::set_moving(body.scene_model, 1)
```

**Replication scheme = velocity-based dead reckoning.** The server sends a
snapshot (position, orientation, velocity, angular velocity) with a bundle-id +
timestamp; the client integrates forward (position from velocity, orientation
from angular velocity via quaternion rotation) to the current game time. This
is why `_sync.bundle_id` / `_sync.t` are kept on each `Body` — they mark the
last-applied snapshot so duplicate/stale packets are dropped.

`Body::synchronize` (the integrator) is in the physics layer
(`ps3_name_collision::Body` — the PDB names the collision/body namespace
`ps3_name_collision`, a build-time namespace remnant).

## 6. Handshake & address resolution — `Network::handshake` (0x005ed370, 567 B)

```
host = string before first ':'   (whole string if none)
port = atoi(string after ':')    (overridable by a Lua int arg)
addr = UDPSocket::make_address(host, port)      # name -> SteamID + port
if addr != nil:
    bind(_socket, port, exclusive)
    if _broadcast_socket: bind(_broadcast_socket, port + 1, exclusive)
    return new RPCCaller(this->_rpc, addr, true)   # 0x4c (76 B) outbound call handle
return null
```

This is the source of the sequential ephemeral ports observed at runtime
(47584/47585): the engine picks a base port, then binds the unicast and
broadcast sockets to `port` and `port+1`. The returned `RPCCaller` is the
peer handle the Lua layer uses to address that connection.

## 7. Send side — `Connection::send_one_bundle` (0x005f4180, 819 B)

Mirror of section 4:

```
bundle_id++                                   # u16, wraps at 0x10000
for each i in Network._packet_interceptors:
    if interceptors[i].id_begins_with(&bundle_id, 2): bundle_id++   # skip claimed IDs
buf = 1200-byte buffer (0x4b0)
write u16 bundle_id
if _can_send_ordered == false and peer.port != 0x4d:
    _handshake_sender.add(new WantsToSendOrderedPacket)   # ordered negotiation
for sender in [handshake, unreliable, reliable, ordered]:
    sender.drain into buf via TransmissionPackets::pack
concatenate the four packed ranges into one buffer
transmit the single UDP datagram (<= 0x4b0)
```

The four per-channel queues are packed into one 1200-byte buffer and go out
as a single datagram, exactly matching the receive-side frame
(`u16 bundle_id | N × [u8 reliable, u8 type, u16 id, payload]`). The
`WantsToSendOrderedPacket` injection is the client-side half of the
ordered-transport negotiation: until the peer grants it (or the peer is the
local 0x4d self-port), every bundle carries the request in the handshake
channel. (Note: the decompiler labels one of the four drain calls
`_voice_sender`; the structure shows the four sender queues, so treat the
label as a vtable-misread, not a fifth channel.)

## 8. Open / next

- `Synchronizer::send_server_unit_synchronization` (0x00604ec0) and
  `send_client_unit_synchronization` (0x00605600) — the send side of the same
  replication (which units/bodies get snapshot+sent, and on what cadence).
- Cross-check against decompiled Lua (lobby / `fs::Steam` layer).
