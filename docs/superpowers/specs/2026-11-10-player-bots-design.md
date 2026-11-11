# Player Bots — Design Doc

## Intent and why

Scream Prototype ships eight `scream_*` versus gamemodes and a complete P2P
stack, but a round needs a human on every slot. The goal is to make matches
playable with any number of humans (including one) by filling the remaining
slots with server-controlled bots:

- A human playing **Ghostface** gets **survivor bots** to hunt.
- A human playing a **Survivor** gets **survivor bot teammates** and a
  **Ghostface bot** opponent.

Bots must behave like real players, not props: they move freely around the
map, pursue the round's objective, and react to the killer. The Ghostface bot
uses its archetype abilities (stalker/sneak, melee, execution) to hunt and
kill survivors.

The engine already contains the full substrate for this: a behavior-tree AI
stack (`BrainManager`, `BTBrain`, 17 action nodes), a navigation graph
(`AIGraphManager` + `MovementUtilities.request_path`), a server-authoritative
NPC replication class (`MPNpc`), and — most importantly — a dormant
network-member seam `NetworkMember:set_ai_controlled(val, bt, skill_template,
group_id)` that makes the engine spawn a unit, attach a named behavior tree to
its brain, and replicate it to all clients. Bots here are a **restoration and
wiring** task, consistent with how the multiplayer stack itself was restored:
we connect and extend existing systems rather than inventing new ones.

## Goals

- A `BotManager` that, when a versus round starts, fills empty survivor and
  Ghostface slots with AI-controlled `NetworkMember`s.
- Survivor bots that **wander** the map, **seek and complete objectives**
  (carriable/evidence pickup and delivery), and **flee** from a visible or
  near Ghostface.
- A Ghostface bot that **wanders/patrols**, **sneaks** (stalker mode),
  **hunts** survivors, and **kills** (melee + ground execution).
- Bots replicate correctly to all connected clients through the existing
  husk/RPC replication, server-authoritative.
- Bots respect the same death, knockout, revive, and scoring rules as humans
  (they already flow through `ai_controlled()` checks in TeamManager,
  Gametype, MPPlayerDamage, ActionHandler).

## Non-goals

- Human-quality aim, mind games, or adaptive learning. Bots should be
  believable and functional, not competitive.
- Pathing on maps without a generated AI graph (see Constraints). If a map
  has no graph, bots degrade gracefully to idle/guard behavior rather than
  crash.
- Editor/X360-only code paths.
- New animation, model, or audio assets. Bots reuse existing player/NPC
  units and anim state machines.

## Anti-goals (failure even if it "works")

- Bots that stand still at spawn for the whole round.
- Bots that crash the round when the killer is a bot, when the last human
  leaves, or when the round restarts.
- A Ghostface bot that never uses stalker mode or never executes, or a
  survivor bot that never picks up an objective.
- Client-side bots: all bot brains run on the server only, matching
  `MPNpc`'s existing `if Network:is_server()` authority.

## Constraints

- **Lua 5.1, GRIN float32 bytecode.** All new/edited scripts must compile
  through `tools/float32luac.py` / `tools/dev_compile.py` and run under the
  engine's `.luc` loader. Source lives under `lua/<tree>/win32/...`.
- **Server-authoritative networking.** Any state change that other players
  must see (pickup, damage, stalker mode, execution) must go through the
  existing RPC handlers (`Network:server():...` on clients,
  `Network:clients():...` broadcast from server) exactly as the human code
  paths do.
- **Nav graph availability.** `AIGraphManager` builds its graph from level
  data; `MovementUtilities.request_path` returns `nil,error_code` when no
  path exists. Bot movement code must handle `graph_not_found_here` and
  unreachable targets by falling back, never by erroring.
- **Behavior trees are XML-declared and hot-loaded by `BrainManager:
  load_all_trees()`**, which currently loads a hardcoded directory
  (`\data\lib\ai\beings\npc\*.xml`). New trees must be registered there.
- **The `set_ai_controlled` 4-argument form has no shipped caller.** It is
  verified to assign `_behavior_tree`/`_skill_template`, and
  `NetworkMember:spawn_and_sync_unit` already consumes them
  (`brain():load_brain(self._behavior_tree)`). This seam must be proven live
  in a spike before building on it.

## Approaches considered

### A. Reuse the BT stack; add two trees + the missing action nodes (chosen)

Add a `BotManager` that fills slots at round start via
`NetworkPlayerManager:register_player(..., ai_controlled=true, ...)` and
`NetworkMember:set_ai_controlled(true, tree, skill_template)`. Write two new
behavior trees — `survivor.xml` and `ghostface.xml` — plus the action nodes
they need (`BTWanderAction`, `BTObjectiveAction`, `BTFleeAction`,
`BTStalkAction`, `BTExecuteAction`) alongside the reusable
`BTApproachAction`/`BTIdleAction`. New conditions hang off `BTConditions`.

- Trades: most code, but it is the engine's own design. Bots are real
  `NetworkMember`s, replicate through the proven husk/RPC path, and ride the
  existing per-frame `BrainManager` tick with no new scheduler.

### B. Bypass BT; drive `MPNpc` units from one hand-rolled Lua brain

- Rejected: discards the shipped `BrainManager`/`BTBrain`/skill-template
  system and the `set_ai_controlled` replication seam, forcing hand-rolled
  network and slot wiring. More risk, less reuse.

### C. Spike only (folded into A as its first task)

- Prove `set_ai_controlled` attaches a brain and replicates before building
  two trees on an unverified seam. This de-risks A.

## The how (decided parts)

### Bot spawning: `BotManager`

New manager `managers.bot` (`BotManager.lua`), constructed in `Setup.lua`
next to `managers.brain = BrainManager:new()`. On round start (hooked from
the versus `Gametype` server flow) it:

1. Counts human members per team via `TeamManager`.
2. For each empty survivor slot and the empty Ghostface slot, calls
   `NetworkPlayerManager:register_player(id, name, true, rpc, server, false)`
   to create an AI member, then `member:set_ai_controlled(true, tree_name,
   skill_template)`.
3. Lets the existing `NetworkMember:spawn_and_sync_unit` path spawn the
   correct archetype unit (`mp_player_survivor_*` / `mp_player_ghostface`)
   and attach the brain.

Bot names come from a small pool ("Bot …"). Bot members are cleaned up on
round end / player-leave via the existing `remove_player` path, which already
handles AI members.

### Survivor tree (`survivor.xml`)

Priority order (Selector):
1. `BTKnockedOutAction` (condition `knocked_out`) — reused.
2. `BTFleeAction` (condition `killer_visible_or_near`) — new; path away from
   `threat_position`, run movement type.
3. `BTObjectiveAction` (condition `has_available_objective`) — new; path to
   nearest carriable/evidence, trigger pickup via the same RPC a human's
   interact uses, then path to delivery target.
4. `BTWanderAction` (default) — new; pick a reachable random nav node, walk
   to it, repeat.

### Ghostface tree (`ghostface.xml`)

1. `BTKnockedOutAction` (condition `knocked_out`) — reused.
2. `BTExecuteAction` (condition `can_execute_knocked_out`) — new; if an enemy
   is knocked out and within `KNOCKOUT_REVIVE_TRIGGER_DISTANCE`, run the
   `CAN_EXECUTE` path (`request_execute_knocked_out`).
3. `BTHuntAction` (condition `has_enemy`) — reuses approach logic via
   `BTUtilityFunctions.follow_target`; enters stalker mode on approach when
   unseen, attacks in range.
4. `BTStalkAction` / stalker handling — drive
   `Player:enter_stalker_mode`/`exit_stalker_mode` on the bot's unit base
   when closing distance while not visible.
5. `BTWanderAction` (default) — patrol between nav nodes, staying in stalker
   mode when far from survivors.

### New action nodes and conditions

New files under `lua/quick/win32/data/lib/ai/behavior_tree/actions/`:
`BTWanderAction.lua`, `BTFleeAction.lua`, `BTObjectiveAction.lua`,
`BTStalkAction.lua`, `BTExecuteAction.lua`, `BTHuntAction.lua`. New
conditions in `BTConditions.lua`: `killer_visible_or_near`,
`has_available_objective`, `can_execute_knocked_out`. New fields on `AiData`
as needed (objective target, wander goal, flee state).

### What is left to the builder

- Exact tuning numbers (detection/flee ranges, wander radius, stalker
  enter/exit hysteresis, objective scan interval).
- The precise objective query against the level's carriable/evidence set
  (mirroring `MissionObjectiveUnitIconsEvidence`'s target scan).
- Whether Ghostface stalker uses `enter_stalker_mode` directly or the
  `toggle_stalker_mode_cb` input path (the direct base methods are the
  bot-appropriate seam; the `_cb` reads controller input).

## Verification

- **Spike (gate):** in a live two-instance versus round, call
  `set_ai_controlled(true, "normal", <skill>)` on one member; confirm a unit
  spawns, a `BTBrain` attaches, and it replicates to the other client. Only
  then build the trees.
- **Survivor:** solo host, Ghostface human → survivor bots spawn, wander,
  pick up an objective, and flee when the killer approaches.
- **Ghostface:** solo host, survivor human → Ghostface bot spawns, patrols,
  stalks, downs and executes a survivor.
- **Stability:** no `attempt to ...` in crashlog; round restart and
  player-leave do not orphan brains or crash.
