BTFleeAction = BTFleeAction or class(BTNode)
function BTFleeAction:init(identifier, parent, condition_name, hook_name)
  BTNode.init(self, identifier, parent, condition_name, hook_name)
end
function BTFleeAction:name()
  return "BTFleeAction"
end
function BTFleeAction:enter(unit, t, dt)
  local aidata = unit:ai_data()
  local member = BTBotUtility.member(unit)
  local carried = member and member:carriable()
  if alive(carried) then
    unit:base():start_carriable_drop("drop_carriable", true)
    aidata.bot_delivering = false
  end
  BTBotUtility.stop(unit)
  aidata.bot_next_flee_path = 0
  aidata.bot_flee_started_at = t
  BTBotUtility.set_movement(unit, "run")
end
function BTFleeAction:leave(unit, t, dt)
  BTBotUtility.stop(unit)
end
function BTFleeAction:run(unit, t, dt)
  local aidata = unit:ai_data()
  local threat = aidata.bot_flee_from
  if not threat then
    return
  end
  BTBotUtility.set_movement(unit, "run")
  if t < aidata.bot_next_flee_path then
    if unit:locomotion_data().current_path then
      MovementUtilities.update_path(unit)
    end
    return
  end
  aidata.bot_next_flee_path = t + 0.7
  local origin = unit:position()
  local away = origin - threat
  away = away:with_z(0)
  if away:length() < 1 then
    away = Vector3(1, 0, 0)
  else
    away = away:normalized()
  end
  -- Sidestepping prevents every fleeing bot from following the same straight line.
  local side = math.random(2) == 1 and 1 or -1
  local lateral = away:cross(Vector3(0, 0, 1)):normalized() * side * 600
  local destination = origin + away * BTBotUtility.FLEE_DISTANCE + lateral
  BTBotUtility.path_to(unit, destination)
end
