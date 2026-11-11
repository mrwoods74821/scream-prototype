-- Ability states used by AI MPNpc units. They deliberately avoid cameras,
-- HUDs, and human input while preserving the stock combat RPC flow.
MPNpcEmptyState = MPNpcEmptyState or class()
function MPNpcEmptyState:init(unit)
  self._unit = unit
end
function MPNpcEmptyState:enter()
end
function MPNpcEmptyState:exit()
end
function MPNpcEmptyState:update()
end
function MPNpcEmptyState:safe_abort_of_actions()
end
function MPNpcEmptyState:get_carriable_action()
  return true
end
function MPNpcEmptyState:can_do_ability_action()
  local data = self._unit:player_data()
  return not data.special_move_attacking and not data.special_move_grappled and not self._unit:damage_data().dead and not self._unit:damage_data().knocked_out
end
function MPNpcEmptyState:can_do_special_move_attack()
  local data = self._unit:player_data()
  return self:can_do_ability_action() and tweak_data.archetypes.archetype_definitions[data.archetype].special_move_attack ~= nil
end
function MPNpcEmptyState:can_do_interact_action()
  return self:can_do_ability_action() and not self._unit:player_data().carrying
end

MPNpcSpecialMoveAttack = MPNpcSpecialMoveAttack or class(PlayerSpecialMoveAttack)
function MPNpcSpecialMoveAttack:init(unit)
  self._unit = unit
  self._upd = unit:player_data()
  self._base = unit:base()
  self:_reset_variables()
  self._slotmask_targets = managers.slot:get_mask("melee_targets")
  self._tweak_data = tweak_data.archetypes.archetype_definitions[self._upd.archetype].special_move_attack
  self._upd.special_move_attacking = false
  self._controller = {
    get_input_axis = function()
      return Vector3(0, 0, 0)
    end
  }
end
function MPNpcSpecialMoveAttack:enter(prev_name, ctrl)
  local unit = self._unit
  self:_reset_variables()
  self._controller = ctrl or self._controller
  local target_unit = self._upd.special_move_target_unit
  self:_update_movement(target_unit)
  self._upd.special_move_attacking = true
  unit:set_driving("script")
  self._base:play_redirect("execute_lunge", true)
  self._target_unit = target_unit
  self._lunging = true
end
function MPNpcSpecialMoveAttack:update(t, dt)
  if self._lunging then
    self:_update_lunge(t, dt)
  end
  if self._execution_time and t >= self._execution_time then
    self:execute()
    self._execution_time = nil
  end
end
function MPNpcSpecialMoveAttack:_update_aiming()
end
function MPNpcSpecialMoveAttack:safe_abort_of_actions()
end
function MPNpcSpecialMoveAttack:get_carriable_action()
  return false
end
function MPNpcSpecialMoveAttack:can_do_ability_action()
  return false
end
function MPNpcSpecialMoveAttack:can_do_special_move_attack()
  return false
end

MPNpcGroundExecuting = MPNpcGroundExecuting or class()
function MPNpcGroundExecuting:init(unit)
  self._unit = unit
  self._upd = unit:player_data()
  self._dmg_data = unit:damage_data()
  self._execute_acknowledged = false
  self._base = unit:base()
  self._stab_sound_instance = nil
end
function MPNpcGroundExecuting:enter()
  self._execute_acknowledged = false
  self._execution_timer = TimerManager:game():time()
  local victim = self._upd.executing_player
  if alive(victim) then
    managers.network:send_unit_rpc("reliable", "play", victim, "stabbing")
    self._stab_sound_instance = victim:play("stabbing")
  end
end
function MPNpcGroundExecuting:update(t, dt)
  local victim = self._upd.executing_player
  local target_pos = self._upd.ground_execute_target_pos
  if target_pos then
    self._base:set_position(math.lerp(self._unit:position(), target_pos, 5 * dt))
  end
  if not (alive(victim) and victim:damage_data().knocked_out) or victim:damage_data().dead then
    self._base:change_state("onground")
    self._base:play_redirect("look")
  elseif t > self._execution_timer + self._base.archetype_data.EXECUTION_TIME and self._execute_acknowledged then
    self._base:change_state("onground")
    self._base:play_redirect("look")
    local body = victim:body("Spine1")
    managers.network:server():western_generic_damage(managers.networklookup:get_id("melee"), body, self._unit, Vector3(0, 0, 1), body:position(), Vector3(0, 0, -1), 200, managers.networklookup:get_id("punch"))
  end
end
function MPNpcGroundExecuting:execute_acknowledged()
  self._execute_acknowledged = true
end
function MPNpcGroundExecuting:exit()
  self._upd.executing_player = nil
  self._upd.ground_execute_target_pos = nil
  if alive(self._stab_sound_instance) then
    self._stab_sound_instance:stop()
  end
  self._stab_sound_instance = nil
end
function MPNpcGroundExecuting:safe_abort_of_actions()
end
function MPNpcGroundExecuting:get_carriable_action()
  return false
end
function MPNpcGroundExecuting:can_do_special_move_attack()
  return false
end
function MPNpcGroundExecuting:can_do_ability_action()
  return false
end
