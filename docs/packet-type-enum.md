# Packet Type Enum — PacketFactory::make_packet (0x005fc480)

Authoritative enum from the `switch(param_1)` in `make_packet`. 31 types,
IDs 0x00–0x1c. Allocation size = `wrapped_malloc` arg. RPC types set a
subclass vtable on a base `RPCParentPacket` (0x34) for Unreliable/Reliable,
or a standalone `RPCOrderedPacket` (0x34) for Ordered.

| ID (hex) | ID (dec) | Enum constant                | Class                    | alloc |
|----------|----------|------------------------------|--------------------------|-------|
| 0x00     | 0        | ACKNOWLEDGE_PACKET           | AcknowledgePacket        | 0x18  |
| 0x01     | 1        | RELIABLE_ID_PACKET           | ReliableIdPacket         | 0x18  |
| 0x02     | 2        | ORDERED_SEQNO_PACKET         | OrderedSeqnoPacket       | 0x18  |
| 0x03     | 3        | DEBUG_STRING_PACKET          | DebugStringPacket        | 0x30  |
| 0x04     | 4        | SPAWN_UNIT_PACKET            | SpawnUnitPacket          | 0x50  |
| 0x05     | 5        | UNSPAWN_UNIT_PACKET          | UnspawnUnitPacket        | 0x18  |
| 0x06     | 6        | BODY_PACKET                  | BodyPacket               | 0x34  |
| 0x07     | 7        | CLIENT_SPAWN_UNIT_PACKET     | ClientSpawnUnitPacket    | 0x50  |
| 0x08     | 8        | ASSIGN_CLIENT_UNIT_ID_PACKET | AssignClientUnitIdPacket | 0x18  |
| 0x09     | 9        | UNIT_PACKET                  | UnitPacket               | 0x30  |
| 0x0a     | 10       | CLIENT_TABLE_PACKET          | ClientTablePacket        | 0x34  |
| 0x0b     | 11       | SERVER_TABLE_PACKET          | ServerTablePacket        | 0x34  |
| 0x0c     | 12       | PING_PACKET                  | PingPacket               | 0x14  |
| 0x0d     | 13       | I_AM_SERVER_PACKET           | IAmServerPacket          | 0x14  |
| 0x0e     | 14       | I_AM_SERVER_PACKET_PING      | IAmServerPacketPing      | 0x14  |
| 0x0f     | 15       | I_AM_CLIENT_PACKET           | IAmClientPacket          | 0x14  |
| 0x10     | 16       | UNIT_POSITION_PACKET         | UnitPositionPacket       | 0x30  |
| 0x11     | 17       | SAVE_GAME_SEGMENT_PACKET     | SaveGameSegmentPacket    | 0x468 |
| 0x12     | 18       | SAVE_GAME_RECEIVED_PACKET    | SaveGameReceivedPacket   | 0x14  |
| 0x13     | 19       | CLIENT_UNSPAWN_UNIT_PACKET   | ClientUnspawnUnitPacket  | 0x18  |
| 0x14     | 20       | SPAWN_UNIT_ON_CLIENT_PACKET  | SpawnUnitOnClientPacket  | 0x50  |
| 0x15     | 21       | WANTS_TO_SEND_ORDERED_PACKET | WantsToSendOrderedPacket | 0x14  |
| 0x16     | 22       | CANNOT_RECEIVE_ORDERED_PACKET| CannotReceiveOrderedPacket| 0x14 |
| 0x17     | 23       | UNIT_SPAWNED_PACKET          | UnitSpawnedPacket        | 0x18  |
| 0x18     | 24       | AUTH_SESSION_PACKET          | AuthSessionPacket        | 0x418 |
| 0x19     | 25       | AUTH_SESSION_RESULT_PACKET   | AuthSessionResultPacket  | 0x18  |
| 0x1a     | 26       | RPC_UNRELIABLE_PACKET        | RPCParentPacket(RPCUnreliablePacket vftable) | 0x34 |
| 0x1b     | 27       | RPC_RELIABLE_PACKET          | RPCParentPacket(RPCReliablePacket vftable)  | 0x34 |
| 0x1c     | 28       | RPC_ORDERED_PACKET           | RPCOrderedPacket         | 0x34  |

Note: the switch's `default:` branch handles the three RPC types (0x1a/0x1b/0x1c)
and returns null + logs `[PacketFactory] Cannot make packets of type <n>` for
anything else. The enum's effective range is 0x00–0x1c inclusive = **29 distinct
`W4PacketType` values**, not 31. (The earlier "31 packet types" figure was an
overcount — the authoritative count is 29.) The two SaveGame variants (0x11
segment, 0x12 received) and the ping/hello 0x14-size types round out the tail.
