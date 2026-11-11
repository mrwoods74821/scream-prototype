# Player Bots Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fill empty survivor and Ghostface slots in versus rounds with server-controlled bots that wander, do objectives, flee (survivors), and sneak/hunt/kill (Ghostface), by wiring the engine's shipped behavior-tree AI into the versus round flow.

**Architecture:** A `BotManager` calls the shipped `managers.brain:spawn_bot()`/`spawn_npc()` per empty slot at round start. Each bot is a real AI `NetworkMember` whose unit gets a `BTBrain` running one of two new behavior trees (`survivor`, `ghostface`). New BT action nodes implement wander/flee/objective/stalk/execute on top of the existing `MovementUtilities.request_path` nav, the `Player` base's stalker/execute methods, and the `gametype_server` objective RPCs. All brains run server-side only.

**Tech Stack:** Lua 5.1 (GRIN float32 `.luc`), Diesel behavior-tree system, existing network RPC layer.

**Spec:** `docs/superpowers/specs/2026-11-10-player-bots-design.md`

## Global Constraints

- Lua 5.1; compile all changed/new scripts with `tools/dev_compile.py` (float32).
- New BT node classes must be `require`d in `BehaviorTree.lua` AND registered in `BehaviorTree._types`, else `create_node` asserts.
- New trees must be added to `BrainManager:load_all_trees` (dir `\data\lib\ai\beings\npc\`).
- Server-authoritative: brains only tick on `Network:is_server()`; visible state changes go through existing RPC handlers.
- Never overwrite `devroot/compiled/win32_fcl/data/lib/managers/menu/MenuControllerBindNode.luc` (carries patch_mcbn nil-guard).
- Bots must tolerate `MovementUtilities.request_path` returning `nil,err` (no nav graph / unreachable) by falling back, never erroring.

## Review Focus

- Round restart / player-leave: AI members must be removed without orphaning brains (existing `remove_player` path handles AI members; verify brains are released via `MPNpc:die`/`BTBrain:die`).
- Map with no nav graph: bots must idle/guard, not crash.
- Ghostface bot executing: must reuse the exact `CAN_EXECUTE` knocked-out path so scoring/RPC stay consistent.
- Objective scan when zero objectives remain: survivor bots fall back to wander, no nil index.
- `spawn_bot` archetype must be Ghostface for the killer slot and a `survivor_*` archetype for survivor slots (the default random pool includes gunslinger/ranger/etc which are wrong for this mode).

---

### Task 0: Spike — prove spawn_bot attaches a brain and replicates (GATE)

**Files:**
- Modify (spike only, revert after): `lua/fcl/win32/data/lib/network/gamemodes/Gametype.lua` (round-start hook) OR a one-off dev console call.

**Interfaces:**
- Consumes: `managers.brain:spawn_bot(archetype_name, params)` where `params = {character_name=string, team_name=string, behavior_tree=string, skill_template=string, group_id=any}`.
- Produces: confirmation the seam is live; informs every later task.

- [ ] **Step 1: Find the versus round-start hook.** Read `Gametype.lua` for the server-side function that starts a round / spawns players (search `spawn`, `round`, `start`, `begin`). Record the exact function name and line.

- [ ] **Step 2: Add a temporary bot spawn.** At that hook (server only), insert:
```lua
if Network:is_server() and managers.brain then
  managers.brain:spawn_bot("survivor_1", {
    character_name = "SpikeBot",
    team_name = "team_b",          -- survivor team for the mode; confirm via TeamManager
    behavior_tree = "normal",
    skill_template = "normal"
  })
end
```

- [ ] **Step 3: Compile** with `tools/dev_compile.py --changed` and confirm zero errors.

- [ ] **Step 4: Live two-instance versus round.** Host + one client, EXPOSE THE KILLER. Confirm: SpikeBot appears in the round, a `BTBrain` attaches (brain ticks, unit idles per `normal.xml`), and the client sees the bot unit. Check logs and on-screen.

- [ ] **Step 5: Record result + revert the temp edit.** If the brain does not attach or does not replicate, STOP and fix the seam before Tasks 1+. Commit the negative/positive finding to `docs/`.

---

### Task 1: New BT action nodes + conditions (foundation for both trees)

**Files:**
- Create: `lua/quick/win32/data/lib/ai/behavior_tree/actions/BTWanderAction.lua`
- Create: `lua/quick/win32/data/lib/ai/behavior_tree/actions/BTFleeAction.lua`
- Create: `lua/quick/win32/data/lib/ai/behavior_tree/actions/BTObjectiveAction.lua`
- Create: `lua/quick/win32/data/lib/ai/behavior_tree/actions/BTStalkAction.lua`
- Create: `lua/quick/win32/data/lib/ai/behavior_tree/actions/BTExecuteAction.lua`
- Create: `lua/quick/win32/data/lib/ai/behavior_tree/actions/BTHuntAction.lua`
- Modify: `lua/quick/win32/data/lib/ai/behavior_tree/BTConditions.lua` (add conditions)
- Modify: `lua/quick/win32/data/lib/ai/behavior_tree/BehaviorTree.lua` (require + `_types`)
- Modify: `lua/fcl/win32/data/lib/units/data/AiData.lua` (new fields)

**Interfaces:**
- Consumes: `BTUtilityFunctions.recalc_path(unit, pos)`, `unit:locomotion_data()`, `unit:ai_data()`, `BTBrain:detect_enemy` threat fields (`threat_position`, `current_enemy`, `has_enemy`).
- Produces (node class names for trees): `BTWanderAction`, `BTFleeAction`, `BTObjectiveAction`, `BTStalkAction`, `BTExecuteAction`, `BTHuntAction`.
- Produces (conditions): `killer_visible_or_near`, `has_available_objective`, `can_execute_knocked_out`.

Each action follows the shipped pattern: `class(BTNode)`, `init(parent, condition_name, hook_name)` calling `BTNode.init`, `name()`, `enter`, `leave`, `run`. Movement goes through `BTUtilityFunctions.recalc_path` + reading `locomotion_data.current_path` / `move_target_goal`.

- [ ] **Step 1: AiData fields.** Add to `AiData:init`: `wander_goal=nil`, `flee_from=nil`, `objective_unit=nil`, `objective_deliver=nil`, `stalking=false`, `last_wander_time=0`, `wander_wait=0`.

- [ ] **Step 2: BTWanderAction** — on `run`, if no current path or reached goal, pick a random reachable point within `wander_radius` of current pos via `recalc_path`; walk (`wanted_movement_type="walk"`); on unreachable (`graph_not_found_here`) idle briefly then retry.

- [ ] **Step 3: BTFleeAction** — on enter set run; on `run`, compute a point directly away from `ai_data.flee_from` (or `threat_position`) at flee distance, `recalc_path` to it; refresh while threat persists.

- [ ] **Step 4: BTObjectiveAction** — on `run`, if `objective_unit` set: path to it; in range, trigger the same pickup RPC the human interact path uses (`Global.gametype_server:request_pickup_carriable(unit, member)` server-side). If carrying, path to `objective_deliver`. Handles nil objective by ending (Selector falls to wander).

- [ ] **Step 5: BTStalkAction** — toggles `unit:base():enter_stalker_mode()`/`exit_stalker_mode()` on the Ghostface bot's Player base when closing on an enemy while `stalker_checker:is_visible()` is false; exits when seen or in attack range. Guard with `archetype_data.HAS_STALKER_MODE`.

- [ ] **Step 6: BTExecuteAction** — condition `can_execute_knocked_out`; mirrors the `CAN_EXECUTE` block in `Player.lua` (knocked-out enemy within `KNOCKOUT_REVIVE_TRIGGER_DISTANCE`), calling `request_execute_knocked_out` server-side and `play_redirect("ko_finisher_start")` + `change_state("ground_executing")`.

- [ ] **Step 7: BTHuntAction** — reuses `BTUtilityFunctions.follow_target` to close on `current_enemy`; when within melee range, trigger the knife attack via the weapon/inventory path MPNpc uses.

- [ ] **Step 8: Conditions** — `killer_visible_or_near` (Ghostface enemy within flee radius or `can_see_enemy`), `has_available_objective` (`objective_unit ~= nil`), `can_execute_knocked_out` (enemy knocked out, alive, within trigger distance, `CAN_EXECUTE`).

- [ ] **Step 9: Register nodes.** Add `require("ai/behavior_tree/actions/BT<Name>")` for all six and add each to `BehaviorTree._types`.

- [ ] **Step 10: Compile** all changed files; fix any float32/syntax errors.

---

### Task 2: Objective query helper (survivor targeting)

**Files:**
- Modify: `lua/quick/win32/data/lib/ai/behavior_tree/actions/BTObjectiveAction.lua`
- Reference: `lua/quick/win32/data/lib/units/beings/player/gui/MissionObjectiveUnitIcons/MissionObjectiveUnitIconsEvidence.lua` (target scan), `NetworkMember.lua:1044/1086` (interact/carriable).

**Interfaces:**
- Consumes: level carriable/evidence units; `Global.gametype_server:request_pickup_carriable`.
- Produces: `BTObjectiveAction:_scan_for_objective(unit)` setting `ai_data.objective_unit` / `objective_deliver`.

- [ ] **Step 1:** Implement `_scan_for_objective` — find nearest carriable/evidence unit to the bot (mirror the evidence icon target scan) and set `objective_unit`; determine delivery target from the objective/gamemode.

- [ ] **Step 2:** Wire a periodic rescan (e.g. every 2s) so a completed/dropped objective retargets; when none remain, clear fields so the tree falls to wander.

- [ ] **Step 3:** Compile.

---

### Task 3: Behavior tree XML files

**Files:**
- Create: `lua/quick/win32/data/lib/ai/beings/npc/survivor.xml`
- Create: `lua/quick/win32/data/lib/ai/beings/npc/ghostface.xml`
- Modify: `lua/quick/win32/data/lib/ai/behavior_tree/BrainManager.lua` (`load_all_trees`)

**Interfaces:**
- Consumes: Task 1 node/condition names.
- Produces: tree names `"survivor"` and `"ghostface"` usable as `spawn_bot` `behavior_tree`.

- [ ] **Step 1: survivor.xml** — Selector `Survivor`: `BTKnockedOutAction(knocked_out)`, `BTFleeAction(killer_visible_or_near)`, `BTObjectiveAction(has_available_objective)`, `BTWanderAction`.

- [ ] **Step 2: ghostface.xml** — Selector `Ghostface`: `BTKnockedOutAction(knocked_out)`, `BTExecuteAction(can_execute_knocked_out)`, `BTHuntAction(has_enemy)` (with stalk handling), `BTWanderAction` (patrol; stalker when far).

- [ ] **Step 3:** Add both to `load_all_trees`.

- [ ] **Step 4:** Compile; boot and confirm trees load without `create_node` assert.

---

### Task 4: BotManager — fill empty slots at round start

**Files:**
- Create: `lua/quick/win32/data/lib/managers/BotManager.lua`
- Modify: `lua/quick/win32/data/lib/setups/Setup.lua` (construct `managers.bot` near `managers.brain`)
- Modify: `lua/fcl/win32/data/lib/network/gamemodes/Gametype.lua` (server round-start hook calls `managers.bot:fill_bots()`)

**Interfaces:**
- Consumes: `managers.brain:spawn_bot`, `TeamManager` team/member counts, versus mode team names.
- Produces: `BotManager:fill_bots()`, `BotManager:_desired_counts()`, `BotManager:NAMES` pool.

- [ ] **Step 1:** `BotManager:init` — name pool, enabled flag, requires to load.

- [ ] **Step 2:** `_desired_counts()` — read the versus mode's expected team sizes (from `TeamManager`/`networkgame` settings) and current human counts.

- [ ] **Step 3:** `fill_bots()` — server only; for each empty survivor slot call `spawn_bot("survivor_N", {team_name=<survivor team>, behavior_tree="survivor", skill_template="normal"})`; if the Ghostface slot is empty call `spawn_bot("ghostface", {team_name=<killer team>, behavior_tree="ghostface", skill_template="normal"})`. Never spawn Ghostface into the random archetype pool — pass the name explicitly.

- [ ] **Step 4:** Construct in `Setup.lua`; hook the Gametype server round-start function found in Task 0 Step 1.

- [ ] **Step 5:** Compile; confirm managers table gains `bot` without load errors.

---

### Task 5: Live verification (full feature)

- [ ] **Step 1:** Host EXPOSE THE KILLER as Ghostface → survivor bots spawn, wander, and pick up an objective. Watch + logs.
- [ ] **Step 2:** Host as survivor → survivor teammate bots + a Ghostface bot spawn; Ghostface patrols, stalks, downs and executes a survivor.
- [ ] **Step 3:** Flee check — approach a survivor bot as Ghostface; it runs.
- [ ] **Step 4:** Stability — restart the round and have a player leave; no crash, no `attempt to ...` in crashlog, brains released.
- [ ] **Step 5:** Two-instance — a second client sees all bots replicate (positions, stalker invisibility, execution).
- [ ] **Step 6:** Commit. Update `docs/` and the `scream-prototype` skill with the verified bot architecture.
