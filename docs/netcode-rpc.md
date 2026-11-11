# RPC System (scream_win32_public_dev.exe)

The RPC layer is a **registry-driven, Lua-dispatched** remote-call system.
Three pieces: the `RPC` message registry, `RPCCaller` (initiate), `RPCReceiver`
(dispatch), and `RPCParentPacket` (wire format). All names PDB-demangled.

## Registry — `RPC`

`RPC._messages[]` — array of `RPCMessage` (0x28 = 40 B each). Each entry:
- `_delivery` — UNRELIABLE / RELIABLE / ORDERED (maps to the three RPC packet types)
- `_check` — 0 = none, 1 = client→server only, 2 = server→client only
- `_receiver` — `idstring`, name of the Lua receiver table
- `_name` — the Lua method name within that table
- `_params[]` — array of `RPCParam` (0x84 = 132 B each): **typed param
  descriptors** that drive both `pack` and `unpack`. The wire layout of an RPC
  is defined entirely by the registered param types, not by the packet.

`RPCReceiver._receivers` — `map<idstring, LuaRef>`: named Lua tables that
implement RPC callbacks. Plus a `_default_receiver` LuaRef.

The registry is the join point: an RPC call carries only a `message_id` (u8)
over the wire; both ends look up the same `RPCMessage` to know delivery,
routing, receiver, and param types. This is why `_message_id` must be ≤ 0xff
(≤ 255 distinct RPC messages).

## Initiate — `RPCCaller::rpc_method_call(message_id, LuaArgs)` (0x006082a0, 830 B)

```
if message_id > 0xff: throw "Too many rpc messages index >= 0 && index <=255"
                      (network/rpc.cpp:0x30b)
msg = RPC._messages[message_id]
delivery = msg._delivery
pkt = new RPCParentPacket(message_id, args)   # 0x34
pkt.vtable = Unreliable | Reliable | Ordered   # by delivery
Packet::make_cache(pkt)                        # serialize once
for peer in caller._peers:
    conn = Network._connections[peer] or new Connection(peer)  # 0xac
    Connection::add_packet(conn, pkt)          # fan-out: same cached packet
```

An RPC call **fans out** to every peer in the caller's peer set using one
serialized byte cache. `RPCCaller` also holds `num_peers`, `peer_ip_at_index`,
`peer_name_at_index`, `ping_at_index`, `script_peer_at_index`, and
`add/remove_peers_in_caller` (the script-facing peer list).

## Wire format — `RPCParentPacket` (0x005f5f50)

`generate` (write, vtable +0x0c) and `extract` (read, vtable +0x14):
```
if Context._network.send_hash: write/read _rpc_hash (u32, 4 B)   # version guard
write/read _message_id (u8, 1 B)
for each RPCMessage._params[i]:  RPCParam::pack / dummy_unpack (BitPacker)
```

The `_rpc_hash` (4 bytes) is emitted only when `Context.network.send_hash` is
true — a **registry version guard**: it lets the two ends detect mismatched
RPC message layouts and reject/stall. (An earlier session recorded
`send_hash` as renumbering RPC wire type IDs 0x1a/0x1b/0x1c →
0x68/0x69/0x6a; that is not consistent with `make_packet`'s 0x00–0x1c switch
and with working RPC, so the type bytes stay 0x1a/0x1b/0x1c and the hash is
the version-check mechanism. The 0x68+ observation remains unconfirmed.)

`extract` throws `PacketError "RPC message index out of range"` if
`_message_id >= _messages.size()` — a robustness check against a stale/mismatched
registry on the receiving side.

## Dispatch — `RPCReceiver::receive(message_id, LuaArgs, Connection)` (0x00609d10, 1104 B)

```
if message_id out of range: log "[Network] Received unknown message from <addr>"; return
msg = RPC._messages[message_id]
if default_receiver is null (ref == -2):
    if msg._delivery != UNRELIABLE:
        _receive_queue.push_back({ message_id, args, connection })   # defer
    return
# default receiver exists
if msg._check == 1 and peer.port != 0x4d and not Network.is_my_client(peer):
    log "[Network] Received a client-to-server message from <addr> who is not my client."; return
if msg._check == 2 and peer.port != 0x4d and not Network.is_my_server(peer):
    log "[Network] Received a server-to-client message from <addr> who is not my server."; return
table = (msg._receiver == "") ? default_receiver : _receivers[msg._receiver]
if no such receiver: log "[Network] Network has no receiver named <name>"; return
caller = new RPCCaller(RPC, sender_peer, true)      # reply handle, 1st arg
recv_table = LuaArg.to_table(receiver)
fn = recv_table[msg._name]
if lua_type(fn) == 6:  fn(caller, ...unpacked_args)   # LUA_FUNCTION
else: log "[Network] Network callback object <table> does not have any implementation for method <name>"
```

Key behaviors:
- **Direction checks** (`_check`): client→server (`1`) requires the sender be
  one of my clients; server→client (`2`) requires the sender be my server.
  `peer.port == 0x4d` (77) bypasses the check — the local/broadcast self-port.
- **Deferred delivery**: if there's no default receiver and the message is
  reliable/ordered, it's queued in `_receive_queue` and drained later by
  `RPCReceiver::process_queue` (called at the top of `Network::update`).
  Unreliable messages with no receiver are dropped immediately (no point
  buffering a fire-and-forget that will be lost).
- The Lua callback's **first argument is an `RPCCaller`** scoped to the sender,
  so the handler can reply to that specific peer.

## Parameter marshalling — `RPCParam::pack(BitPacker*, LuaArg, RPCParamContext*)` (0x005f4d60, 2348 B)

`pack` is a switch on `RPCParam._type` (the `type="..."` attribute from XML).
Every value is written into the shared `BitPacker` stream; the per-type packer
parameters (min/max/bits/step) live in the `RPCParam` struct, configured by
`RPC::load` from the XML param attributes.

| type (XML) | wire encoding |
|---|---|
| bool | 1 bit (0/1) |
| int | `_bits` bits: value clamped to `[min,max]`, stored as `value - min` |
| float | raw 4-byte IEEE float if `use_bit_packer=false`, else `FloatPacker` |
| vector3 | raw 12 bytes if `use_bit_packer=false`, else `Vector3Packer` |
| unitvector | `UnitVectorPacker` (nil → zero vector) |
| rotation (gquat) | `GQuatPacker` (nil → identity 0,0,0,1) |
| string | `BitPacker::operator<<` (length-prefixed) |
| longstring | `BitPacker::write_long_string` |
| unit | `UnitPacker` (nil → null unit); also sets `context->unit` for later params |
| body | `UnitPacker` + `IntPacker` body index (`Unit::body_index`; nil → -1) |
| object3d | `IntPacker` scene-relative index (`SceneModel::object_index`; no context unit → -1) |
| animation_state | `IntPacker` state index (`StateMachineInstance::state_name_to_index`; unknown → -1) |
| physic_effect | `IntPacker` name index via `PhysicEffectManager` (nil → -1) |
| soundbank | `IntPacker` name index via `SoundDevice` vtbl+0x30 (nil → -1) |
| cue | `IntPacker` name index via `SoundDevice` vtbl+0x38 (nil → -1) |
| table | `RPCTable::write` with schema from `RPC::table_at_index(index_of_table_with_name(_name))` |
| xuid / xnaddr / xsessioninfo | **throws**: "Cannot pack XUID/XNADDR/XSessionInfo on non-xbox platform" (rpc.cpp:0xe8/0xee/0xf4) |
| (other) | logs `[RPC] Cannot pack unknown parameter type` |

Design note: named-reference params (object3d, animation_state, physic_effect,
soundbank, cue) travel as **indices into a shared registry**, never as names.
Cheap on the wire, but order-sensitive: both ends must have built identical
registries, which is exactly what the `_rpc_hash` version guard detects.

## Lua surface

From the decompiled Lua, scripts register RPCs by populating `RPC._messages`
(delivery/check/receiver/name/params) and `_receivers` (named tables with
method implementations). The C++ side is thin: it validates, routes, unmarshals
params per the registered types, and calls the named Lua method with a reply
`RPCCaller` as arg 1.

## Cross-check targets (task 6)

- [x] `RPCParam::pack` per-type bit layouts — resolved above (this doc).
- [ ] Find where the decompiled Lua builds `rpc._messages` / registers receivers
  (likely a `rpc.lua` / `Network` setup file).
- [ ] Confirm `send_hash` is set in `Context.network` init (the `fs::Steam` /
  network setup layer) and that the 0x68/0x69/0x6a wire IDs appear there
  (unconfirmed — see audit doc correction #2).
- [x] `Network::add_members` (0x00607140) — 57-method `network` table, listed
  in `netcode-lua-api.md`.
