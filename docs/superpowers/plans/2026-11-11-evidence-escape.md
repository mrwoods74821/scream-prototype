# Evidence Escape Implementation Plan

**Goal:** Drop a carried package when fleeing and recover it after escape.

**Architecture:** Use the existing NPC drop routine on flee entry. Preserve
the current objective reference until the next scan, then resume that same
package if it is still available. Other survivors can claim it meanwhile.

**Spec:** `docs/superpowers/specs/2026-11-11-evidence-escape-design.md`

## Tasks

1. Write `tests/test_evidence_escape.lua` with real production action files
   and fake engine objects. Run it against the pre-change behavior and record
   the expected missing drop and lost-target failures.
2. In `BTFleeAction:enter`, stop the current movement, clear any non-carriable
   action state, and call `start_carriable_drop("drop_carriable", true)` when
   the member has an attached carriable. Clear `bot_delivering` while retaining
   the target for recovery.
3. In `BTObjectiveAction.scan`, prioritize the existing target if its carrier
   matches the member or if it is unclaimed. If another member owns it, clear
   the stale reference before normal selection.
4. Run the behavior tests, compile all bot sources, deploy, review the diff,
   and document the remaining in-game test scope.
