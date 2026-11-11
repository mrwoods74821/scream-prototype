BTExecuteAction = BTExecuteAction or class(BTNode)
function BTExecuteAction:init(identifier, parent, condition_name, hook_name)
  BTNode.init(self, identifier, parent, condition_name, hook_name)
end
function BTExecuteAction:name()
  return "BTExecuteAction"
end
function BTExecuteAction:enter(unit, t, dt)
  local aidata = unit:ai_data()
  aidata.bot_execute_target = nil
  aidata.bot_execute_started_at = t
  BTBotUtility.stop(unit)
end
function BTExecuteAction:leave(unit, t, dt)
  BTBotUtility.stop(unit)
end
function BTExecuteAction:run(unit, t, dt)
  local aidata = unit:ai_data()
  local base = unit:base()
  local target = aidata.bot_execute_target or BTBotUtility.find_knocked_out_enemy(unit)
  if not (alive(target) and base and base._current_state) then
    aidata.bot_execute_target = nil
    return
  end
  if t > aidata.bot_execute_started_at + BTBotUtility.EXECUTE_TIMEOUT then
    aidata.bot_execute_target = nil
    aidata.bot_execute_started_at = t
    return
  end
  if base._current_state_name == "ground_executing" then
    return
  end
  if not target:damage_data().knocked_out or target:damage_data().dead then
    aidata.bot_execute_target = nil
    return
  end
  local distance_limit = tweak_data.mp_setting_defaults.KNOCKOUT_REVIVE_TRIGGER_DISTANCE or 250
  local body = target:body("Hips")
  local target_pos = body and body:center_of_mass() or target:position()
  if BTBotUtility.distance_to(unit, target_pos) >= distance_limit then
    aidata.bot_execute_target = nil
    return
  end
  if not base._current_state:can_do_interact_action() then
    return
  end
  BTBotUtility.set_stalker(unit, false, t)
  local player_data = unit:player_data()
  player_data.executing_player = target
  player_data.ground_execute_target_pos = target_pos - (target_pos - unit:position()):normalized() * 50
  base._current_state:safe_abort_of_actions({execute_player = true})
  base:play_redirect("ko_finisher_start")
  base:set_target_rot(Rotation(target_pos:with_z(0) - unit:position():with_z(0), math.UP))
  base:change_state("ground_executing")
  if Network:is_server() then
    ActionHandler:request_execute_knocked_out(unit, target)
  end
  aidata.bot_execute_target = target
end
