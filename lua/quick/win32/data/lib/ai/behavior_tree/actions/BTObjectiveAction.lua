BTObjectiveAction = BTObjectiveAction or class(BTNode)
function BTObjectiveAction:init(identifier, parent, condition_name, hook_name)
  BTNode.init(self, identifier, parent, condition_name, hook_name)
end
function BTObjectiveAction:name()
  return "BTObjectiveAction"
end
function BTObjectiveAction:enter(unit, t, dt)
  local aidata = unit:ai_data()
  aidata.bot_next_objective_path = 0
  aidata.bot_next_objective_action = 0
  aidata.bot_objective_started_at = t
  BTBotUtility.set_movement(unit, "jog")
end
function BTObjectiveAction:leave(unit, t, dt)
  BTBotUtility.stop(unit)
end
function BTObjectiveAction:_find_nearest_objective(unit)
  local aidata = unit:ai_data()
  local member = BTBotUtility.member(unit)
  local networkgame = managers.networkgame
  if not (member and networkgame) then
    return nil
  end
  local allowed = member._carriable_data or {}
  local nearest
  local nearest_distance = math.huge
  local nearest_is_delivery = false
  local nearest_delivery_location
  local now = TimerManager:game():time()
  local position = unit:position()
  for _, objective in ipairs(networkgame._carriables or {}) do
    if alive(objective) then
      local data = objective:element_data()
      if data.type == "carriable" and allowed[objective:name()] then
        local carrier = data.carriable_carrier
        if carrier == member then
          for _, drop_zone in pairs(data.drop_zone or {}) do
            local location = drop_zone.location
            if location then
              local destination = location:position()
              local distance = (destination - position):length()
              if distance < nearest_distance then
                nearest = objective
                nearest_distance = distance
                nearest_is_delivery = true
                nearest_delivery_location = location
              end
            end
          end
        elseif not carrier and now >= aidata.bot_objective_cooldown_until then
          local distance = (objective:position() - position):length()
          if distance < nearest_distance then
            nearest = objective
            nearest_distance = distance
            nearest_is_delivery = false
          end
        end
      end
    end
  end
  return nearest, nearest_is_delivery, nearest_delivery_location
end
function BTObjectiveAction.scan(unit, t)
  local aidata = unit:ai_data()
  if t < aidata.bot_next_objective_scan then
    return
  end
  aidata.bot_next_objective_scan = t + 1
  local objective, delivering, delivery_location = BTObjectiveAction:_find_nearest_objective(unit)
  aidata.bot_objective = objective
  aidata.bot_delivering = delivering
  aidata.bot_delivery_location = delivery_location
  aidata.bot_delivery_pos = delivery_location and delivery_location:position() or nil
end
function BTObjectiveAction:_drop(unit, objective, member)
  local base = unit:base()
  local data = objective:element_data()
  local location
  for _, drop_zone in pairs(data.drop_zone or {}) do
    if drop_zone.location and drop_zone.location:inside(unit) then
      location = drop_zone.location
      break
    end
  end
  if not location then
    return false
  end
  BTBotUtility.stop(unit)
  -- Use the normal immediate drop animation path; Carriable:drop then fires
  -- the mission-script delivery event once the carried body comes to rest.
  if base.start_carriable_drop then
    base:start_carriable_drop("drop_carriable", true)
  else
    return false
  end
  return true
end
function BTObjectiveAction:run(unit, t, dt)
  local aidata = unit:ai_data()
  local member = BTBotUtility.member(unit)
  local objective = aidata.bot_objective
  if not (member and alive(objective)) then
    aidata.bot_objective = nil
    return
  end
  BTBotUtility.set_movement(unit, "jog")
  local data = objective:element_data()
  if data.carriable_carrier == member then
    local destination = aidata.bot_delivery_pos
    if not destination then
      BTObjectiveAction.scan(unit, t - 2)
      return
    end
    local distance = BTBotUtility.distance_to(unit, destination)
    if distance < BTBotUtility.OBJECTIVE_RADIUS and t >= aidata.bot_next_objective_action then
      aidata.bot_next_objective_action = t + 1
      if self:_drop(unit, objective, member) then
        aidata.bot_objective = nil
        aidata.bot_delivering = false
        aidata.bot_delivery_pos = nil
        aidata.bot_delivery_location = nil
      end
      return
    end
    if t >= aidata.bot_next_objective_path then
      aidata.bot_next_objective_path = t + 1.5
      BTBotUtility.path_to(unit, destination)
    end
    return
  end
  if data.carriable_carrier then
    aidata.bot_objective = nil
    return
  end
  local destination = objective:position()
  local distance = BTBotUtility.distance_to(unit, destination)
  if distance <= BTBotUtility.OBJECTIVE_RADIUS and t >= aidata.bot_next_objective_action then
    BTBotUtility.stop(unit)
    aidata.bot_next_objective_action = t + 1
    if Network:is_server() and Global.gametype_server then
      Global.gametype_server:request_pickup_carriable(objective, member)
    end
    return
  end
  if t >= aidata.bot_next_objective_path then
    aidata.bot_next_objective_path = t + 1.5
    BTBotUtility.path_to(unit, destination)
  end
  if t > aidata.bot_objective_started_at + 30 then
    aidata.bot_objective = nil
    aidata.bot_objective_cooldown_until = t + 4
    BTBotUtility.stop(unit)
  end
end
