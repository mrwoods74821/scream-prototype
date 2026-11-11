BTHuntAction = BTHuntAction or class(BTNode)
function BTHuntAction:init(identifier, parent, condition_name, hook_name)
  BTNode.init(self, identifier, parent, condition_name, hook_name)
end
function BTHuntAction:name()
  return "BTHuntAction"
end
function BTHuntAction:enter(unit, t, dt)
  local aidata = unit:ai_data()
  aidata.bot_next_stalker_toggle = 0
  BTBotUtility.set_movement(unit, "walk")
end
function BTHuntAction:leave(unit, t, dt)
  BTBotUtility.stop(unit)
end
function BTHuntAction:run(unit, t, dt)
  local aidata = unit:ai_data()
  local enemy = aidata.current_enemy
  if not alive(enemy) then
    return
  end
  local distance = BTBotUtility.distance_to(unit, enemy:position())
  if distance > 700 then
    BTBotUtility.set_stalker(unit, true, t)
    BTBotUtility.tag_target(unit, enemy, t)
  end
  if BTBotUtility.special_attack(unit, enemy, t) then
    return
  end
  BTBotUtility.face(unit, enemy:position())
  if distance <= BTBotUtility.MELEE_RANGE then
    BTBotUtility.stop(unit)
    BTBotUtility.set_stalker(unit, false, t)
    BTBotUtility.melee(unit, enemy, t)
    return
  end
  BTBotUtility.set_movement(unit, unit:player_data().stalker_mode and "walk" or "run")
  BTUtilityFunctions.follow_target(unit, t, dt)
  if unit:locomotion_data().current_path then
    MovementUtilities.update_path(unit)
  end
end
