BrainManager = BrainManager or class()
BrainManager.brains_per_update = 1
function BrainManager:init()
  self._all_brains = {}
  self._behavior_trees = {}
  self:load_all_trees()
  self._ai_members = {}
end
function BrainManager:add(brain)
  self._all_brains[brain._unit] = brain
end
function BrainManager:release(brain)
  self._all_brains[brain._unit] = nil
end
function BrainManager:update(t, dt)
  local profile_id = Profiler:start("brainmanager")
  local i = 0
  while i < BrainManager.brains_per_update do
    self._last_updated_unit = next(self._all_brains, self._last_updated_unit)
    if alive(self._last_updated_unit) then
      self._all_brains[self._last_updated_unit]:recieve_update(t, dt)
    end
    i = i + 1
  end
  Profiler:stop(profile_id, "brainmanager")
end
function BrainManager:mover_test()
  self._high_quality_mover = not self._high_quality_mover
  Application:debug("Setting HI QUALITY MOVER USED=", self._high_quality_mover)
  for unit, brain in pairs(self._all_brains) do
    unit:mover():set_high_quality(self._high_quality_mover)
  end
end
function BrainManager:reparse_brains()
  self:load_all_trees()
  for unit, brain in pairs(self._all_brains) do
    local tree_name = brain:behavior_tree():name()
    brain:load_brain(tree_name)
  end
end
function BrainManager:set_nav_graph(graph)
  self._nav_graph = graph
end
function BrainManager:nav_graph()
  return self._nav_graph
end
function BrainManager:load_all_trees()
  local tree_dir = "\\data\\lib\\ai\\beings\\npc\\"
  self:load_behavior_tree(tree_dir .. "guard.xml", "Guard")
  self:load_behavior_tree(tree_dir .. "normal.xml", "Normal")
  self:load_behavior_tree(tree_dir .. "attack_move.xml", "AttackMove")
  self:load_behavior_tree(tree_dir .. "dummy.xml", "Dummy")
  self:load_behavior_tree(tree_dir .. "shootout_bot.xml", "ShootOutBot")
  self:load_behavior_tree(tree_dir .. "survivor.xml", "Survivor")
  self:load_behavior_tree(tree_dir .. "ghostface.xml", "Ghostface")
end
function BrainManager:get_behavior_tree(tree_name)
  return self._behavior_trees[tree_name]
end
function BrainManager:load_behavior_tree(tree_name, explicit_name)
  local xml_node = self:_parse_xml(tree_name)
  if not xml_node then
    Application:error("[BrainManager] behavior tree missing: " .. tostring(tree_name))
    return
  end
  local bt = BehaviorTree:new(xml_node)
  self._behavior_trees[explicit_name or bt:name()] = bt
end
function BrainManager:_parse_xml(file_name)
  if File:config_exists(file_name) then
    local xml_node = File:parse_xml(file_name)
    if xml_node then
      return xml_node
    end
  end
  -- A loose dev boot keeps authored source XML under devroot/config/data.
  -- File:config_exists resolves the engine's compiled/source config paths.
  if File:config_exists(file_name) then
    return File:parse_xml(file_name)
  end
end
function BrainManager:resurrect()
  for player_id, member in pairs(self._ai_members) do
    if member._dead then
      return player_id, member
    end
  end
end
function BrainManager:spawn_npc(archetype, params)
  local ai_character_id
  local team = managers.teammanager:get_team_by_name(params.team_name)
  local team_id = team and team:get_id()
  assert(team_id)
  local player_id, member = self:resurrect()
  if not member then
    if managers.networkplayer:has_free_slots() then
      local unique_id = managers.networkplayer:next_unique_id()
      player_id = managers.networkplayer:register_player(unique_id, params.character_name, "npc", Network:server())
      member = managers.networkplayer:get_member(player_id)
      member:add_archetype(archetype)
      member:set_ai_controlled("npc", params.behavior_tree, params.skill_template, params.group_id)
      local clients = Network:clients()
      clients:register_player_on_client(params.character_name, player_id, false, 2)
      managers.teammanager:set_member_in_team(team, member)
      self._ai_members[player_id] = member
    else
      Application:debug("CANNOT SPAWN MORE AI ... max reached!")
    end
  else
    member:add_archetype(archetype)
    member:set_ai_controlled("npc", params.behavior_tree, params.skill_template, params.group_id)
    member:set_name(params.character_name)
    Network:clients():register_player_on_client(params.character_name, player_id, false, 3)
    managers.teammanager:set_member_in_team(team, member)
  end
  if member then
    local spawn_point
    if params.location then
      Application:debug("SPAWNING AI CHOOSEN LOCATION " .. params.location:name())
      local pos = params.location:get_spawn_position(true)
      spawn_point = {
        position = pos,
        rotation = params.location:rotation()
      }
    else
      Application:debug("SPAWNING AI AT USEEN LOCATION.")
      local enemy_players = managers.teammanager:get_all_member_units_for_side("team_a")
      local spawn_loc = self:get_unseen_spawn(enemy_players, 4000)
      if not spawn_loc then
        return nil
      end
      spawn_point = {
        position = spawn_loc:position(),
        rotation = spawn_loc:rotation()
      }
    end
    if not spawn_point or not spawn_point.position then
      return nil
    end
    member:spawn_player_at(spawn_point)
    member._unit:brain():make_enemy_slotmask()
    return member, player_id
  end
  return nil
end
function BrainManager:register_death_zones()
  local mask = managers.slot:get_mask("death_zone")
  local death_zones = World:find_units_quick("all", mask)
  for _, unit in ipairs(death_zones) do
    unit:set_body_collision_callback(callback(self, self, "death_zone_check"))
  end
end
function BrainManager:death_zone_check(tag, unit, colliding_body, other_unit, other_body)
  Application:debug("DEATH ZONE VICTIM: ", unit:name(), other_unit:name())
  if alive(other_unit) and other_unit:brain() then
    other_unit:damage():kill_instant(false, true)
  end
end
function BrainManager:spawn_bot(archetype_name, params)
  if not archetype_name then
    local archetypes = {
      "survivor_1",
      "gunslinger",
      "blaster",
      "ranger",
      "sniper"
    }
    archetype_name = archetypes[math.random(#archetypes)]
  end
  if managers.networkplayer:has_free_slots() then
    local character_name = params.character_name
    local unique_id = managers.networkplayer:next_unique_id()
    local ai_character_id = managers.networkplayer:register_player(unique_id, character_name, "bot", Network:server(), true)
    local ai_character_member = managers.networkplayer:get_member(ai_character_id)
    local team_name = params.team_name
    local team = managers.teammanager:get_team_by_name(team_name)
    local team_id = team and team:get_id()
    if team_id then
      managers.teammanager:change_team_by_id(ai_character_id, team_id)
      local archetype = tweak_data.archetypes.archetype_definitions[archetype_name]
      ai_character_member:add_archetype(archetype)
      ai_character_member:set_ai_controlled("bot", params.behavior_tree, params.skill_template, params.group_id)
      local clients = Network:clients()
      clients:register_player_on_client(character_name, ai_character_id, false, 1)
      managers.teammanager:set_member_in_team(team, ai_character_member)
      return true
    else
      managers.networkplayer:remove_player(ai_character_id)
    end
  else
    Application:debug("BrainManager:spawn_bot: No free slots, no units spawned")
  end
  return false
end
function BrainManager:get_unseen_spawn(player_units, wanted_dist)
  local spawn_collection = managers.location:get_location("npc_spawn")
  if not spawn_collection then
    return
  end
  local locations = spawn_collection:contains()
  local player_unit = player_units[1]
  local pos, rot
  if not player_unit then
    local any = managers.location:get_location(next(locations))
    return any
  else
    pos = player_unit:position()
    rot = player_unit:camera():get_camera_rotation()
  end
  local best_diff = 100000
  local best_loc
  local player_dir = rot:y():normalized()
  for name, loc in pairs(locations) do
    local loc_dir = loc:rotation():y():normalized()
    local loc_pos = loc:position()
    local to_spawn_dir = loc_pos - pos
    local in_front_dot = to_spawn_dir:dot(player_dir) > 0.5
    local dot = in_front_dot and loc_dir:dot(player_dir) or -loc_dir:dot(player_dir)
    if 0.5 < dot then
      local dist = (loc_pos - pos):length()
      local diff = math.abs(dist - wanted_dist)
      if best_diff > diff then
        best_diff = diff
        best_loc = loc
        if diff < 1000 then
          return best_loc
        end
      end
    end
  end
  if not best_loc then
    Application:debug("No unseen NPC-spawn pos found!")
    local any = managers.location:get_location(next(locations))
    return any
  end
  return best_loc
end
function BrainManager:get_members()
  return self._ai_members
end
