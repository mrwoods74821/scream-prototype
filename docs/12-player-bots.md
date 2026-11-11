# Player bots: implementation and test handoff

## What is implemented

The feature uses the engine's server-authoritative `MPNpc` and `BTBrain` path.
It does not create extra human `Player` units.

- `BotManager` fills `team_a` with three survivors and `team_b` with one
  Ghostface in `scream_*` modes. Existing team members reduce bot counts, so a
  human Ghostface produces survivor bots, while a human survivor produces
  survivor teammates and a Ghostface bot.
- The roster uses `BrainManager:spawn_npc` for first spawn, member replication,
  and husk synchronization. Bot respawns use the same `NetworkMember` spawn
  routine with role state restored after death.
- New `Survivor` and `Ghostface` behavior trees are registered by `BrainManager`.
  The XML uses the exact tree names consumed by `load_brain`.
- Survivor bots wander using `MovementUtilities.request_path`, seek permitted
  carriables, pick them up through `GametypeServerCustom:request_pickup_carriable`,
  carry them to their configured drop zones, and flee when Ghostface is near.
  On flee entry a carrier drops its package through the normal replicated
  `start_carriable_drop` path and escapes unencumbered. Once safe, the normal
  objective scan reclaims the dropped package or any other available one.
- Ghostface patrols, stalks with NPC-safe visibility/speed changes, tags enemies
  through `TagManager`, performs the stock grapple/knockout RPC sequence, attacks
  with the knife's AI `wants_to_fire` input, and executes knocked-out enemies via
  `ActionHandler:request_execute_knocked_out`.
- `MPNpcStates.lua` supplies NPC-only lunge and execution states, avoiding
  human camera, HUD, and controller dependencies.
- `mp_npc_ghostface.xml` supplies a dedicated Ghostface NPC unit, replacing the
  previous gunslinger NPC mapping for this archetype.

## Source locations

- `lua/quick/win32/data/lib/managers/BotManager.lua`
- `lua/quick/win32/data/lib/ai/behavior_tree/actions/BT*`
- `lua/quick/win32/data/lib/ai/beings/npc/{survivor,ghostface}.xml`
- `lua/quick/win32/data/lib/units/mp/npc/{MPNpc,MPNpcStates}.lua`
- `lua/quick/win32/db/unit/m/mp_npc_ghostface.xml`
- Small integration edits to `BrainManager.lua`, `BehaviorTree.lua`,
  `BTConditions.lua`, `AiData.lua`, `TweakData.lua`, `Setup.lua`,
  `Gametype.lua`, and `NetworkGameManager.lua`.

## Compile and deploy

From `/home/elijah/projects/scream-prototype`:

    python3 scripts/deploy_bots.py

The last run compiled all 18 changed Lua sources with
`compiled=18 skipped=0 failed=0`. Both behavior trees and the NPC unit XML
were parsed successfully by Python's XML parser.

Scripts are written to `devroot/compiled/win32_fcl`. Source behavior trees go
to `devroot/config/data/lib/ai/beings/npc`. The new unit definition goes to
`devroot/db_fcl/unit/m`, with a duplicate under `devroot/config/db/unit/m`.
The dev context has XML compilation enabled. The normal bundled `game/` tree
retains only its pre-existing `CoreSetup.luc` display override.

## In-game verification (Elijah)

Start the loose development boot:

    PROTON=1 scripts/launch_dev.sh

Host EXPOSE THE KILLER (`scream_vs`). The dev launcher enforces its normal
observation window, so use a longer duration for an extended round, for
example:

    PROTON=1 DURATION=600 scripts/launch_dev.sh

Test both role configurations:

1. Host as Ghostface. Three survivor bots should spawn, wander, seek
   objectives, and flee when approached.
2. Host as a survivor. Two survivor teammates and one Ghostface bot should
   spawn. The killer should patrol, stalk, tag, close distance, attack, and
   execute a downed survivor.
3. Observe bot death and respawn, round transitions, and any second client.
4. If something fails, preserve the latest crashlog and note the exact round
   and role. Search the log for `[BotManager]`, `MPNpc`, `BTBrain`,
  `BrainManager`, `BTObjectiveAction`, and `attempt to`.

## Verification status

Static compilation and XML validation are complete. Runtime behavior and
network replication have not been exercised in this session; Elijah performs
the in-game tests. Any runtime failure must be fixed from the actual log before
calling the feature verified.
