BTWanderAction = BTWanderAction or class(BTNode)
function BTWanderAction:init(identifier, parent, condition_name, hook_name)
  BTNode.init(self, identifier, parent, condition_name, hook_name)
end
function BTWanderAction:name()
  return "BTWanderAction"
end
function BTWanderAction:enter(unit, t, dt)
  local aidata = unit:ai_data()
  aidata.bot_wander_goal = nil
  aidata.bot_next_wander_attempt = 0
  BTBotUtility.stop(unit)
end
function BTWanderAction:leave(unit, t, dt)
  BTBotUtility.stop(unit)
end
function BTWanderAction:_random_destination(unit)
  local angle = math.random() * math.pi * 2
  local radius = BTBotUtility.WANDER_RADIUS * (0.35 + math.random() * 0.65)
  local origin = unit:position()
  return origin + Vector3(math.cos(angle) * radius, math.sin(angle) * radius, 0)
end
function BTWanderAction:run(unit, t, dt)
  local aidata = unit:ai_data()
  local locomotion_data = unit:locomotion_data()
  BTBotUtility.set_movement(unit, BTBotUtility.is_ghostface(unit) and "walk" or "jog")
  if aidata.bot_wander_goal then
    local distance = BTBotUtility.distance_to(unit, aidata.bot_wander_goal)
    if distance <= BTBotUtility.WANDER_REACHED_DISTANCE or t > aidata.bot_wander_started_at + 18 then
      BTBotUtility.stop(unit)
      aidata.bot_wander_goal = nil
      aidata.bot_wander_wait_until = t + 1 + math.random() * 3
      return
    end
    if locomotion_data.current_path then
      MovementUtilities.update_path(unit)
    end
    return
  end
  if t < aidata.bot_wander_wait_until or t < aidata.bot_next_wander_attempt then
    return
  end
  local destination = self:_random_destination(unit)
  aidata.bot_next_wander_attempt = t + 1.5
  if BTBotUtility.path_to(unit, destination) then
    aidata.bot_wander_goal = destination
    aidata.bot_wander_started_at = t
  else
    -- Try another direction next tick. With no nav graph this remains a safe idle.
    aidata.bot_wander_wait_until = t + 0.5
  end
end
