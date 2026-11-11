BTStalkAction = BTStalkAction or class(BTNode)
function BTStalkAction:init(identifier, parent, condition_name, hook_name)
  BTNode.init(self, identifier, parent, condition_name, hook_name)
end
function BTStalkAction:name()
  return "BTStalkAction"
end
function BTStalkAction:enter(unit, t, dt)
  local aidata = unit:ai_data()
  aidata.bot_next_stalker_toggle = 0
  BTBotUtility.set_movement(unit, "walk")
end
function BTStalkAction:leave(unit, t, dt)
end
function BTStalkAction:run(unit, t, dt)
  local aidata = unit:ai_data()
  local enemy = aidata.current_enemy
  if not alive(enemy) then
    BTBotUtility.set_stalker(unit, true, t)
    return
  end
  local distance = BTBotUtility.distance_to(unit, enemy:position())
  if distance > 700 then
    BTBotUtility.set_stalker(unit, true, t)
  elseif distance < BTBotUtility.MELEE_RANGE then
    BTBotUtility.set_stalker(unit, false, t)
  end
  BTBotUtility.face(unit, enemy:position())
  BTBotUtility.set_movement(unit, unit:player_data().stalker_mode and "walk" or "jog")
end
