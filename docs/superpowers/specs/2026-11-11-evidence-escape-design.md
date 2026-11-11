# Evidence Escape Behavior Design

## Intent

Survivors abandon evidence when Ghostface threatens them during delivery.
They escape unencumbered and recover the package after the threat clears.

## Chosen behavior

When `BTFleeAction:enter` runs, the carrier uses the existing
`MPNpc:start_carriable_drop` path. The package's `carriable_carrier` is
cleared by `NetworkMember:carriable_dropped`, and the existing drop code
replicates the detachment to clients.

The objective action keeps its current target reference across the flee
transition. On the next objective scan, it first checks that reference. If
another survivor has claimed or delivered it, it clears the reference and
uses normal objective selection. Empty-handed survivors use normal selection,
including packages dropped by their teammates.

A carrier that is near its destination finishes the delivery during the same
frame if the drop-zone check succeeds. Otherwise it drops and flees.

## Scope

- Modify only `BTFleeAction.lua` and `BTObjectiveAction.lua`.
- Reuse existing drop, replication, movement, and objective-pickup paths.
- No new proximity thresholds or alternate package priorities.
- Test behavior with a Lua harness using fake units and members, with the
  actual production action files loaded by `dofile`.
- Compile and deploy through `scripts/deploy_bots.py`. Elijah owns runtime
  verification in the game.
