BTConditions = BTConditions or {}
function BTConditions.always_true(aidata)
  return true
end
function BTConditions.always_false(aidata)
  return false
end
function BTConditions.has_order(aidata)
  return aidata.order ~= nil
end
function BTConditions.has_enemy(aidata)
  return aidata.has_enemy
end
function BTConditions.can_see_enemy(aidata)
  return aidata.can_see_enemy
end
function BTConditions.has_clear_shot_and_inrange(aidata)
  return aidata.within_shooting_range and aidata.clear_shoot
end
function BTConditions.has_clear_shot(aidata)
  return aidata.clear_shoot
end
function BTConditions.within_shooting_range(aidata)
  return aidata.within_shooting_range
end
function BTConditions.within_preferred_shooting_range(aidata)
  return aidata.within_preferred_shooting_range
end
function BTConditions.outside_preferred_shooting_range(aidata)
  return not aidata.within_preferred_shooting_range
end
function BTConditions.knocked_out(aidata)
  return aidata.unit:damage_data().knocked_out
end
function BTConditions.no_active_behaviour(aidata)
  return aidata.current_behaviour == ""
end
function BTConditions.has_guard_position(aidata)
  return aidata.guard_position
end
function BTConditions.guarding(aidata)
  return aidata.order == "Guard"
end
function BTConditions.not_guarding(aidata)
  return not BTConditions.guarding(aidata)
end
function BTConditions.outside_guard_range_delta(aidata)
  if not BTConditions.has_guard_position(aidata) then
    return false
  end
  local length = aidata.guard_position and (aidata.unit_position_flat - aidata.guard_position:with_z(0)):length() or -1
  local return_value = aidata.order == "Guard" and aidata.guard_position and (aidata.unit_position_flat - aidata.guard_position:with_z(0)):length() > aidata.guard_range * 0.5
  return return_value
end
function BTConditions.outside_guard_range(aidata)
  if not BTConditions.has_guard_position(aidata) then
    return false
  end
  local length = aidata.guard_position and (aidata.unit_position_flat - aidata.guard_position:with_z(0)):length() or -1
  local return_value = aidata.order == "Guard" and aidata.guard_position and (aidata.unit_position_flat - aidata.guard_position:with_z(0)):length() > aidata.guard_range
  return return_value
end
function BTConditions.inside_guard_range(aidata)
  return not BTConditions.outside_guard_range(aidata)
end
function BTConditions.enemy_outside_guard_range(aidata)
  if not BTConditions.has_enemy(aidata) then
    return false
  end
  if not BTConditions.has_guard_position(aidata) then
    return false
  end
  local p = aidata.threat_position
  local length = p and (p:with_z(0) - aidata.guard_position:with_z(0)):length() or -1
  local guard_range = aidata.guard_range
  return length > guard_range
end
function BTConditions.enemy_inside_guard_range(aidata)
  return not BTConditions.enemy_outside_guard_range(aidata)
end
function BTConditions.enemy_outside_guard_shoot_range(aidata)
  if not BTConditions.has_enemy(aidata) then
    return false
  end
  if not BTConditions.has_guard_position(aidata) then
    return false
  end
  local p = aidata.threat_position
  local length = p and (p:with_z(0) - aidata.guard_position:with_z(0)):length() or -1
  local guard_range = aidata.guard_range
  local shooting_range = aidata.preferred_range
  return length > guard_range + shooting_range
end
function BTConditions.enemy_inside_guard_shoot_range(aidata)
  return not BTConditions.enemy_outside_guard_shoot_range(aidata)
end
function BTConditions.can_reach_enemy(aidata)
  return aidata.can_reach_enemy
end
function BTConditions.new_task(aidata)
  return aidata.new_task
end
function BTConditions.order_fulfilled(aidata)
  return aidata.order_fulfilled
end
function BTConditions.move_order(aidata)
  return aidata.order == "AttackMove"
end
function BTConditions.last_hurt_by(aidata)
  return aidata.last_hurt_by
end
function BTConditions.can_circle_target(aidata)
  return aidata.circling_target or Application:time() > aidata.last_circling_try + 1
end
function BTConditions.enemy_infront(aidata)
  return aidata.enemy_infront
end
function BTConditions.trapped(aidata)
  return aidata.trapped
end
function BTConditions.revive_friend(aidata)
  return aidata.revive_friend
end
BTHooks = BTHooks or {}
function BTHooks.flank(aidata)
  aidata.flank = true
end

function BTConditions.killer_visible_or_near(aidata)
  if not aidata.bot_enabled or aidata.bot_is_ghostface or not alive(aidata.current_enemy) then
    return false
  end
  if not BTBotUtility.is_ghostface(aidata.current_enemy) then
    return false
  end
  local enemy = aidata.current_enemy
  local distance = (enemy:position() - aidata.unit:position()):length()
  if distance > BTBotUtility.FLEE_RADIUS then
    return false
  end
  aidata.bot_flee_from = enemy:position()
  return aidata.can_see_enemy or distance < BTBotUtility.FLEE_RADIUS * 0.75
end
function BTConditions.has_available_objective(aidata)
  if not aidata.bot_enabled or aidata.bot_is_ghostface then
    return false
  end
  local t = TimerManager:game():time()
  BTObjectiveAction.scan(aidata.unit, t)
  return alive(aidata.bot_objective)
end
function BTConditions.can_execute_knocked_out(aidata)
  if not aidata.bot_enabled or not aidata.bot_is_ghostface then
    return false
  end
  local target = BTBotUtility.find_knocked_out_enemy(aidata.unit)
  aidata.bot_execute_target = target
  return target ~= nil
end
function BTConditions.bot_has_enemy(aidata)
  return aidata.bot_enabled and alive(aidata.current_enemy)
end
