# 04 — Data-Driven Netcode (what the content says)

Extracted from `bundles/quick.bundle` (BNDL v2 parse, 2026-09-24). All examples verbatim from the depot.

## Unit replication grammar — `<network>` tag in unit XML

84 unit XMLs carry a network declaration. Attributes: `sync` mode, `remote_unit`, `sync_rotation`.

| sync mode | Meaning (inference from symbols + usage) | Examples |
|---|---|---|
| `client` | Locally-owned unit; spawns `remote_unit` husk on other machines | all player units |
| `husk` | The remote proxy unit itself; receives state | *_husk units |
| `bodies` | Physics-rigid-body replication (BodyPacket) | pickups, grenades |
| `unit` | whole-unit sync | rare (2 files) |

Canonical player pattern (mp_player_ghostface.xml):
`<network remote_unit="mp_player_ghostface_husk" sync="client" sync_rotation="true"/>`
and its husk (mp_player_ghostface_husk.xml):
`<network remote_unit="" sync="husk" sync_rotation="true"/>`

Server-authoritative actors use NPC + husk pairs (mp_npc_* → remote_unit mp_player_*_husk). Weapons split client/server variants: mp_gun_grenade_client (sync="client") vs mp_gun_grenade_server (sync="bodies").

## Complete archetype roster (networked units in bundle)

- Scream archetypes: mp_player_ghostface (+husk), mp_player_survivor_1..4 (+husks)
- Lead and Gold classes: mp_player_{blaster,gunslinger,ranger,sniper} (+_blue/_red team variants + husks)
- Support: mp_observer (spectator camera), mp_western_beartrap, mp_western_dynamite(+husk), MP pickup families (health/armour/weapon boxes)
- Husk Lua extensions: MPPlayerHusk, MPPlayerDamageHusk, MPPlayerInventoryHusk, PlayerSynergyHusk, MPDynamiteUnitHusk

## RPC declarations — data/settings/network.xml

Shipped file declares EnvEditor + Benchmark messages (typed params: string, float step, vector3 step; delivery reliable/unreliable; check none). Example:

```
<message name="benchmark_start" delivery="reliable" check="none">
    <param type="string"/> ×3
</message>
```

This is the template for any new gameplay RPC we add: declare in network.xml, handle in Lua via RPCCaller. NOTE: shipped network.xml may be a subset — the FCL boot layer (boot.fcl) likely carries the full gameplay RPC table; recover it in the toolchain phase.

## Gamemode configs — 20 shipped, XMB format

Lead and Gold modes: coop, tdm, duel, fks, kth_conquest, kth_headquarters, practice, pwk_vs, sog(_vs), strawberry_pwk.
Scream prototype modes (the target experiences):

| Mode | Notes (from XMB tokens) |
|---|---|
| scream_vs | survivors vs ghostface; team_based, respawn_time 999, show_enemy_faces |
| scream_tag1 / scream_tag2 | tag variants |
| scream_catch | hints: ghostface_killer, flashlight, cutthroat, LOS, staytogether, sneak, basement, dare, rightback, notover, virgin |
| scream_knife, scream_stray, scream_dodgeball, scream_disguised, scream_practice | additional MP experiments |

coop_gamemode tokens confirm: team_a = players, team_b = AI, objectives-driven (coop_rules.xml event script: start_game/setup_game/start_round/end_round with SetSpawnLocation coop_player_spawn, RoundTime, AllowSpawn, scoring stores).

## Network Lua scripts (quick.bundle .luc layer)

- NetworkSystemLinkRDV.luc — system-link (LAN/direct) flow, RDV
- HudNetworkClient(Panel).luc — client connection HUD
- Network{Area,HuskUnit,LocalUnit,Unit}Damage.luc — damage replication flows
- CoreNetEWS* / NetEWSServer.luc — in-engine editor networking (Bringer of Worlds editor layer)
- MPObserver/ObserverCamera/ObserverHud.luc — spectator system

## Boot layer (boot.fcl / boot_common.fcl) — pending recovery

game.lhd lists the full boot file set; menu/session Lua (MainMenuManager, MenuPageManager, NetworkSystemLinkRDV deps, ControllerWrapper...) lives in this layer. FCL/LHD format is fully documented in the diesel-bundle-extraction skill; extraction + .luc decompilation is Toolchain Phase 1 (see 05/06).

## Level list

fort, mine, mountain, prairie, ranch, town, train, the_hill_scavenge (per-level FCL containers + level XML scenes in quick.bundle).
