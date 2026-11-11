AiData = AiData or class()
function AiData:init(unit)
  self.mode = "nothing"
  self.move_to_pos = nil
  self.move_to_pos_precision = 100
  self.next_move_to_pos = nil
  self.look_at_pos = nil
  self.run = false
  self.speed = 10
  self.current_enemy = nil
  self.current_enemy_seen = false
  self.use_weapon = false
  self.can_use_weapon = false
  self.grenade_target = nil
  self.passive = false
  self.last_enemy_pos = nil
  self.last_enemy_time = 0
  self.last_enemy_time_seen = 0
  self.last_enemy_time_been_seen = 0
  self.last_enemy_pos_update = 0
  self.hang_on_to_last_enemy_pos_time = 0
  self.shooting_enemy = nil
  self.link_object = nil
  self.debug_param = {}
  self.fire = {}
  self.fire.last_time = 0
  self.fire.last_buffer_min = 0.2
  self.fire.last_buffer_max = 0.8
  self.fire.distance_chance_min = 2500
  self.fire.distance_chance_max = 5000
  self.fire.hit_chance_max = 1
  self.fire.hit_chance_min = 0.8
  self.fire.hit_chance_diff = self.fire.hit_chance_max - self.fire.hit_chance_min
  self.fire.narrow_sights_time = 1
  self.fire.narrow_sights_mul = 0.5
  self.fire.narrow_sights_diff = 1 - self.fire.narrow_sights_mul
  self.fire.movement_chance_mod = 0.4
  self.fire.movement_chance_velocity = 500
  self.coverpos = nil
  self.coverpos_direction = nil
  self.coverpos_path_right = nil
  self.coverpos_path_left = nil
  self.coverpos_roll_pos = nil
  self.cover_been_out_time = 0
  self.const = {}
  self.const.size_x = 700
  self.const.size_y = 800
  self.const.size_z = 500
  self.const.player_height = 200
  self.move = {}
  self.look = {}
  self.look.spidersense = 0
  self.look.sphere_radius = 5000
  self.look.radius = math.tan(52) * self.look.range
  self.look.angle = 50
  self.look.fire_angle = 30
  self.sense = {}
  self.team = 1
  self.move.path = {}
  self.move.patrol_index = 1
  self.move.patrol_path = {}
  self.move.slotmask_shortcut_ground = managers.slot:get_mask("ai_ground_shortcut")
  self.guardpos = nil
  self.guardlook = nil
  self.ai_event_cue_map = {}
  self.talk = {}
  self.talk.timer = 0
  self.talk.buffer_min = 1
  self.talk.buffer_max = 5
  -- Bot behavior state. The weapon table is also consumed by the stock
  -- weapon AI-input path when no controller is attached to an NPC.
  self.weapon = {
    wants_to_fire = false,
    wants_to_reload = false,
    wants_to_fan = false,
    wants_to_archtype_special_fire = false,
    continuos_fan = false
  }
  self.bot_enabled = true
  self.bot_is_ghostface = false
  self.bot_role = "survivor"
  self.bot_wander_goal = nil
  self.bot_wander_wait_until = 0
  self.bot_wander_started_at = 0
  self.bot_next_wander_attempt = 0
  self.bot_flee_from = nil
  self.bot_next_flee_path = 0
  self.bot_flee_started_at = 0
  self.bot_objective = nil
  self.bot_objective_cooldown_until = 0
  self.bot_next_objective_scan = 0
  self.bot_next_objective_path = 0
  self.bot_next_objective_action = 0
  self.bot_objective_started_at = 0
  self.bot_delivering = false
  self.bot_delivery_pos = nil
  self.bot_delivery_location = nil
  self.bot_next_attack = 0
  self.bot_next_tag = 0
  self.bot_stalking = false
  self.bot_next_stalker_toggle = 0
  self.bot_next_special_attack = 0
  self.bot_execute_target = nil
  self.bot_execute_started_at = 0
end
MindProbe_AiData = {}
function MindProbe_AiData:draw_guardpos(unit)
  if self.guardpos ~= nil then
    Application:draw_line(unit:position(), math.obj_to_world(self.link_object, self.guardpos), 0, 0, 1)
    Application:draw_sphere(math.obj_to_world(self.link_object, self.guardpos), 50, 1, 1, 1)
    Application:draw_line(math.obj_to_world(self.link_object, self.guardpos) + Vector3(0, 0, 500), math.obj_to_world(self.link_object, self.guardpos), 0, 0, 1)
    if self.guardlook ~= nil then
      Application:draw_sphere(self.guardpos + self.guardlook, 10, 1, 1, 1)
    end
  end
end
function MindProbe_AiData:draw_move_to_pos(unit)
  if self.move_to_pos ~= nil then
    Application:draw_sphere(self.move_to_pos, 75, 0, 1, 1)
  end
  if self.next_move_to_pos ~= nil then
    Application:draw_sphere(self.next_move_to_pos, 75, 1, 1, 0)
  end
end
function MindProbe_AiData:draw_look_at_pos(unit)
  if self.look_at_pos ~= nil then
    Application:draw_sphere(self.look_at_pos, 50, 1, 0, 1)
  end
end
function MindProbe_AiData:draw_current_enemy(unit)
  if self.current_enemy ~= nil then
    local p = self.current_enemy:position()
    Application:draw_sphere(p, self.new_target_check, 1, 0, 0)
  end
end
function MindProbe_AiData:draw_last_enemy_pos(unit)
  if self.last_enemy_pos == nil then
    return
  end
  Application:draw_sphere(self.last_enemy_pos, 50, 0, 1, 0)
end
function MindProbe_AiData:draw_shooting_enemy(unit)
  if self.shooting_enemy ~= nil then
    local selfobj = unit:unit_data().target_objects.head
    local targetobj = self.shooting_enemy:unit_data().target_objects.head
    Application:draw_line(selfobj:position(), targetobj:position(), 1, 0, 1)
  end
end
function MindProbe_AiData:draw_coverpos(unit)
  if self.coverpos == nil then
    return
  end
  Application:draw_sphere(self.coverpos, 50, 1, 1, 0)
end
function MindProbe_AiData:draw_sense(unit)
  for key, value in pairs(self.sense) do
    Application:draw_sphere(value.lastpos, 50, 0, 1, 0)
  end
end
function MindProbe_AiData:draw_path(unit)
  local p = unit:position()
  for _, pos in ipairs(self.move.path) do
    local gaa = math.obj_to_world(self.link_object, pos)
    Application:draw_line(p + Vector3(0, 0, 70), gaa + Vector3(0, 0, 70), 0, 0, 1)
    Application:draw_line(p + Vector3(0, 0, 70), gaa + Vector3(0, 0, 70), 0, 0, 1)
    Application:draw_sphere(gaa, 55, 0, 0, 1)
    p = gaa
  end
end
function MindProbe_AiData:draw_patrol_path(unit)
  if #self.move.patrol_path > 0 then
    local p = self.move.patrol_path[1].position
    for _, pos in ipairs(self.move.patrol_path) do
      Application:draw_line(p + Vector3(1, 0, 0), pos.position + Vector3(1, 0, 0), 1, 0, 0)
      Application:draw_line(p + Vector3(0, 1, 0), pos.position + Vector3(0, 1, 0), 1, 0, 0)
      Application:draw_sphere(pos.position, 55, 1, 0, 0)
      p = pos.position
    end
  end
end
function MindProbe_AiData:draw_new_target_check(unit)
  local p = unit:position()
  Application:draw_sphere(p, self.new_target_check, 0, 0, 1)
end
function MindProbe_AiData:draw_radius(unit)
  local p = unit:position()
  Application:draw_sphere(p, self.look.radius, 0, 0, 1)
end
function MindProbe_AiData:draw_polar_line(pos, basepolar, spin, pitch, range)
  local newpol = Polar(1, basepolar.pitch + pitch, basepolar.spin + spin)
  local target = newpol:to_vector() * range
  Application:draw_line(pos, pos + target, 1, 0, 1)
end
function MindProbe_AiData:draw_view_cone(unit, pos, viewcone)
  local pol = unit:rotation():y():to_polar()
  self:draw_polar_line(pos, pol, viewcone.halffov, viewcone.halfzfov / 2, viewcone.range)
  self:draw_polar_line(pos, pol, -viewcone.halffov, viewcone.halfzfov / 2, viewcone.range)
  self:draw_polar_line(pos, pol, viewcone.halffov, -viewcone.halfzfov / 2, viewcone.range)
  self:draw_polar_line(pos, pol, -viewcone.halffov, -viewcone.halfzfov / 2, viewcone.range)
end
function MindProbe_AiData:draw_look(unit)
  local pos = unit:position() + Vector3(0, 0, self.const.size_z / 2)
  local my_head_pos = unit:unit_data().target_objects.head:position()
  if my_head_pos then
    pos = my_head_pos
  end
  if unit:ai_data().look.spidersense ~= 0 then
    Application:draw_sphere(pos, unit:ai_data().look.spidersense, 1, 1, 1)
    Application:draw_circle(pos, unit:ai_data().look.spidersense, 1, 1, 1)
  end
  local ai_data = unit:ai_data()
  local viewcone = ai_data.look.vision[ai_data.look_index]
  self:draw_view_cone(unit, pos, viewcone)
end
function MindProbe_AiData:draw_enemy_hide_dir(unit)
  if self.move.enemy_hide_dir ~= nil then
    Application:draw_line(self.last_enemy_pos, self.last_enemy_pos + self.move.enemy_hide_dir:normalized() * self.move.idle_search_look_distance, 1, 0, 1)
  end
end
