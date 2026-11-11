require("network/NetworkGameElement")
require("network/VoteContext")
GametypeBase = GametypeBase or class()
function GametypeBase:init(settings)
  Application:debug("GametypeBase:init()")
  self._updator_name_string = ""
  self._new_round = true
  self._settings = settings
  self._game_ended = false
  self._game_started = false
  self:set_updator("update_empty")
  self._use_time_condition = false
  if self._settings.time_limit > 0 then
    self._use_time_condition = true
  end
  Application:debug("_use_time_condition:", self._use_time_condition)
  self._registered_callback_objects = {}
end
function GametypeBase:update(time, rel_time)
  self._updator(time, rel_time)
end
function GametypeBase:is_custom()
  return false
end
function GametypeBase:game_ended()
  return self._game_ended
end
function GametypeBase:is_game_started()
  return self._game_started
end
function GametypeBase:set_updator(updator)
  self._updator_name_string = updator
  self._updator = callback(self, self, updator)
end
function GametypeBase:set_game_started(val)
  self._game_started = val
end
function GametypeBase:set_game_ended(val)
  self._game_ended = val
end
function GametypeBase:update_empty(time, rel_time)
end
function GametypeBase:settings()
  return self._settings
end
function GametypeBase:register_callbackhandler(cbh)
  if not self:_is_callbackhandler_registered(cbh) then
    table.insert(self._registered_callback_objects, cbh)
  end
end
function GametypeBase:_is_callbackhandler_registered(cbh)
  for i, callbackhandler in ipairs(self._registered_callback_objects) do
    if callbackhandler == cbh then
      return i
    end
  end
  return nil
end
function GametypeBase:clear_callbackhandlers()
  self._registered_callback_objects = {}
end
function GametypeBase:remove_callbackhandler(cbh)
  local index = self:_is_callbackhandler_registered(cbh)
  if index then
    self._registered_callback_objects[index] = nil
  end
end
function GametypeBase:_handlecallbacks(func_name, ...)
  local func_name_to_be_called = "on_" .. func_name .. "_callback"
  for _, callbackhandler in ipairs(self._registered_callback_objects) do
    local f = callbackhandler[func_name_to_be_called]
    if f then
      f(callbackhandler, ...)
    end
  end
end
Gametype = Gametype or class(GametypeBase)
function Gametype:init(settings)
  GametypeBase.init(self, settings)
  Application:debug("Gametype:init()")
  self._disconnect = false
  managers.networkgameelement = NetworkGameElement:new()
  managers.network:register_and_set_receiver("gametype", self)
  if self._settings.number_of_teams > 1 then
    managers.teammanager:create_team(2, "team_a", "mp_teama_player")
    managers.teammanager:create_team(3, "team_b", "mp_teamb_player")
  end
  if self._settings.number_of_teams > 2 then
    managers.teammanager:create_team(4, "team_c", "mp_teamc_player")
  end
  if self._settings.number_of_teams > 3 then
    managers.teammanager:create_team(5, "team_d", "mp_teamd_player")
  end
  self:set_updator("update_waiting_for_start_game")
  self._vote_context = VoteContext:new()
  self._emitter = managers.action_event:create_emitter()
end
function Gametype:allow_scoreboard()
  return true
end
function Gametype:disconnected()
  return self._disconnect
end
function Gametype:menu_activated()
end
function Gametype:_set_player_controller_active(on)
  local unit = Global.local_member and Global.local_member:get_unit()
  if unit then
    local controller = unit:base() and unit:base()._controller
    if controller then
      if on then
        controller:enable()
      else
        controller:disable()
      end
    end
  end
end
function Gametype:menu_deactivated()
  if self._game_ended then
    self:_set_player_controller_active(false)
  end
end
function Gametype:update_waiting_return_to_lobby(time, rel_time)
  if not Global.local_member then
    return
  end
  self._quit_timer = self._quit_timer - rel_time
  self._vote_context:update(time, rel_time)
  local skip_screen = Global.local_member:get_vote("skip_screen")
  if skip_screen or self._quit_timer and not self._quiting and self._quit_timer <= 0 then
    Global.local_member:clear_votes()
    if not self._salescreen_started or time > self._return_time then
      self:quit_menu()
      self._quiting = true
      self._salescreen_started = nil
      return
    end
  end
end
function Gametype:update(time, rel_time)
  GametypeBase.update(self, time, rel_time)
end
function Gametype:quit_menu()
  if managers.network.systemlink:is_lan() or managers.network.group:is_group_leader() then
  else
    if managers.network.group:get_leader_rpc() then
      managers.network.group:register_callback("go_to_lobby", callback(self, self, "_cb_go_to_lobby_ok"))
      managers.network.group:go_to_lobby()
    else
    end
  end
  managers.menu:quit_multiplayer()
end
function Gametype:_cb_go_to_lobby_ok()
  managers.network.group:register_callback("go_to_lobby", nil)
end
function Gametype:update_game_running(time, rel_time)
  managers.networkgameelement:update(time, rel_time)
  if self._matchover_sync_time and TimerManager:wall():time() > self._matchover_sync_time then
    self._matchover_sync_time = nil
    if not self._disconnect and Global.local_member then
      Global.local_member:matchover_sync()
    end
  end
end
function Gametype:done_loading(hot_join)
  self._hot_join = hot_join
  self:_handlecallbacks("done_loading")
  self._emitter:done_loading()
  managers.dialog:close_dialog("waiting_for_server")
end
function Gametype:send_game_stats()
  self._game_stats_sent = true
  if managers.network.systemlink and managers.network.systemlink:is_lan() then
    return
  end
  if SystemInfo:platform() == "X360" and managers.network.matchmake and managers.network.matchmake._uses_arbitration then
    self:send_xbl_stats()
  end
  if SystemInfo:platform() == "WIN32" and not managers.network.systemlink:is_lan() then
    self:rdv_end_participation()
  end
end
function Gametype:submit_xbl_ov_stats(player, player_list)
  local stats = {}
  stats.OV_MATCHES_PLAYED = 1
  stats.OV_MATCHES_WON = player._finish_position == 1 and 1 or 0
  stats.OV_XP = player:get_score()
  stats.OV_KILLS = player:get_frags()
  stats.OV_DEATHS = player:get_deaths()
  self:write_xbl_stats("OV", player, stats)
end
function Gametype:submit_xbl_true_skill_stats(game_mode, player, player_list)
  local stats = {}
  stats.relative_score = #player_list - player._finish_position
  if player:get_team() then
    stats.session_team = player:get_team():get_id()
  else
    stats.session_team = 1
  end
  self:write_xbl_stats(game_mode .. "_skill_ranked", player, stats)
end
function Gametype:rdv_end_participation()
  local players = managers.networkplayer:players()
  managers.network.matchmake:end_participation(Global.local_member:get_score(), #players)
end
function Gametype:write_xbl_stats(board, player, stats)
  cat_print_inspect("matti", "[write_xbl_stats] board:" .. board .. ", player:" .. player:get_player_name() .. "\n", stats)
  managers.network.matchmake:write_stats(board, player:get_mm_id(), stats)
end
function Gametype:start_game()
  Application:debug("Gametype:start_game()")
  managers.network.group:ingame_start_game()
  self:load_map_settings(managers.networkgame:current_level())
  self:set_game_started(true)
  self:set_updator("update_game_running")
  Application:debug("_use_time_condition:", self._use_time_condition)
  if self._use_time_condition then
    self._emitter:sync_time(self._settings.time_limit * 60, TimerManager:game():time())
  end
  self:save_grouped_members()
  self:_handlecallbacks("start_game")
  local gamemode = managers.networkgame:get_wanted_gamemode()
  self._emitter:start_game(gamemode)
  managers.statistics:register_start_round()
end
function Gametype:load_map_settings(map)
end
function Gametype:save_grouped_members()
  self._saved_group_members = {}
  for k, v in pairs(managers.network.group:get_group_players()) do
    local member = managers.networkplayer:get_member_from_mm_id(v.playerid)
    if member then
      table.insert(self._saved_group_members, member)
    else
      Application:error("Failed to find member from id " .. tostring(v.playerid))
    end
  end
end
function Gametype:from_server_round_over(winning_team, winning_reason, end_round, end_match, sender)
  if managers.menu:menu_active() then
    managers.menu:start_close_fade_out()
    managers.menu:deactivate()
  end
  local member = Global.local_member
  if member then
    member:freeze_unit()
  end
  self:_handlecallbacks("round_over")
  self._emitter:round_over(end_round)
  managers.teammanager:round_over(end_round)
end
function Gametype:from_server_round_start(new_round, sender)
  Application:debug("Gametype:from_server_round_start(...)")
  self._new_round = new_round
  self._emitter:start_round()
end
function Gametype:update_waiting_for_start_game()
end
function Gametype:update_waiting_for_round_start()
end
function Gametype:from_server_match_over(winning_team, winning_reason, wait_for_map, sender)
  managers.network.voice_chat:clear_team()
  managers.music:player():stop_nice()
  managers.statistics:register_end_match(winning_team)
  if managers.reward then
    managers.reward:save_rewards()
  end
  local member = Global.local_member
  if member then
    member:freeze_unit()
    member:give_reserved_score()
    self._matchover_sync_time = TimerManager:wall():time() + 2
  end
  if managers.menu:menu_active() then
    managers.menu:start_close_fade_out()
    managers.menu:deactivate()
  end
  self:set_game_ended(true)
  if managers.network.systemlink and managers.network.systemlink:is_lan() then
  else
    managers.network.matchmake:end_game()
    managers.network.group:end_game()
  end
  TimerManager:game_animation():set_multiplier(0)
  self:_handlecallbacks("match_over")
  self._emitter:match_over()
  if wait_for_map then
    self:set_updator("update_empty")
  else
    self:start_quit_countdown()
    managers.network.generic:set_entermenu(true)
  end
end
function Gametype:from_server_sync_time(time, sender)
  if time then
    self._emitter:sync_time(time, TimerManager:game():time())
  end
end
function Gametype:from_server_tweak_data_resync_begin()
  self._tweak_data_resync_buffer = ""
end
function Gametype:from_server_tweak_data_resync_send(block)
  self._tweak_data_resync_buffer = self._tweak_data_resync_buffer .. block
end
function Gametype:from_server_tweak_data_resync_complete()
  cat_print("tweak_data", self._tweak_data_resync_buffer)
  local tweak, err = loadstring("return " .. self._tweak_data_resync_buffer)()
  self._tweak_data_resync_buffer = ""
  if not err then
    for key, player in pairs(managers.networkplayer:players()) do
      local player_unit = player:get_unit()
      if player_unit and alive(player_unit) then
        player:get_unit():base():set_tweak_data_variables(tweak)
      end
    end
  else
    assert(false, "Bad serialized data recieved")
  end
end
function Gametype:who_killed_who(killer, victim, with_weapon, params)
  local weapon_name = ""
  local weapon_id = managers.networklookup:get_id(with_weapon)
  if (killer ~= victim or with_weapon == "bleed") and with_weapon then
    weapon_name = with_weapon
  end
  params.assist_member_id = StatisticsHelper:get_assist_killer_id(killer, victim, params)
  params.is_victim_trapped = victim:get_unit():player_data().trapped
  managers.statistics:register_kill(TimerManager:game():time(), killer, victim, weapon_name, params)
  self._emitter:who_killed_who(killer, victim, weapon_name)
  managers.network:send("who_killed_who", killer:get_id(), victim:get_id(), weapon_id, params)
end
function Gametype:from_server_synch_respawn_timer(respawn_interval, pulsed)
  self._emitter:synch_respawn_timer(respawn_interval, pulsed)
end
function Gametype:can_hit(attacker, victim)
  return true
end
function Gametype:get_minutes_played()
  if self._use_time_condition then
    return math.floor(self._settings.time_limit - self._game_timer:time() / 60)
  end
  return 0
end
function Gametype:kill_player_unit()
  if Global.local_member then
    local unit = Global.local_member:get_unit()
    if alive(unit) then
      managers.player:disconnect(true)
      unit:kill_mover()
    end
  end
end
function Gametype:game_over_forefit()
  if self._game_ended then
    return
  end
  managers.menu:get_controller():set_enabled(false)
  managers.network.voice_chat:close_all()
  self._disconnect = true
  self:kill_player_unit()
  self._emitter:show_error_message("forefit", callback(self, self, "close_message_show_score_new", "forefit"))
  self:_handlecallbacks("game_over_forefit")
  managers.menu:leave_lobby()
end
function Gametype:lost_server()
  if self._vote_context and self._vote_context:is_active() then
    return
  end
  if self._disconnect then
    return
  end
  managers.menu:get_controller():set_enabled(false)
  managers.network.voice_chat:close_all()
  self._disconnect = true
  self:kill_player_unit()
  self._emitter:show_error_message("lostserver", callback(self, self, "close_message_show_score_new", "lostserver"))
end
function Gametype:_cb_go_to_lobby()
  cat_print("lobby", "MultiplayerScreen:_cb_go_to_lobby: Returning to my group leaders lobby")
  managers.network.group:register_callback("go_to_lobby", nil)
  if managers.network.systemlink:is_lan() then
    managers.network.systemlink:leave_group()
  end
  managers.menu:quit_multiplayer()
end
function Gametype:close_message_show_score_new(error_type)
  self._emitter:hide_error_message(error_type)
  managers.networkgame:remove_loading_status()
  managers.network.voice_chat:clear_team()
  managers.music:player():stop_nice()
  local member = Global.local_member
  if member then
    member:freeze_unit()
  end
  if managers.menu:menu_active() then
    managers.menu:deactivate()
  end
  self:set_game_ended(true)
  if managers.network.systemlink and managers.network.systemlink:is_lan() then
  else
    managers.network.matchmake:end_game()
    managers.network.group:end_game()
  end
  TimerManager:game_animation():set_multiplier(0)
  self._emitter:game_over_forefit()
  self._emitter:show_scoreboard({state = "dropped", show_end = true})
  self:start_quit_countdown()
end
function Gametype:start_quit_countdown(num_of_seconds)
  if self._quiting then
    Application:stack_dump_error("Started quit countdown even though the game was currently quiting the game.")
    return
  end
  self._vote_context:start()
  self._quit_timer = tweak_data.game.end_game_timeout
  self:set_updator("update_waiting_return_to_lobby")
end
function Gametype:remove_loading_status()
  managers.networkgame:remove_loading_status()
  self._emitter:loading_network_clients_done()
  managers.music:player():play_nice(managers.networkgame:get_song_name())
  managers.network.voice_chat:resume()
end
function Gametype:skip_quit_countdown(time)
  if self._quit_timer then
    local t = time or 0
    self._quit_timer = t
  end
end
function Gametype:vote_skip_end_screen_request()
  if not Global.local_member then
    return
  end
  local call_object
  local member = Global.local_member:get_id()
  local lan = managers.network.systemlink and managers.network.systemlink:is_lan()
  if lan then
    if managers.network.systemlink:is_server() then
      call_object = managers.network._network_handlers.game
    else
      call_object = managers.network.systemlink:get_server_rpc()
    end
    cat_print("lobby", "requesting end screen to host!")
    if call_object then
      call_object:vote_end_screen_request_lan(member)
    else
      cat_print("lobby", "vote_skip_end_screen_request: call_object is nil. Returning to lobby.")
      self._vote_context:exit(2.1)
    end
  else
    if managers.network.group:is_group_leader() then
      call_object = managers.network._network_handlers.game
    else
      call_object = managers.network.group:get_leader_rpc()
    end
    cat_print("lobby", "requesting end screen to host!")
    if call_object then
      call_object:vote_end_screen_request(member)
    else
      cat_print("lobby", "vote_skip_end_screen_request: call_object is nil. Returning to lobby.")
      self._vote_context:exit(2.1)
    end
  end
end
function Gametype:vote_skip_end_screen(member)
  local mem = managers.networkplayer:player(member)
  if mem then
    mem:set_vote_skip_end_screen()
  end
  local vote_complete = self:vote_complete()
  if vote_complete then
    self._vote_context:exit(2)
  end
end
function Gametype:vote_complete()
  local num_skips = 0
  local lan = managers.network.systemlink and managers.network.systemlink:is_lan()
  local max_skips = lan and managers.networkplayer:num_players() or managers.network.group:num_group_players() + 1
  local ready_list = {}
  local undecided_list = {}
  local left_list = {}
  if not lan then
    num_skips = num_skips + 1
    table.insert(ready_list, Global.local_member)
  end
  local group_members = lan and managers.networkplayer:players() or self._saved_group_members or {}
  for k, member in pairs(group_members) do
    if member:has_left_game() then
      num_skips = num_skips + 1
      table.insert(left_list, member)
    elseif member:get_vote_skip_end_screen() == true then
      num_skips = num_skips + 1
      table.insert(ready_list, member)
    else
      table.insert(undecided_list, member)
    end
  end
  if max_skips <= num_skips then
    return true
  else
    return false
  end
end
function Gametype:player_left()
  if self._vote_context and self._vote_context:is_active() then
    local vote_complete = self:vote_complete()
    if vote_complete then
      self._vote_context:exit(2)
    end
  end
end
function Gametype:leave_group()
  if managers.network.systemlink and managers.network.systemlink:is_lan() then
    managers.network.systemlink:leave_group()
    self._vote_context:exit(2)
  else
    if managers.network.group:num_group_players() > 0 then
      managers.network.group:leave_group_lobby()
    end
    managers.network.generic:set_entermenu(true)
    self._vote_context:exit(2.1)
  end
end
GametypeServer = GametypeServer or class(GametypeBase)
function GametypeServer:init(settings)
  GametypeBase.init(self, settings)
  Application:debug("GametypeServer:init()")
  managers.network:register_and_set_receiver("gametypeserver", self)
  self._allow_to_spawn = false
  self:set_updator("update_empty")
  self._end_time = nil
  self._players_done_loading = 1
  self._last_warning_time = 0
  self._gametype_name = nil
  self._spawn_points_map = {}
end
function GametypeServer:allow_to_spawn()
  return self._allow_to_spawn
end
function GametypeServer:set_allow_to_spawn(val)
  self._allow_to_spawn = val
end
function GametypeServer:request_level_and_gamemode(sender)
  Application:debug("received level and gamemode request")
  local level = managers.networkgame:current_level()
  local gamemode = managers.networkgame:get_wanted_gamemode()
  local player = managers.networkplayer:get_member_from_rpc(sender)
  if player then
    Network:remove_client(sender)
    managers.networkplayer:drop_player(sender)
    Application:debug("[Robin]request_level_and_gamemode() player already in game, throttling and returning")
  else
    local banned = managers.networkplayer:player_banned(sender)
    local success = managers.networkplayer:has_free_human_slots() and not banned
    Application:debug("SERVER HAS FREE SLOTS, WELCOME=", success)
    if success then
      local is_relayed = NetworkAux.rpc_relayed(sender)
      if not is_relayed then
        local motd = Global.dedicated and Global.server_settings.message_of_the_day or ""
        sender:from_server_level_and_gamemode(level, gamemode, managers.networklookup:get_category_id("success", "join_game"), motd)
        local username = tostring(managers.network.account:username())
        managers.networkplayer:register_loading_player(sender, username, 90)
        Network:set_timeout(sender, 3000)
        Application:debug("[Robin]request_level_and_gamemode() sending level and gamemode")
      else
        Application:debug("[Freen]request_level_and_gamemode() sending level and gamemode -> BAD CONNECTION, bailing!")
        sender:from_server_level_and_gamemode("", "", managers.networklookup:get_category_id("bad_connection", "join_game"), "")
      end
    elseif banned then
      sender:from_server_level_and_gamemode("", "", managers.networklookup:get_category_id("banned", "join_game"), "")
    else
      sender:from_server_level_and_gamemode("", "", managers.networklookup:get_category_id("server_full", "join_game"), "")
    end
  end
end
function GametypeServer:update(time, rel_time)
  GametypeBase.update(self, time, rel_time)
  self:check_emptyserver()
  if Input:keyboard() and Input:keyboard():pressed("f1") then
    self:debug_spawn(1)
  end
  if Input:keyboard() and Input:keyboard():pressed("f2") then
    self:debug_spawn(2)
  end
  if Input:keyboard() and Input:keyboard():pressed("f3") then
    self:debug_spawn(3)
  end
  if Input:keyboard() and Input:keyboard():pressed("f4") then
    self:debug_spawn(4)
  end
end
function GametypeServer:debug_spawn(player_num)
  if not self:allow_to_spawn() then
    Application:debug("debug respawn failed, not allowed to spawn!")
    return
  end
  local team = managers.teammanager:get_team_by_name("team_a")
  local show_members = team:get_members()
  local team_members_indexed = {}
  for index, team_member in pairs(show_members) do
    local team_member_id = team_member:get_id()
    team_members_indexed[team_member_id] = team_member
  end
  local num = 1
  local player_to_spawn, spawn_at_player
  for index, team_member in pairs(team_members_indexed) do
    if player_num == num and team_member._dead then
      player_to_spawn = team_member
    elseif not spawn_at_player and not team_member._dead and alive(team_member:get_unit()) then
      spawn_at_player = team_member:get_unit()
    end
    num = num + 1
  end
  if player_to_spawn then
    if spawn_at_player then
      local pos = spawn_at_player:position()
      local rot = spawn_at_player:rotation()
      Application:debug("DEBUG_SPAWN at: " .. tostring(pos) .. tostring(rot))
      player_to_spawn:spawn_at({position = pos, rotation = rot})
    else
      player_to_spawn:spawn_player(true)
    end
  end
end
function GametypeServer:resync_tweak_data(data)
  do return end
  local rpc = Network:all()
  local serialized_data = TableAlgorithms.serialize(data, 0)
  local blocksize = TweakData.RESYNC_MAX_BLOCK_SIZE
  local total_size = string.len(serialized_data)
  assert(0 < total_size)
  local from = 1
  local to = blocksize
  local block
  rpc:from_server_tweak_data_resync_begin()
  while total_size > to do
    block = string.sub(serialized_data, from, to)
    rpc:from_server_tweak_data_resync_send(block)
    from = to + 1
    to = from + blocksize - 1
  end
  block = string.sub(serialized_data, from)
  rpc:from_server_tweak_data_resync_send(block)
  rpc:from_server_tweak_data_resync_complete()
end
function GametypeServer:done_loading()
  Application:debug("GametypeServer:done_loading()")
  self:set_updator("update_waiting_for_game_start")
  managers.networkplayer:create_ghost(Network:server())
  managers.networkplayer:toggle_ghost(true)
  managers.brain:register_death_zones()
end
function GametypeServer:client_loading_done(client)
  self._players_done_loading = self._players_done_loading + 1
end
function GametypeServer:allow_to_join()
  local allow_join = true
  if self:is_game_started() then
    allow_join = self._settings.allow_dropin_join
  end
  return allow_join
end
function GametypeServer:update_waiting_for_game_start(time, rel_time)
  local disconnected = false
  if Global.gametype and Global.gametype._disconnect then
    disconnected = Global.gametype._disconnect
  end
  if managers.networkgame:clients_done_loading() == true and not disconnected then
    if not self._delay_start_count then
      self._delay_start_count = TimerManager:wall():time() + 5
    end
    if TimerManager:wall():time() > self._delay_start_count then
      self._delay_start_count = nil
      self:set_updator("update_waiting_for_game_start_countdown")
      self._cd_secondsleft = 21
      self._cd_fraction = 0
      Network:all():remove_loading_status()
    end
  end
end
function GametypeServer:update_waiting_for_game_start_countdown(t, dt)
  self._cd_fraction = self._cd_fraction - dt
  if self._cd_fraction <= 0 then
    self._cd_secondsleft = self._cd_secondsleft - 1
    local str_id = "sg_countdown_" .. tostring(self._cd_secondsleft)
    managers.networkcommunication:send_to_all(str_id)
    if 0 < self._cd_secondsleft then
      self._cd_fraction = self._cd_fraction + 1
    else
      self:set_allow_to_spawn(true)
      self:start_game()
    end
  end
end
function GametypeServer:spawn_players_and_setup_teams(players, teams)
  if not self:allow_to_spawn() then
    return
  end
  -- Fill empty slots with AI bots before humans spawn (server only).
  if Network:is_server() and managers.bot then
    managers.bot:fill_bots()
  end
  for key, value in pairs(managers.networkplayer:players()) do
    if not value:has_left_game() then
      value:spawn_player()
    end
  end
end
function GametypeServer:drop_in_player(member)
  member:get_rpc():start_game()
  member:get_rpc():remove_loading_status()
  if not member:has_left_game() and self:allow_to_spawn() then
    member:spawn_player()
  end
end
function GametypeServer:start_game()
  if not self:is_game_started() then
    Application:debug("Start game")
    self:set_updator("update_game_running")
    self:set_game_started(true)
    Network:all():start_game()
    self:spawn_players_and_setup_teams()
    if self._use_time_condition and self._settings.time_limit > 0 then
      self._end_time = Application:time() + self._settings.time_limit * 60
    end
    self:resync_tweak_data(tweak_data.archetypes)
    self:send_start_message()
    self:_handlecallbacks("start_game")
  end
end
function GametypeServer:start_round(new_round)
  if self._use_time_condition and self._settings.time_limit > 0 then
    self._end_time = Application:time() + self._settings.time_limit * 60
  end
  self:_handlecallbacks("start_round", new_round)
end
function GametypeServer:end_round()
end
function GametypeServer:send_start_message()
end
function GametypeServer:report_kill(killer_member, killed_member, with_weapon, params)
  local player1 = killer_member
  local player2 = killed_member
  player1 = player1 or player2
  if not params.from_knocked_out then
    player2:die(true, not params.knocked_out)
  else
    player2:die(false, true)
  end
  local game_time = TimerManager:game():time()
  local killed_rpc = killed_member:get_rpc()
  if not params.knocked_out then
    if tweak_data.mp_setting_defaults.archetype_selection.IS_RANDOM and self.random_select_archetype then
      self:random_select_archetype(killed_member:get_id())
    elseif not killed_member:ai_controlled() and (not with_weapon or with_weapon ~= "suicide") and not params.from_knocked_out then
      killed_member:set_archetype_updated(false)
    end
    managers.player_trigger:report_death(killed_member:get_unit(), player2:get_team():get_missionscript_side())
  else
    killed_member:set_archetype_updated(false)
    managers.player_trigger:report_knocked_out(killed_member:get_unit(), player2:get_team():get_missionscript_side())
  end
  if with_weapon ~= "execution" and with_weapon ~= "suicide" and player1 ~= player2 then
    managers.player_trigger:report_fragged(killed_member:get_unit(), player2:get_team():get_missionscript_side())
  end
  Global.gametype:who_killed_who(player1, player2, with_weapon, params)
end
function GametypeServer:from_client_deatharea_collision(underwater, sender)
  local member = managers.networkplayer:get_member_from_rpc(sender)
  if member then
    member:deatharea_collision(underwater)
  end
end
function GametypeServer:pickup_flag(member, flag_unit)
end
function GametypeServer:leave_flag(member, flag_unit, move_back)
end
function GametypeServer:check_emptyserver()
  if Global.mp_ignore_empty then
    return
  end
  if managers.network.systemlink and managers.network.systemlink:allow_empty() then
    return
  end
  if self._settings.allow_empty then
    return
  end
  if self:is_game_started() and not self:game_ended() and self:is_server_empty() then
    cat_debug("multiplayer", "Game ends as server is empty. To force game keep running set Global.mp_ignore_empty = true")
    if SystemInfo:platform() == "WIN32" then
      managers.network.matchmake:end_competition()
    end
    self:set_allow_to_spawn(false)
    self:set_game_ended(true)
    self._disconnect = true
    Network:all():game_over_forefit()
  end
end
function GametypeServer:hideinfo()
end
function GametypeServer:is_server_empty_dm()
  if Global.mp_force_empty then
    return true
  end
  if managers.networkplayer._number_of_players == 1 then
    return true
  end
  return false
end
function GametypeServer:is_server_empty_team()
  if Global.mp_force_empty then
    return true
  end
  if managers.teammanager:get_team_by_name("team_a")._number_of_members == 0 then
    return true
  end
  if managers.teammanager:get_team_by_name("team_b")._number_of_members == 0 then
    return true
  end
  return false
end
