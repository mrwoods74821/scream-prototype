-- Server-authoritative survivor and Ghostface bot roster.
BotManager = BotManager or class()
BotManager.SURVIVOR_COUNT = 3
BotManager.GHOSTFACE_COUNT = 1
BotManager.SURVIVOR_ARCHETYPES = {"survivor_1", "survivor_2", "survivor_3", "survivor_4"}
BotManager.SURVIVOR_NAMES = {"Susan", "Melinda", "Brandon", "James"}

function BotManager:init()
  self._members = {}
  self._update_accumulator = 0
end

function BotManager:_is_scream_mode()
  local mode = managers.networkgame and managers.networkgame:get_wanted_gamemode() or ""
  return string.sub(mode, 1, 7) == "scream_"
end

function BotManager:_members_in_team(team_name)
  local team = managers.teammanager:get_team_by_name(team_name)
  local result = {}
  for _, member in pairs(team and team:get_members() or {}) do
    if not member:has_left_game() then
      result[#result + 1] = member
    end
  end
  return result
end

function BotManager:_spawn_point(member)
  local point
  if Global.gametype_server and Global.gametype_server.get_spawn_point then
    point = Global.gametype_server:get_spawn_point(member)
  end
  point = point or (managers.networkgame._spawn_points or {})[1]
  if not point then
    return nil
  end
  return {
    position = point.position or point[1],
    rotation = point.rotation or point[2] or Rotation()
  }
end

function BotManager:_location(point)
  return {
    name = function()
      return "bot_spawn"
    end,
    position = function()
      return point.position
    end,
    rotation = function()
      return point.rotation
    end,
    get_spawn_position = function()
      return point.position
    end
  }
end

function BotManager:_configure_member(member, role, index)
  local ghostface = role == "ghostface"
  member._bot_role = role
  member._bot_spawn_index = index
  member._bot_respawn_at = nil
  local team = member:get_team()
  member._carriable_data = {}
  for name, allowed in pairs(team and team:get_carriable_data() or {}) do
    member._carriable_data[name] = allowed
  end
  local unit = member:get_unit()
  if alive(unit) then
    unit:brain():make_enemy_slotmask()
    local data = unit:ai_data()
    data.bot_enabled = true
    data.bot_is_ghostface = ghostface
    data.bot_role = role
  end
end

function BotManager:_spawn(role, index)
  local ghostface = role == "ghostface"
  local team_name = ghostface and "team_b" or "team_a"
  local wanted = ghostface and BotManager.GHOSTFACE_COUNT or BotManager.SURVIVOR_COUNT
  if #self:_members_in_team(team_name) >= wanted or not managers.networkplayer:has_free_slots() then
    return false
  end
  local archetype_name = ghostface and "ghostface" or BotManager.SURVIVOR_ARCHETYPES[index]
  local archetype = tweak_data.archetypes.archetype_definitions[archetype_name]
  local team = managers.teammanager:get_team_by_name(team_name)
  if not archetype or not team then
    return false
  end
  local member = managers.networkplayer:register_player(managers.networkplayer:next_unique_id(), "spawn_probe", "npc", Network:server())
  local point = self:_spawn_point(member)
  managers.networkplayer:remove_player(member:get_id())
  if not point then
    return false
  end
  local character_name = ghostface and "Ghostface [BOT]" or BotManager.SURVIVOR_NAMES[index] .. " [BOT]"
  local spawned, player_id = managers.brain:spawn_npc(archetype, {
    character_name = character_name,
    team_name = team_name,
    behavior_tree = ghostface and "Ghostface" or "Survivor",
    skill_template = "normal",
    location = self:_location(point)
  })
  if not spawned then
    return false
  end
  self._members[player_id] = spawned
  self:_configure_member(spawned, role, index)
  Application:debug("[BotManager] spawned " .. character_name .. " in " .. team_name)
  return true
end

function BotManager:fill_bots()
  if not Network:is_server() or not self:_is_scream_mode() then
    return
  end
  local survivors = self:_members_in_team("team_a")
  local used = {}
  for _, member in ipairs(survivors) do
    if member._bot_spawn_index then
      used[member._bot_spawn_index] = true
    end
  end
  for index = 1, BotManager.SURVIVOR_COUNT do
    if #self:_members_in_team("team_a") >= BotManager.SURVIVOR_COUNT then
      break
    end
    if not used[index] then
      self:_spawn("survivor", index)
    end
  end
  if #self:_members_in_team("team_b") < BotManager.GHOSTFACE_COUNT then
    self:_spawn("ghostface", 1)
  end
end

function BotManager:update(t, dt)
  if not Network:is_server() then
    return
  end
  self._update_accumulator = self._update_accumulator + dt
  if self._update_accumulator < 0.5 then
    return
  end
  self._update_accumulator = 0
  for player_id, member in pairs(self._members) do
    if managers.networkplayer:get_member(player_id) == nil then
      self._members[player_id] = nil
    elseif member._dead then
      if not member._bot_respawn_at then
        local delay = member:get_team_setting("respawn_time") or managers.networkgame:get_setting_value("respawn_time") or 6
        member._bot_respawn_at = t + delay
      end
      local point = self:_spawn_point(member)
      if t >= member._bot_respawn_at and point and Global.gametype_server and Global.gametype_server:allow_to_spawn() then
        member:spawn_player_at(point)
        member._bot_respawn_at = nil
        self:_configure_member(member, member._bot_role, member._bot_spawn_index)
      end
    else
      member._bot_respawn_at = nil
    end
  end
end

function BotManager:clear_bots()
  for player_id, member in pairs(self._members) do
    if managers.networkplayer:get_member(player_id) then
      local unit = member:get_unit()
      if alive(unit) and unit:brain() then
        unit:brain():die()
      end
      managers.networkplayer:remove_player(player_id)
    end
    managers.brain._ai_members[player_id] = nil
  end
  self._members = {}
end
