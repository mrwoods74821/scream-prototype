-- Shared helpers for the survivor and Ghostface bot behavior trees.
-- All functions are called on the authoritative server from BTBrain.
BTBotUtility = BTBotUtility or {}

BTBotUtility.WANDER_RADIUS = 2400
BTBotUtility.WANDER_REACHED_DISTANCE = 130
BTBotUtility.FLEE_RADIUS = 1900
BTBotUtility.FLEE_DISTANCE = 2800
BTBotUtility.OBJECTIVE_RADIUS = 220
BTBotUtility.MELEE_RANGE = 190
BTBotUtility.SPECIAL_ATTACK_RANGE = 300
BTBotUtility.TAG_RANGE = 2200
BTBotUtility.EXECUTE_TIMEOUT = 7

function BTBotUtility.member(unit)
  local base = unit:base()
  return base and base:get_member()
end

function BTBotUtility.is_ghostface(unit)
  local aidata = unit:ai_data()
  if aidata.bot_is_ghostface then
    return true
  end
  local archetype = tweak_data.archetypes.archetype_definitions[unit:player_data().archetype]
  return archetype and archetype.NAME == "ghostface" or false
end

function BTBotUtility.stop(unit)
  local locomotion_data = unit:locomotion_data()
  locomotion_data.current_path = nil
  locomotion_data.move_target_sub_goal = nil
  locomotion_data.move_target_goal = nil
  locomotion_data.target_rotation = unit:rotation()
  unit:locomotion():stop_movement()
end

function BTBotUtility.set_movement(unit, movement_type)
  unit:locomotion_data().wanted_movement_type = movement_type
end

function BTBotUtility.path_to(unit, destination)
  if not destination then
    return false
  end
  return BTUtilityFunctions.recalc_path(unit, destination) == true
end

function BTBotUtility.distance_to(unit, destination)
  return destination and (destination - unit:position()):length() or math.huge
end

function BTBotUtility.face(unit, destination)
  if not destination then
    return
  end
  local direction = destination - unit:position()
  if direction:length() > 1 then
    unit:locomotion_data().target_rotation = Rotation(direction:with_z(0), math.UP)
  end
end

function BTBotUtility.archetype(unit)
  return tweak_data.archetypes.archetype_definitions[unit:player_data().archetype]
end

function BTBotUtility.find_enemy_members(unit)
  local member = BTBotUtility.member(unit)
  local team = member and member:get_enemy_team()
  return team and team:get_members() or {}
end

function BTBotUtility.find_knocked_out_enemy(unit)
  local archetype = BTBotUtility.archetype(unit)
  if not (archetype and archetype.CAN_EXECUTE) then
    return nil
  end
  local distance_limit = tweak_data.mp_setting_defaults.KNOCKOUT_REVIVE_TRIGGER_DISTANCE or 250
  local closest
  local closest_distance = distance_limit
  for _, member in pairs(BTBotUtility.find_enemy_members(unit)) do
    local enemy = member:get_unit()
    if alive(enemy) then
      local player_data = enemy:player_data()
      local damage_data = enemy:damage_data()
      if damage_data.knocked_out and not damage_data.dead and not player_data.is_being_revived and not player_data.suiciding and not player_data.disable_teammate_revival then
        local body = enemy:body("Hips")
        local enemy_pos = body and body:center_of_mass() or enemy:position()
        local distance = BTBotUtility.distance_to(unit, enemy_pos)
        if distance < closest_distance then
          closest = enemy
          closest_distance = distance
        end
      end
    end
  end
  return closest
end

function BTBotUtility.set_stalker(unit, enabled, t)
  local aidata = unit:ai_data()
  local base = unit:base()
  if not (base and base.archetype_data and base.archetype_data.HAS_STALKER_MODE) then
    return false
  end
  if aidata.bot_stalking == enabled then
    return true
  end
  if t < aidata.bot_next_stalker_toggle then
    return false
  end
  if enabled then
    local checker = unit:stalker_checker()
    if checker and checker:is_visible() then
      return false
    end
    if base._current_state and not base._current_state:can_do_ability_action() then
      return false
    end
    base:enter_stalker_mode()
    if Network:is_server() then
      Network:clients():set_stalker_mode(unit, unit:player_data().stalker_mode)
    end
  else
    base:force_exit_stalker_mode()
  end
  aidata.bot_stalking = unit:player_data().stalker_mode == true
  aidata.bot_next_stalker_toggle = t + 1
  return aidata.bot_stalking == enabled
end

function BTBotUtility.tag_target(unit, enemy, t)
  local aidata = unit:ai_data()
  local archetype = BTBotUtility.archetype(unit)
  if not (alive(enemy) and t >= aidata.bot_next_tag) then
    return false
  end
  local signature = archetype and archetype.SIGNATURE_MOVE
  if not (signature and signature.NAME == "tag_enemy") then
    return false
  end
  if BTBotUtility.distance_to(unit, enemy:position()) > BTBotUtility.TAG_RANGE then
    return false
  end
  local member = BTBotUtility.member(unit)
  local enemy_member = BTBotUtility.member(enemy)
  if not (member and enemy_member) then
    return false
  end
  aidata.bot_next_tag = t + (signature.COOLDOWN or 8)
  if enemy:player_data().tagged then
    return false
  end
  managers.tags:set_tag_status(enemy_member:get_id(), true, member:get_id())
  unit:play("scream_phone")
  return true
end

function BTBotUtility.special_attack(unit, enemy, t)
  local aidata = unit:ai_data()
  local base = unit:base()
  local player_data = unit:player_data()
  if not (alive(enemy) and player_data.stalker_mode and t >= aidata.bot_next_special_attack) then
    return false
  end
  if not (base and base._current_state and base._current_state:can_do_special_move_attack()) then
    return false
  end
  if BTBotUtility.distance_to(unit, enemy:position()) > BTBotUtility.SPECIAL_ATTACK_RANGE then
    return false
  end
  aidata.bot_next_special_attack = t + 4
  base:force_exit_stalker_mode()
  aidata.bot_stalking = false
  player_data.special_move_target_unit = enemy
  base:change_state("specialmoveattack")
  return true
end

function BTBotUtility.melee(unit, enemy, t)
  local aidata = unit:ai_data()
  if not alive(enemy) then
    return false
  end
  if t < aidata.bot_next_attack then
    return false
  end
  if BTBotUtility.distance_to(unit, enemy:position()) > BTBotUtility.MELEE_RANGE then
    return false
  end
  BTBotUtility.face(unit, enemy:position())
  local weapon = unit:inventory():get_current_weapon()
  if not alive(weapon) then
    return false
  end
  -- MPMelee consumes this on the next update through _check_fire_trigger_pressed.
  aidata.weapon.wants_to_fire = true
  aidata.bot_next_attack = t + 1.15
  return true
end
