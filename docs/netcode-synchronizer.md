# Synchronizer — Unit/Body/Table Replication (send + receive)

The `Synchronizer` (AutoCreatedSingleton) is the unit/body replication engine.
It owns `_unit_map` (unit_id → Unit), `_owned_client_units` (units this client
controls), `_client_owner` (unit → owning client), `_table_version`, and
per-connection round-robin cursors.

## Classification (field at Unit base +400 = `_sync.type`, values 2–5)

In `send_server_unit_synchronization` every live unit is sorted into three
buckets by type + flags:

| Bucket       | criteria (type / flag)                        | packet         |
|--------------|-----------------------------------------------|----------------|
| `sync_bodies`| type==2, or (type==3 && flag@+0x118 && field==2) | BodyPacket     |
| `sync_units` | type==4/5 (or type==3 without body flag)       | UnitPacket     |
| `sync_tables`| unit's `sync.tables` map non-empty (versioned)  | ServerTablePacket |

## Server → client — `send_server_unit_synchronization` (0x00604ec0, 1739 B)

```
for each unit in _unit_map: classify -> sync_bodies / sync_units / sync_tables

# bodies: round-robin under a per-connection byte budget
i = 0
while i < sync_bodies.size:
    idx = conn._next_sync_body % sync_bodies.size; conn._next_sync_body++
    add_bodies_synchronization(conn, sync_bodies[idx], out, bytes_used)
    i++
    if bytes_used >= conn._traffic_shaper.max_body_bytes: break
Connection::add_packets(conn, bodies)      # one datagram of body snapshots

# units: all, every frame
for unit in sync_units: add_unit_synchronization(conn, unit, out1, out2)
add_packet for each of out1, out2

# tables: versioned delta, owner-gated
for unit in sync_tables:
    for (table_name) in unit.sync.tables:
        pkt = new ServerTablePacket(unit, table_name, _table_version)
        pkt.generate() -> buffer (<= 3000 B)
        if _client_owner[unit] != conn.peer   (only the owning client)
           and needs_to_send(pkt, conn):       # version changed since last sent
            add_packet(conn, pkt)
```

**Body pacing** is the key design: bodies (vehicles/shell/husks with physics)
are expensive, so only a rotating subset is snapshotted per frame per peer,
bounded by `_traffic_shaper.max_body_bytes`. Regular units go every frame.
Tables (script/property state) are **delta-synced by version** and only to the
client that owns the unit.

## Client → server — `send_client_unit_synchronization` (0x00605600, 939 B)

Runs only when `_client_server_state==2` (server role) and the peer is `self`
(i.e. the client sending to its own server). Iterates `_owned_client_units`:

```
for unit in _owned_client_units:
    if unit._parent == null:
        if unit._driving == 2:        # client is driving a body/vehicle
            add_bodies_synchronization(conn, unit, out_bodies)
        else:
            add_unit_synchronization(conn, unit, out_units, out_extra)
    for (table_name) in unit.sync.tables:
        pkt = new ClientTablePacket(unit, table_name, _table_version)
        pkt.generate() -> buffer (<= 3000 B)
        if needs_to_send(pkt, conn): add_packet(conn, pkt)
add_packets(conn, out_bodies); add_packets(conn, out_units); add_packets(conn, out_extra)
```

This is **client prediction / client-authoritative control**: the player's own
unit (and the body it is driving) is snapshot by the client and sent up; the
server relays/authoritatively integrates. Non-owned units are not sent up.

## Receive — `Synchronizer::receive` (0x005de550, 1376 B) — dead reckoning

(See netcode-pipeline.md §5.) `BodyPacket._unit_data[]` carries per-body
position/quaternion/velocity/angular_velocity. Client integrates forward to
current game time:
```
axis = normalize(angular_velocity); angle = |angular_velocity|
quat = rotation * GQuat.Rotate(axis, angle)
Body::synchronize(body, pos, quat, velocity, angular_velocity, game_time, peer)
```
Staleness: skip if bundle-id delta > 9999 and age < 300 ms.

## Delta-state summary

- **Units (type 4/5):** full snapshot every frame, both directions.
- **Bodies (type 2/3):** round-robin subset per frame, byte-budgeted
  (`max_body_bytes`); velocity+angular-velocity dead reckoning on receive.
- **Tables:** versioned (`_table_version`), delta-only (`needs_to_send`),
  owner-gated, ≤3000 B per table payload.
- **Reliability:** bodies/units ride the reliable/ordered transport (per the
  `BodyPacket`/`UnitPacket` `reliability_class`); tables are versioned so a
  lost table is re-sent on the next version bump.

## Ownership model

- `_client_owner`: unit → client SteamID (who may receive its tables / control it).
- `_owned_client_units`: the set of units this peer controls (sent up).
- `Network::take_ownership / resign_ownership / owner` (Lua: `take_ownership`,
  `resign_ownership`, `owner`) drive this at the script layer.
