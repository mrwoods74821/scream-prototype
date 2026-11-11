require("shared/external/MathUtils")
require("managers/TagManager")
NetworkGameManager = NetworkGameManager or class()
function NetworkGameManager:init()
  self._current_level = nil
  self._settings = NetworkGameSettings:new()
  self:load_globals()
  self._flag_red = nil
  self._flag_blue = nil
  self._carriables = {}
  self._zone_red = nil
  self._zone_blue = nil
  self._motd = nil
  Global.gametype = nil
  Global.gametype_server = nil
  Global.local_member = nil
  self._spawn_points = {}
  self._spawnpoints = {}
  self._viewpoints = {}
  self._element_units = {}
  self.mounted_weapons = {}
  if SystemInfo:platform() == "PS3" then
    Application:debug("**** NetworkGameManager - PSN:set_online_callback *****")
    PSN:set_online_callback(callback(self, self, "ps3_disconnect"))
  end
  self._emitter = managers.action_event:create_emitter()
end
function NetworkGameManager:kill_member(member_id)
  local member = managers.networkplayer:get_member(member_id)
  if member then
    member:kill()
  else
    Application:error("NetworkGameManager:kill_member(). - No member with id: " .. member_id)
  end
end
function NetworkGameManager:set_wanted_gamemode(gamemode, set_for_dedicated)
  self._settings.game_mode = gamemode
  managers.networklookup:init_gamemode_settings(set_for_dedicated)
end
function NetworkGameManager:get_wanted_gamemode()
  return self._settings.game_mode
end
function NetworkGameManager:set_allow_empty(flag)
  self._settings.allow_empty = flag
end
function NetworkGameManager:flag_red()
  return self._flag_red
end
function NetworkGameManager:flag_blue()
  return self._flag_blue
end
function NetworkGameManager:disable_zone(id)
  if self._zone_red and self._zone_blue then
    if id == 2 then
      self._zone_blue:set_enabled(false)
    else
      self._zone_red:set_enabled(false)
    end
  end
end
function NetworkGameManager:load_settings_from_global()
end
function NetworkGameManager:sync_setting_to_clients(name, value)
  Network:clients():from_server_setting(name, value)
end
function NetworkGameManager:send_settings_to(rpc)
  Application:debug("JOW Sending settings to client:")
  for name, value in pairs(self._settings) do
    Application:debug("JOW ", name, " = ", value)
    rpc:from_server_setting(name, tostring(value))
  end
end
function NetworkGameManager:receive_setting(name, value)
  Application:debug("JOW Receiveing setting:", name, "=", value)
  local setting_val = value
  if tonumber(value) then
    setting_val = tonumber(value)
  elseif value == "true" then
    setting_val = true
  elseif value == "false" then
    setting_val = false
  end
  self._settings[name] = setting_val
end
function NetworkGameManager:collision_callback(tag, unit, colliding_body, other_unit, other_body, position, normal, velocity)
  local member = managers.networkplayer:get_member_from_unit(other_unit)
  if member then
    if unit:element_data().type == "deatharea" then
      member:deatharea_collision()
    elseif unit:element_data().type == "team_flag" then
      member:pickup_flag(unit)
    elseif unit:element_data().type == "team_zone" then
      member:enter_zone(unit)
    elseif unit:element_data().type == "carriable" then
      member:carriable_available(unit)
    elseif unit:element_data().type == "respawn" then
      member:respawn_available(unit)
    end
  elseif unit:element_data().type == "carriable" then
    unit:base():carriable_collision(tag, unit, colliding_body, other_unit, other_body, position, normal, velocity)
  end
end
function NetworkGameManager:report_element_unit(unit)
  if not self._element_units[unit:element_data().type] then
    self._element_units[unit:element_data().type] = {}
  end
  table.insert(self._element_units[unit:element_data().type], unit)
  if unit:element_data().type == "viewpoint" then
    self:add_viewpoint(unit)
  end
  if unit:element_data().type == "spawn_point" then
    self:add_spawnpoint(unit)
    self:add_spawn_point(unit:position(), unit:rotation())
  end
  if unit:element_data().type == "team_flag" then
    unit:set_body_collision_callback(callback(self, self, "collision_callback"))
    unit:element_data().start_position = unit:position()
    unit:element_data().start_rotation = unit:rotation()
    if unit:element_data().name == "team_a" then
      self._flag_red = unit
    end
    if unit:element_data().name == "team_b" then
      self._flag_blue = unit
    end
  end
  if unit:element_data().type == "deatharea" or unit:element_data().type == "team_zone" then
    unit:set_body_collision_callback(callback(self, self, "collision_callback"))
    if unit:element_data().type == "team_zone" then
      if unit:element_data().name == "team_a" then
        self._zone_red = unit
      else
        self._zone_blue = unit
      end
    end
  end
  if unit:element_data().type == "carriable" then
    unit:set_body_collision_callback(callback(self, self, "collision_callback"))
    unit:element_data().start_position = unit:position()
    unit:element_data().start_rotation = unit:rotation()
    table.insert(self._carriables, unit)
  end
  if unit:element_data().type == "respawn" then
    unit:set_body_collision_callback(callback(self, self, "collision_callback"))
    unit:element_data().start_position = unit:position()
    unit:element_data().start_rotation = unit:rotation()
    if unit:element_data().name == "team_a" then
      self._flag_red = unit
    end
    if unit:element_data().name == "team_b" then
      self._flag_blue = unit
    end
  end
  if unit:element_data().type == "mounted_weapon" then
    unit:element_data().start_position = unit:position()
    unit:element_data().start_rotation = unit:rotation()
    self.mounted_weapons[unit] = {}
    self.mounted_weapons[unit].user_member_id = nil
  end
end
function NetworkGameManager:get_element_units(unit_type)
  if self._element_units[unit_type] then
    return self._element_units[unit_type]
  end
  Application:error("There was no unit in the element_list with that type:", unit_type)
end
function NetworkGameManager:add_viewpoint(unit)
  table.insert(self._viewpoints, {
    position = unit:position(),
    rotation = unit:rotation()
  })
end
function NetworkGameManager:add_spawnpoint(unit)
  local spawnpoint_name = unit:element_data().name
  if not self._spawnpoints[spawnpoint_name] then
    cat_debug("multiplayer", "No position in self._spawnpoints list with key: " .. spawnpoint_name .. "   >> Creating one!")
    self._spawnpoints[spawnpoint_name] = {}
  end
  cat_debug("multiplayer", "Adding a spawnpoint in list at: " .. spawnpoint_name)
  table.insert(self._spawnpoints[spawnpoint_name], {
    position = unit:position(),
    rotation = unit:rotation()
  })
end
function NetworkGameManager:add_spawn_point(position, rotation)
  table.insert(self._spawn_points, {position = position, rotation = rotation})
end
function NetworkGameManager:get_setting_value(name)
  return self._settings[name]
end
function NetworkGameManager:settings()
  return self._settings
end
function NetworkGameManager:loading_screen_settings()
  local settings = {}
  for setting, value in pairs(self._settings) do
    settings[setting] = value
  end
  if settings.flag_limit == 0 then
    settings.flag_limit = nil
  end
  if settings.frag_limit == 0 then
    settings.frag_limit = nil
  end
  if settings.time_limit == 0 then
    settings.time_limit = nil
  end
  if settings.limited_spawns == 0 then
    settings.limited_spawns = false
  end
  settings.allow_dropin_join = nil
  settings.allow_empty = nil
  settings.use_team_spawns = nil
  settings.number_of_teams = nil
  settings.game_mode = nil
  return settings
end
function NetworkGameManager:set_motd(text)
  if text == "" then
    self._motd = nil
  else
    self._motd = text
  end
end
function NetworkGameManager:get_motd()
  return self._motd
end
function NetworkGameManager:get_viewpoint(lastviewpoint)
  if #self._viewpoints == 0 then
    return nil
  end
  if lastviewpoint then
    local nextviewpoint = lastviewpoint + 1
    if nextviewpoint > #self._viewpoints then
      nextviewpoint = 1
    end
    return self._viewpoints[nextviewpoint], nextviewpoint
  else
    return self._viewpoints[math.random(#self._viewpoints)]
  end
end
function NetworkGameManager:get_spawn_point(member)
  local spawn_point
  if Global.gametype_server then
    spawn_point = Global.gametype_server:get_spawn_point(member)
    if spawn_point then
      return spawn_point
    end
  else
    assert(false, "No gametype_server in  NetworkGameManager:get_spawn_point")
  end
  assert(false, "No spawn point found in  NetworkGameManager:get_spawn_point. Maybe you forgot SetSpawnLocation in rules.xml for a team?")
end
function NetworkGameManager:get_spawn_points_by_team(team)
  local team_spawn_points
  local team_name = team._team_name
  if team then
    cat_debug("multiplayer", "I got a team, getting spawnpoint for team: " .. team_name)
    team_spawn_points = self._spawnpoints[team_name]
  end
  if not team_spawn_points then
    cat_debug("multiplayer", "Got no team spawns. Spawning at a neutral spawnpoint.")
    team_spawn_points = self._spawnpoints.neutral
  end
  return team_spawn_points
end
function NetworkGameManager:save_globals()
  Global.NetworkGame = self
end
function NetworkGameManager:load_globals()
  if Global.NetworkGame then
    for k, v in pairs(Global.NetworkGame) do
      self[k] = v
    end
    Global.NetworkGame = nil
  end
end
function NetworkGameManager:current_level()
  return self._current_level
end
function NetworkGameManager:shuffle_players_between_teams()
  local variant = managers.networklookup:get_current_gamemode_setting("shuffle_teams")
  if variant == "scream" then
    managers.teammanager:swap_defenders_by_chronological_order()
  end
end
function NetworkGameManager:load_level(zone)
  if managers.bot then
    managers.bot:clear_bots()
  end
  if managers.menu then
    managers.menu:disable_menu_workspace()
  end
  self._current_level = zone
  Global.zone_data.load_zone = zone
  Global.zone_data.load_stage = "stage1"
  Global.zone_data.script_class = "DefaultMPLevel"
  self._spawn_points = {}
  self._players = {}
  managers.transition:clear()
  managers.transition:disable_gui()
  managers.transition:set_loading_screen_enabled(true)
  managers.transition._start_loading = true
  if managers.network.voice_chat then
    managers.network.voice_chat:_save_globals(false)
  end
  managers.network:unbind_port()
  Network:reset_all_timeouts(3600000)
  small_loading = false
  managers.transition._start_loading = true
  managers.transition:cleanup_engine_persistent_states()
  self._map = managers.networklookup:get_map(self._current_level)
  cat_print("join", "[Join] NetworkGameManager:load_level", managers.zones:get_level_name())
  cat_print("join", "[Join] Application:exec =============================================")
  Application:exec("levels/zone", managers.zones:get_level_name())
  self:save_globals()
end
function NetworkGameManager:save_players_list(players)
  cat_print("join", "[Join] NetworkGameManager:save_players_list(players)")
  cat_print_inspect("join", players)
  Global.mp_loading = {}
  for k, v in pairs(players) do
    local id = 0
    if v.pnid then
      id = v.pnid
    end
    if v.xuid then
      id = v.xuid
    end
    if v.id then
      id = v.id
    end
    if v.player_id then
      id = v.player_id
    end
    if id == 0 then
      Application:throw_exception("COULD NOT EXTRACT PLAYER ID FROM PLAYER LIST")
    end
    table.insert(Global.mp_loading, {
      name = v.name,
      player_id = tostring(id)
    })
  end
  cat_print_inspect("lobby", Global.mp_loading)
end
function NetworkGameManager:custom_gamemode()
  return managers.networklookup:custom_gamemode(self._settings.game_mode)
end
function NetworkGameManager:get_song_name()
  if tweak_data.level.dont_play_music then
    return "multiplayer_song"
  end
  local mode_setting = self._map._modes[self._settings.game_mode]
  local gamemode_music = mode_setting.music
  if gamemode_music then
    return gamemode_music
  end
  local generic_map_music = self._map._settings.music
  if generic_map_music then
    return generic_map_music
  end
  return "multiplayer_song"
end
function NetworkGameManager:done_loading()
  Global.in_game = true
  cat_print("join", "[Join] NetworkGameManager:done_loading()")
  self:load_settings_from_global()
  managers.teammanager = managers.teammanager or TeamManager:new()
  managers.teammanager:setup()
  managers.tags = managers.tags or TagManager:new()
  if not Global.building_file_order and not Global.dedicated then
    managers.music:preload_songs(self:get_song_name())
  end
  World:preload_unit("dev_collision_dummy_sphere", true)
  World:preload_unit("mp_player_ghostface", true)
  World:preload_unit("mp_player_ghostface_husk", true)
  World:preload_unit("mp_player_survivor_1", true)
  World:preload_unit("mp_player_survivor_1_husk", true)
  World:preload_unit("mp_player_survivor_2", true)
  World:preload_unit("mp_player_survivor_2_husk", true)
  World:preload_unit("mp_player_survivor_3", true)
  World:preload_unit("mp_player_survivor_3_husk", true)
  World:preload_unit("mp_player_survivor_4", true)
  World:preload_unit("mp_player_survivor_4_husk", true)
  World:preload_unit("mp_npc_survivor_1", true)
  World:preload_unit("mp_npc_ghostface", true)
  managers.environment:preload_environment("scream_ghostface")
  if self._settings.using_ai or tweak_data.mp_setting_defaults.BOTS_PLAYING then
    World:preload_unit("mp_npc_gunslinger_red", true)
    World:preload_unit("mp_npc_ranger_red", true)
    World:preload_unit("mp_npc_blaster_red", true)
    World:preload_unit("mp_npc_sniper_red", true)
    World:preload_unit("mp_npc_gunslinger_blue", true)
    World:preload_unit("mp_npc_ranger_blue", true)
    World:preload_unit("mp_npc_blaster_blue", true)
    World:preload_unit("mp_npc_sniper_blue", true)
  end
  World:effect_manager():set_rendering_enabled(true)
  if Network:is_client() then
    cat_print("join", "[Join] Network is client")
    managers.network:bind_port()
    local username = tostring(managers.network.account:username())
    local temp = Global.my_ranking
    Network:server():from_client_loading_done(username, Global.my_ranking, self._current_level)
    managers.networkplayer:create_ghost(Network:self())
    managers.networkplayer:toggle_ghost(true)
    managers.location:load_current()
    Network:reset_all_timeouts(30)
    local dialog_config = {
      timeout = 30,
      show_timeout = true,
      on_timeout_callback = callback(self, self, "close_message_go_to_lobby")
    }
    managers.dialog:open_dialog("waiting_for_server", dialog_config)
    if not Global.lobby_handler and SystemInfo:platform() == "WIN32" then
      Application:debug("NetworkGameManager:done_loading Global.gameserver_ip=", Global.gameserver_ip)
      if Global.gameserver_ip and Global.gameserver_ip ~= "" then
        local res, c = Network:connection_details(Network:server())
        local server_ip_port = "127.0.0.1:1"
        if res then
          server_ip_port = tostring(c.ip) .. ":" .. tostring(c.port)
        end
        Application:debug("server ip port : global(" .. Global.gameserver_ip .. ") by connection details(" .. server_ip_port .. ")")
        local to_auth = tweak_data.network.steam.gameserver_auth_from_connection_details and server_ip_port or Global.gameserver_ip
        Network:authentication_session_start(to_auth)
      end
    end
    Global.gameserver_ip = nil
  elseif Network:is_server() then
    if managers.steam and Global.lobby_handler then
      Global.lobby_handler:send_message({start_game = "yes"})
    end
    cat_print("join", "[Join] Network is server, reset game mode")
    self:create_gamemode()
    local world_directory = managers.worlddefinition:world_dir()
    local success = managers.ai_graph:load(world_directory)
    if success then
      local nav_graph = Search:nav("surface_human")
      managers.brain:set_nav_graph(nav_graph)
    end
    managers.location:load_current()
    managers.event:load_mission()
    managers.network:bind_port()
  end
  if Global.mp_loading then
    local temp = Global.mp_loading
    if Network:is_server() then
    end
    cat_print("join", "[Join] NetworkGameManager:done_loading()")
    cat_print_inspect("lobby", Global.mp_loading)
    self._loading_clients = self._loading_clients or {}
    self._ready_clients = self._ready_clients or {}
    for k, v in pairs(Global.mp_loading) do
      table.insert(self._loading_clients, {
        name = v.name,
        player_id = v.player_id,
        ready = false,
        timedout = false,
        archetype = nil
      })
    end
    Global.mp_loading = nil
  end
  if self._settings.game_mode == "strawberry_ctf" then
    managers.platform:set_presence("MPStrawberryCTF")
  elseif self:custom_gamemode() then
    managers.platform:set_presence("Wont work")
  end
  local fade = tweak_data.player.overlay.player_fade_in_mp
  self._overlay_eff_fade_id = managers.overlay_effect:play_effect(fade)
end
function NetworkGameManager:add_loading_client(client)
  self._loading_clients = self._loading_clients or {}
  self._ready_clients = self._ready_clients or {}
  local name = client.name
  for _, player in ipairs(self._loading_clients) do
    if player.name == name then
      return
    end
  end
  local id = client.pnid or client.xuid or client.id or client.player_id
  if not id then
    Application:throw_exception("COULD NOT EXTRACT PLAYER ID")
  end
  cat_print("join", "[Join] NetworkGameManager:add_loading_client", tostring(id))
  table.insert(self._loading_clients, {
    name = name,
    player_id = tostring(id),
    ready = false,
    timedout = false
  })
end
function NetworkGameManager:remove_loading_status()
  self._loading_clients = nil
end
function NetworkGameManager:client_done(name, player_id, rpc)
  cat_print("join", "[Join] NetworkGameManager:client_done():", name, player_id, rpc)
  if Network:is_server() then
    if tweak_data.mp_setting_defaults.archetype_selection.IS_RANDOM then
      Global.gametype_server:random_select_archetype(managers.networkplayer:get_member_from_rpc(rpc):get_id())
    else
      rpc:send_archetype_to_server()
    end
  end
  if not self._loading_clients then
    Application:error("No loading clients: ", name, player_id)
    return
  end
  rpc:from_server_loading_state(tostring(managers.network.account:username()), tostring(managers.network.account:player_id()), true)
  for k, v in pairs(self._loading_clients) do
    if v.player_id == player_id then
      v.ready = true
      self._ready_clients[k] = v
    else
      rpc:from_server_loading_state(v.name, v.player_id, v.ready)
    end
  end
  Network:clients_except(rpc):from_server_loading_state(name, player_id, true)
  for k, v in pairs(self._loading_clients) do
    if v.ready == false then
      return
    end
  end
  self._loading_clients = nil
end
function NetworkGameManager:set_loading_state(name, player_id, ready)
  cat_print("join", "[Join] NetworkGameManager:set_loading_state():", name, player_id, ready)
  if not self._loading_clients then
    return
  end
  for k, v in pairs(self._loading_clients) do
    if v.player_id == player_id then
      v.ready = ready
      if ready == true then
      end
      return
    end
  end
  for k, v in pairs(self._loading_clients) do
    if v.ready == false then
      return
    end
  end
  self._loading_clients = nil
end
function NetworkGameManager:create_gamemode(hot_join)
  local is_custom = self:custom_gamemode()
  if Network:is_client() then
    cat_print("join", "[Join] NetworkGameManager:create_gamemode: Starting a gametype on client. Gamemode: ", self._settings.game_mode)
    if is_custom then
      Global.gametype = GametypeCustom:new(self._settings)
    else
      Application:throw_exception("The gamemode can not be created. No gamemode is called: " .. self._settings.game_mode)
    end
  elseif Network:is_server() then
    cat_print("join", "[Join] NetworkGameManager:create_gamemode: Starting a gametype server and a client. Gamemode: ", self._settings.game_mode)
    if is_custom then
      Global.gametype_server = GametypeServerCustom:new(self._settings)
      Global.gametype = GametypeCustom:new(self._settings)
    else
      Application:throw_exception("The gamemode can not be created. No gamemode is called: " .. self._settings.game_mode)
    end
    if not Global.dedicated then
      local player_id = managers.networkplayer:register_player(Network:server(), managers.networkplayer._player_name, false, Network:server(), true, true)
    end
    Global.gametype_server:done_loading()
    if tweak_data.mp_setting_defaults.archetype_selection.IS_RANDOM and not Global.dedicated then
      Global.gametype_server:random_select_archetype(Global.local_member:get_id())
    end
    if tweak_data.mp_setting_defaults.BOTS_PLAYING then
      local k = 0
      while managers.networkplayer:has_free_bot_slots() do
        k = k + 1
        local team_name = managers.teammanager:get_least_players_team():get_name()
        local name = "BOT_" .. tostring(k)
        local params = {
          character_name = name,
          team_name = team_name,
          behavior_tree = "ShootOutBot",
          skill_template = "normal",
          group_id = nil
        }
        managers.brain:spawn_bot(nil, params)
      end
    end
    Global.gametype:done_loading()
    self:set_game_in_progress()
  end
end
function NetworkGameManager:set_game_in_progress()
  local is_win32 = SystemInfo:platform() == "WIN32"
  local is_ps3 = SystemInfo:platform() == "PS3"
  if is_win32 then
    managers.steam:set_game_in_progress()
  elseif is_ps3 and Global.lobby_handler then
    local handler = Global.lobby_handler
    if handler:owned() then
      handler:set_gameinprogress()
    end
  end
end
function NetworkGameManager:update(time, rel_time)
  if Network:is_server() then
    if Global.gametype_server then
      Global.gametype_server:update(time, rel_time)
    end
    managers.networkplayer:update(time, rel_time)
    if managers.bot then
      managers.bot:update(time, rel_time)
    end
  end
  if Network:is_client() and Global.local_member then
    Global.local_member:update(time, rel_time)
  end
  if Global.gametype then
    Global.gametype:update(time, rel_time)
  end
  if self._loading_clients then
    for k, v in pairs(self._loading_clients) do
      if v.ready == false then
        if not v.time then
          local timeout = 60
          if Application:bundled() then
            timeout = 60
          end
          v.time = TimerManager:wall():time() + timeout
        end
        local timeleft = v.time - TimerManager:wall():time()
        if timeleft <= 0 then
          if v.timedout == false then
            v.timedout = true
            v.ready = true
            v.archetype = true
            cat_print("join", "[Join] NetworkGameManager:update() Loading timeout on client")
          end
        elseif timeleft < 6 then
          cat_print("join", "[Join] NetworkGameManager:update() Timeleft < 6")
        end
      end
    end
    if self:loading_timed_out() then
      cat_print("join", "[Join] NetworkGameManager:update() Loading timed out")
      self._loading_clients = nil
      self._ready_clients = nil
      Network:unbind()
      if managers.network.group:_is_server() or managers.network.systemlink:is_server() then
        self._emitter:show_error_message("forefit", callback(self, self, "close_message_go_to_lobby", "forefit"))
      else
        if managers.network.systemlink:is_lan() then
          managers.network.systemlink:leave_group()
        end
        self._emitter:show_error_message("lostserver", callback(self, self, "close_message_go_to_lobby", "lostserver"))
      end
      managers.menu:leave_lobby()
      return
    end
    for k, v in pairs(self._loading_clients) do
      if v.ready == false then
        return
      end
    end
    self._loading_clients = nil
  end
  if self._ready_clients then
    local all_chosen = true
    for k, v in pairs(self._ready_clients) do
      if v.archetype then
      else
        all_chosen = false
      end
    end
    if all_chosen then
      self._ready_clients = nil
    end
  end
  if managers.tags and Network:is_server() then
    managers.tags:update(time, rel_time)
  end
end
function NetworkGameManager:loading_timed_out()
  local timed_out = false
  local timeouts = 0
  local num_of_clients = TableAlgorithms.count(self._loading_clients) + TableAlgorithms.count(self._ready_clients)
  if self._loading_clients then
    for k, v in pairs(self._loading_clients) do
      if v.timedout then
        timeouts = timeouts + 1
      end
    end
    if 0 < timeouts then
      cat_print("join", "[Join] NetworkGameManager:loading_timed_out() num of timeouts = ", timeouts .. "/" .. num_of_clients)
    end
  end
  if 0 < timeouts and num_of_clients <= timeouts then
    timed_out = true
  end
  return timed_out
end
function NetworkGameManager:close_message_go_to_lobby(error_type)
  self._emitter:hide_error_message(error_type)
  managers.menu:quit_multiplayer()
end
function NetworkGameManager:clients_done_loading()
  if self._loading_clients then
    return false
  else
    return true
  end
end
function NetworkGameManager:create_my_session()
  Application:throw_exception("Deprecated function!")
end
function NetworkGameManager:test_xbl_w()
  local testdata = {}
  testdata["experience points"] = 1
  testdata["games won"] = 1
  testdata["games played"] = 1
  testdata["kill death ratio"] = 1
  testdata["total game time"] = 1
  self:write_xbl("deathmatch", testdata)
end
function NetworkGameManager:write_xbl(board_id, post, func)
  local state = managers.platform:get_state()
  local xuid = managers.platform:get_xuid(nil)
  if state == "signed_in_to_live" and xuid then
    cat_print("Karl", self._my_session)
    if not alive(self._my_session) then
      self:create_my_session()
    end
    if self._my_session and self._my_session:state() ~= "started" then
      XboxLive:arbitration_register(self._my_session)
      XboxLive:start_session(self._my_session)
    end
    XboxLive:write_session_stats(self._my_session, xuid, board_id, post, callback(self, self, "stats_written"))
    self._last_write = TimerManager:main():time() + 300
  else
    Application:error("Not signed in")
  end
end
function NetworkGameManager:stats_written()
  XboxLive:end_session(self._my_session)
  XboxLive:delete_session(self._my_session)
  self._my_session = nil
end
function NetworkGameManager:ps3_disconnect(online)
  Global.multiplayer_private = nil
  if not managers.network.systemlink:is_lan() and not online then
    managers.menu:get_controller():set_enabled(false)
    managers.network.voice_chat:destroy_voice(true)
    if Global.gametype then
      Global.gametype._disconnect = true
      Global.gametype:kill_player_unit()
    end
    managers.network.group:register_callback("go_to_lobby", nil)
    self._emitter:show_error_message("lostconnection_ps3", callback(self, self, "_ps3_close_message_leave_group", "lostconnection_ps3"))
    managers.menu:leave_lobby()
  end
end
function NetworkGameManager:_ps3_close_message_leave_group(error_type)
  self._emitter:hide_error_message(error_type)
  managers.network.group:register_callback("go_to_lobby", nil)
  managers.network.group:leave_group_lobby(true)
  managers.dialog:open_dialog("returning_to_menu", {})
  if managers.network.systemlink:is_lan() then
    managers.network.systemlink:leave_group()
  end
  managers.network.generic:set_entermenu()
  managers.menu:quit_multiplayer()
end
function NetworkGameManager:showdlg_xboxlivedisconnect()
  assert(false, "NetworkGameManager:showdlg_xboxlivedisconnect, could not find any reference to this function ( peter )")
end
