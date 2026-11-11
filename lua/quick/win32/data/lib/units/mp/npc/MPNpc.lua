require("units/mp/npc/MPNpcStates")
MPNpc = MPNpc or class(PlayerBase)
GLOBAL_NPC_NETWORK_SEND = true
function MPNpc:init(unit)
  PlayerBase.init(self, unit)
  self._member = nil
  local weapons = tweak_data.archetypes.archetype_definitions[self._upd.archetype].weapons
  self._inventory:setup(self._controller, weapons)
  self:set_tweak_data_variables()
  self._reload_callback_id = tweak_data:add_reload_callback(callback(self, self, "_resync_tweak_data"))
  self._is_husk = true
  self._emitter = managers.action_event:create_emitter()
  self._anim_state_machine:set_callback_object(self)
  local torso = self._unit:get_object("Spine1")
  self._unit:unit_data().player_autotarget_objects = self._unit:unit_data().player_autotarget_objects or {}
  self._unit:unit_data().player_autotarget_objects.torso = torso
  self._states = {
    onground = MPNpcEmptyState:new(unit),
    specialmoveattack = MPNpcSpecialMoveAttack:new(unit),
    ground_executing = MPNpcGroundExecuting:new(unit)
  }
  self._current_state = self._states.onground
  self._current_state_name = "onground"
  self._stalker_checker = unit:stalker_checker()
  self._dummy_controller = {
    get_input_axis = function()
      return Vector3(0, 0, 0)
    end
  }
end
function MPNpc:setup_member(member)
  self._member = self._member or member
  if self._stalker_checker and self._member then
    self._stalker_checker._member = self._member
  end
end
function MPNpc:get_member()
  return self._member
end
function MPNpc:update(unit, t, dt)
  PlayerBase.update(self, unit, t, dt)
  if self._current_state and self._current_state.update then
    self._current_state:update(t, dt)
  end
  self:_update_ik()
  if self._upd.special_move_grappled then
    local attacker_unit = self._upd.special_move_attacker_unit
    if alive(attacker_unit) then
      local unit = self._unit
      local pos = attacker_unit:position()
      local rot = attacker_unit:rotation()
      unit:base():set_position(pos)
      unit:set_rotation(rot)
    end
  end
end
function MPNpc:die()
  local unit = self._unit
  unit:set_slot(0)
end
function MPNpc:change_state(state)
  local new_state = self._states and self._states[state]
  if not new_state then
    Application:debug("[MPNpc] ignoring unavailable state " .. tostring(state))
    return
  end
  if self._current_state and self._current_state.exit then
    self._current_state:exit(state)
  end
  self._current_state = new_state
  self._current_state_name = state
  new_state:enter("onground", self._dummy_controller)
  local id = managers.networklookup:get_id(state)
  managers.network:send_unit_rpc("ordered", "change_state", self._unit, id)
end
function MPNpc:dead()
  if Network:is_server() then
    self._unit:brain():die()
  end
  self._unit:set_extension_update_enabled("base", false)
  self._unit:set_extension_update_enabled("locomotion", false)
end
function MPNpc:hurt_standard(position, direction)
end
function MPNpc:play(s)
  Debug:write("MPNpc", "sound( " .. s .. ")")
end
function MPNpc:play_state(redir, override)
  local res = Actor.play_state(self, redir, override)
  if res and res ~= "" then
    Debug:write("MPNpc", "MPNpc:play_state( " .. tostring(redir) .. ", " .. tostring(override) .. ")")
    if GLOBAL_NPC_NETWORK_SEND then
      managers.network:send_unit_rpc("ordered", "play_state", self._unit, res)
    end
  end
  return res
end
function MPNpc:play_redirect(redir, override)
  local res = Actor.play_redirect(self, redir, override)
  if res and res ~= "" then
    Debug:write("MPNpc", "MPNpc:play_redirect( " .. tostring(redir) .. ", " .. tostring(override) .. ")")
    if GLOBAL_NPC_NETWORK_SEND then
      managers.network:send_unit_rpc("ordered", "play_state", self._unit, res)
    end
  end
  return res
end
function MPNpc:stop_segment(segment)
  Actor.stop_segment(self, segment)
  local id = managers.networklookup:get_id(segment)
  if GLOBAL_NPC_NETWORK_SEND then
    managers.network:send_unit_rpc("ordered", "stop_segment", self._unit, id)
  end
end
function MPNpc:anim_play(anim, speed)
  Actor.anim_play(self, anim, speed)
  speed = speed or 0
  local id = managers.networklookup:get_id(anim)
  if GLOBAL_NPC_NETWORK_SEND then
    managers.network:send_unit_rpc("ordered", "anim_play", self._unit, id, speed)
  end
end
function MPNpc:anim_play_to(anim, time, speed)
  Actor.anim_play_to(self, anim, time, speed)
  local id = managers.networklookup:get_id(anim)
  if GLOBAL_NPC_NETWORK_SEND then
    managers.network:send_unit_rpc("ordered", "anim_play_to", self._unit, id, time, speed)
  end
end
function MPNpc:anim_set_time(anim, time)
  Actor.anim_set_time(self, anim, time)
  local id = managers.networklookup:get_id(anim)
  if GLOBAL_NPC_NETWORK_SEND then
    managers.network:send_unit_rpc("ordered", "anim_set_time", self._unit, id, time)
  end
end
function MPNpc:activate_gun_state(gun)
  local locomotion = self._unit:locomotion()
  local base_state, base_group, base_redirect
  if gun == "rifle" then
    self:play_redirect("goto_right_arm_rifle")
    base_state = "onground/rifle/stand/noaim/idle/look"
    base_group = "onground"
  elseif gun == "revolver" then
    self:play_redirect("goto_right_arm_revolver")
    base_state = "onground/revolver/stand/noaim/idle/look"
    base_group = "onground"
  elseif gun == "no_gun" then
    self:play_state("right_arm/empty")
    base_redirect = "look"
    base_group = "onground"
  elseif gun == "carriable" then
    self:play_state("right_arm/empty")
    base_redirect = "look"
  end
  if base_state then
    locomotion:set_animation_base_state(base_state, base_redirect)
  end
  if base_group then
    locomotion:set_animation_base_group(base_group)
  end
end
function MPNpc:can_toggle_weapon()
  return true
end
function MPNpc:can_reload()
  return true
end
function MPNpc:can_shoot()
  return true
end
function MPNpc:set_recent_weapon_switch()
end
function MPNpc:can_use_weapon()
  return true
end
function MPNpc:set_aim_time(t, override)
  if self:can_shoot() or override then
    self._aim_time = t
  end
end
function MPNpc:play_hit_effect(damage, unit, camera, body_name)
  self._emitter:hit_effect(math.floor(damage), unit, camera, body_name)
end
function MPNpc:anim_evade_begin(unit)
  self._unit:locomotion_data().evading = true
end
function MPNpc:anim_evade_end()
  self._unit:locomotion_data().evading = false
end
function MPNpc:spotted_by_sniper(sniper_unit)
end

function MPNpc:enter_stalker_mode()
  local unit = self._unit
  local player_data = self._upd
  player_data.stalker_mode = true
  unit:set_visible(false)
  unit:set_slot(48)
  local weapon = self._inventory:get_current_weapon()
  if alive(weapon) then
    weapon:set_visible(false)
  end
  local speed = self.archetype_data.STALKER_SPEED or 1.5
  self._anim_state_machine:set_global("walking_speed", self._original_speed.walking * speed, "jogging_speed", self._original_speed.jogging * speed, "running_speed", self._original_speed.running * speed)
end
function MPNpc:exit_stalker_mode()
  local unit = self._unit
  self._upd.stalker_mode = false
  unit:set_visible(true)
  unit:set_slot(4)
  local weapon = self._inventory:get_current_weapon()
  if alive(weapon) then
    weapon:set_visible(true)
  end
  local speed = self.archetype_data.SPEED or 1
  self._anim_state_machine:set_global("walking_speed", self._original_speed.walking * speed, "jogging_speed", self._original_speed.jogging * speed, "running_speed", self._original_speed.running * speed)
  unit:play("scream_decloak")
end
function MPNpc:force_exit_stalker_mode()
  if self._upd.stalker_mode then
    self:exit_stalker_mode()
    if Network:is_server() then
      Network:clients():set_stalker_mode(self._unit, false)
    end
  end
end
function MPNpc:set_target_rot(rot)
  self._unit:set_rotation(rot)
end
function MPNpc:execute_other_player(executed_unit, success)
  if success and self._current_state_name == "ground_executing" then
    self._current_state:execute_acknowledged()
  elseif self._upd.executing_player then
    self._upd.executing_player = nil
    self:change_state("onground")
  end
end
function MPNpc:special_move_grapple_request_granted(victim_unit)
  if self._current_state_name == "specialmoveattack" then
    self._current_state:grapple_request_granted(victim_unit)
  end
end
function MPNpc:special_move_grapple_request_denied()
  if self._current_state_name == "specialmoveattack" then
    self._current_state:grapple_request_denied()
  end
end
function MPNpc:end_special_move_lunge_anim_cb()
  self:change_state("onground")
end
function MPNpc:exit_special_move_execute_anim_cb()
  self:change_state("onground")
end
function MPNpc:attach_carriable(carriable_unit, carriable_rp_name, player_link_obj)
  if not alive(carriable_unit) then
    return
  end
  carriable_unit:link(player_link_obj, self._unit, carriable_rp_name)
  self._upd.carriable_unit = carriable_unit
  self._upd.carrying = true
  local physics_body = carriable_unit:body("physics_body")
  local pickup_body = carriable_unit:body("pickup_collision_body")
  if physics_body then
    physics_body:set_enabled(false)
  end
  if pickup_body then
    pickup_body:set_enabled(false)
  end
end
function MPNpc:start_carriable_drop()
  local member = self._member
  if not member then
    return
  end
  local carriable_unit = member:carriable_dropped()
  if alive(carriable_unit) then
    carriable_unit:unlink()
    local physics_body = carriable_unit:body("physics_body")
    local pickup_body = carriable_unit:body("pickup_collision_body")
    if physics_body then
      physics_body:set_enabled(true)
    end
    if pickup_body then
      pickup_body:set_enabled(true)
    end
  end
  self._upd.carriable_unit = nil
  self._upd.carrying = false
  self._upd.dropping_carriable = false
end
function MPNpc:clear_carriable_data()
  self._upd.carriable_unit = nil
  self._upd.carrying = false
  self._upd.dropping_carriable = false
end
function MPNpc:abort_carrying()
  self:clear_carriable_data()
end
function MPNpc:from_server_force_drop_carriable(carriable_unit)
  Actor.from_server_force_drop_carriable(self, carriable_unit)
  self:clear_carriable_data()
end
function MPNpc:enter_revive_anim_cb()
  self._reviving_sound_instance = self._unit:play("revive")
end
function MPNpc:end_revive_anim_cb()
  self._unit:locomotion_data().hibernate = false
  self._unit:ai_data().reviving_progress = "finished"
end
function MPNpc:special_move_grappled(attacker_unit)
  if alive(attacker_unit) then
    local unit = self._unit
    local upd = self._upd
    upd.special_move_grappled = true
    upd.special_move_attacker_unit = attacker_unit
    unit:kill_mover()
    unit:set_driving("animation")
    unit:base():play_redirect("execute_start", true)
  end
end
function MPNpc:enter_special_move_grappled_anim_cb()
  Application:debug("[MPNpc:enter_special_move_grappled_anim_cb()] unit:", self._unit, "current_state_name:", self._anim_state_machine:segment_state("body_base"))
  self._sound_instance_scream_strangle = self._unit:play("strangle")
end
function MPNpc:enter_special_move_executed_anim_cb()
  local upd = self._upd
  upd.special_move_grappled = false
  upd.special_move_attacker_unit = nil
  if self._sound_instance_scream_strangle and alive(self._sound_instance_scream_strangle) then
    self._sound_instance_scream_strangle:stop()
    self._sound_instance_scream_strangle = nil
  end
  local neck = self._unit:get_object("Neck")
  World:effect_manager():spawn({
    effect = "knife_throat",
    parent = neck,
    rotation = Rotation(0, 0, 0)
  })
end
