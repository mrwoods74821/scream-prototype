TweakData = TweakData or class()
TweakData.RELOAD = true
TweakData.reload_callback_map = TweakData.reload_callback_map or {}
TweakData.last_reload_callback_id = TweakData.last_reload_callback_id or 0
TweakData.RESYNC_MAX_BLOCK_SIZE = 1024
function TweakData:init()
  self:setup_rewards()
  self:setup_experience()
  self:setup_archetypes()
  self:setup_version_config()
end
function TweakData:setup_version_config()
  self.version_config = {}
  self.version_config.trial_mode = false
  self.version_config.content_restriction_age_ps3 = 16
  self.version_config.switchable_huds = true
  self.punishment = {}
  self.punishment.warning_threshold = 2
  self.punishment.kick_threshold = 3
  self.idle_kick = {}
  self.idle_kick.kick_time = 900
end
function TweakData:setup_rewards()
  self.rewards = {}
  self.rewards.multikill = {}
  self.rewards.multikill.time = 4
  self.rewards.goodfellow = {}
  self.rewards.goodfellow.revives = 4
  self.rewards.force_multiplier = {}
  self.rewards.force_multiplier.matches = 100
  self.rewards.pack_mule = {}
  self.rewards.pack_mule.times = 3
  self.rewards.lewis_and_clark = {}
  self.rewards.lewis_and_clark.released_maps = 6
  self.rewards.fish_in_a_barrel = {}
  self.rewards.fish_in_a_barrel.kills = 3
  self.rewards.barrage = {}
  self.rewards.barrage.kills = 3
  self.rewards.barrage.time = 12
  self.rewards.one_step_ahead = {}
  self.rewards.one_step_ahead.kills = 3
  self.rewards.natural_born_leader = {}
  self.rewards.natural_born_leader.kills = 10
  self.rewards.to_the_victor_belong_the_spoils = {}
  self.rewards.to_the_victor_belong_the_spoils.matches = 300
  self.rewards.rising_scourge_of_the_west = {}
  self.rewards.rising_scourge_of_the_west.kills = 250
  self.rewards.scourge_of_the_west = {}
  self.rewards.scourge_of_the_west.kills = 1000
  self.rewards.ultimate_scourge_of_the_west = {}
  self.rewards.ultimate_scourge_of_the_west.kills = 2500
  self.rewards.hat_trick = {}
  self.rewards.hat_trick.hats = 25
  self.rewards.hats_off_to_you_sir = {}
  self.rewards.hats_off_to_you_sir.hats = 100
  self.rewards.they_were_all_hat_no_cattle = {}
  self.rewards.they_were_all_hat_no_cattle.hats = 250
  self.rewards.ace_high = {}
  self.rewards.ace_high.max_level = 9
  self.rewards.quigley = {}
  self.rewards.quigley.distance = 5000
  self.rewards.fistful_of_tnt_1 = {}
  self.rewards.fistful_of_tnt_1.demolitions = 20
  self.rewards.fistful_of_tnt_2 = {}
  self.rewards.fistful_of_tnt_2.demolitions = 60
  self.rewards.fistful_of_tnt_3 = {}
  self.rewards.fistful_of_tnt_3.demolitions = 180
  self.rewards.sidearm_savvy_1 = {}
  self.rewards.sidearm_savvy_1.kills = 20
  self.rewards.sidearm_savvy_2 = {}
  self.rewards.sidearm_savvy_2.kills = 60
  self.rewards.sidearm_savvy_3 = {}
  self.rewards.sidearm_savvy_3.kills = 180
  self.rewards.nightingale_1 = {}
  self.rewards.nightingale_1.revives = 30
  self.rewards.nightingale_2 = {}
  self.rewards.nightingale_2.revives = 180
  self.rewards.nightingale_3 = {}
  self.rewards.nightingale_3.revives = 720
  self.rewards.goldrush_1 = {}
  self.rewards.goldrush_1.sacks = 30
  self.rewards.goldrush_2 = {}
  self.rewards.goldrush_2.sacks = 180
  self.rewards.goldrush_3 = {}
  self.rewards.goldrush_3.sacks = 720
  self.rewards.conqueror_1 = {}
  self.rewards.conqueror_1.zones = 30
  self.rewards.conqueror_2 = {}
  self.rewards.conqueror_2.zones = 180
  self.rewards.conqueror_3 = {}
  self.rewards.conqueror_3.zones = 720
  self.rewards.noble_prize_1 = {}
  self.rewards.noble_prize_1.kills = 30
  self.rewards.noble_prize_2 = {}
  self.rewards.noble_prize_2.kills = 180
  self.rewards.noble_prize_3 = {}
  self.rewards.noble_prize_3.kills = 720
  self.rewards.marshal_1 = {}
  self.rewards.marshal_1.tags = 40
  self.rewards.marshal_2 = {}
  self.rewards.marshal_2.tags = 250
  self.rewards.marshal_3 = {}
  self.rewards.marshal_3.tags = 800
  self.rewards.lure_of_the_huntress_1 = {}
  self.rewards.lure_of_the_huntress_1.trapped_enemies = 30
  self.rewards.lure_of_the_huntress_2 = {}
  self.rewards.lure_of_the_huntress_2.trapped_enemies = 180
  self.rewards.lure_of_the_huntress_3 = {}
  self.rewards.lure_of_the_huntress_3.trapped_enemies = 720
  self.rewards.wild_bill_1 = {}
  self.rewards.wild_bill_1.kills = 50
  self.rewards.wild_bill_2 = {}
  self.rewards.wild_bill_2.kills = 300
  self.rewards.wild_bill_3 = {}
  self.rewards.wild_bill_3.kills = 900
  self.rewards.avarice = {}
  self.rewards.avarice.sacks = 8
  self.rewards.sharpshooter = {}
  self.rewards.sharpshooter.kills = 20
  self.rewards.lead_pusher = {}
  self.rewards.lead_pusher.kills = 30
  self.rewards.goldsnatcher = {}
  self.rewards.goldsnatcher.sacks = 4
  self.rewards.shootist = {}
  self.rewards.shootist.kills = 3
  self.rewards.headhunter = {}
  self.rewards.headhunter.headshots = 8
  self.rewards.survivor = {}
  self.rewards.survivor.minutes = 10
  self.rewards.survivor.kills = 4
  self.rewards.ghost = {}
  self.rewards.ghost.minutes = 10
  self.rewards.ghost.kills = 10
  self.rewards.coureur_des_bois = {}
  self.rewards.coureur_des_bois.trapped_enemies = 10
  self.rewards.artemis = {}
  self.rewards.artemis.kills = 6
  self.rewards.decapitator = {}
  self.rewards.decapitator.headshots = 10
  self.rewards.spotter = {}
  self.rewards.spotter.kills = 5
  self.rewards.eagle_eye = {}
  self.rewards.eagle_eye.tags = 20
  self.rewards.finisher = {}
  self.rewards.finisher.executions = 10
  self.rewards.angel_of_death = {}
  self.rewards.angel_of_death.executions = 20
  self.rewards.medicine_man = {}
  self.rewards.medicine_man.revives = 10
  self.rewards.road_agent = {}
  self.rewards.road_agent.kills = 12
  self.rewards.road_agent.sacks = 3
  self.rewards.quickshot = {}
  self.rewards.quickshot.kills = 20
  self.rewards.grenadier = {}
  self.rewards.grenadier.kills = 15
  self.rewards.buckshot = {}
  self.rewards.buckshot.kills = 25
  self.rewards.mad_hatter = {}
  self.rewards.mad_hatter.hats = 15
  self.rewards.forty_niner = {}
  self.rewards.forty_niner.matches = 30
  self.rewards.leprechaun = {}
  self.rewards.leprechaun.matches = 100
  self.rewards.detonator = {}
  self.rewards.detonator.matches = 30
  self.rewards.kegmeister = {}
  self.rewards.kegmeister.matches = 100
  self.rewards.head_honcho = {}
  self.rewards.head_honcho.matches = 30
  self.rewards.royalty = {}
  self.rewards.royalty.matches = 100
  self.rewards.demolisher = {}
  self.rewards.demolisher.objectives = 60
  self.rewards.dead_meat = {}
  self.rewards.dead_meat.deaths = 150
  self.rewards.daisy_pusher = {}
  self.rewards.daisy_pusher.deaths = 300
end
function TweakData:setup_experience()
  self.experience = {}
  self.experience.levels = {}
  self.experience.levels[{0, 40}] = 1
  self.experience.levels[{40, 170}] = 2
  self.experience.levels[{170, 400}] = 3
  self.experience.levels[{400, 700}] = 4
  self.experience.levels[{700, 1100}] = 5
  self.experience.levels[{1100, 1700}] = 6
  self.experience.levels[{1700, 2300}] = 7
  self.experience.levels[{2300, 3100}] = 8
  self.experience.levels[{3100, 4000}] = 9
  self.experience.kill = 30
  self.experience.kill_knocked_down = 40
  self.experience.kill_by_fanning = 10
  self.experience.kill_by_dynamite = 10
  self.experience.kill_by_keg = 10
  self.experience.kill_tagged = 10
  self.experience.tagged_enemy_killed = 10
  self.experience.headshot = 10
  self.experience.assist_kill = 20
  self.experience.friend_untagged = 10
  self.experience.trap_destroyed = 10
  self.experience.kill_lowlevel_penalty = 0.1
  self.experience.kill_highlevel_reward = 0.1
  self.experience.destroy_bank_safe = 300
  self.experience.destroy_water_wheel = 300
  self.experience.destroy_windmill = 300
  self.experience.destroy_door = 50
  self.experience.destroy_wall = 50
  self.experience.destroy_hangbridge = 50
  self.experience.destroy_backroom_02 = 0
  self.experience.destroy_backroom_02b = 0
  self.experience.destroy_backroom_02_front = 0
  self.experience.destroy_mine_rock_spike_gold = 100
  self.experience.trap = 45
  self.experience.revive = 50
  self.experience.carry_time = 2.5
  self.experience.carry_xp = 5
  self.experience.sack_collected = 50
  self.experience.flag_taken = 20
  self.experience.flag_returned = 20
  self.experience.capture_zone_neutral = 100
  self.experience.capture_zone_enemy = 80
  self.experience.sync_update_time = 0.5
end
function TweakData:setup_archetypes()
  self.player = self.player or {}
  self.player.movement = self.player.movement or {}
  self.player.teammate_outline = {}
  self.player.teammate_outline.max_dist = 7600
  self.player.teammate_outline.update_frequency = 0.1
  self.player.teammate_outline.in_view_angle = 45
  self.player.sniper_flare = {}
  self.player.sniper_flare.min_dist = 1000
  self.emotes = {
    SNIPER_COOLDOWN = 30,
    SACK_CARRIER_SPOTTED_COOLDOWN = 30,
    KEG_CARRIER_SPOTTED_COOLDOWN = 30,
    POINT_TAKEN_BY_TEAM_COOLDOWN = 5,
    POINT_BEING_CAPTURED_BY_TEAM_COOLDOWN = 5,
    NEED_ASSISTANCE_REQUEST_COOLDOWN = 4,
    REGROUP_REQUEST_COOLDOWN = 5,
    ATTACK_REQUEST_COOLDOWN = 5,
    KEG_DELIVERED_COOLDOWN = 15,
    SACK_DELIVERED_COOLDOWN = 15,
    KEG_TAKER_COOLDOWN = 20,
    SACK_TAKER_COOLDOWN = 20
  }
  self.player.movement.CARRIABLE_PICKUP_MAX_Z = 200
  self.player.movement.JUMP_HEIGHT_SCALE = 1.3
  self.player.movement.JUMP_LENGTH_SCALE = 1.3
  self.player.movement.JUMP_TIME_SCALE = 1
  self.player.movement.JUMP_AIR_CONTROL_SCALE = 200
  self.player.movement.JUMP_MIN_LENGTH_FACTOR = 0.7
  self.player.movement.MAX_JUMP_SPEED_FACTOR = 1
  self.player.movement.MIN_JUMP_SPEED_FACTOR = 0.6
  self.player.movement.SLIDING_ALLOWED = false
  self.player.movement.EVADE_CHECK_TIMER = 0.2
  self.player.movement.FIRE_BACKWARDS_RIFLE_MIN_ANGLE = 90
  self.player.movement.FIRE_BACKWARDS_FAN_MIN_ANGLE = 90
  self.player.movement.FIRE_BACKWARDS_REVOLVER_MIN_ANGLE = 0
  self.player.movement.TURNING_THRESHOLD_DEGREES = 25
  self.player.movement.TURNING_POINT = Rotation(-160, 0, 0)
  self.player.movement.AUTO_RELOAD_SETTING = "auto"
  self.player.movement.AUTO_RELOAD_ON_FIRE_DELAY_DEFAULT = 0.3
  self.player.movement.JUMP_SURFACE_DETECTION_SPHERE_OFFSET = -45
  self.player.movement.JUMP_SURFACE_DETECTION_SPHERE_RADIUS = -15
  self.player.movement.JUMP_SURFACE_DETECTION_SPHERE_DEBUG = false
  self.player.movement.quickturn = {}
  self.player.movement.quickturn.ENABLED = false
  self.player.movement.quickturn.QUICK_TURN_TIME_WINDOW = 0.35
  self.player.movement.quickturn.QUICK_TURN_NEUTRAL_THRESHOLD = -0.8
  self.player.movement.quickturn.QUICK_TURN_ACTIVATE_THRESHOLD = -0.85
  self.player.movement.quickturn.QUICK_TURN_ROTATION_TIME = 0.25
  self.MINIMUM_PLAYERS_ONLINE_MODE = 4
  self.husks = {}
  self.husks.anim_lod = {}
  self.husks.anim_lod.period = 3
  self.husks.anim_lod.close_radius = 1000
  self.husks.anim_lod.frustum_ext = 500
  self.husks.anim_lod.far_radius = 5000
  self.death_cam = {}
  self.death_cam.CYCLE_TEAM = "both"
  self.mp_setting_defaults = {}
  self.mp_setting_defaults.RESPAWN_POINT_TRIGGER_DISTANCE = 200
  self.mp_setting_defaults.KNOCKOUT_REVIVE_TRIGGER_DISTANCE = 100
  self.mp_setting_defaults.RESPAWN_TIME = 4
  self.mp_setting_defaults.PULSED_RESPAWN_TIME = 24
  self.mp_setting_defaults.PULSED_RESPAWN_ON_GROUND = false
  self.mp_setting_defaults.archetype_selection = {}
  self.mp_setting_defaults.archetype_selection.IS_RANDOM = true
  self.mp_setting_defaults.BOTS_PLAYING = false
  self.mp_setting_defaults.vote_duration = 15
  self.mp_setting_defaults.time_between_votes = 45
  self.mp_setting_defaults.max_started_votes = 10
  self.mp_setting_defaults.all_evidence_found_environment_name = "default"
  self.mp_setting_defaults.all_evidence_found_environment_time = 120
  self.mp_setting_defaults.game_mode_explanation_screens = {
    team_a = {
      instant_show = true,
      time_before_fadeout = 55,
      texture = "welcome_picture",
      caption_id = "hud_welcome_caption_surv",
      text_id = "hud_welcome_text_surv"
    },
    team_b = {
      instant_show = true,
      time_before_fadeout = 55,
      texture = "welcome_picture_gf",
      caption_id = "hud_welcome_caption_gf",
      text_id = "hud_welcome_text_gf"
    }
  }
  self.mp_setting_defaults.archetype_selection.random_weights_a = {
    survivor_1 = 1000,
    survivor_2 = 1,
    survivor_3 = 1,
    survivor_4 = 1000
  }
  self.mp_setting_defaults.archetype_selection.random_weights_b = {ghostface = 1}
  self.mp_setting_defaults.archetype_selection.max_selected_archetype = {
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1
  }
  self.mp_setting_defaults.spawn_pulse_factors_for_uneven_teams = {
    1,
    0.5,
    0.67,
    0.75,
    0.8,
    0.83,
    0.86,
    0.88,
    0.89,
    0.9,
    0.91,
    0.92,
    default = 1
  }
  self.mp_setting_defaults.SHOW_ENEMY_NAMES = false
  self.mp_setting_defaults.SHOW_FRIENDLY_NAMES = false
  self.mp_setting_defaults.SHOW_FRIENDLIES_THROUGH_WALLS = true
  self.mp_setting_defaults.SHOW_TARGET_NAME = false
  self.mp_setting_defaults.RAGDOLL_LINGER_TIME = 20
  self.mp_setting_defaults.PULSE_RESPAWN_GRACE_TIME = 0
  self.mp_setting_defaults.auto_balancing = {PLAYER_DIFF = 2}
  self.mp_setting_defaults.pwk_vs = {}
  self.mp_setting_defaults.pwk_vs.show_attack_on_enemy = true
  self.mp_setting_defaults.pwk_vs.show_protect_on_team = true
  self.mp_setting_defaults.SCREAM_EVIDENCE_COLLECTED_TO_WIN = 3
  self.hud = self.hud or {}
  self.cariable_settings = self.cariable_settings or {}
  self.cariable_settings.DESPAWN_TIME = 40
  self.synergy = {}
  self.synergy_radius = 1000
  self.synergy_removal_timeout = 5
  self.synergy.regeneration = {
    0.5,
    1,
    1.8,
    2.6,
    3.4,
    4.2,
    5,
    5.8,
    6.6,
    7.4
  }
  self.synergy.accuracy = {
    1,
    0.96,
    0.88,
    0.8,
    0.72,
    0.64,
    0.56,
    0.48,
    0.4,
    0.32
  }
  self.synergy.damage_taken = {
    1,
    0.98,
    0.94,
    0.9,
    0.86,
    0.82,
    0.78,
    0.74,
    0.7,
    0.66
  }
  self.synergy.damage_dealt = {
    1,
    1.05,
    1.15,
    1.25,
    1.35,
    1.45,
    1.55,
    1.65,
    1.75,
    1.85
  }
  self.synergy.detection = {
    1.02,
    1.04,
    1.08,
    1.12,
    1.17,
    1.22,
    1.28,
    1.34,
    1.41,
    1.49
  }
  self.synergy.crit_chance = {
    1,
    1.04,
    1.08,
    1.12,
    1.17,
    1.22,
    1.28,
    1.34,
    1.48,
    1.56
  }
  self.synergy_effect = {}
  self.synergy_effect.regeneration = 0
  self.synergy_effect.accuracy = 0
  self.synergy_effect.damage_taken = 0.9
  self.synergy_effect.damage_dealt = 0
  self.synergy_effect.detection = 0
  self.synergy_effect.crit_chance = 0
  self.synergy_effect.REGEN_DAMAGE_CAP = 5
  self.ai_skill = {}
  self.ai_skill.normal = {}
  self.ai_skill.normal.default = {}
  self.ai_skill.normal.default.omniscience = false
  self.ai_skill.normal.default.detection_range = 9000
  self.ai_skill.normal.default.guard_range = 6000
  self.ai_skill.normal.default.hear_range = 3600
  self.ai_skill.normal.default.shooting_range = 3500
  self.ai_skill.normal.default.preferred_range = 1500
  self.ai_skill.normal.default.aim_angle_lerp = 2.25
  self.ai_skill.normal.default.look_angle_lerp = 3
  self.ai_skill.normal.default.fire_within_angle = 5
  self.ai_skill.normal.default.fire_within_bullseye_dist = 30
  self.ai_skill.normal.default.fire_delay = 0.2
  self.ai_skill.normal.default.use_ai_spread = true
  self.ai_skill.normal.default.spread = 5
  self.ai_skill.normal.default.ko_spread = 10
  self.ai_skill.normal.default.ko_silent_time = math.huge
  self.ai_skill.normal.default.revive_request_delay = 5
  self.ai_skill.normal.default.knocked_out_bleed_dps = 0.2
  self.ai_skill.normal.default.health_regen = 0
  self.ai_skill.normal.default.insta_killed = false
  self.ai_skill.normal.default.damage_dealt = 1
  self.ai_skill.normal.gunslinger = {}
  self.ai_skill.normal.gunslinger.shooting_range = 3500
  self.ai_skill.normal.gunslinger.preferred_range = 1500
  self.ai_skill.normal.gunslinger.omniscience = true
  self.ai_skill.normal.blaster = {}
  self.ai_skill.normal.blaster.shooting_range = 2500
  self.ai_skill.normal.blaster.preferred_range = 1000
  self.ai_skill.normal.blaster.omniscience = true
  self.ai_skill.normal.ranger = {}
  self.ai_skill.normal.ranger.shooting_range = 5000
  self.ai_skill.normal.ranger.preferred_range = 2000
  self.ai_skill.normal.ranger.omniscience = true
  self.ai_skill.normal.sniper = {}
  self.ai_skill.normal.sniper.shooting_range = 15000
  self.ai_skill.normal.sniper.preferred_range = 7500
  self.ai_skill.normal.sniper.fire_within_angle = 1.5
  self.ai_skill.normal.sniper.aim_angle_lerp = 1.5
  self.ai_skill.normal.sniper.omniscience = true
  self.ai_skill.normal.debug_guard = {}
  self.ai_skill.normal.debug_guard.detection_range = 5000
  self.ai_skill.normal.debug_guard.guard_range = 2000
  self.ai_skill.normal.debug_guard.hear_range = 500
  self.ai_skill.normal.debug_guard.shooting_range = 750
  self.ai_skill.normal.debug_guard.preferred_range = 500
  self.ai_skill.novice = {}
  self.ai_skill.novice.default = {}
  self.ai_skill.novice.default.omniscience = false
  self.ai_skill.novice.default.detection_range = 8000
  self.ai_skill.novice.default.guard_range = 6000
  self.ai_skill.novice.default.hear_range = 3200
  self.ai_skill.novice.default.shooting_range = 3000
  self.ai_skill.novice.default.preferred_range = 1500
  self.ai_skill.novice.default.aim_angle_lerp = 3
  self.ai_skill.novice.default.look_angle_lerp = 3
  self.ai_skill.novice.default.fire_within_angle = 50
  self.ai_skill.novice.default.fire_within_bullseye_dist = 40
  self.ai_skill.novice.default.knocked_out_bleed_dps = 4
  self.ai_skill.novice.default.fire_delay = 1.5
  self.ai_skill.novice.default.damage_dealt = 0.4
  self.ai_skill.novice.default.use_ai_spread = true
  self.ai_skill.novice.default.spread = 10
  self.ai_skill.novice.default.ko_spread = 10
  self.ai_skill.novice.default.ko_silent_time = math.huge
  self.ai_skill.novice.default.revive_request_delay = 5
  self.ai_skill.novice.gunslinger = {}
  self.ai_skill.novice.gunslinger.shooting_range = 3700
  self.ai_skill.novice.gunslinger.preferred_range = 1700
  self.ai_skill.novice.gunslinger.omniscience = true
  self.ai_skill.novice.blaster = {}
  self.ai_skill.novice.blaster.shooting_range = 2700
  self.ai_skill.novice.blaster.preferred_range = 1200
  self.ai_skill.novice.blaster.omniscience = true
  self.ai_skill.novice.ranger = {}
  self.ai_skill.novice.ranger.shooting_range = 5000
  self.ai_skill.novice.ranger.preferred_range = 1900
  self.ai_skill.novice.ranger.omniscience = true
  self.ai_skill.novice.sniper = {}
  self.ai_skill.novice.sniper.shooting_range = 15000
  self.ai_skill.novice.sniper.preferred_range = 7500
  self.ai_skill.novice.sniper.omniscience = true
  self.ai_skill.novice.sniper.aim_angle_lerp = 3
  self.ai_skill.novice.sniper.look_angle_lerp = 3
  self.ai_skill.novice.sniper.fire_within_angle = 45
  self.ai_skill.novice.sniper.fire_within_bullseye_dist = 40
  self.ai_skill.novice.survivor_1 = {}
  self.ai_skill.novice.survivor_1.shooting_range = 5000
  self.ai_skill.novice.survivor_1.preferred_range = 1900
  self.ai_skill.novice.survivor_1.omniscience = false
  self.ai_skill.novice.survivor_1.detection_range = 1
  self.ai_skill.novice.survivor_1.guard_range = 1
  self.ai_skill.novice.survivor_1.hear_range = 1
  self.ai_skill.novice.survivor_1.shooting_range = 1
  self.ai_skill.easy = {}
  self.ai_skill.easy.default = {}
  self.ai_skill.easy.default.omniscience = false
  self.ai_skill.easy.default.detection_range = 8500
  self.ai_skill.easy.default.guard_range = 6000
  self.ai_skill.easy.default.hear_range = 3400
  self.ai_skill.easy.default.shooting_range = 3250
  self.ai_skill.easy.default.preferred_range = 1500
  self.ai_skill.easy.default.aim_angle_lerp = 3.1
  self.ai_skill.easy.default.look_angle_lerp = 3.1
  self.ai_skill.easy.default.fire_within_angle = 45
  self.ai_skill.easy.default.fire_within_bullseye_dist = 35
  self.ai_skill.easy.default.knocked_out_bleed_dps = 4
  self.ai_skill.easy.default.fire_delay = 1.5
  self.ai_skill.easy.default.damage_dealt = 0.4
  self.ai_skill.easy.default.use_ai_spread = true
  self.ai_skill.easy.default.spread = 8
  self.ai_skill.easy.default.ko_spread = 8
  self.ai_skill.easy.default.ko_silent_time = math.huge
  self.ai_skill.easy.default.revive_request_delay = 4
  self.ai_skill.easy.gunslinger = {}
  self.ai_skill.easy.gunslinger.shooting_range = 3600
  self.ai_skill.easy.gunslinger.preferred_range = 1600
  self.ai_skill.easy.gunslinger.omniscience = true
  self.ai_skill.easy.blaster = {}
  self.ai_skill.easy.blaster.shooting_range = 2700
  self.ai_skill.easy.blaster.preferred_range = 1200
  self.ai_skill.easy.blaster.omniscience = true
  self.ai_skill.easy.ranger = {}
  self.ai_skill.easy.ranger.shooting_range = 5000
  self.ai_skill.easy.ranger.preferred_range = 1800
  self.ai_skill.easy.ranger.omniscience = true
  self.ai_skill.easy.sniper = {}
  self.ai_skill.easy.sniper.shooting_range = 15000
  self.ai_skill.easy.sniper.preferred_range = 7500
  self.ai_skill.easy.sniper.omniscience = true
  self.ai_skill.easy.sniper.aim_angle_lerp = 3
  self.ai_skill.easy.sniper.look_angle_lerp = 3
  self.ai_skill.easy.sniper.fire_within_angle = 45
  self.ai_skill.easy.sniper.fire_within_bullseye_dist = 30
  self.ai_skill.medium = {}
  self.ai_skill.medium.default = {}
  self.ai_skill.medium.default.omniscience = true
  self.ai_skill.medium.default.detection_range = 9000
  self.ai_skill.medium.default.guard_range = 6000
  self.ai_skill.medium.default.hear_range = 3600
  self.ai_skill.medium.default.shooting_range = 3500
  self.ai_skill.medium.default.preferred_range = 1500
  self.ai_skill.medium.default.aim_angle_lerp = 3.3
  self.ai_skill.medium.default.look_angle_lerp = 3.3
  self.ai_skill.medium.default.fire_within_angle = 42
  self.ai_skill.medium.default.fire_within_bullseye_dist = 32
  self.ai_skill.medium.default.knocked_out_bleed_dps = 4
  self.ai_skill.medium.default.fire_delay = 1
  self.ai_skill.medium.default.damage_dealt = 0.6
  self.ai_skill.medium.default.use_ai_spread = true
  self.ai_skill.medium.default.spread = 7
  self.ai_skill.medium.default.ko_spread = 7
  self.ai_skill.medium.default.ko_silent_time = math.huge
  self.ai_skill.medium.default.revive_request_delay = 3
  self.ai_skill.medium.gunslinger = {}
  self.ai_skill.medium.gunslinger.shooting_range = 3500
  self.ai_skill.medium.gunslinger.preferred_range = 1500
  self.ai_skill.medium.gunslinger.omniscience = true
  self.ai_skill.medium.blaster = {}
  self.ai_skill.medium.blaster.shooting_range = 2700
  self.ai_skill.medium.blaster.preferred_range = 1200
  self.ai_skill.medium.blaster.omniscience = true
  self.ai_skill.medium.ranger = {}
  self.ai_skill.medium.ranger.shooting_range = 5000
  self.ai_skill.medium.ranger.preferred_range = 2000
  self.ai_skill.medium.ranger.omniscience = true
  self.ai_skill.medium.sniper = {}
  self.ai_skill.medium.sniper.shooting_range = 15000
  self.ai_skill.medium.sniper.preferred_range = 7500
  self.ai_skill.medium.sniper.omniscience = true
  self.ai_skill.medium.sniper.aim_angle_lerp = 3
  self.ai_skill.medium.sniper.look_angle_lerp = 3
  self.ai_skill.medium.sniper.fire_within_angle = 35
  self.ai_skill.medium.sniper.fire_within_bullseye_dist = 30
  self.ai_skill.hard = {}
  self.ai_skill.hard.default = {}
  self.ai_skill.hard.default.omniscience = true
  self.ai_skill.hard.default.detection_range = 9000
  self.ai_skill.hard.default.guard_range = 6000
  self.ai_skill.hard.default.hear_range = 3600
  self.ai_skill.hard.default.shooting_range = 3500
  self.ai_skill.hard.default.preferred_range = 1500
  self.ai_skill.hard.default.aim_angle_lerp = 3.5
  self.ai_skill.hard.default.look_angle_lerp = 3.5
  self.ai_skill.hard.default.fire_within_angle = 35
  self.ai_skill.hard.default.fire_within_bullseye_dist = 30
  self.ai_skill.hard.default.knocked_out_bleed_dps = 3
  self.ai_skill.hard.default.fire_delay = 0.8
  self.ai_skill.hard.default.damage_dealt = 0.7
  self.ai_skill.hard.default.use_ai_spread = true
  self.ai_skill.hard.default.spread = 5.5
  self.ai_skill.hard.default.ko_spread = 6
  self.ai_skill.hard.default.ko_silent_time = math.huge
  self.ai_skill.hard.default.revive_request_delay = 2
  self.ai_skill.hard.gunslinger = {}
  self.ai_skill.hard.gunslinger.shooting_range = 3500
  self.ai_skill.hard.gunslinger.preferred_range = 1500
  self.ai_skill.hard.gunslinger.omniscience = true
  self.ai_skill.hard.blaster = {}
  self.ai_skill.hard.blaster.shooting_range = 2600
  self.ai_skill.hard.blaster.preferred_range = 1100
  self.ai_skill.hard.blaster.omniscience = true
  self.ai_skill.hard.ranger = {}
  self.ai_skill.hard.ranger.shooting_range = 5000
  self.ai_skill.hard.ranger.preferred_range = 2000
  self.ai_skill.hard.ranger.omniscience = true
  self.ai_skill.hard.sniper = {}
  self.ai_skill.hard.sniper.shooting_range = 15000
  self.ai_skill.hard.sniper.preferred_range = 7500
  self.ai_skill.hard.sniper.omniscience = true
  self.ai_skill.hard.sniper.aim_angle_lerp = 3.5
  self.ai_skill.hard.sniper.look_angle_lerp = 3.5
  self.ai_skill.hard.sniper.fire_within_angle = 30
  self.ai_skill.hard.sniper.fire_within_bullseye_dist = 30
  self.ai_skill.expert = {}
  self.ai_skill.expert.default = {}
  self.ai_skill.expert.default.omniscience = true
  self.ai_skill.expert.default.detection_range = 9000
  self.ai_skill.expert.default.guard_range = 6000
  self.ai_skill.expert.default.hear_range = 3600
  self.ai_skill.expert.default.shooting_range = 3200
  self.ai_skill.expert.default.preferred_range = 1500
  self.ai_skill.expert.default.aim_angle_lerp = 5
  self.ai_skill.expert.default.look_angle_lerp = 5
  self.ai_skill.expert.default.fire_within_angle = 20
  self.ai_skill.expert.default.fire_within_bullseye_dist = 20
  self.ai_skill.expert.default.knocked_out_bleed_dps = 3
  self.ai_skill.expert.default.fire_delay = 0.3
  self.ai_skill.expert.default.damage_dealt = 0.8
  self.ai_skill.expert.default.use_ai_spread = true
  self.ai_skill.expert.default.spread = 4
  self.ai_skill.expert.default.ko_spread = 5
  self.ai_skill.expert.default.ko_silent_time = math.huge
  self.ai_skill.expert.default.revive_request_delay = 1
  self.ai_skill.expert.gunslinger = {}
  self.ai_skill.expert.gunslinger.shooting_range = 3500
  self.ai_skill.expert.gunslinger.preferred_range = 1500
  self.ai_skill.expert.gunslinger.omniscience = true
  self.ai_skill.expert.blaster = {}
  self.ai_skill.expert.blaster.shooting_range = 2500
  self.ai_skill.expert.blaster.preferred_range = 1000
  self.ai_skill.expert.blaster.omniscience = true
  self.ai_skill.expert.ranger = {}
  self.ai_skill.expert.ranger.shooting_range = 5000
  self.ai_skill.expert.ranger.preferred_range = 2000
  self.ai_skill.expert.ranger.omniscience = true
  self.ai_skill.expert.sniper = {}
  self.ai_skill.expert.sniper.shooting_range = 15000
  self.ai_skill.expert.sniper.preferred_range = 7500
  self.ai_skill.expert.sniper.omniscience = true
  self.ai_skill.expert.sniper.aim_angle_lerp = 4
  self.ai_skill.expert.sniper.look_angle_lerp = 4
  self.ai_skill.expert.sniper.fire_within_angle = 25
  self.ai_skill.expert.sniper.fire_within_bullseye_dist = 25
  self.archetypes = {}
  self.archetypes.archetype_definitions = {}
  self.archetypes.weapons = {}
  self.archetypes.ammo_types = {}
  self.archetypes.ammo_types.twelvegauge = {
    AMMO_MAX = 2000,
    BULLETS_PER_SHOT = 12,
    BULLETS_PER_RELOAD = nil,
    HEADSHOT_MULTIPLIER = 2,
    DMG_NEAR = 9,
    DMG_MID = 8,
    DMG_FAR = 7,
    DMG_EXTREME = 5,
    TAG_DAMAGE_MULTIPLIER = 1.4
  }
  self.archetypes.ammo_types.pointfiftyninetysharps = {
    AMMO_MAX = 2000,
    BULLETS_PER_SHOT = nil,
    BULLETS_PER_RELOAD = 1,
    HEADSHOT_MULTIPLIER = 3,
    DMG_NEAR = 120,
    DMG_MID = 120,
    DMG_FAR = 120,
    DMG_EXTREME = 120,
    ARMSHOT_MULTIPLIER = 0.9,
    LEGSHOT_MULTIPLIER = 0.9,
    TAG_DAMAGE_MULTIPLIER = 1.4
  }
  self.archetypes.ammo_types.pointfortyfive = {
    AMMO_MAX = 2000,
    BULLETS_PER_SHOT = nil,
    BULLETS_PER_RELOAD = 6,
    HEADSHOT_MULTIPLIER = 2,
    DMG_NEAR = 45,
    DMG_MID = 40,
    DMG_FAR = 30,
    DMG_EXTREME = 12,
    ARMSHOT_MULTIPLIER = 0.9,
    LEGSHOT_MULTIPLIER = 0.6,
    TAG_DAMAGE_MULTIPLIER = 1.4
  }
  self.archetypes.ammo_types.pointfortyfour = {
    AMMO_MAX = 2000,
    BULLETS_PER_SHOT = nil,
    BULLETS_PER_RELOAD = 1,
    HEADSHOT_MULTIPLIER = 2,
    DMG_NEAR = 36,
    DMG_MID = 28,
    DMG_FAR = 21,
    DMG_EXTREME = 9,
    ARMSHOT_MULTIPLIER = 0.8,
    LEGSHOT_MULTIPLIER = 0.6,
    TAG_DAMAGE_MULTIPLIER = 1.4
  }
  self.archetypes.ammo_types.pointthirtysix = {
    AMMO_MAX = 2000,
    BULLETS_PER_SHOT = nil,
    BULLETS_PER_RELOAD = 1,
    HEADSHOT_MULTIPLIER = 2,
    DMG_NEAR = 45,
    DMG_MID = 40,
    DMG_FAR = 30,
    DMG_EXTREME = 12,
    ARMSHOT_MULTIPLIER = 0.9,
    LEGSHOT_MULTIPLIER = 0.6,
    TAG_DAMAGE_MULTIPLIER = 1.4
  }
  self.archetypes.ammo_types.pointthirty = {
    AMMO_MAX = 2000,
    BULLETS_PER_SHOT = nil,
    BULLETS_PER_RELOAD = 1,
    HEADSHOT_MULTIPLIER = 2,
    DMG_NEAR = 65,
    DMG_MID = 60,
    DMG_FAR = 55,
    DMG_EXTREME = 40,
    ARMSHOT_MULTIPLIER = 0.9,
    LEGSHOT_MULTIPLIER = 0.6,
    TAG_DAMAGE_MULTIPLIER = 1.3
  }
  self.archetypes.weapons.smith_and_wesson = {
    UNIT_NAME = "mp_western_revolver",
    NAME_ID = "hud_colt_45",
    RELOAD_SPEED = 1.3,
    BULLET_FORCE_SHOTGUN = false,
    BULLET_FORCE_MULTIPLIER = 1,
    CAN_ZOOM = true,
    READY_DELAY = 0.33,
    FANNING_DELAY = 0.01,
    AUTO_RELOAD_ON_FIRE_DELAY = self.player.movement.AUTO_RELOAD_ON_FIRE_DELAY_DEFAULT,
    CRIT_CHANCE = 0.074,
    AUTO_RELOAD_SETTING = self.player.movement.AUTO_RELOAD_SETTING,
    HOLSTERED_RELOAD_TIME = 20,
    SPREAD_FIRE_UNZOOM_MIN = 3,
    SPREAD_FIRE_UNZOOM_MAX = 13,
    SPREAD_FIRE_UNZOOM_PER_SHOT = 1.8,
    SPREAD_FIRE_UNZOOM_REDUCTION_FACTOR = 0.5,
    SPREAD_MOVE_UNZOOM_MAX = nil,
    SPREAD_MOVE_UNZOOM_REDUCTION_FACTOR = nil,
    SPREAD_FIRE_ZOOM_MIN = 1.5,
    SPREAD_FIRE_ZOOM_MAX = 7.5,
    SPREAD_FIRE_ZOOM_PER_SHOT = 2,
    SPREAD_FIRE_ZOOM_REDUCTION_FACTOR = 2,
    SPREAD_MOVE_ZOOM_MAX = nil,
    SPREAD_MOVE_ZOOM_REDUCTION_FACTOR = nil,
    RECOIL_MAX_ANGLE = 0.4,
    RECOIL_MIN_ANGLE = 0.1,
    RECOIL_MAX_DEVIATION_ANGLE = 0.2,
    RECOIL_TIME = 0.07,
    AMMO_CLIP = 6,
    AMMO_INIT = nil,
    NEAR_RANGE = 1,
    MID_RANGE = 2000,
    FAR_RANGE = 2700,
    EXTREME_RANGE = 3499,
    MAX_RANGE = 3500,
    AMMO_TYPE = self.archetypes.ammo_types.pointfortyfive,
    RETICLE_SIZE_NORMAL = 250,
    RETICLE_SIZE_ZOOM = 125,
    RETICLE_HINT_DIST_NORMAL = 20000,
    RETICLE_HINT_DIST_ZOOM = 40000,
    HEAT_INCREASE = 8,
    HEAT_DECREASE = 5,
    HEAT_MAX = 31,
    HEAT_EFFECT_START = 26,
    HEAT_EFFECT_STOP = 20,
    TEXTURE = "gui_archetype_weapon_colt45a",
    CAMERA = "revolver",
    CAMERA_ZOOM = "revolver"
  }
  self.archetypes.weapons.buffalo_rifle = {
    NAME_ID = "hud_sniper_rifle",
    UNIT_NAME = "mp_western_buffalo_rifle",
    TEXTURE = "gui_archetype_weapon_sniper",
    RELOAD_SPEED = 1,
    BULLET_FORCE_SHOTGUN = false,
    BULLET_FORCE_MULTIPLIER = 5,
    CAN_ZOOM = true,
    READY_DELAY = 1,
    CRIT_CHANCE = 0.2,
    AUTO_RELOAD_ON_FIRE_DELAY = self.player.movement.AUTO_RELOAD_ON_FIRE_DELAY_DEFAULT,
    AUTO_RELOAD_SETTING = self.player.movement.AUTO_RELOAD_SETTING,
    HOLSTERED_RELOAD_TIME = 5,
    SPREAD_FIRE_UNZOOM_MIN = 2,
    SPREAD_FIRE_UNZOOM_MAX = 10,
    SPREAD_FIRE_UNZOOM_PER_SHOT = 6,
    SPREAD_FIRE_UNZOOM_REDUCTION_FACTOR = 1,
    SPREAD_MOVE_UNZOOM_MAX = 4,
    SPREAD_MOVE_UNZOOM_REDUCTION_FACTOR = 8,
    SPREAD_FIRE_ZOOM_MIN = 0,
    SPREAD_FIRE_ZOOM_MAX = 0,
    SPREAD_FIRE_ZOOM_PER_SHOT = 0,
    SPREAD_FIRE_ZOOM_REDUCTION_FACTOR = 0,
    SPREAD_MOVE_ZOOM_MAX = 0,
    SPREAD_MOVE_ZOOM_REDUCTION_FACTOR = 0,
    RECOIL_MAX_ANGLE = 0.8,
    RECOIL_MIN_ANGLE = 0.2,
    RECOIL_MAX_DEVIATION_ANGLE = 0.4,
    RECOIL_TIME = 0.15,
    AMMO_CLIP = 1,
    AMMO_INIT = nil,
    NEAR_RANGE = 1,
    MID_RANGE = 2500,
    FAR_RANGE = 13000,
    EXTREME_RANGE = 16969,
    MAX_RANGE = 16970,
    AMMO_TYPE = self.archetypes.ammo_types.pointfiftyninetysharps,
    RETICLE_SIZE_NORMAL = 250,
    RETICLE_SIZE_ZOOM = 125,
    RETICLE_HINT_DIST_NORMAL = 20000,
    RETICLE_HINT_DIST_ZOOM = 40000,
    HEAT_INCREASE = 12,
    HEAT_DECREASE = 6,
    HEAT_MAX = 30,
    HEAT_EFFECT_START = 16,
    HEAT_EFFECT_STOP = 4,
    FLARE_DISTANCE = 100,
    CAMERA = "rifle",
    CAMERA_ZOOM = "sniper_rifle",
    CHARGE_DMG_MODIFIERS = {
      {time = 0, dmg = 0.2},
      {time = 0.5, dmg = 0.3},
      {time = 3.3, dmg = 1}
    }
  }
  self.archetypes.weapons.winchester = {
    UNIT_NAME = "mp_western_winchester",
    NAME_ID = "hud_winchester",
    RELOAD_SPEED = 1,
    BULLET_FORCE_SHOTGUN = false,
    BULLET_FORCE_MULTIPLIER = 1,
    CAN_ZOOM = true,
    READY_DELAY = 0.4,
    AUTO_RELOAD_ON_FIRE_DELAY = self.player.movement.AUTO_RELOAD_ON_FIRE_DELAY_DEFAULT,
    CRIT_CHANCE = 0.0925,
    AUTO_RELOAD_SETTING = self.player.movement.AUTO_RELOAD_SETTING,
    HOLSTERED_RELOAD_TIME = 5,
    SPREAD_FIRE_UNZOOM_MIN = 2,
    SPREAD_FIRE_UNZOOM_MAX = 10,
    SPREAD_FIRE_UNZOOM_PER_SHOT = 6,
    SPREAD_FIRE_UNZOOM_REDUCTION_FACTOR = 1,
    SPREAD_MOVE_UNZOOM_MAX = 4,
    SPREAD_MOVE_UNZOOM_REDUCTION_FACTOR = 8,
    SPREAD_FIRE_ZOOM_MIN = 0.5,
    SPREAD_FIRE_ZOOM_MAX = 7.5,
    SPREAD_FIRE_ZOOM_PER_SHOT = 1.2,
    SPREAD_FIRE_ZOOM_REDUCTION_FACTOR = 0.5,
    SPREAD_MOVE_ZOOM_MAX = 1,
    SPREAD_MOVE_ZOOM_REDUCTION_FACTOR = 5,
    RECOIL_MAX_ANGLE = 0.4,
    RECOIL_MIN_ANGLE = 0.1,
    RECOIL_MAX_DEVIATION_ANGLE = 0.2,
    RECOIL_TIME = 0.07,
    AMMO_CLIP = 10,
    AMMO_INIT = nil,
    NEAR_RANGE = 1,
    MID_RANGE = 3000,
    FAR_RANGE = 5500,
    EXTREME_RANGE = 7499,
    MAX_RANGE = 7500,
    AMMO_TYPE = self.archetypes.ammo_types.pointfortyfour,
    RETICLE_SIZE_NORMAL = 250,
    RETICLE_SIZE_ZOOM = 125,
    RETICLE_HINT_DIST_NORMAL = 20000,
    RETICLE_HINT_DIST_ZOOM = 40000,
    HEAT_INCREASE = 12,
    HEAT_DECREASE = 6,
    HEAT_MAX = 30,
    HEAT_EFFECT_START = 16,
    HEAT_EFFECT_STOP = 4,
    TEXTURE = "gui_archetype_weapon_winchester",
    CAMERA = "rifle",
    CAMERA_ZOOM = "rifle"
  }
  self.archetypes.weapons.admiral_revolver = {
    UNIT_NAME = "mp_western_admiral_revolver",
    NAME_ID = "hud_admiral_revolver",
    RELOAD_SPEED = 1,
    BULLET_FORCE_SHOTGUN = false,
    BULLET_FORCE_MULTIPLIER = 1,
    CAN_ZOOM = true,
    READY_DELAY = 0.35,
    FANNING_DELAY = nil,
    CRIT_CHANCE = 0.0997,
    AUTO_RELOAD_SETTING = self.player.movement.AUTO_RELOAD_SETTING,
    AUTO_RELOAD_ON_FIRE_DELAY = self.player.movement.AUTO_RELOAD_ON_FIRE_DELAY_DEFAULT,
    HOLSTERED_RELOAD_TIME = 5,
    SPREAD_FIRE_UNZOOM_MIN = 5,
    SPREAD_FIRE_UNZOOM_MAX = 5,
    SPREAD_FIRE_UNZOOM_PER_SHOT = 0,
    SPREAD_FIRE_UNZOOM_REDUCTION_FACTOR = 1,
    SPREAD_MOVE_UNZOOM_MAX = 0,
    SPREAD_MOVE_UNZOOM_REDUCTION_FACTOR = 7,
    SPREAD_FIRE_ZOOM_MIN = 2,
    SPREAD_FIRE_ZOOM_MAX = 7.5,
    SPREAD_FIRE_ZOOM_PER_SHOT = 2,
    SPREAD_FIRE_ZOOM_REDUCTION_FACTOR = 0.5,
    SPREAD_MOVE_ZOOM_MAX = 1,
    SPREAD_MOVE_ZOOM_REDUCTION_FACTOR = 3,
    RECOIL_MAX_ANGLE = 0.4,
    RECOIL_MIN_ANGLE = 0.1,
    RECOIL_MAX_DEVIATION_ANGLE = 0.2,
    RECOIL_TIME = 0.07,
    AMMO_CLIP = 6,
    AMMO_INIT = nil,
    NEAR_RANGE = 1,
    MID_RANGE = 1500,
    FAR_RANGE = 2800,
    EXTREME_RANGE = 4299,
    MAX_RANGE = 4300,
    AMMO_TYPE = self.archetypes.ammo_types.pointthirtysix,
    RETICLE_SIZE_NORMAL = 250,
    RETICLE_SIZE_ZOOM = 125,
    RETICLE_HINT_DIST_NORMAL = 20000,
    RETICLE_HINT_DIST_ZOOM = 40000,
    HEAT_INCREASE = 8,
    HEAT_DECREASE = 5,
    HEAT_MAX = 30,
    HEAT_EFFECT_START = 16,
    HEAT_EFFECT_STOP = 4,
    TEXTURE = "gui_archetype_weapon_revolver36",
    CAMERA = "revolver",
    CAMERA_ZOOM = "revolver"
  }
  self.archetypes.weapons.coach_rifle = {
    UNIT_NAME = "mp_western_sawed_off_shotgun",
    NAME_ID = "hud_shotgun",
    RELOAD_SPEED = 1,
    BULLET_FORCE_SHOTGUN = true,
    BULLET_FORCE_MULTIPLIER = 1.5,
    CRIT_CHANCE = 0.1,
    CAN_ZOOM = true,
    READY_DELAY = 0.1,
    FANNING_DELAY = nil,
    SPREAD_FIRE_UNZOOM_MIN = 4.3,
    AUTO_RELOAD_SETTING = self.player.movement.AUTO_RELOAD_SETTING,
    AUTO_RELOAD_ON_FIRE_DELAY = self.player.movement.AUTO_RELOAD_ON_FIRE_DELAY_DEFAULT,
    HOLSTERED_RELOAD_TIME = 5,
    RECOIL_MAX_ANGLE = 6.4,
    RECOIL_MIN_ANGLE = 3,
    RECOIL_MAX_DEVIATION_ANGLE = 0.3,
    RECOIL_TIME = 0.1,
    AMMO_CLIP = 2,
    AMMO_INIT = nil,
    NEAR_RANGE = 1,
    MID_RANGE = 700,
    FAR_RANGE = 1500,
    EXTREME_RANGE = 1999,
    MAX_RANGE = 2000,
    AMMO_TYPE = self.archetypes.ammo_types.twelvegauge,
    RETICLE_SIZE_NORMAL = 250,
    RETICLE_SIZE_ZOOM = 125,
    RETICLE_HINT_DIST_NORMAL = 20000,
    RETICLE_HINT_DIST_ZOOM = 40000,
    HEAT_INCREASE = 8,
    HEAT_DECREASE = 5,
    HEAT_MAX = 30,
    HEAT_EFFECT_START = 16,
    HEAT_EFFECT_STOP = 4,
    CAMERA = "revolver",
    CAMERA_ZOOM = "coach_rifle",
    TEXTURE = "gui_archetype_weapon_shotgun",
    LINK_OFFSET = {
      blaster = {pos = "-5.5 -3 0", rot_x = 5}
    }
  }
  self.archetypes.weapons.gatling = {
    NAME_ID = "hud_winchester",
    BULLET_FORCE_SHOTGUN = false,
    BULLET_FORCE_MULTIPLIER = 1,
    READY_DELAY = 0.12,
    IRREGULARITY = 5,
    CRIT_CHANCE = 0.015,
    SPREAD_FIRE_UNZOOM_MIN = 0.8,
    SPREAD_FIRE_UNZOOM_MAX = 1.5,
    SPREAD_FIRE_UNZOOM_REDUCTION_FACTOR = 1,
    RECOIL_MAX_ANGLE = 0.1,
    RECOIL_MIN_ANGLE = 0.1,
    RECOIL_MAX_DEVIATION_ANGLE = 0.1,
    RECOIL_TIME = 0.15,
    NEAR_RANGE = 1,
    MID_RANGE = 3000,
    FAR_RANGE = 5500,
    EXTREME_RANGE = 7499,
    MAX_RANGE = 7500,
    AMMO_TYPE = self.archetypes.ammo_types.pointthirty,
    RETICLE_SIZE_NORMAL = 250,
    RETICLE_SIZE_ZOOM = 125,
    RETICLE_HINT_DIST_NORMAL = 20000,
    RETICLE_HINT_DIST_ZOOM = 40000,
    HEAT_INCREASE = 12,
    HEAT_DECREASE = 6,
    HEAT_MAX = 30,
    HEAT_EFFECT_START = 16,
    HEAT_EFFECT_STOP = 4,
    TEXTURE = "gui_archetype_weapon_winchester",
    CAMERA = "gatling",
    CAMERA_ZOOM = "gatling",
    CAMERA_MIN_PITCH = -30,
    CAMERA_MAX_PITCH = 15,
    CAMERA_MIN_YAW = -40,
    CAMERA_MAX_YAW = 40,
    CAMERA_PITCH_ROT_MULT = 0.1,
    CAMERA_YAW_ROT_MULT = 0.1,
    CAMERA_PITCH_ROT_MULT_PC = 0.05,
    CAMERA_YAW_ROT_MULT_PC = 0.05,
    MAX_ANGLE_VELOCITY = 1500,
    DAMPING_ANGLE = 20,
    NETWORK_UPDATE_ANGLE = 2
  }
  self.archetypes.melee_sequences = {}
  self.archetypes.melee_sequences.knife = {
    {
      REDIRECT = "punch_hook_1",
      DAMAGE = 9,
      READY_DELAY = 0.3,
      FOLLOW_UP_TIME = 0.5
    },
    {
      REDIRECT = "punch_hook_2",
      DAMAGE = 9,
      READY_DELAY = 0.3,
      FOLLOW_UP_TIME = 0.5
    },
    {
      REDIRECT = "punch_hook_3",
      DAMAGE = 9,
      READY_DELAY = 0.3,
      FOLLOW_UP_TIME = 0.5
    },
    {
      REDIRECT = "punch_hook_4",
      DAMAGE = 9,
      READY_DELAY = 0.3,
      FOLLOW_UP_TIME = nil
    }
  }
  self.archetypes.melee_sequences.knife_aiming = {
    {
      REDIRECT = "punch_hook_3",
      DAMAGE = 9,
      READY_DELAY = 0.3,
      FOLLOW_UP_TIME = 0.5
    },
    {
      REDIRECT = "punch_hook_2",
      DAMAGE = 9,
      READY_DELAY = 0.3,
      FOLLOW_UP_TIME = 0.5
    },
    {
      REDIRECT = "punch_hook_1",
      DAMAGE = 9,
      READY_DELAY = 0.3,
      FOLLOW_UP_TIME = 0.5
    },
    {
      REDIRECT = "punch_hook_4",
      DAMAGE = 9,
      READY_DELAY = 0.3,
      FOLLOW_UP_TIME = nil
    }
  }
  self.archetypes.melee_sequences.flashlight = {
    {
      REDIRECT = "flashlight_punch_hook_1",
      DAMAGE = 2,
      READY_DELAY = 0.3,
      FOLLOW_UP_TIME = 0.5
    },
    {
      REDIRECT = "flashlight_punch_hook_2",
      DAMAGE = 2,
      READY_DELAY = 0.3,
      FOLLOW_UP_TIME = 0.5
    },
    {
      REDIRECT = "flashlight_punch_hook_3",
      DAMAGE = 2,
      READY_DELAY = 0.3,
      FOLLOW_UP_TIME = 0.5
    },
    {
      REDIRECT = "flashlight_punch_hook_4",
      DAMAGE = 2,
      READY_DELAY = 0.3,
      FOLLOW_UP_TIME = nil
    }
  }
  self.archetypes.melee_sequences.flashlight_aiming = {
    {
      REDIRECT = "flashlight_punch_hook_3",
      DAMAGE = 2,
      READY_DELAY = 0.3,
      FOLLOW_UP_TIME = 0.5
    },
    {
      REDIRECT = "flashlight_punch_hook_2",
      DAMAGE = 2,
      READY_DELAY = 0.3,
      FOLLOW_UP_TIME = 0.5
    },
    {
      REDIRECT = "flashlight_punch_hook_1",
      DAMAGE = 2,
      READY_DELAY = 0.3,
      FOLLOW_UP_TIME = 0.5
    },
    {
      REDIRECT = "flashlight_punch_hook_4",
      DAMAGE = 2,
      READY_DELAY = 0.3,
      FOLLOW_UP_TIME = nil
    }
  }
  self.archetypes.melee_sequences.bat = {
    {
      REDIRECT = "punch_hook_1",
      DAMAGE = 20,
      READY_DELAY = 0.75,
      FOLLOW_UP_TIME = 1
    },
    {
      REDIRECT = "punch_hook_2",
      DAMAGE = 20,
      READY_DELAY = 0.4,
      FOLLOW_UP_TIME = 0.6
    },
    {
      REDIRECT = "punch_hook_3",
      DAMAGE = 20,
      READY_DELAY = 0.5,
      FOLLOW_UP_TIME = 0.7
    },
    {
      REDIRECT = "punch_hook_4",
      DAMAGE = 20,
      READY_DELAY = 0.4,
      FOLLOW_UP_TIME = 0.6
    },
    {
      REDIRECT = "punch_hook_3",
      DAMAGE = 20,
      READY_DELAY = 0.5,
      FOLLOW_UP_TIME = 0.7
    },
    {
      REDIRECT = "punch_hook_4",
      DAMAGE = 20,
      READY_DELAY = 0.4,
      FOLLOW_UP_TIME = 0.6
    },
    {
      REDIRECT = "punch_hook_3",
      DAMAGE = 20,
      READY_DELAY = 0.5,
      FOLLOW_UP_TIME = nil
    }
  }
  self.archetypes.melee_sequences.bat_aiming = {
    {
      REDIRECT = "punch_hook_1",
      DAMAGE = 20,
      READY_DELAY = 0.75,
      FOLLOW_UP_TIME = 1
    },
    {
      REDIRECT = "punch_hook_2",
      DAMAGE = 20,
      READY_DELAY = 0.4,
      FOLLOW_UP_TIME = 0.6
    },
    {
      REDIRECT = "punch_hook_3",
      DAMAGE = 20,
      READY_DELAY = 0.5,
      FOLLOW_UP_TIME = 0.7
    },
    {
      REDIRECT = "punch_hook_4",
      DAMAGE = 20,
      READY_DELAY = 0.4,
      FOLLOW_UP_TIME = 0.6
    },
    {
      REDIRECT = "punch_hook_3",
      DAMAGE = 20,
      READY_DELAY = 0.5,
      FOLLOW_UP_TIME = 0.7
    },
    {
      REDIRECT = "punch_hook_4",
      DAMAGE = 20,
      READY_DELAY = 0.4,
      FOLLOW_UP_TIME = 0.6
    },
    {
      REDIRECT = "punch_hook_3",
      DAMAGE = 20,
      READY_DELAY = 0.5,
      FOLLOW_UP_TIME = nil
    }
  }
  self.archetypes.weapons.knife = {
    UNIT_NAME = "wpn_knife",
    NAME_ID = "hud_admiral_revolver",
    CAMERA = "revolver",
    CAMERA_ZOOM = "revolver",
    TEXTURE = "gui_archetype_weapon_revolver36",
    ROTATE_PLAYER_TOWARDS_AIM = false,
    ATTACK_SEQUENCE = self.archetypes.melee_sequences.knife,
    ATTACK_SEQUENCE_AIMING = self.archetypes.melee_sequences.knife_aiming,
    HIT_SHAPE = "cylinder",
    DEBUG_DRAW = false
  }
  self.archetypes.weapons.flashlight = {
    UNIT_NAME = "mp_flashlight",
    NAME_ID = "hud_admiral_revolver",
    CAMERA = "revolver",
    CAMERA_ZOOM = "revolver",
    CAN_ZOOM = true,
    TEXTURE = "gui_archetype_weapon_revolver36",
    ROTATE_PLAYER_TOWARDS_AIM = false,
    ATTACK_SEQUENCE = self.archetypes.melee_sequences.flashlight,
    ATTACK_SEQUENCE_AIMING = self.archetypes.melee_sequences.flashlight,
    NEEDS_ZOOM_TO_REVEAL_STALKER = true,
    HIT_SHAPE = "cylinder",
    DEBUG_DRAW = false,
    MAX_RANGE = 1500,
    FLASHLIGHT_ANGLE = 10,
    MAX_GLARE_RANGE = 1500,
    FLASHLIGHT_OUTER_GLARE_ANGLE = 15,
    FLASHLIGHT_INNER_GLARE_ANGLE = 5,
    STAGGERS_FRIENDLIES = false
  }
  self.archetypes.weapons.bat = {
    UNIT_NAME = "wpn_bat",
    NAME_ID = "hud_admiral_revolver",
    CAMERA = "revolver",
    CAMERA_ZOOM = "revolver",
    TEXTURE = "gui_archetype_weapon_revolver36",
    ROTATE_PLAYER_TOWARDS_AIM = true,
    ATTACK_SEQUENCE = self.archetypes.melee_sequences.bat,
    ATTACK_SEQUENCE_AIMING = self.archetypes.melee_sequences.bat_aiming,
    HIT_SHAPE = "cylinder",
    DEBUG_DRAW = false,
    STAGGERS_FRIENDLIES = true
  }
  self.archetypes.weapons.golfclub = {
    UNIT_NAME = "wpn_golf_club",
    NAME_ID = "hud_admiral_revolver",
    CAMERA = "revolver",
    CAMERA_ZOOM = "revolver",
    TEXTURE = "gui_archetype_weapon_revolver36",
    ROTATE_PLAYER_TOWARDS_AIM = true,
    ATTACK_SEQUENCE = self.archetypes.melee_sequences.bat,
    ATTACK_SEQUENCE_AIMING = self.archetypes.melee_sequences.bat_aiming,
    HIT_SHAPE = "cylinder",
    DEBUG_DRAW = false,
    STAGGERS_FRIENDLIES = true
  }
  self.archetypes.ammo_types.pointfortyfive.ko = {
    HEADSHOT_MULTIPLIER = 1,
    DMG_NEAR = 45,
    DMG_MID = 40,
    DMG_FAR = 30,
    DMG_EXTREME = 12
  }
  self.archetypes.ammo_types.pointthirtysix.ko = {
    HEADSHOT_MULTIPLIER = 1,
    DMG_NEAR = 40,
    DMG_MID = 35,
    DMG_FAR = 30,
    DMG_EXTREME = 10
  }
  self:_inherit_table_data(self.archetypes.ammo_types.pointfortyfive, self.archetypes.ammo_types.pointfortyfive.ko)
  self:_inherit_table_data(self.archetypes.ammo_types.pointthirtysix, self.archetypes.ammo_types.pointthirtysix.ko)
  self.archetypes.weapons.smith_and_wesson.ko = {
    READY_DELAY = 0.5,
    SPREAD_FIRE_UNZOOM_MIN = 3,
    SPREAD_FIRE_UNZOOM_MAX = 12,
    SPREAD_FIRE_UNZOOM_PER_SHOT = 2,
    SPREAD_FIRE_UNZOOM_REDUCTION_FACTOR = 1,
    AMMO_TYPE = self.archetypes.ammo_types.pointfortyfive.ko
  }
  self.archetypes.weapons.admiral_revolver.ko = {
    READY_DELAY = 0.5,
    SPREAD_FIRE_UNZOOM_MIN = 3,
    SPREAD_FIRE_UNZOOM_MAX = 10,
    SPREAD_FIRE_UNZOOM_PER_SHOT = 3,
    SPREAD_FIRE_UNZOOM_REDUCTION_FACTOR = 1,
    AMMO_TYPE = self.archetypes.ammo_types.pointthirtysix.ko
  }
  self:_inherit_table_data(self.archetypes.weapons.smith_and_wesson, self.archetypes.weapons.smith_and_wesson.ko)
  self:_inherit_table_data(self.archetypes.weapons.admiral_revolver, self.archetypes.weapons.admiral_revolver.ko)
  self.carriables = {}
  self.carriables.sack = {THROW_PITCH = 30, THROW_SPEED = 750}
  self.carriables.powderkeg = {
    DAMAGE = 307,
    MIN_DAMAGE = 35,
    RADIUS = 500,
    MAX_DAMAGE_RADIUS = 250,
    THROW_PITCH = 30,
    THROW_SPEED = 1000
  }
  self.archetypes.special_abilities = {}
  self.archetypes.special_abilities.fan = {NAME = "fan"}
  self.archetypes.special_abilities.call_enemy = {
    NAME = "call_enemy",
    TAG_TIME = 60,
    ALLOWED_TAGGED_ENEMIES = 2,
    COOLDOWN = 10,
    TAG_MAX_DISTANCE = 200000,
    REMOVE_TAG_DISTANCE = 250,
    HUD_TEXTURE = "hud_phone_icon"
  }
  self.archetypes.special_abilities.tag_enemy = {
    NAME = "tag_enemy",
    TAG_TIME = 5,
    ALLOWED_TAGGED_ENEMIES = 1,
    COOLDOWN = 15,
    TAG_MAX_DISTANCE = 5000,
    TAG_MAX_DISTANCE_WALKING_TARGET = 2000,
    TAG_AIM_RECT_SCREEN_SIZE = 0.5,
    REMOVE_TAG_DISTANCE = 250,
    HUD_TEXTURE = "hud_phone_icon",
    NUMBER_OF_TAG_DIALOGS = {
      melinda = 2,
      susan = 2,
      james = 2,
      brandon = 2
    }
  }
  self.archetypes.special_abilities.set_trap = {
    NAME = "set_trap",
    DAMAGE = 20,
    RADIUS = 70,
    ALLOWED_TRAPS = 2,
    COOLDOWN = 0,
    LINGER_TIME = 12,
    ESCAPE_ANIM_LOOPS = 2,
    DETECT_RADIUS = 5000,
    HUD_TEXTURE = "hud_set_trap_small_icon"
  }
  self.archetypes.special_abilities.throw_bomb = {
    NAME = "throw_bomb",
    DAMAGE = 307,
    MIN_DAMAGE = 35,
    RADIUS = 420,
    MAX_DAMAGE_RADIUS = 200,
    HEALTH = 1,
    COOLDOWN = 10,
    THROW_PITCH = 20,
    SPEED = 1300,
    FUSE_BURN_TIME = 4,
    HUD_TEXTURE = "hud_throw_bomb_small_icon"
  }
  self.archetypes.archetype_definitions.gunslinger = {
    NAME_ID = "hud_gunslinger",
    UNIT_NAME = "mp_player_gunslinger",
    NPC_NAME = "mp_npc_gunslinger",
    DESCRIPTION_ID = "lag_manual_text_1_1",
    SIGNATURE_MOVE = self.archetypes.special_abilities.fan,
    SPEED = 0.9,
    STUN_PUNCH_COOLDOWN = 2,
    damage = {},
    weapons = {
      main_weapon = self.archetypes.weapons.smith_and_wesson
    },
    synergies = {
      regeneration = 1,
      accuracy = 1,
      damage_taken = 0,
      damage_dealt = 0,
      detection = 0,
      crit_chance = 0
    },
    TEXTURE_FULLBODY = "gui_archetype_fullbody_gunslinger",
    TEXTURE_PORTRAIT = "gui_archetype_white_gunslinger"
  }
  self.archetypes.archetype_definitions.ranger = {
    NAME_ID = "hud_ranger",
    UNIT_NAME = "mp_player_ranger",
    NPC_NAME = "mp_npc_ranger",
    DESCRIPTION_ID = "lag_manual_text_1_3",
    SIGNATURE_MOVE = self.archetypes.special_abilities.tag_enemy,
    SPEED = 0.9,
    STUN_PUNCH_COOLDOWN = 2,
    damage = {},
    synergies = {
      regeneration = 1,
      accuracy = 0,
      damage_taken = 0,
      damage_dealt = 1,
      detection = 0,
      crit_chance = 0
    },
    weapons = {
      main_weapon = self.archetypes.weapons.winchester,
      sidearm = self.archetypes.weapons.admiral_revolver
    },
    TEXTURE_FULLBODY = "gui_archetype_fullbody_ranger",
    TEXTURE_PORTRAIT = "gui_archetype_white_ranger"
  }
  self.archetypes.archetype_definitions.blaster = {
    NAME_ID = "hud_blaster",
    UNIT_NAME = "mp_player_blaster",
    NPC_NAME = "mp_npc_blaster",
    DESCRIPTION_ID = "lag_manual_text_1_4",
    SIGNATURE_MOVE = self.archetypes.special_abilities.throw_bomb,
    SPEED = 0.9,
    STUN_PUNCH_COOLDOWN = 2,
    damage = {},
    TEXTURE_FULLBODY = "gui_archetype_fullbody_blaster",
    TEXTURE_PORTRAIT = "gui_archetype_white_blaster",
    synergies = {
      regeneration = 1,
      accuracy = 0,
      damage_taken = 1,
      damage_dealt = 0,
      detection = 0,
      crit_chance = 0
    },
    weapons = {
      main_weapon = self.archetypes.weapons.coach_rifle,
      sidearm = self.archetypes.weapons.admiral_revolver
    }
  }
  self.archetypes.archetype_definitions.sniper = {
    NAME_ID = "hud_sniper",
    UNIT_NAME = "mp_player_sniper",
    NPC_NAME = "mp_npc_sniper",
    DESCRIPTION_ID = "lag_manual_text_1_2",
    TEXTURE_FULLBODY = "gui_archetype_fullbody_sniper",
    TEXTURE_PORTRAIT = "gui_archetype_white_sniper",
    SIGNATURE_MOVE = self.archetypes.special_abilities.set_trap,
    SPEED = 0.9,
    STUN_PUNCH_COOLDOWN = 2,
    damage = {},
    synergies = {
      regeneration = 1,
      accuracy = 0,
      damage_taken = 0,
      damage_dealt = 0,
      detection = 0,
      crit_chance = 1
    },
    weapons = {
      main_weapon = self.archetypes.weapons.buffalo_rifle,
      sidearm = self.archetypes.weapons.admiral_revolver
    }
  }
  self.archetypes.archetype_definitions.ghostface = {
    NAME_ID = "hud_gunslinger",
    UNIT_NAME = "mp_player_ghostface",
    NAME = "ghostface",
    NPC_NAME = "mp_npc_ghostface",
    DESCRIPTION_ID = "lag_manual_text_1_1",
    SIGNATURE_MOVE = self.archetypes.special_abilities.tag_enemy,
    SPEED = 1.1,
    STUN_PUNCH_COOLDOWN = 2,
    SHOW_TARGET_OUTLINES = true,
    HAS_STALKER_MODE = true,
    STALKER_MODE_AUTO_VISIBLE_DISTANCE = 0,
    STALKER_MODE_AUTO_INVISIBLE_DISTANCE = 5000,
    STALKER_MODE_AUTO_INVISIBLE_ANGLE = 45,
    CAN_EXECUTE = true,
    EXECUTION_TIME = 3,
    STALKER_SPEED = 1.5,
    SPAWN_IN_STALKER_MODE = true,
    damage = {
      HEALTH = 10,
      INSTANT_KILL_DMG_THRESHOLD = 1,
      MELEE_STUNNED_ANIM_SPEED = 1
    },
    weapons = {
      main_weapon = self.archetypes.weapons.knife
    },
    special_move_attack = {GRAPPLE_DISTANCE = 80, EXECUTION_DELAY = 2},
    synergies = {
      regeneration = 1,
      accuracy = 0,
      damage_taken = 0,
      damage_dealt = 0,
      detection = 0,
      crit_chance = 0
    },
    welcome_panel_data = {
      {
        time_before_fadeout = 5,
        texture = "welcome_picture_gf",
        caption_id = "hud_welcome_caption_gf_2",
        text_id = "hud_welcome_text_gf_2"
      }
    },
    TEXTURE_FULLBODY = "gui_archetype_fullbody_gunslinger",
    TEXTURE_PORTRAIT = "gui_archetype_white_gunslinger",
    TEXTURE_INGAME_HELP = "hud_ingame_help_ghostface",
    stalker_mode = {
      raycast_origin_object = "Head",
      raycast_points = {
        "Hips",
        "LeftHand",
        "RightHand",
        "LeftFoot",
        "RightFoot"
      },
      rays_per_frame = 2
    }
  }
  self.archetypes.archetype_definitions.survivor_1 = {
    NAME_ID = "hud_sniper",
    UNIT_NAME = "mp_player_survivor_1",
    NAME = "susan",
    NPC_NAME = "mp_npc_survivor_1",
    DESCRIPTION_ID = "lag_manual_text_1_2",
    TEXTURE_FULLBODY = "gui_archetype_fullbody_sniper",
    TEXTURE_PORTRAIT = "gui_archetype_white_sniper",
    TEXTURE_INGAME_HELP = "hud_ingame_help_survivor",
    SIGNATURE_MOVE = {},
    SPEED = 1,
    JOG_WHEN_CARRYING = true,
    CARRYING_SPEED_MULTIPLIER = 0.8,
    STUN_PUNCH_COOLDOWN = 2,
    damage = {
      HEALTH = 30,
      MINIMUM_REGENERATABLE_DAMAGE = 18,
      MELEE_STUNNED_ANIM_SPEED = 2
    },
    synergies = {
      regeneration = 0,
      accuracy = 0,
      damage_taken = 0,
      damage_dealt = 0,
      detection = 0,
      crit_chance = 0
    },
    welcome_panel_data = {
      {
        time_before_fadeout = 5,
        texture = "welcome_picture",
        caption_id = "hud_welcome_caption_surv_1",
        text_id = "hud_welcome_text_surv_1"
      }
    },
    weapons = {
      main_weapon = self.archetypes.weapons.bat,
      showdown = self.archetypes.weapons.smith_and_wesson
    }
  }
  self.archetypes.archetype_definitions.survivor_2 = {
    NAME_ID = "hud_sniper",
    UNIT_NAME = "mp_player_survivor_2",
    NAME = "melinda",
    NPC_NAME = "mp_npc_survivor_1",
    DESCRIPTION_ID = "lag_manual_text_1_2",
    TEXTURE_FULLBODY = "gui_archetype_fullbody_sniper",
    TEXTURE_PORTRAIT = "gui_archetype_white_sniper",
    TEXTURE_INGAME_HELP = "hud_ingame_help_survivor",
    SIGNATURE_MOVE = {},
    SPEED = 1,
    JOG_WHEN_CARRYING = true,
    CARRYING_SPEED_MULTIPLIER = 0.8,
    STUN_PUNCH_COOLDOWN = 2,
    damage = {
      HEALTH = 30,
      MINIMUM_REGENERATABLE_DAMAGE = 18,
      MELEE_STUNNED_ANIM_SPEED = 2
    },
    synergies = {
      regeneration = 0,
      accuracy = 0,
      damage_taken = 0,
      damage_dealt = 0,
      detection = 0,
      crit_chance = 0
    },
    welcome_panel_data = {
      {
        time_before_fadeout = 5,
        texture = "welcome_picture",
        caption_id = "hud_welcome_caption_surv_2",
        text_id = "hud_welcome_text_surv_2"
      }
    },
    weapons = {
      main_weapon = self.archetypes.weapons.flashlight,
      showdown = self.archetypes.weapons.smith_and_wesson
    }
  }
  self.archetypes.archetype_definitions.survivor_3 = {
    NAME_ID = "hud_sniper",
    UNIT_NAME = "mp_player_survivor_3",
    NAME = "brandon",
    NPC_NAME = "mp_npc_survivor_1",
    DESCRIPTION_ID = "lag_manual_text_1_2",
    TEXTURE_FULLBODY = "gui_archetype_fullbody_sniper",
    TEXTURE_PORTRAIT = "gui_archetype_white_sniper",
    TEXTURE_INGAME_HELP = "hud_ingame_help_survivor",
    SIGNATURE_MOVE = {},
    SPEED = 1,
    JOG_WHEN_CARRYING = true,
    CARRYING_SPEED_MULTIPLIER = 0.8,
    STUN_PUNCH_COOLDOWN = 2,
    damage = {
      HEALTH = 30,
      MINIMUM_REGENERATABLE_DAMAGE = 18,
      MELEE_STUNNED_ANIM_SPEED = 2
    },
    synergies = {
      regeneration = 0,
      accuracy = 0,
      damage_taken = 0,
      damage_dealt = 0,
      detection = 0,
      crit_chance = 0
    },
    welcome_panel_data = {
      {
        time_before_fadeout = 5,
        texture = "welcome_picture",
        caption_id = "hud_welcome_caption_surv_3",
        text_id = "hud_welcome_text_surv_3"
      }
    },
    weapons = {
      main_weapon = self.archetypes.weapons.golfclub,
      showdown = self.archetypes.weapons.smith_and_wesson
    }
  }
  self.archetypes.archetype_definitions.survivor_4 = {
    NAME_ID = "hud_sniper",
    UNIT_NAME = "mp_player_survivor_4",
    NAME = "james",
    NPC_NAME = "mp_npc_survivor_1",
    DESCRIPTION_ID = "lag_manual_text_1_2",
    TEXTURE_FULLBODY = "gui_archetype_fullbody_sniper",
    TEXTURE_PORTRAIT = "gui_archetype_white_sniper",
    TEXTURE_INGAME_HELP = "hud_ingame_help_survivor",
    SIGNATURE_MOVE = {},
    SPEED = 1,
    JOG_WHEN_CARRYING = true,
    CARRYING_SPEED_MULTIPLIER = 0.8,
    STUN_PUNCH_COOLDOWN = 2,
    damage = {
      HEALTH = 30,
      MINIMUM_REGENERATABLE_DAMAGE = 18,
      MELEE_STUNNED_ANIM_SPEED = 2
    },
    synergies = {
      regeneration = 0,
      accuracy = 0,
      damage_taken = 0,
      damage_dealt = 0,
      detection = 0,
      crit_chance = 0
    },
    welcome_panel_data = {
      {
        time_before_fadeout = 5,
        texture = "welcome_picture",
        caption_id = "hud_welcome_caption_surv_4",
        text_id = "hud_welcome_text_surv_4"
      }
    },
    weapons = {
      main_weapon = self.archetypes.weapons.flashlight,
      showdown = self.archetypes.weapons.smith_and_wesson
    }
  }
  self.MAXIMUM_DAMAGE = 511
  self.archetypes.allowed_archetypes = {
    "survivor_1",
    "gunslinger",
    "ranger",
    "blaster",
    "sniper"
  }
  self.archetypes.default_archetype = {
    self.archetypes.archetype_definitions.gunslinger
  }
  self.archetypes.default_damage_settings = {}
  self.archetypes.default_damage_settings.HEALTH = 100
  self.archetypes.default_damage_settings.HEALTH_AFTER_REVIVE = 10
  self.archetypes.default_damage_settings.MINIMUM_REGENERATABLE_DAMAGE = 0
  self.archetypes.default_damage_settings.KNOCKED_OUT_DAZE_TIME = 3
  self.archetypes.default_damage_settings.SPAWN_INVULERNABLE_TIME = 0
  self.archetypes.default_damage_settings.KNOCKED_OUT_BLEED_DPS = 0
  self.archetypes.default_damage_settings.LAST_MEMBER_TO_DO_DAMAGE_TIMER = 5
  self.archetypes.default_damage_settings.FALL_DAMAGE_DEATH_HEIGHT = 1100
  self.archetypes.default_damage_settings.FALL_DAMAGE_KO_HEIGHT = 1100
  self.archetypes.default_damage_settings.FALL_DAMAGE_HURT_HEIGHT = 500
  self.archetypes.default_damage_settings.FALL_DAMAGE_ROLL_HEIGHT = 200
  self.archetypes.default_damage_settings.FALL_DAMAGE_HURT_PROCENT = 0
  self.archetypes.default_damage_settings.HURT_ANIM_DELAY = 1
  self.archetypes.default_damage_settings.MAX_SWIM_DURATION = 1.5
  self.archetypes.default_damage_settings.SPLINE_HURT_DAMAGE = 6
  self.archetypes.default_damage_settings.LAST_SPLINE_HURT_DAMAGE = 0
  self.archetypes.default_damage_settings.SPLINE_HURT_RESET_DELAY = 3
  self.archetypes.default_damage_settings.SPLINE_HURT_DELAY = 2
  self.archetypes.default_damage_settings.MAX_DAMAGE_FALL = 100
  self.archetypes.default_damage_settings.DAMAGE_FALL_STEPS = 5
  self.archetypes.default_damage_settings.SAME_BODY_COLLISION_DELAY = 0.8
  self.archetypes.default_damage_settings.FAST_TRESHOLD = 850
  self.archetypes.default_damage_settings.MEDIUM_TRESHOLD = 500
  self.archetypes.default_damage_settings.SMALL_TRESHOLD = 250
  self.archetypes.default_damage_settings.SLOW_TRESHOLD = 2
  self.archetypes.default_damage_settings.MELEE_DAMAGE_MIN = 25
  self.archetypes.default_damage_settings.MELEE_DAMAGE_MAX = 25
  self.archetypes.default_damage_settings.MELEE_ON_KNOCKED_DOWN = true
  self.archetypes.default_damage_settings.MELEE_POWER = 200
  self.archetypes.default_damage_settings.MELEE_STUNNED_ANIM_SPEED = 1.6
  self.archetypes.default_damage_settings.SMALL_DMG_THRESHOLD = 3
  self.archetypes.default_damage_settings.MEDIUM_DMG_THRESHOLD = 40
  self.archetypes.default_damage_settings.LARGE_DMG_THRESHOLD = 75
  self.archetypes.default_damage_settings.LOW_HEALTH_SOUND = 0.5
  self.archetypes.default_damage_settings.INSTANT_KILL_DMG_THRESHOLD = 198
  for name, arch in pairs(self.archetypes.archetype_definitions) do
    if not arch.damage then
      arch.damage = table.map_copy(self.archetypes.default_damage_settings)
    else
      for key, param in pairs(self.archetypes.default_damage_settings) do
        arch.damage[key] = arch.damage[key] or param
      end
    end
  end
  self:setup_hard_difficulty()
end
function TweakData:_inherit_table_data(parent_table, child_table)
  for p_key, p_value in pairs(parent_table) do
    if not child_table[p_key] then
      child_table[p_key] = p_value
    end
  end
end
function TweakData:setup_difficulty(is_init)
  if not is_init then
    self:reloaded()
  end
end
function TweakData:setup_hard_difficulty()
  self.player = self.player or {}
  self.player.MIN_IDLE_SOUND_INTERVAL = 60
  self.player.MAX_IDLE_SOUND_INTERVAL = 120
  self.player.voice = {}
  self.player.voice.TAUNT_HEADSHOT_COUNT = 2
  self.player.voice.TAUNT_HEADSHOT_TIME = 4
  self.spring_camera = {}
  self.spring_camera.SPRING_CONSTANT = {}
  self.spring_camera.SPRING_CONSTANT.xy = 1
  self.spring_camera.SPRING_CONSTANT.z = 0.5
  self.spring_camera.MAX_OFFSET = {}
  self.spring_camera.MAX_OFFSET.xy = 20
  self.spring_camera.MAX_OFFSET.z = 20
  self.spring_camera.DAMPING_CONSTANT = {}
  self.spring_camera.DAMPING_CONSTANT.xy = 3
  self.spring_camera.DAMPING_CONSTANT.z = 2
  self.player.camera = {}
  self.player.camera.RAY_LENGTH = 20000
  self.player.camera.AIMING_DOWN_FORWARD_OFFSET = 90
  self.player.camera.collision = {}
  self.player.camera.collision.SMOOTH_RADIUS = 30
  self.player.camera.collision.NEAR_RADIUS = 5
  self.player.camera.collision.PRECISION = 0.005
  self.player.camera.collision.MAX_VELOCITY = 250
  self.observer = {}
  self.observer.camera = {}
  self.observer.camera.BLEND_TIME = 0.3
  self.observer.camera.ROTATION_SPEED = 180
  self.observer.camera.CUT_TO_ATTACKER_TIME = 5
  self.player.camera.FOV_ONGROUND = 70
  self.player.camera.FOV_ONGROUND_CON = 75
  self.player.camera.FOV_ONGROUND_ZOOM = 35
  self.player.camera.FOV_ONGROUND_WHIP = 70
  self.player.camera.FOV_ONGROUND_KITE = 55
  self.player.camera.FOV_INAIR = 75
  self.player.camera.FOV_INAIR_CON = 75
  self.player.camera.FOV_INWATER = 75
  self.player.camera.FOV_SLIDE_CON = 65
  self.player.camera.NEAR_RANGE_STD = 7.5
  self.player.camera.FAR_RANGE_STD = 200000
  self.player.camera.CHANGE_SPEED_ZOOM_IN = 0.5
  self.player.camera.CHANGE_SPEED_ZOOM_OUT = 0.5
  self.player.camera.DISTANCE_WHIPSPIN = 1400
  self.player.camera.VELOCITY_WHIPSPIN = 700
  self.player.camera.MIN_SENSIVITY = 0.3
  self.player.camera.MAX_SENSIVITY = 2
  self.player.camera.dof = {}
  self.player.camera.dof.std = {}
  self.player.camera.dof.std.near_min = 0
  self.player.camera.dof.std.near_max = 150
  self.player.camera.dof.std.far_min = 30000
  self.player.camera.dof.std.far_max = 50000
  self.player.camera.dof.std.clamp = 1
  self.player.camera.dof.std.prio = 1
  self.player.camera.dof.std.name = "std"
  self.player.camera.dof.std.fade_in = 0.5
  self.player.camera.dof.std.sustain = nil
  self.player.camera.dof.std.fade_out = 0.5
  self.player.camera.dof.zoom = {}
  self.player.camera.dof.zoom.near_min = 0
  self.player.camera.dof.zoom.near_max = 0
  self.player.camera.dof.zoom.far_min = 50000
  self.player.camera.dof.zoom.far_max = 50000
  self.player.camera.dof.zoom.clamp = 1
  self.player.camera.dof.zoom.prio = 1
  self.player.camera.dof.zoom.name = "zoom"
  self.player.camera.dof.zoom.fade_in = 0.5
  self.player.camera.dof.zoom.sustain = nil
  self.player.camera.dof.zoom.fade_out = 0
  self.player.camera.dof.zoom.update_callback = "upd_clbk_follow_aim"
  self.player.camera.dof.zoom.follow_aim = {}
  self.player.camera.dof.zoom.follow_aim.near_min = 0.8
  self.player.camera.dof.zoom.follow_aim.near_max = 0.5
  self.player.camera.dof.zoom.follow_aim.far_min = 1.5
  self.player.camera.dof.zoom.follow_aim.far_max = 3
  self.player.camera.dof.zoom.follow_aim.overshoot_threshold = 1000
  self.player.camera.dof.zoom.follow_aim.overshoot = 0.5
  self.player.camera.dof.zoom.follow_aim.normal_lerp = 0.5
  self.player.camera.dof.zoom.follow_aim.overshoot_lerp = 0.2
  self.player.camera.dof.menu = {}
  self.player.camera.dof.menu.near_min = 0
  self.player.camera.dof.menu.near_max = 0
  self.player.camera.dof.menu.far_min = 100000
  self.player.camera.dof.menu.far_max = 100000
  self.player.camera.dof.menu.clamp = 1
  self.player.camera.dof.menu.prio = 100
  self.player.camera.dof.menu.name = "menu"
  self.player.camera.dof.menu.fade_in = 0
  self.player.camera.dof.menu.sustain = nil
  self.player.camera.dof.menu.fade_out = 0
  self.player.camera.dof.video = {}
  self.player.camera.dof.video.near_min = 2000
  self.player.camera.dof.video.near_max = 2000
  self.player.camera.dof.video.far_min = 2000
  self.player.camera.dof.video.far_max = 2000
  self.player.camera.dof.video.clamp = 1
  self.player.camera.dof.video.prio = 100
  self.player.camera.dof.video.name = "video"
  self.player.camera.dof.video.fade_in = 0
  self.player.camera.dof.video.sustain = nil
  self.player.camera.dof.video.fade_out = 0.5
  self.player.camera.dof.video.timer = TimerManager:wall()
  self.player.camera.dof.video.play_busy = true
  self.player.camera.dof.death = {}
  self.player.camera.dof.death.near_min = 2000
  self.player.camera.dof.death.near_max = 2000
  self.player.camera.dof.death.far_min = 2000
  self.player.camera.dof.death.far_max = 2000
  self.player.camera.dof.death.clamp = 100
  self.player.camera.dof.death.prio = 100
  self.player.camera.dof.death.name = "death"
  self.player.camera.dof.death.fade_in = 3
  self.player.camera.dof.death.sustain = nil
  self.player.camera.dof.death.fade_out = 0
  self.player.camera.dof.effect = {}
  self.player.camera.dof.effect.near_min = 2000
  self.player.camera.dof.effect.near_max = 2000
  self.player.camera.dof.effect.far_min = 2000
  self.player.camera.dof.effect.far_max = 2000
  self.player.camera.dof.effect.clamp = 1
  self.player.camera.dof.effect.prio = 4
  self.player.camera.dof.effect.name = "effect"
  self.player.camera.dof.effect.fade_in = 0.1
  self.player.camera.dof.effect.sustain = 0.5
  self.player.camera.dof.effect.fade_out = 0
  self.player.camera.dof.generic = {}
  self.player.camera.dof.generic.near_min = 2000
  self.player.camera.dof.generic.near_max = 2000
  self.player.camera.dof.generic.far_min = 2000
  self.player.camera.dof.generic.far_max = 2000
  self.player.camera.dof.generic.clamp = 1
  self.player.camera.dof.generic.prio = 5
  self.player.camera.dof.generic.name = "generic"
  self.player.camera.dof.generic.fade_in = 0.1
  self.player.camera.dof.generic.sustain = 0.5
  self.player.camera.dof.generic.fade_out = 0.1
  self.player.camera.dof.trans = {}
  self.player.camera.dof.trans.near_min = 0
  self.player.camera.dof.trans.near_max = 0
  self.player.camera.dof.trans.far_min = 0
  self.player.camera.dof.trans.far_max = 0
  self.player.camera.dof.trans.clamp = 1
  self.player.camera.dof.trans.prio = 5
  self.player.camera.dof.trans.name = "trans"
  self.player.camera.dof.trans.fade_in = 0
  self.player.camera.dof.trans.sustain = 0.1
  self.player.camera.dof.trans.fade_out = 0.3
  self.player.camera.dof.impact = {}
  self.player.camera.dof.impact.near_min = 2000
  self.player.camera.dof.impact.near_max = 2000
  self.player.camera.dof.impact.far_min = 2000
  self.player.camera.dof.impact.far_max = 2000
  self.player.camera.dof.impact.clamp = 1
  self.player.camera.dof.impact.prio = 6
  self.player.camera.dof.impact.name = "impact"
  self.player.camera.dof.impact.fade_in = 0.1
  self.player.camera.dof.impact.sustain = 0
  self.player.camera.dof.impact.fade_out = 0.2
  self.player.camera.dof.connected = {}
  self.player.camera.dof.connected.near_min = 2000
  self.player.camera.dof.connected.near_max = 2000
  self.player.camera.dof.connected.far_min = 2000
  self.player.camera.dof.connected.far_max = 2000
  self.player.camera.dof.connected.clamp = 1
  self.player.camera.dof.connected.prio = 6
  self.player.camera.dof.connected.name = "connected"
  self.player.camera.dof.connected.fade_in = 0.5
  self.player.camera.dof.connected.sustain = nil
  self.player.camera.dof.connected.fade_out = 0.5
  self.player.camera.dof.connected.update_callback = "upd_clbk_follow_aim"
  self.player.camera.dof.connected.follow_aim = {}
  self.player.camera.dof.connected.follow_aim.near_min = 0.8
  self.player.camera.dof.connected.follow_aim.near_max = 0.5
  self.player.camera.dof.connected.follow_aim.far_min = 1
  self.player.camera.dof.connected.follow_aim.far_max = 2
  self.player.camera.dof.connected.follow_aim.overshoot_threshold = 1000
  self.player.camera.dof.connected.follow_aim.overshoot = 0.5
  self.player.camera.dof.connected.follow_aim.normal_lerp = 0.3
  self.player.camera.dof.connected.follow_aim.overshoot_lerp = 0.2
  self.player.camera.dof.throw_aim = {}
  self.player.camera.dof.throw_aim.near_min = 2000
  self.player.camera.dof.throw_aim.near_max = 2000
  self.player.camera.dof.throw_aim.far_min = 2000
  self.player.camera.dof.throw_aim.far_max = 2000
  self.player.camera.dof.throw_aim.clamp = 0.5
  self.player.camera.dof.throw_aim.prio = 3
  self.player.camera.dof.throw_aim.name = "throw_aim"
  self.player.camera.dof.throw_aim.fade_in = 0.5
  self.player.camera.dof.throw_aim.sustain = nil
  self.player.camera.dof.throw_aim.fade_out = 0.5
  self.player.camera.dof.throw_aim.update_callback = "upd_clbk_follow_aim"
  self.player.camera.dof.throw_aim.follow_aim = {}
  self.player.camera.dof.throw_aim.follow_aim.near_min = 0.8
  self.player.camera.dof.throw_aim.follow_aim.near_max = 0.5
  self.player.camera.dof.throw_aim.follow_aim.far_min = 1
  self.player.camera.dof.throw_aim.follow_aim.far_max = 2
  self.player.camera.dof.throw_aim.follow_aim.overshoot_threshold = 1000
  self.player.camera.dof.throw_aim.follow_aim.overshoot = 0.3
  self.player.camera.dof.throw_aim.follow_aim.normal_lerp = 0.3
  self.player.camera.dof.throw_aim.follow_aim.overshoot_lerp = 0.05
  self.player.camera.dof.turn_speed = {}
  self.player.camera.dof.turn_speed.near_min = 0
  self.player.camera.dof.turn_speed.near_max = 150
  self.player.camera.dof.turn_speed.far_min = 1500
  self.player.camera.dof.turn_speed.far_max = 2000
  self.player.camera.dof.turn_speed.clamp = 1
  self.player.camera.dof.turn_speed.prio = 1
  self.player.camera.dof.turn_speed.name = "turn_speed"
  self.player.camera.dof.turn_speed.fade_in = 0.2
  self.player.camera.dof.turn_speed.sustain = nil
  self.player.camera.dof.turn_speed.fade_out = 0.2
  self.player.camera.dof.action_point = {}
  self.player.camera.dof.action_point.near_min = 0
  self.player.camera.dof.action_point.near_max = 0
  self.player.camera.dof.action_point.far_min = 2000
  self.player.camera.dof.action_point.far_max = 2000
  self.player.camera.dof.action_point.clamp = 1
  self.player.camera.dof.action_point.prio = 6
  self.player.camera.dof.action_point.name = "action_point"
  self.player.camera.dof.action_point.fade_in = 0.1
  self.player.camera.dof.action_point.fade_out = 0.1
  self.player.camera.steer_buraq = {}
  self.player.camera.steer_buraq.DISTANCE = 4000
  self.player.camera.steer_buraq.VELOCITY_IN = 2000
  self.player.camera.steer_buraq.VELOCITY_OUT = 3000
  self.player.camera.death = {}
  self.player.camera.death.classic1 = {}
  self.player.camera.death.classic1.distance = 800
  self.player.camera.death.classic1.pitch = 35
  self.player.camera.death.classic1.lerp = 1
  self.player.camera.blend_times = {}
  self.player.camera.blend_times.DEFAULT = 1
  self.player.camera.blend_times.ENTER_ZOOM_AIM = 0.4
  self.player.camera.blend_times.LEAVE_ZOOM_AIM = 1
  self.player.camera.blend_times.ENTER_FULLY_DAMAGED = 0
  self.player.camera.blend_times.LEAVE_FULLY_DAMAGED = 0
  self.player.camera.blend_times.ENTER_JUMP = 0.2
  self.player.camera.blend_times.LEAVE_JUMP = 0.4
  self.player.camera.blend_times.ENTER_INAIR = 0.2
  self.player.camera.blend_times.LEAVE_INAIR = 0.4
  self.player.camera.blend_times.ENTER_EVADE = 0.2
  self.player.camera.blend_times.LEAVE_EVADE = 0.4
  self.player.overlay = {}
  self.player.overlay.level_fade_out = {}
  self.player.overlay.level_fade_out.blend_mode = "normal"
  self.player.overlay.level_fade_out.sustain = 30
  self.player.overlay.level_fade_out.fade_in = 3
  self.player.overlay.level_fade_out.fade_out = 0
  self.player.overlay.level_fade_out.color = Color(1, 0, 0, 0)
  self.player.overlay.level_fade_out.timer = TimerManager:main()
  self.player.overlay.level_fade_out.play_paused = true
  self.player.overlay.level_fade_in = {}
  self.player.overlay.level_fade_in.blend_mode = "normal"
  self.player.overlay.level_fade_in.sustain = 0
  self.player.overlay.level_fade_in.fade_in = 0
  self.player.overlay.level_fade_in.fade_out = 3
  self.player.overlay.level_fade_in.color = Color(1, 0, 0, 0)
  self.player.overlay.level_fade_in.timer = TimerManager:main()
  self.player.overlay.level_fade_in.play_paused = true
  self.player.overlay.player_fade_out = {}
  self.player.overlay.player_fade_out.blend_mode = "normal"
  self.player.overlay.player_fade_out.fade_in = 0.2
  self.player.overlay.player_fade_out.fade_out = 0
  self.player.overlay.player_fade_out.color = Color(1, 0, 0, 0)
  self.player.overlay.player_fade_out.timer = TimerManager:main()
  self.player.overlay.player_fade_out.play_paused = true
  self.player.overlay.player_fade_in = {}
  self.player.overlay.player_fade_in.blend_mode = "normal"
  self.player.overlay.player_fade_in.sustain = 0
  self.player.overlay.player_fade_in.fade_in = 0
  self.player.overlay.player_fade_in.fade_out = 3
  self.player.overlay.player_fade_in.color = Color(1, 0, 0, 0)
  self.player.overlay.player_fade_in.timer = TimerManager:main()
  self.player.overlay.player_fade_in.play_paused = true
  self.player.overlay.player_fade_in_mp = {}
  self.player.overlay.player_fade_in_mp.blend_mode = "normal"
  self.player.overlay.player_fade_in_mp.sustain = 0
  self.player.overlay.player_fade_in_mp.fade_in = 0
  self.player.overlay.player_fade_in_mp.fade_out = 5
  self.player.overlay.player_fade_in_mp.color = Color(1, 0, 0, 0)
  self.player.overlay.player_fade_in_mp.timer = TimerManager:main()
  self.player.overlay.player_fade_in_mp.play_paused = true
  self.player.death = {}
  self.player.death.game_over_delay = 0.5
  self.player.death.vel_go_delay_add = 0
  self.player.death.auto_respawn_time = 1
  self.player.death.b_g_fade_in_time = 1
  self.player.death.b_g_max_alpha = 0.7
  self.player.death.text_fade_in_time = 1
  self.player.movement = self.player.movement or {}
  self.player.movement.SCRIPTED_MOVEMENT_ENABLED = false
  self.player.movement.SCRIPTED_MOVEMENT_ZOOM_ENABLED = true
  self.player.movement.SCRIPTED_MOVEMENT_SPEED = 600
  self.player.movement.SCRIPTED_MOVEMENT_SPEED_ZOOM = 300
  self.player.movement.EVADE_LENGTH_MULTIPLIER = 1.1
  self.player.movement.STICK_LIMIT_JOG = 0.9
  self.player.movement.STICK_LIMIT_RUN = 0.9
  self.player.movement.ALLOW_RUN = false
  self.player.movement.MOVE_START_TOTAL_TIME = 0.2
  self.player.movement.MOVE_START_RUN_TIME = 0.2
  self.player.movement.HEAVY_FALL_VELOCITY_Z = 3000
  self.player.movement.MEDIUM_FALL_VELOCITY_Z = 1500
  self.player.movement.NARROW_WALK_SNAP_ANGLE = 20
  self.player.movement.EVADE_FATIGUE_RECOVERY_T = 1.4
  self.player.movement.EVADE_IMMUNITY = 2
  self.player.movement.EVADE_IMMUNITY_FATIGUED = 0.5
  self.player.movement.EVADE_ANIM_SPEED = 0.8
  self.player.movement.EVADE_ANIM_SPEED_FATIGUED = 0.6
  self.player.stamina = {}
  self.player.stamina.MIN_WALK_STAMINA = 0
  self.player.stamina.WALK_COST = 0
  self.player.stamina.JOG_COST = 0
  self.player.stamina.MIN_JOG_STAMINA = 0
  self.player.stamina.MIN_START_JOG_STAMINA = 0
  self.player.stamina.SPRINT_COST = 0
  self.player.stamina.MIN_SPRINT_STAMINA = 0
  self.player.stamina.MIN_START_SPRINT_STAMINA = 0
  self.player.stamina.MIN_EVADE_STAMINA = 0
  self.player.stamina.EVADE_COST = 0
  self.player.stamina.REGENERATION = 0
  self.player.aim = {}
  self.player.aim.RAY_LENGTH = self.player.camera.RAY_LENGTH
  self.player.aim.DEBUG_RAY_PERSISTENCY = 30
  self.player.aim.LOOK_SPEED_BASE_MULTI_ZOOM = 1
  self.player.aim.ROT_BLUR_SPEED = 3.5
  self.player.aim.LOOK_SPEED_STD = 17
  self.player.aim.ACC_TIME_MAX_STD = 0.25
  self.player.aim.ACC_STICK_START_STD = 0.98
  self.player.aim.ACC_PRE_VAL_STD = 0.35
  self.player.aim.VER_INPUT_MUL_STD = 0.87
  self.player.aim.LOOK_SPEED_ZOOM = 7
  self.player.aim.ACC_TIME_MAX_ZOOM = 0.25
  self.player.aim.ACC_STICK_START_ZOOM = 0.98
  self.player.aim.ACC_PRE_VAL_ZOOM = 0.35
  self.player.aim.VER_INPUT_MUL_ZOOM = 1
  self.player.aim.ARM_ANIM_TIME_LIMIT = 1.5
  self.player.aim.ONGROUND_AUTOAIM_RANGE = 1700
  self.player.aim.INAIR_AUTOAIM_RANGE = 2000
  self.player.aim.INAIR_CON_AUTOAIM_RANGE = 3000
  self.player.aim.CAMERA_PITCH_ROT_MULT = 0.1
  self.player.aim.CAMERA_YAW_ROT_MULT = 0.1
  self.player.aim.CAMERA_MAX_PITCH = 65
  self.player.aim.CAMERA_MIN_PITCH = -66
  self.player.aim.CAMARA_SOFT_LIMIT_SIZE = 25
  self.player.mp_aim = {}
  self.player.mp_aim.ONGROUND_AUTOAIM_RANGE = 1700
  self.player.mp_aim.INAIR_AUTOAIM_RANGE = 2000
  self.player.mp_aim.INAIR_CON_AUTOAIM_RANGE = 3000
  self.player.mp_aim.MAXIMUM_FIRE_ANGLE = 5
  self.player.aim.autoaim = {}
  self.player.aim.autoaim.sp = {}
  self.player.aim.autoaim.mp = {}
  local general_sp_autoaim_onground = 0.5
  local general_sp_autoaim_onground_zoom = 0.3
  local general_sp_autoaim_inair = 0.7
  self.player.aim.autoaim.sp.onground = general_sp_autoaim_onground
  self.player.aim.autoaim.sp.onground_con = general_sp_autoaim_onground
  self.player.aim.autoaim.sp.onground_zoom = general_sp_autoaim_onground_zoom
  self.player.aim.autoaim.sp.onground_shield = general_sp_autoaim_onground
  self.player.aim.autoaim.sp.onground_hipcutter = 0
  self.player.aim.autoaim.sp.onground_excalibur = 0
  self.player.aim.autoaim.sp.inair = general_sp_autoaim_inair
  self.player.aim.autoaim.sp.inair_con = general_sp_autoaim_inair
  self.player.aim.autoaim.sp.onwall_con = general_sp_autoaim_onground
  self.player.aim.autoaim.sp.slide_con = general_sp_autoaim_onground
  self.player.aim.autoaim.sp.splinemove = general_sp_autoaim_onground
  self.player.aim.autoaim.sp.onground_turret = 0
  self.player.aim.autoaim.sp.inair_anim_move = general_sp_autoaim_inair
  self.player.aim.autoaim.sp.onground_anim_move = general_sp_autoaim_onground
  local general_mp_autoaim_onground = 0.5
  local general_mp_autoaim_onground_zoom = 0.3
  local general_mp_autoaim_inair = 0.7
  self.player.aim.autoaim.mp.onground = general_mp_autoaim_onground
  self.player.aim.autoaim.mp.onground_con = general_mp_autoaim_onground
  self.player.aim.autoaim.mp.onground_zoom = general_mp_autoaim_onground_zoom
  self.player.aim.autoaim.mp.onground_shield = 0
  self.player.aim.autoaim.mp.onground_hipcutter = 0
  self.player.aim.autoaim.mp.onground_excalibur = 0
  self.player.aim.autoaim.mp.inair = general_mp_autoaim_inair
  self.player.aim.autoaim.mp.inair_con = general_mp_autoaim_inair
  self.player.aim.autoaim.mp.onwall_con = general_mp_autoaim_onground
  self.player.aim.autoaim.mp.slide_con = general_mp_autoaim_onground
  self.player.aim.autoaim.mp.splinemove = general_mp_autoaim_onground
  self.player.aim.autoaim.mp.onground_turret = 0
  self.player.aim.autoaim.mp.inair_anim_move = general_mp_autoaim_inair
  self.player.aim.autoaim.mp.onground_anim_move = general_mp_autoaim_onground
  self.player.punch = {}
  self.player.punch.damage = {}
  self.player.punch.damage.STD = 1.5
  self.player.punch.damage.ADR = 3
  self.player.punch.throw = {}
  self.player.punch.throw.LIGHT_RANGE = 4500
  self.player.punch.throw.MEDIUM_RANGE = 4500
  self.player.intel = {}
  self.player.intel.COVER_CHECK_INTERVAL = 0.3
  self.player.intel.COVER_CHECK_OFFSET_GROUND = 50
  self.player.intel.COVER_CHECK_LOWER_HEIGHT = 50
  self.player.intel.COVER_CHECK_UPPER_HEIGHT = 50
  self.player.intel.COVER_CHECK_WIDTH = 200
  self.player.intel.COVER_CHECK_DEPTH = 200
  self.player.inventory = {}
  self.player.inventory.INVENTORY_SIZE = 3
  self.player.inventory.PICKUP_DISTANCE = 200
  self.player.inventory.MANUAL_PICKUP_DISTANCE = 300
  self.player.inventory.TEST_WEAPON_SWITCH_DELAY = 1
  self.player.shockwave = {}
  self.player.shockwave.pulldown = {}
  self.player.shockwave.pulldown.SLOTMASK = "punchables"
  self.player.shockwave.pulldown.RADIUS_KILL = 200
  self.player.shockwave.pulldown.RADIUS_STUN = 800
  self.player.shockwave.pulldown.PROPAGATION_VEL = 2000
  self.player.weapon = {}
  self.player.weapon.maingun = {}
  self.player.weapon.maingun.MAX_RANGE = 20000
  self.player.weapon.maingun.BURST_DELAY = 0.7
  self.player.weapon.maingun.TRIGGER_INWARDS_OFFSET = 0.1
  self.player.weapon.maingun.TRIGGER_OUTWARDS_OFFSET = 0.1
  self.player.weapon.maingun.BURST_BUTTON_MASH_DELAY = 0
  self.player.weapon.maingun.BURST_BULLET_AMOUNT = 1
  self.player.weapon.maingun.FIRE_DELAY = 0.055
  self.player.weapon.maingun.FIRE_DELAY_ZOOM = 0.055
  self.player.weapon.maingun.FIRE_TIMER = 1
  self.player.weapon.maingun.DAMAGE = 1
  self.player.weapon.maingun.DAMAGE_KITE_DYNAMIC = 1
  self.player.weapon.maingun.DAMAGE_NEAR = 3
  self.player.weapon.maingun.DAMAGE_FAR = 0.73
  self.player.weapon.maingun.DAMAGE_NEAR_THRESHOLD = 1500
  self.player.weapon.maingun.DAMAGE_FAR_THRESHOLD = 4500
  self.player.weapon.maingun.DAMAGE_UPGRADES = {0.05, 0.1}
  self.player.weapon.maingun.DAMAGE_MODIFIER = 0.7
  self.player.weapon.maingun.SPREAD_STD = 6
  self.player.weapon.maingun.SPREAD_ZOOM = 0.65
  self.player.weapon.maingun.SPREAD_ZOOM_TIMER = 3
  self.player.weapon.maingun.SPREAD_ZOOM_UPGRADE = {0.9}
  self.player.weapon.maingun.SPREAD_STD_UPGRADE = {0.9}
  self.player.weapon.maingun.SPREAD_KITE = 1
  self.player.weapon.maingun.SPREAD_WATERSKII = 3
  self.player.weapon.maingun.RETICLE_SIZE_NORMAL = 122
  self.player.weapon.maingun.RETICLE_SIZE_CON = 115
  self.player.weapon.maingun.RETICLE_SIZE_ZOOM = 65
  self.player.weapon.maingun.RETICLE_DOT_ALPHA_ZOOM = 0.8
  self.player.weapon.maingun.RETICLE_SIZE_WATERSKII = 55
  self.player.weapon.maingun.RETICLE_HINT_DIST_NORMAL = 2000
  self.player.weapon.maingun.RETICLE_HINT_DIST_ZOOM = 3700
  self.player.weapon.maingun.AUTOAIM_DIST_RAMP_NORMAL = {ramp_start = 0.6, lerp_to = 0.1}
  self.player.weapon.maingun.AUTOAIM_DIST_RAMP_ZOOM = {ramp_start = 0.8, lerp_to = 0.05}
  self.player.weapon.maingun.ZOOM_AIM_SPEED = self.player.aim.LOOK_SPEED_BASE_MULTI_ZOOM
  self.player.weapon.maingun.AMMO_MAX = 48
  self.player.weapon.maingun.AMMO_MAX_UPGRADES = {15, 30}
  self.player.weapon.maingun.LOW_AMMO_THRESHOLD = 15
  self.player.weapon.maingun.CLIP_RATIO = 4
  self.player.weapon.maingun.CAM_SHAKE_AMPLITUDE = 0.05
  self.player.weapon.maingun.CAM_SHAKE_AMPLITUDE_ZOOM = 0.1
  self.player.weapon.maingun.HEADSHOT_DISTANCE = 3000
  self.player.weapon.maingun2 = table.map_copy(self.player.weapon.maingun)
  self.player.weapon.maingun2.DAMAGE_KITE_DYNAMIC = 0.3
  self.player.weapon.maingun2.DAMAGE_NEAR_THRESHOLD = 1500
  self.player.weapon.maingun2.DAMAGE_NEAR = 5
  self.player.weapon.maingun2.DAMAGE_FAR = 0.8
  self.player.weapon.maingun2.DAMAGE_FAR_THRESHOLD = 4500
  self.player.weapon.maingun2.DAMAGE_UPGRADES = {0.1, 0.3}
  self.player.weapon.mgsj = {}
  self.player.weapon.mgsj.FIRE_DELAY = 0.04
  self.player.weapon.mgsj.FIRE_DELAY_UPGRADES = {0.9}
  self.player.weapon.mgsj.DAMAGE = 0.22
  self.player.weapon.mgsj.DAMAGE_KITE_DYNAMIC = 0.1
  self.player.weapon.mgsj.DAMAGE_NEAR_THRESHOLD = 3000
  self.player.weapon.mgsj.DAMAGE_FAR_THRESHOLD = 5000
  self.player.weapon.mgsj.DAMAGE_NEAR = 0.9
  self.player.weapon.mgsj.DAMAGE_FAR = 0.7
  self.player.weapon.mgsj.RETICLE_SIZE_NORMAL = 115
  self.player.weapon.mgsj.RETICLE_SIZE_CON = 115
  self.player.weapon.mgsj.RETICLE_SIZE_ZOOM = 45
  self.player.weapon.mgsj.RETICLE_SIZE_WATERSKII = 55
  self.player.weapon.mgsj.RETICLE_HINT_DIST_NORMAL = 2500
  self.player.weapon.mgsj.RETICLE_HINT_DIST_ZOOM = 5000
  self.player.weapon.mgsj.AUTOAIM_DIST_RAMP_NORMAL = {ramp_start = 0.45, lerp_to = 0.2}
  self.player.weapon.mgsj.AUTOAIM_DIST_RAMP_ZOOM = {ramp_start = 0.7, lerp_to = 0.2}
  self.player.weapon.mgsj.ZOOM_AIM_SPEED = self.player.aim.LOOK_SPEED_BASE_MULTI_ZOOM
  self.player.weapon.mgsj.SPREAD_STD = 6
  self.player.weapon.mgsj.SPREAD_ZOOM = 0.5
  self.player.weapon.mgsj.SPREAD_KITE = 1
  self.player.weapon.mgsj.SPREAD_WATERSKII = 1
  self.player.weapon.mgsj.MAX_RANGE = 15000
  self.player.weapon.mgsj.AMMO_MAX = 400
  self.player.weapon.mgsj.AMMO_MAX_UPGRADES = {200}
  self.player.weapon.mgsj.HEADSHOT_DISTANCE = 4000
  self.player.weapon.mgsj.AUTO_SWITCH_DELAY = 1
  self.player.weapon.mgsj.BURST_COUNTER = 3
  self.player.weapon.sniperrifle = {}
  self.player.weapon.sniperrifle.FIRE_DELAY = 1
  self.player.weapon.sniperrifle.FIRE_DELAY_ZOOM = 1
  self.player.weapon.sniperrifle.FIRE_DELAY_UPGRADES = {0.9, 0.85}
  self.player.weapon.sniperrifle.DAMAGE = 24
  self.player.weapon.sniperrifle.RETICLE_SIZE_NORMAL = 16
  self.player.weapon.sniperrifle.RETICLE_SIZE_CON = 16
  self.player.weapon.sniperrifle.RETICLE_SIZE_ZOOM = 0
  self.player.weapon.sniperrifle.RETICLE_SIZE_WATERSKII = 0
  self.player.weapon.sniperrifle.RETICLE_HINT_DIST_NORMAL = 10000
  self.player.weapon.sniperrifle.RETICLE_HINT_DIST_ZOOM = 10000
  self.player.weapon.sniperrifle.SPREAD_STD = 14.5
  self.player.weapon.sniperrifle.SPREAD_ZOOM = 0
  self.player.weapon.sniperrifle.SPREAD_KITE = 14.5
  self.player.weapon.sniperrifle.SPREAD_WATERSKII = 3
  self.player.weapon.sniperrifle.AMMO_MAX = 8
  self.player.weapon.sniperrifle.RECOIL_DELAY = 0.15
  self.player.weapon.sniperrifle.RECOIL_DELAY_UPGRADES = {0.7}
  self.player.weapon.sniperrifle.HEADSHOT_DISTANCE = 50000
  self.player.weapon.sniperrifle.ZOOM_AIM_SPEED = 0.2
  self.player.weapon.sniperrifle.ZOOM_FOV = 15
  self.player.weapon.sniperrifle.AUTO_SWITCH_DELAY = 1
  self.player.weapon.sniperrifle.MAX_RANGE = 50000
  self.player.weapon.grenade = {}
  self.player.weapon.grenade.FIRE_DELAY = 1
  self.player.weapon.grenade.AIM_POS_LERP_SPEED = 0.6
  self.player.weapon.grenade.AIM_ROT_SLERP_SPEED = 0.3
  self.player.weapon.grenade.BALLISTIC_RAY_LENGTH = 1000000
  self.player.weapon.grenade.BALLISTIC_RAY_DRAG = 0.07
  self.player_mp = {}
  self.player_mp.weapon = {}
  self.player_mp.weapon.grenade = {}
  self.player_mp.weapon.maingun = table.map_copy(self.player.weapon.maingun)
  self.player_mp.weapon.maingun.MAX_RANGE = 24000
  self.player_mp.weapon.maingun.BURST_DELAY = 0.5
  self.player_mp.weapon.maingun.FIRE_TIMER = 0.7
  self.player_mp.weapon.maingun.DAMAGE = 1.9
  self.player_mp.weapon.maingun.SPREAD_STD = 3
  self.player_mp.weapon.maingun.SPREAD_ZOOM = 0.5
  self.player_mp.weapon.maingun.RETICLE_HINT_DIST_NORMAL = 3000
  self.player_mp.weapon.maingun.RETICLE_HINT_DIST_ZOOM = 3000
  self.player_mp.weapon.maingun.AUTOAIM_DIST_RAMP_NORMAL = {ramp_start = 0.45, lerp_to = 0.2}
  self.player_mp.weapon.maingun.AUTOAIM_DIST_RAMP_ZOOM = {ramp_start = 0.7, lerp_to = 0.2}
  self.player_mp.weapon.maingun.RETICLE_SIZE_NORMAL = 128
  self.player_mp.weapon.maingun.RETICLE_SIZE_CON = 128
  self.player_mp.weapon.maingun.RETICLE_SIZE_ZOOM = 55
  self.player_mp.weapon.mgsj = table.map_copy(self.player.weapon.mgsj)
  self.player_mp.weapon.mgsj.DAMAGE = 1.7
  self.player_mp.weapon.mgsj.RETICLE_SIZE_NORMAL = 160
  self.player_mp.weapon.mgsj.RETICLE_SIZE_CON = 180
  self.player_mp.weapon.mgsj.RETICLE_SIZE_ZOOM = 70
  self.player_mp.weapon.mgsj.SPREAD_STD = 2.75
  self.player_mp.weapon.mgsj.SPREAD_ZOOM = 0.7
  self.player_mp.weapon.mgsj.RETICLE_HINT_DIST_NORMAL = 3000
  self.player_mp.weapon.mgsj.RETICLE_HINT_DIST_ZOOM = 3000
  self.player_mp.weapon.mgsj.AUTOAIM_DIST_RAMP_NORMAL = {ramp_start = 0.45, lerp_to = 0.2}
  self.player_mp.weapon.mgsj.AUTOAIM_DIST_RAMP_ZOOM = {ramp_start = 0.7, lerp_to = 0.2}
  self.player_mp.weapon.mgsj.AMMO_MAX = 200
  self.player_mp.weapon.sniperrifle = table.map_copy(self.player.weapon.sniperrifle)
  self.player_mp.weapon.sniperrifle.FIRE_DELAY = 1.2
  self.player_mp.weapon.sniperrifle.FIRE_DELAY_ZOOM = 1.5
  self.player_mp.weapon.sniperrifle.DAMAGE = 26
  self.player_mp.weapon.sniperrifle.ZOOM_AIM_SPEED = 0.5
  self.player_mp.weapon.sniperrifle.ZOOM_FOV = 13
  self.player_mp.weapon.sniperrifle.AMMO_MAX = 8
  self.player_mp.weapon.sniperrifle.MAX_RANGE = 201000
  self.player_mp.weapon.sniperrifle.RETICLE_HINT_DIST_NORMAL = nil
  self.player_mp.weapon.sniperrifle.RETICLE_HINT_DIST_ZOOM = nil
  self.player_mp.death = {}
  self.player_mp.death.game_over_delay = 1
  self.player_mp.death.vel_go_delay_add = 1
  self.player_mp.tech = {}
  self.player_mp.tech.AMMO_REGEN_DELAY = 1
  self.player_mp.tech.AMMO_REGEN = 2
  self.player_mp.tech.HEALTH_REGEN_DELAY = 1
  self.player_mp.tech.HEALTH_REGEN = 2
  self.player_mp.tech.DAMAGE_MODIFIER = 0.9
  self.player_mp.tech.FIRE_RATE_MOD = 0.85
  self.player_mp.tech.MELEE_DMG_MOD = 1.25
  self.player_mp.tech.HEALTH_ABSORB_MOD = 1
  self.player_mp.tech.RUN_SPEED_MOD = 1.1
  self.player_mp.tech.JUMP_PWR_MOD = 1.1
  self.player_mp.scoreboard = {}
  self.player_mp.scoreboard.dof = {}
  self.player_mp.scoreboard.dof.near_min = 2500
  self.player_mp.scoreboard.dof.near_max = 5000
  self.player_mp.scoreboard.dof.far_min = 25000
  self.player_mp.scoreboard.dof.far_max = 50000
  self.player_mp.scoreboard.dof.clamp = 1
  self.player_mp.scoreboard.dof.prio = 1
  self.player_mp.scoreboard.dof.name = "scoreboard"
  self.player_mp.scoreboard.dof.fade_in = 1
  self.player_mp.scoreboard.dof.sustain = nil
  self.player_mp.scoreboard.dof.fade_out = 0
  self.player_mp.scoreboard.overlay = {}
  self.player_mp.scoreboard.overlay.ingame = {}
  self.player_mp.scoreboard.overlay.ingame.blend_mode = "normal"
  self.player_mp.scoreboard.overlay.ingame.sustain = nil
  self.player_mp.scoreboard.overlay.ingame.fade_in = 0.1
  self.player_mp.scoreboard.overlay.ingame.fade_out = 0.1
  self.player_mp.scoreboard.overlay.ingame.color = Color(0.5, 0, 0, 0)
  self.player_mp.scoreboard.overlay.endgame = {}
  self.player_mp.scoreboard.overlay.endgame.blend_mode = "normal"
  self.player_mp.scoreboard.overlay.endgame.sustain = nil
  self.player_mp.scoreboard.overlay.endgame.fade_in = 1
  self.player_mp.scoreboard.overlay.endgame.fade_out = 2
  self.player_mp.scoreboard.overlay.endgame.color = Color(0, 0, 0, 0)
  self.player_mp.matchmaking = {}
  self.player_mp.matchmaking.FAKESKILL_FUZZINESS = 300
  self.player_mp.revive = {}
  self.player_mp.revive.CHECK_TEAMMATES_INTERVAL = 0.5
  self.mp_score = {}
  self.mp_score.KILL_POINT = 2
  self.mp_score.MELEE_POINT = 2
  self.mp_score.KILLER_INAIR_MULTIPLIER = 2
  self.mp_score.VICTIM_INAIR_MULTIPLIER = 2
  self.mp_score.ZIPKICK_MULTIPLIER = 4
  self.mp_score.FLAG_DISTANCE = 10000
  self.mp_score.FLAG_DEFEND_POINT = 3
  self.mp_score.FLAG_ATTACK_POINT = 3
  self.mp_score.FLAG_GRAB_POINT = 3
  self.mp_score.FLAG_RETURN_POINT = 3
  self.mp_score.FLAG_CAPTURE_POINT = 5
  self.mp_score.MULTIPLIER_TIME = 10
  self.locinfo = {}
  self.locinfo.BEGINING_WAIT_TIME = 1
  self.locinfo.DEFAULT_DURATION = 8
  self.locinfo.FADE_IN = 1
  self.locinfo.FADE_OUT = 0.5
  self.locinfo.TEXT_FONT_SIZE = 34
  self.locinfo.TEXT_COLOR = Color.white
  self.instruction = {}
  self.instruction.DEFAULT_DURATION = 3
  self.instruction.FADE_IN = 0.3
  self.instruction.FADE_OUT = 0.3
  self.instruction.TEXT_FONT_SIZE = 22
  self.instruction.EN_TEXT_FONT_SIZE = 22
  self.instruction.KO_TEXT_FONT_SIZE = 26
  self.instruction.JP_TEXT_FONT_SIZE = 22
  self.instruction.TEXT_COLOR = Color.white
  self.SAFE_RECT = {x = 0.85, y = 0.85}
  self.SAFE_RECT_PC = {x = 0.975, y = 0.975}
  self.hud = self.hud or {}
  self.hud.DARK_EDGES_ALPHA = 0.4
  self.hud.HUD_BG_ALPHA = 0.627451
  self.hud.BORDER_COLOR = Color(1, 1, 1)
  self.hud.OPTIMAL_SWING_OFFSET = -60
  self.hud.NUMBER_OF_BRACKETS = 6
  self.hud.ADRENALINE_SIZE = 128
  self.hud.scaling = {}
  self.hud.scaling.normal = {}
  self.hud.scaling.normal.FONT_SIZE = 22
  self.hud.scaling.normal.EN_FONT_SIZE = 22
  self.hud.scaling.normal.KO_FONT_SIZE = 26
  self.hud.scaling.normal.JP_FONT_SIZE = 22
  self.hud.scaling.normal.SCALE_MOD = 1
  self.hud.scaling.normal.SCORE_BOARD_SCALE_MOD = 1
  self.hud.scaling.normal.GRAPPLE_SCALE_MOD = 0
  self.hud.scaling.normal.RETICLE_SCALE_MOD = 1
  self.hud.scaling.minisized = {}
  self.hud.scaling.minisized.FONT_SIZE = 22
  self.hud.scaling.minisized.EN_FONT_SIZE = 18
  self.hud.scaling.minisized.KO_FONT_SIZE = 22
  self.hud.scaling.minisized.JP_FONT_SIZE = 18
  self.hud.scaling.minisized.SCALE_MOD = 0.53
  self.hud.scaling.minisized.SCORE_BOARD_SCALE_MOD = 0.58
  self.hud.scaling.minisized.GRAPPLE_SCALE_MOD = 0
  self.hud.scaling.minisized.RETICLE_SCALE_MOD = 0.61
  self.hud.scaling.maxisized = {}
  self.hud.scaling.maxisized.FONT_SIZE = 22
  self.hud.scaling.maxisized.EN_FONT_SIZE = 22
  self.hud.scaling.maxisized.KO_FONT_SIZE = 26
  self.hud.scaling.maxisized.JP_FONT_SIZE = 22
  self.hud.scaling.maxisized.SCALE_MOD = 1
  self.hud.scaling.maxisized.SCORE_BOARD_SCALE_MOD = 1
  self.hud.scaling.maxisized.GRAPPLE_SCALE_MOD = 0
  self.hud.scaling.maxisized.RETICLE_SCALE_MOD = 1
  self.hud.colors = {}
  self.hud.colors.PLAYER_WHITE = Color(1, 1, 1)
  self.hud.colors.RELAY_ORANGE = Color(1, 0.8235294, 0)
  self.hud.colors.WAYPOINT_GREEN = Color(0.627451, 0.99215686, 0)
  self.hud.colors.WDROP_CYAN = Color(0, 1, 1)
  self.hud.colors.ENEMY_RED = Color(1, 0, 0.05882353)
  self.hud.colors.DAMAGE_OVERLAY_RED = Color(0.87058824, 0.12156863, 0.12156863)
  self.hud.colors.CTF_BLUE = Color(0.003921569, 0.68235296, 0.9411765)
  self.hud.colors.DROWN_PURPLE = Color(0.57254905, 0.15294118, 0.56078434)
  self.hud.colors.MP_WHITE = Color(1, 1, 1)
  self.hud.colors.MP_TEAM_RED = Color(1, 0, 0.05882353)
  self.hud.colors.MP_TEAM_BLUE = Color(0, 0.5411765, 1)
  self.hud.colors.MP_TEAM_RED_TINT = Color(0.6666667, 0.23529412, 0.16862746)
  self.hud.colors.MP_TEAM_BLUE_TINT = Color(0, 0.5411765, 1) / 3
  self.hud.colors.MP_KNOCKED_OUT = Color(0.627451, 0.99215686, 0)
  self.hud.colors.MP_NEUTRAL_TINT = Color(0, 0, 0)
  self.hud.colors.MP_USE_TEAM_COLORS = false
  self.hud.colors.mp_player = {}
  self.hud.colors.mp_player["1"] = Color(1, 0, 0)
  self.hud.colors.mp_player["2"] = Color(0, 1, 1)
  self.hud.colors.mp_player["3"] = Color(1, 1, 0)
  self.hud.colors.mp_player["4"] = Color(1, 0.27450982, 0.74509805)
  self.hud.colors.mp_player["5"] = Color(0, 1, 0)
  self.hud.colors.mp_player["6"] = Color(0.15686275, 0.29803923, 1)
  self.hud.colors.mp_player["7"] = Color(1, 1, 1)
  self.hud.colors.mp_player["8"] = Color(0.5686275, 0, 0.70980394)
  self.hud.colors.mp_player["9"] = Color(1, 0.2, 0)
  self.hud.colors.mp_player["10"] = Color(0, 0.39215687, 0.29411766)
  self.hud.DAMAGE_SCREEN_START = 0.7
  self.hud.DAMAGE_SCREEN_MAX_ALPHA = 0.4
  self.hud.DAMAGE_OVERLAY_AMPLITUDE = 0.075
  self.hud.DAMAGE_OVERLAY_ATTACK = 0.1
  self.hud.DAMAGE_OVERLAY_SUSTAIN = 0
  self.hud.DAMAGE_OVERLAY_DECAY = 0.1
  self.hud.DAMAGE_OVERLAY_FREQUENCY = 5
  self.hud.ADR_AMMO_FADE_TIME = 1.5
  self.hud.ADR_AMMO_FADE_WAIT_TIMER = 2
  self.hud.ADR_AMMO_MOVE_MULTIPLIER = 10
  self.hud.ADR_AMMO_MOVE_TIME = 0.5
  self.hud.HOSTILE_GRENADE_RADIUS = 1500
  self.hud.ACTION_BUTTON_BLINK_SPEED = 4.5
  self.hud.ACTION_BUTTON_BLINK_ALPHA = 0.1
  self.hud.ACTION_BUTTON_WAIT_BEFORE_FADE_OUT = 5
  self.hud.ACTION_TEXT_WAIT_BEFORE_FADE_OUT = 4
  self.hud.ACTION_BUTTON_FADE_OUT_ALPHA = 0.4
  self.hud.ACTION_TEXT_FADE_OUT_ALPHA = 0
  self.hud.ACTION_BUTTON_FADE_OUT_SPEED = 2
  self.hud.ACTION_TEXT_FADE_OUT_SPEED = 4
  self.hud.BREATH_LOOP_NETWORK_TIME = 2
  self.hud.video_viewer = {}
  self.hud.video_viewer.FADEIN_TIME = 1
  self.hud.video_viewer.FADETO_ALPHA = 0.5
  self.hud.video_viewer.RECALL_FADE_IN = 0.4
  self.hud.video_viewer.RECALL_TIME = 1.8
  self.hud.objective = {}
  self.hud.objective.DEFAULT_NUMBER_OF_OBJECTIVES = 5
  self.hud.objective.TIME_TILL_NEXT_REMINDER = 60
  self.hud.objective.TIME_SHOWN_ON_SCREEN = 10
  self.hud.dynamic = {}
  self.hud.dynamic.LEN_DIVIDER = 35
  self.hud.dynamic.GROW_MULTIPLIER = 3.75
  self.hud.dynamic.GROW_BACK_MULTIPLIER = 2.5
  self.hud.dynamic.MOVE_MULTIPLIER = 2.25
  self.hud.dynamic.MOVE_BACK_MULTIPLIER = 2.5
  self.hud.dynamic.MAXIMUM_MOVE_AMPLITUDE = 50
  self.hud.dynamic.MAXIMUM_GROW_AMPLITUDE = 100
  self.hud.dynamic.DYNAMIC_SIZE = 0.1
  self.hud.enemy_healthbar = {}
  self.hud.enemy_healthbar.TIME_ON_SCREEN = 1.2
  self.hud.enemy_healthbar.TIME_ON_SCREEN_BOSS_CLOSE = 1.5
  self.hud.enemy_healthbar.TIME_ON_SCREEN_AFTER_DEATH = 1.4
  self.hud.enemy_healthbar.BAR_COLOR = self.hud.colors.ENEMY_RED
  self.hud.action_button = {}
  self.hud.action_button.Y_COLOR = Color(0.8627451, 0.6666667, 0)
  self.hud.action_button.X_COLOR = Color(0.18039216, 0.29411766, 0.56078434)
  self.hud.action_button.B_COLOR = Color(0.5568628, 0.16862746, 0.14509805)
  self.hud.action_button.A_COLOR = Color(0.5294118, 0.6039216, 0.25490198)
  self.hud.action_button.INACTIVE_ALPHA = 0.5
  self.hud.adrenaline_health = {}
  self.hud.adrenaline_health.HEALTH_COLOR = Color(0.827451, 0.972549, 0.019607844)
  self.hud.adrenaline_health.HEALTH_IN_WATER_COLOR = Color(0.18039216, 0.29411766, 0.56078434)
  self.hud.adrenaline_health.ADRENALINE_COLOR = Color(0.8666667, 0.08235294, 0.08235294)
  self.hud.adrenaline = {}
  self.hud.adrenaline.START_DELAY = 0.5
  self.hud.adrenaline.BETWEEN_DELAY = 0.2
  self.hud.adrenaline.BLINK_TIME = 0.5
  self.hud.adrenaline.CELL_SHOW_TIME = 0.45
  self.hud.health_shield = {}
  self.hud.health_shield.HEALTH_COLOR = Color(0.41568628, 0.99215686, 0)
  self.hud.health_shield.ARMOR_COLOR = Color(0, 1, 1)
  self.hud.health_shield.HEALTH_ICON_COLOR = Color(0.105882354, 0.24705882, 0)
  self.hud.health_shield.ARMOR_ICON_COLOR = Color(0, 0.2509804, 0.2509804)
  self.hud.health_shield.BACKGROUND_COLOR = Color.white
  self.hud.health_shield.BLINK_COLOR = Color(0.90588236, 0.101960786, 0.16078432)
  self.hud.health_shield.GAIN_COLOR = Color.white
  self.hud.health_shield.BOSS_COLOR = Color(1, 0, 0.05882353)
  self.hud.health_shield.CRITICAL_THRESHOLD = 0.3
  self.hud.health_shield.BLINK_THRESHOLD = 0.3
  self.hud.health_shield.WIDTH = 256
  self.hud.health_shield.SPEED_SLOW = 100
  self.hud.health_shield.SPEED_FAST = 1000
  self.hud.adrenaline_color = {}
  self.hud.adrenaline_color.LOOP = Color(1, 1, 0.08627451)
  self.hud.adrenaline_color.WARMUP1 = Color(0.91764706, 0.58431375, 0.22352941)
  self.hud.adrenaline_color.WARMUP2 = Color(0.9411765, 0.8235294, 0.627451)
  self.hud.adrenaline_color.RUNOUT1 = Color(1, 0.29411766, 0.08627451)
  self.hud.adrenaline_color.RUNOUT2 = Color(0.9607843, 0.9607843, 0.9607843)
  self.hud.adrenaline_color.FILL = Color(0.7529412, 0.7529412, 0.7529412, 0.7529412)
  self.hud.hit_indicator = {}
  self.hud.hit_indicator.INDICATOR_DISTANCE = 150
  self.hud.hit_indicator.INDICATOR_SHOW_RADIUS = 600
  self.hud.hit_indicator.FRONT_FADE_IN_TIME = 0.1
  self.hud.hit_indicator.FRONT_FADE_OUT_TIME = 2
  self.hud.hit_indicator.FRONT_INDICATOR_COLOR = self.hud.colors.ENEMY_RED
  self.hud.BLOOD_EFFECT_RECUR_TIME = 1.5
  self.hud.BLOOD_EFFECT_SMALL_DMG_THRESHOLD = 1
  self.hud.BLOOD_EFFECT_MEDIUM_DMG_THRESHOLD = 15
  self.hud.BLOOD_EFFECT_LARGE_DMG_THRESHOLD = 50
  self.hud.BLOOD_EFFECT_SMALL_NAME = "bloodscreen_small_randomizer"
  self.hud.BLOOD_EFFECT_MEDIUM_NAME = "bloodscreen_mid_randomizer"
  self.hud.BLOOD_EFFECT_LARGE_NAME = "bloodscreen_big_randomizer"
  self.hud.BLOOD_EFFECT_KILLING_NAME = "bloodscreen_big_kill"
  self.hud.NO_BLOOD_EFFECT_SMALL_NAME = "dirtscreen_small_randomizer"
  self.hud.NO_BLOOD_EFFECT_MEDIUM_NAME = "dirtscreen_mid_randomizer"
  self.hud.NO_BLOOD_EFFECT_LARGE_NAME = "dirtscreen_big_randomizer"
  self.hud.NO_BLOOD_EFFECT_KILLING_NAME = "dirtscreen_big_kill"
  self.hud.auto_target = {}
  self.hud.auto_target.BRACKET_COLOR = Color(1, 0, 0)
  self.hud.swing_target_color = {}
  self.hud.swing_target_color.out_of_range = Color(1, 0.5, 0.5, 0.5)
  self.hud.swing_target_color.normal = self.hud.colors.WDROP_CYAN
  self.hud.swing_target_color.enemy = self.hud.colors.ENEMY_RED
  self.hud.swing_target_color.interactable = self.hud.colors.WAYPOINT_GREEN
  self.hud.weapon_icon = {}
  self.hud.weapon_icon.CIRCLE_RADIUS = 110
  self.hud.challenge = {}
  self.hud.challenge.APPEAR_TIME = 0.5
  self.hud.challenge.SHOW_TIME = 3.2
  self.hud.challenge.DISAPPEAR_TIME = 0.5
  self.hud.challenge.FADE_IN_TIME = 0.15
  self.hud.challenge.FADE_OUT_TIME = 0.15
  self.hud.ammo = {}
  self.hud.ammo.maingun = {}
  self.hud.ammo.maingun.SPACING = 4
  self.hud.ammo.maingun.BORDER_SPACING = 1
  self.hud.shaker = {}
  self.hud.shaker.def_template = {
    attack = 0,
    sustain = 0,
    decay = 0.4,
    amplitude = {
      x = 0,
      y = 0,
      z = 10
    },
    frequency = 55
  }
  self.hud.shaker.tungsten = {
    attack = 0,
    sustain = 0,
    decay = 0.4,
    amplitude = {
      x = 0,
      y = 0,
      z = 10
    },
    frequency = 55
  }
  self.hud.shaker.tungsten_zoom = {
    attack = 0,
    sustain = 0,
    decay = 0.4,
    amplitude = {
      x = 0,
      y = 0,
      z = 10
    },
    frequency = 55
  }
  self.hud.shaker.yelena = {
    attack = 0,
    sustain = 0,
    decay = 0.4,
    amplitude = {
      x = 0,
      y = 0,
      z = 10
    },
    frequency = 55
  }
  self.hud.shaker.yelena_zoom = {
    attack = 0,
    sustain = 0,
    decay = 0.4,
    amplitude = {
      x = 0,
      y = 0,
      z = 10
    },
    frequency = 55
  }
  self.hud.shaker.mgsj = {
    attack = 0,
    sustain = 0,
    decay = 0.4,
    amplitude = {
      x = 0,
      y = 0,
      z = 10
    },
    frequency = 55
  }
  self.hud.shaker.mgsj_zoom = {
    attack = 0,
    sustain = 0,
    decay = 0.4,
    amplitude = {
      x = 0,
      y = 0,
      z = 10
    },
    frequency = 55
  }
  self.hud.shaker.hiker = {
    attack = 0,
    sustain = 0.2,
    decay = 0.4,
    amplitude = {
      x = 0,
      y = 0,
      z = 12
    },
    frequency = 25
  }
  self.hud.shaker.hiker_zoom = {
    attack = 0,
    sustain = 0.2,
    decay = 0.4,
    amplitude = {
      x = 0,
      y = 0,
      z = 15
    },
    frequency = 25
  }
  self.hud.shaker.rocket_rail = {
    attack = 0,
    sustain = 0,
    decay = 0.4,
    amplitude = {
      x = 0,
      y = 0,
      z = 10
    },
    frequency = 5
  }
  self.hud.shaker.rocket_rail_zoom = {
    attack = 0,
    sustain = 0,
    decay = 0.4,
    amplitude = {
      x = 0,
      y = 0,
      z = 10
    },
    frequency = 5
  }
  self.hud.shaker.uppercut = {
    attack = 0,
    sustain = 0,
    decay = 0.4,
    amplitude = {
      x = 0,
      y = 0,
      z = 10
    },
    frequency = 55
  }
  self.hud.shaker.airpunch = {
    attack = 0,
    sustain = 0,
    decay = 0.4,
    amplitude = {
      x = 0,
      y = 0,
      z = 10
    },
    frequency = 55
  }
  self.hud.shaker.zipkick = {
    attack = 0,
    sustain = 0,
    decay = 0.4,
    amplitude = {
      x = 0,
      y = 0,
      z = 10
    },
    frequency = 55
  }
  self.hud.shaker.evade = {
    attack = 0,
    sustain = 0,
    decay = 0.4,
    amplitude = {
      x = 0,
      y = 0,
      z = 10
    },
    frequency = 55
  }
  self.hud.shaker.side_collision = {
    attack = 0,
    sustain = 0,
    decay = 0.4,
    amplitude = {
      x = 0,
      y = 0,
      z = 10
    },
    frequency = 55
  }
  self.hud.shaker.bullet_damage = {
    attack = 0,
    sustain = 0,
    decay = 0.4,
    amplitude = {
      x = 0,
      y = 0,
      z = 10
    },
    frequency = 55
  }
  self.hud.shaker.explosion_damage = {
    attack = 0,
    sustain = 0,
    decay = 0.4,
    amplitude = {
      x = 0,
      y = 0,
      z = 10
    },
    frequency = 55
  }
  self.hud.shaker.heavy_punch = {
    attack = 0,
    sustain = 0,
    decay = 0.4,
    amplitude = {
      x = 0,
      y = 0,
      z = 10
    },
    frequency = 55
  }
  self.hud.shaker.baton = {
    attack = 0,
    sustain = 0,
    decay = 0.4,
    amplitude = {
      x = 0,
      y = 0,
      z = 10
    },
    frequency = 55
  }
  self.hud.shaker.player_throw_hit = {
    attack = 0,
    sustain = 0,
    decay = 0.5,
    amplitude = {
      x = 0,
      y = 0,
      z = 30
    },
    frequency = 55
  }
  self.hud.shaker.land_light = {
    attack = 0,
    sustain = 0,
    decay = 0.4,
    amplitude = {
      x = 0,
      y = 0,
      z = 10
    },
    frequency = 55
  }
  self.hud.shaker.land_medium = {
    attack = 0,
    sustain = 0,
    decay = 0.4,
    amplitude = {
      x = 0,
      y = 0,
      z = 10
    },
    frequency = 55
  }
  self.hud.shaker.land_heavy = {
    attack = 0,
    sustain = 0,
    decay = 0.4,
    amplitude = {
      x = 0,
      y = 0,
      z = 10
    },
    frequency = 55
  }
  self.hud.shaker.constructor_walk = {
    attack = 0,
    sustain = 0,
    decay = 0.4,
    amplitude = {
      x = 0,
      y = 0,
      z = 10
    },
    frequency = 55
  }
  self.hud.shaker.backdrop_constructor_walk = {
    attack = 0,
    sustain = 0,
    decay = 0.4,
    amplitude = {
      x = 0,
      y = 0,
      z = 5
    },
    frequency = 55
  }
  self.game = {}
  self.game.end_game_timeout = 20
  self.hud.hide_hud = false
  self.hud.default = {}
  self.hud.default.FONT = "gmfont_22"
  self.hud.default.FONT_SCALE = 0.6
  self.hud.DEFAULT_HAT_TEXTURE = "hud_gunslinger_hat_white"
  self.hud.HAT_SIZE = {w = 24, h = 24}
  self.hud.DEFAULT_FACE_TEXTURE = "hud_gunslinger_neutral_face"
  self.hud.FACE_SIZE = {w = 40, h = 40}
  self.hud.SKULL_SIZE = {w = 46, h = 46}
  self.hud.CROSS_SIZE = {w = 64, h = 64}
  self.hud.tint = true
  self.hud.tint_alpha = 0.5
  self.hud.counter = {}
  self.hud.counter.DEFAULT_FADE_IN_TIME = 1
  self.hud.counter.DEFAULT_WIDTH = 64
  self.hud.counter.DEFAULT_HEIGHT = 64
  self.hud.counter.DEFAULT_COUNTER_TEXTURE = "hud_counter_circle_meter"
  self.hud.counter.DEFAULT_COUNTER_STEPS = 90
  self.hud.counter.DEFAULT_FONT = "gmfont_22"
  self.hud.counter.DEFAULT_FONT_SCALE = 0.8
  self.hud.archetype_selection = {}
  self.hud.archetype_selection.DEFAULT_ARCHETYPE = "gunslinger"
  self.hud.archetype_selection.FADE_IN_SPEED = 8
  self.hud.archetype_selection.FADE_OUT_SPEED = 8
  self.hud.archetype_selection.FRAME_SLIDE_SPEED = 6
  self.hud.archetype_selection.FULLBODY_POSITION = {y = 40}
  self.hud.archetype_selection.PORTRAIT_POSITION = {y = 407}
  self.hud.archetype_selection.FRAME_POSITION = {y = 355}
  self.hud.archetype_selection.ARCHETYPE_TEXT_POSITION = {x = 5, y = 45}
  self.hud.archetype_selection.MAIN_WEAPON_TEXTURE_POSITION = {x = 5, y = 195}
  self.hud.archetype_selection.MAIN_WEAPON_TEXT_POSITION = {x = 115, y = 235}
  self.hud.archetype_selection.MAIN_WEAPON_CAPTION_POSITION = {x = 5, y = 170}
  self.hud.archetype_selection.SECONDARY_WEAPON_TEXTURE_POSITION = {x = 5, y = 290}
  self.hud.archetype_selection.SECONDARY_WEAPON_TEXT_POSITION = {x = 115, y = 330}
  self.hud.archetype_selection.SECONDARY_WEAPON_CAPTION_POSITION = {x = 5, y = 265}
  self.hud.archetype_selection.NOT_AVAILABLE_TEXTURE_POSITION = {x = 100, y = 60}
  self.hud.archetype_selection.WEAPON_CAPTION_FONT_SCALE = 0.6
  self.hud.archetype_selection.WEAPON_TEXT_FONT_SCALE = 0.45
  self.hud.archetype_selection.SELECT_ARCHETYPE_TEXT_FONT_SCALE = 0.6
  self.hud.archetype_selection.SELECT_ARCHETYPE_POSITION = {x = 220, y = 460}
  self.hud.archetype_selection.SELECT_ARCHETYPE_NOT_AVAILABLE_ALPHA = 0.3
  self.hud.archetype_selection.FONT = self.hud.default.FONT
  self.hud.archetype_selection.PORTRAIT_FADE_OUT_ALPHA = 0.25
  self.hud.archetype_selection.SCROLL_TIME = 0.1
  self.hud.archetype_selection.STARTUP_TIME = 0.5
  self.hud.archetype_selection.CAPTION_FONT_SCALE = 1.2
  self.hud.archetype_selection.DESCRIPTION_POSITION = {x = 5, y = 90}
  self.hud.archetype_selection.DESCRIPTION_POSITION_1 = {x = 5, y = 365}
  self.hud.archetype_selection.DESCRIPTION_POSITION_2 = {x = 5, y = 385}
  self.hud.archetype_selection.DESCRIPTION_POSITION_3 = {x = 5, y = 405}
  self.hud.archetype_selection.DESCRIPTION_TEXT_FONT_SCALE = 0.5
  self.hud.archetype_selection.DESCRIPTION_LINE_OFFSET = 20
  self.hud.weapon_panel = {}
  self.hud.weapon_panel.DEFAULT_WEAPON_TEXTURE = "hud_revolver_45"
  self.hud.weapon_panel.DEFAULT_TEXTURED_BULLETS = 6
  self.hud.weapon_panel.DEFAULT_TEXTURED_BULLETS_POSITION = {x = 43, y = 0}
  self.hud.weapon_panel.DEFAULT_EMPTY_CLIP_TEXTURE = "reload"
  self.hud.weapon_panel.WEAPON_ALPHA = 0.65
  self.hud.weapon_panel.OUTLINE_ALPHA = 0.65
  if SystemInfo:language() == "japanese" then
    self.hud.weapon_panel.TEXT_BULLETS_POSITION = {x = 410, y = 105}
  else
    self.hud.weapon_panel.TEXT_BULLETS_POSITION = {x = 410, y = 100}
  end
  self.hud.weapon_panel.USE_RELOAD_ANIMATION = false
  self.hud.weapon_panel.WEAPON_RELOAD_ALPHA = 0.5
  self.hud.weapon_panel.WEAPON_RELOAD_COLOR = Color(1, 0.32941177, 0)
  self.hud.weapon_panel.SCALE = 0.85
  self.hud.health_panel = {}
  self.hud.health_panel.DEFAULT_ALIVE_TEXTURES = "hud_health_gunslinger_neutral_alive"
  self.hud.health_panel.DEFAULT_DEAD_TEXTURES = "hud_health_dead"
  self.hud.health_panel.STAMINA_DISTORTION_MAX_VALUE = 255
  self.hud.health_panel.STAMINA_BLACKOUT_MAX_VALUE = 225
  self.hud.health_panel.STAMINA_MAX_VALUE_AT = 0.2
  self.hud.health_panel.HEALTH_ALPHA_INTERPOLATOR = 1.6
  self.hud.health_panel.SHOW_STAMINA_EFFECT = false
  self.hud.health_panel.USE_CROSS = "hud_health_cross_alive"
  self.hud.health_panel.CROSS_TEXTURE = "hud_health_cross_alive"
  self.hud.reticule_panel = {}
  self.hud.reticule_panel.FADE_IN_SPEED = 4
  self.hud.reticule_panel.FADE_OUT_SPEED = 18
  self.hud.reticule_panel.SPREAD_SPEED = 6
  self.hud.reticule_panel.USE_SPREAD_SMOOTHER = false
  self.hud.reticule_panel.ZOOM_TEXTURE_ALPHA = 0.8
  self.hud.reticule_panel.SPREAD_TEXTURE_ALPHA = 0.1
  self.hud.reticule_panel.INSTANT_HIDE_ZOOM_AT = 40
  self.hud.reticule_panel.INSTANT_HIDE_WIDE_AT = 14
  self.hud.reticule_panel.SHOW_OLD_RETICULE = false
  self.hud.reticule_panel.USE_FILLED_CIRCLE_RETICULE = true
  self.hud.reticule_panel.START_SPREAD_FADE_OUT_AT = 750
  self.hud.reticule_panel.END_SPREAD_FADE_OUT_AT = 800
  self.hud.reticule_panel.HIDE_UNIT_AT_RETICULE_ALPHA = 0.8
  self.hud.score_panel = {}
  self.hud.score_panel.FONT = self.hud.default.FONT
  self.hud.score_panel.MY_TEAM_FONT_SCALE = 0.62
  self.hud.score_panel.ENEMY_TEAM_FONT_SCALE = 0.55
  self.hud.score_panel.GOLD_COIN_ANIMATE_FPS = 30
  self.hud.score_panel.SCORE_ANIM_SCALE = 0.8
  self.hud.score_panel.MOVE_XY = 7
  self.hud.score_panel.TEXT_ALPHA = 1
  self.hud.taunt_panel = {}
  self.hud.taunt_panel.FONT = self.hud.default.FONT
  if SystemInfo:language() == "japanese" then
    self.hud.taunt_panel.FONT_SCALE = 0.55
  else
    self.hud.taunt_panel.FONT_SCALE = 0.43
  end
  self.hud.taunt_panel.FONT_SCALE_CRT = 0.65
  self.hud.taunt_panel.DEFAULT_TEXTURE = "hud_kill_icon_death"
  self.hud.taunt_panel.DEFAULT_TEXTURE_OFFSET = 10
  self.hud.taunt_panel.MELEE_TEXTURE = "hud_kill_icon_gf"
  self.hud.taunt_panel.MELEE_TEXTURE_OFFSET = 10
  self.hud.taunt_panel.DISCONNECT_TEXTURE = "hud_kill_icon_dissconnected"
  self.hud.taunt_panel.DISCONNECT_TEXTURE_OFFSET = 10
  self.hud.taunt_panel.TIME_BEFORE_FADEOUT = 4
  self.hud.taunt_panel.FADE_OUT_SPEED = 4
  self.hud.taunt_panel.MOVE_DOWN_SPEED = 4
  self.hud.taunt_panel.SHOW_OLD_TAUNT = false
  self.hud.taunt_panel.ACCOLADE_DELAY_TIME = 1
  self.hud.taunt_panel.USE_TEXT_SHADOW = false
  self.hud.taunt_panel.RIGHT_ALIGNED = true
  self.hud.taunt_panel.LEFT_ALIGNED = false
  self.hud.taunt_panel.TEXT_ALPHA = 0.5
  self.hud.taunt_panel.TEXT_ALPHA_ON_ME = 1
  self.hud.taunt_panel.WEAPON_TEXTURES = {
    mp_western_revolver = "hud_kill_icon_gunslinger",
    mp_western_winchester = "hud_kill_icon_deputy",
    mp_western_admiral_revolver = "hud_kill_icon_sidearm",
    mp_western_dynamite = "hud_kill_icon_explotion",
    mp_western_buffalo_rifle = "hud_kill_icon_sniper",
    mp_western_sawed_off_shotgun = "hud_kill_icon_buckshot",
    wst_gunpowder_keg_carriable = "hud_kill_icon_explotion",
    wpn_knife = "hud_kill_icon_gf"
  }
  self.hud.taunt_panel.WEAPON_TEXTURES_OFFSET = {
    mp_western_revolver = 10,
    mp_western_winchester = 10,
    mp_western_admiral_revolver = 10,
    mp_western_dynamite = 10,
    mp_western_buffalo_rifle = 10,
    mp_western_sawed_off_shotgun = 10,
    wst_gunpowder_keg_carriable = 10,
    wpn_knife = 10
  }
  self.hud.unit_icon_panel = {}
  self.hud.unit_icon_panel.DEFAULT_FONT = "gmfont_22"
  self.hud.unit_icon_panel.DEFAULT_FONT_SCALE = 0.8
  self.hud.unit_icon_panel.textures = {}
  self.hud.unit_icon_panel.textures.revive = "hud_revive_icon"
  self.hud.unit_icon_panel.textures.tag = "hud_call_enemy_icon"
  self.hud.unit_icon_panel.textures.team_tag = "hud_ranger_team_tag_icon"
  self.hud.unit_icon_panel.textures.carriable = "hud_carriable_icon"
  self.hud.unit_icon_panel.textures.tag_carriable = "hud_tag_carriable_icon"
  self.hud.unit_icon_panel.textures.team_tag_carriable = "hud_tag_carriable_icon"
  self.hud.unit_icon_panel.textures.trap = "hud_trap_icon"
  self.hud.unit_icon_panel.textures.closed_trap = "hud_closed_trap_icon"
  self.hud.unit_icon_panel.textures.protect = "hud_protect_icon"
  self.hud.unit_icon_panel.textures.attack = "hud_attack_icon"
  self.hud.unit_icon_panel.textures.target = "hud_target_icon"
  self.hud.unit_icon_panel.textures.pickup = "hud_pickup_icon"
  self.hud.unit_icon_panel.textures.watcher = "hud_ranger_team_tag_icon"
  self.hud.unit_icon_panel.ATTACH_ICON_TO_BODY = "Spine2"
  self.hud.unit_icon_panel.config = {}
  self.hud.unit_icon_panel.config.revive = {
    max_distance = 10000,
    min_scale_factor = 0.5,
    hide_at_max_distance = true,
    show_direction_icon = false
  }
  self.hud.unit_icon_panel.config.tag = {
    max_distance = 10000,
    min_scale_factor = 0.5,
    hide_at_max_distance = false,
    show_direction_icon = false
  }
  self.hud.unit_icon_panel.config.team_tag = {
    max_distance = 10000,
    min_scale_factor = 0.5,
    hide_at_max_distance = true,
    show_direction_icon = true
  }
  self.hud.unit_icon_panel.config.carriable = {
    max_distance = 10000,
    min_scale_factor = 0.5,
    hide_at_max_distance = true,
    show_direction_icon = false
  }
  self.hud.unit_icon_panel.config.tag_carriable = {
    max_distance = 10000,
    min_scale_factor = 0.5,
    hide_at_max_distance = true,
    show_direction_icon = false
  }
  self.hud.unit_icon_panel.config.team_tag_carriable = {
    max_distance = 10000,
    min_scale_factor = 0.5,
    hide_at_max_distance = true,
    show_direction_icon = false
  }
  self.hud.unit_icon_panel.config.trap = {
    max_distance = 10000,
    min_scale_factor = 0.5,
    hide_at_max_distance = true,
    show_direction_icon = true
  }
  self.hud.unit_icon_panel.config.closed_trap = {
    max_distance = 10000,
    min_scale_factor = 0.5,
    hide_at_max_distance = true,
    show_direction_icon = true
  }
  self.hud.unit_icon_panel.config.protect = {
    max_distance = 10000,
    min_scale_factor = 0.3,
    hide_at_max_distance = false,
    show_direction_icon = true,
    pulse = 0.05,
    pulse_frequency = 0.8
  }
  self.hud.unit_icon_panel.config.attack = {
    max_distance = 10000,
    min_scale_factor = 0.5,
    hide_at_max_distance = false,
    show_direction_icon = true,
    pulse = 0.1,
    pulse_frequency = 1.5
  }
  self.hud.unit_icon_panel.config.target = {
    max_distance = 10000,
    min_scale_factor = 0.3,
    hide_at_max_distance = false,
    show_direction_icon = true,
    pulse = 0.15,
    pulse_frequency = 1
  }
  self.hud.unit_icon_panel.config.pickup = {
    max_distance = 10000,
    min_scale_factor = 0.5,
    hide_at_max_distance = false,
    show_direction_icon = true,
    pulse = 0.15,
    pulse_frequency = 1
  }
  self.hud.unit_icon_panel.config.watcher = {
    max_distance = 10000,
    min_scale_factor = 0.5,
    hide_at_max_distance = false,
    show_direction_icon = true,
    blink = 0.9,
    blink_frequency = 6,
    blink_time = 0.8
  }
  self.hud.unit_icon_panel.MIN_SCALE_FACTOR = 0.5
  self.hud.unit_icon_panel.TAG_MANAGER_UPDATE_INTERVAL = 0.5
  self.hud.unit_icon_panel.SHOW_CARRIABLES = {wst_sog_goldsack = true, wst_gunpowder_keg_carriable = true}
  self.hud.unit_icon_panel.UNIT_SCAN_INTERVALL = 0.5
  self.hud.unit_icon_panel.UNIT_SWITCH_DELAY = 0
  self.hud.unit_icon_panel.CARRIABLE_DESPAWN_NOTIFICATION = 5
  self.hud.unit_icon_panel.effect_blink_atom_names = {}
  self.hud.unit_icon_panel.effect_blink_atom_names.hud_pickup_small = {"shield"}
  self.hud.unit_icon_panel.effect_blink_atom_names.hud_protect_small = {
    "shield",
    "shield pulse"
  }
  self.hud.stalker_panel = {}
  self.hud.stalker_panel.fail_text_fade_out_time = 3
  self.hud.stalker_panel.fail_text_fade_out_speed = 3
  self.hud.stalker_panel.seen_indicator_fade_out_speed = 8
  self.hud.stalker_panel.special_attack_indicator_fade_out_speed = 8
  self.hud.name_panel = {}
  self.hud.name_panel.USE_TEAM_COLOR = true
  self.hud.name_panel.FONT_ALPHA = 0.65
  self.hud.name_panel.FONT_ALPHA_SPEAKING = 1
  self.hud.name_panel.FONT_ALPHA_FADE_SPEED = 8
  self.hud.team_health_panel = {}
  self.hud.team_health_panel.FONT = self.hud.default.FONT
  self.hud.team_health_panel.FONT_ALPHA = 0.65
  self.hud.team_health_panel.FONT_ALPHA_SPEAKING = 1
  self.hud.team_health_panel.FONT_ALPHA_FADE_SPEED = 8
  self.hud.team_health_panel.FONT_SCALE = 0.55
  self.hud.team_health_panel.NO_UNIT_ALPHA = 0.5
  self.hud.team_health_panel.ALPHA = 1
  self.hud.team_health_panel.DEAD_TEXTURE = "hud_health_dead_small"
  self.hud.team_health_panel.NO_UNIT_TEXTURE = "hud_health_dead_small"
  self.hud.team_health_panel.CROSS_TEXTURE = "hud_health_cross_alive_small"
  self.hud.context_panel = {}
  self.hud.context_panel.FADE_IN_SPEED = 6
  self.hud.context_panel.FADE_OUT_SPEED = 4
  self.hud.context_panel.FONT = self.hud.default.FONT
  self.hud.context_panel.FONT_SCALE = 0.7
  self.hud.context_panel.BUTTON_FONT_SCALE = 1
  self.hud.context_panel.DEFAULT_MOUNTED_WEAPON_TEXTURE = "hud_gatling_small"
  self.hud.context_panel.BLINK_SPEED = 3
  self.hud.context_panel.LOW_BLINK_ALPHA = 0.1
  self.hud.context_panel.HIGH_BLINK_ALPHA = 1
  self.hud.context_panel.CARRIABLE_MESSAGE_INTERVAL = 0.5
  self.hud.context_panel.CARRIABLE_HUD_TIMEOUT = 0.2
  self.hud.synergy_panel = {}
  self.hud.synergy_panel.scale = 0.6
  self.hud.synergy_panel.value_scale = 0.42
  self.hud.synergy_panel.show_group_effect = false
  self.hud.synergy_panel.config = {}
  self.hud.synergy_panel.config.accuracy = {
    x = 190,
    y = 22,
    texture = "hud_synergy_accuracy"
  }
  self.hud.synergy_panel.config.damage_taken = {
    x = 234,
    y = 22,
    texture = "hud_synergy_damage_red"
  }
  self.hud.synergy_panel.config.damage_dealt = {
    x = 278,
    y = 22,
    texture = "hud_synergy_damage_inc"
  }
  self.hud.synergy_panel.config.crit_chance = {
    x = 322,
    y = 22,
    texture = "hud_synergy_critical"
  }
  self.hud.synergy_panel.ROLL_SPEED = 2
  self.hud.achievement_panel = {}
  self.hud.achievement_panel.FONT = self.hud.default.FONT
  self.hud.achievement_panel.START_FONT_SCALE = 0.7
  self.hud.achievement_panel.HIGH_FONT_SCALE = 1.2
  self.hud.achievement_panel.END_FONT_SCALE = 0.8
  self.hud.achievement_panel.SIZE_IN_SPEED = 10
  self.hud.achievement_panel.SIZE_OUT_SPEED = 1
  self.hud.achievement_panel.TIME_BEFORE_SIZE_OUT = 3
  self.hud.achievement_panel.ALPHA_FADE_IN_SPEED = 5
  self.hud.achievement_panel.ALPHA_FADE_OUT_SPEED = 2
  self.hud.achievement_panel.TIME_BEFORE_FADEOUT = 4
  self.hud.xp_panel = {}
  self.hud.xp_panel.FONT = self.hud.default.FONT
  self.hud.xp_panel.FONT_SCALE = 1
  self.hud.xp_panel.FONT_COLOR = Color.white
  self.hud.xp_panel.TIME_BEFORE_FADEOUT = 1
  self.hud.xp_panel.FADE_IN_SPEED = 6
  self.hud.xp_panel.FADE_OUT_SPEED = 2
  self.hud.xp_panel.MOVE_UP_SPEED = 1.5
  self.hud.xp_panel.PIXELS_TO_MOVE_UP = 100
  self.hud.xp_panel.RANDOM_X_PIXELS = 16
  self.hud.xp_panel.USE_SHADOW_TEXT = true
  self.hud.xp_panel.MIN_TIME_BETWEEN_XP = 0.3
  self.hud.hit_panel = {}
  self.hud.hit_panel.FONT = self.hud.default.FONT
  self.hud.hit_panel.FONT_SCALE = 1
  self.hud.hit_panel.FONT_COLOR = Color.red
  self.hud.hit_panel.TIME_BEFORE_FADEOUT = 1
  self.hud.hit_panel.FADE_IN_SPEED = 6
  self.hud.hit_panel.FADE_OUT_SPEED = 6
  self.hud.hit_panel.MOVE_UP_SPEED = 6
  self.hud.hit_panel.PIXELS_TO_MOVE_UP = 50
  self.hud.hit_panel.RANDOM_X_PIXELS = 32
  self.hud.hit_panel.USE_SHADOW_TEXT = true
  self.hud.scoreboard = {}
  self.hud.scoreboard.FONT = self.hud.default.FONT
  self.hud.scoreboard.FONT_SCALE = 0.5
  self.hud.scoreboard.RED_TEAM = "Team Red"
  self.hud.scoreboard.BLUE_TEAM = "Team Blue"
  local color = Color.white
  color = color:with_alpha(1)
  self.hud.scoreboard.FONT_COLOR = color
  color = Color(0.5, 0.5, 0.5)
  color = color:with_alpha(0.7)
  self.hud.scoreboard.FONT_COLOR_CONNECTION_LOST = color
  self.hud.scoreboard.half_time_wait_duration = 20
  self.hud.scoreboard.full_time_wait_duration = 20
  self.hud.scoreboard.before_end_match_wait_duration = 3
  self.hud.compass_panel = {}
  self.hud.compass_panel.MAX_DISTANCE = 5000
  self.hud.compass_panel.PIXELS_TO_MOVE = 40
  self.hud.compass_panel.scale = 0.65
  self.hud.compass_panel.full_alpha_on_closest_unit = true
  self.hud.mission_objective_panel = {}
  self.hud.mission_objective_panel.FONT = self.hud.default.FONT
  self.hud.mission_objective_panel.FONT_SCALE = 0.8
  self.hud.mission_objective_panel.CAPTION_FONT_SCALE = 0.6
  self.hud.mission_objective_panel.destroy = {}
  self.hud.mission_objective_panel.destroy.WIDTH = 96
  self.hud.mission_objective_panel.destroy.MAX_DISTANCE = 2500
  self.hud.mission_objective_panel.destroy.MAX_DISTANCE_ALPHA = 0.1
  self.hud.mission_objective_panel.bring = {}
  self.hud.mission_objective_panel.bring.WIDTH = 512
  self.hud.mission_objective_panel.bring.SCORE_FONT_SCALE = 1
  self.hud.mission_objective_panel.conquest = {}
  self.hud.mission_objective_panel.conquest.neutral_color = Color(0.57254905, 0.57254905, 0.57254905)
  self.hud.mission_objective_panel.conquest.bar = {}
  self.hud.mission_objective_panel.conquest.bar.WIDTH = 512
  self.hud.mission_objective_panel.conquest.bar.SCORE_FONT_SCALE = 1
  self.hud.message_panel = {}
  self.hud.message_panel.FONT = "gmfont_44"
  if SystemInfo:language() == "japanese" then
    self.hud.message_panel.FONT_SCALE = 0.7
  else
    self.hud.message_panel.FONT_SCALE = 0.5
  end
  self.hud.message_panel.FADE_IN_SPEED = 8
  self.hud.message_panel.FADE_OUT_SPEED = 4
  self.hud.message_panel.TIME_BEFORE_FADEOUT = 3
  self.hud.message_panel.DEFAULT_TIMEOUT = 5
  self.hud.error_message_panel = {}
  self.hud.error_message_panel.FONT = "gmfont_22"
  self.hud.error_message_panel.FONT_SCALE = 0.6
  self.hud.error_message_panel.FADE_IN_SPEED = 8
  self.hud.error_message_panel.FADE_OUT_SPEED = 4
  self.hud.timer_panel = {}
  self.hud.timer_panel.FONT = self.hud.default.FONT
  self.hud.timer_panel.FONT_SCALE = 0.6
  self.hud.timer_panel.FADE_IN_SPEED = 8
  self.hud.timer_panel.FADE_OUT_SPEED = 4
  self.hud.timer_panel.START_BLINKING_AT = 10
  self.hud.timer_panel.SHOW_TIME = math.huge
  self.hud.network_client_panel = {}
  self.hud.network_client_panel.FADE_IN_SPEED = 8
  self.hud.network_client_panel.FADE_OUT_SPEED = 4
  self.hud.evaluation_copy = false
  self.hud.evaluation_copy_panel = {}
  self.hud.evaluation_copy_panel.ALPHA = 0.5
  self.hud.evaluation_copy_panel.COLOR = Color.red
  self.hud.evaluation_copy_panel.FONT = "gmfont_44"
  self.hud.evaluation_copy_panel.FONT_SCALE = 0.6
  self.hud.evaluation_copy_panel.text = "EVALUATION COPY:PEGI"
  self.hud.evaluation_copy_panel.id = {}
  self.hud.evaluation_copy_panel.id[1] = 9
  self.hud.evaluation_copy_panel.id[2] = 8
  self.hud.evaluation_copy_panel.id[3] = 15
  self.hud.evaluation_copy_panel.id[4] = 16
  self.hud.evaluation_copy_panel.id[5] = 23
  self.hud.ingame_menu = {}
  self.hud.ingame_menu.FONT = self.hud.default.FONT
  self.hud.ingame_menu.FONT_SCALE = 0.8
  self.hud.ingame_menu.CLOCK_FONT_SCALE = 0.6
  self.hud.ingame_menu.END_FONT_SCALE = 0.6
  self.hud.ingame_menu.LAYER = 100
  self.hud.ingame_menu.HEIGHT = 580
  self.hud.ingame_menu.SCROLL_TIME_X = 0.1
  self.hud.ingame_menu.SCROLL_TIME_Y = 0.1
  self.hud.ingame_menu.CONTROLLER_SENSITIVITY_X = 0.4
  self.hud.ingame_menu.CONTROLLER_SENSITIVITY_Y = 0.4
  self.hud.ingame_menu.SELECT_ARROW_ACTIVE_ALPHA = 1
  self.hud.ingame_menu.SELECT_ARROW_INACTIVE_ALPHA = 0.25
  self.hud.ingame_menu.map = {}
  self.hud.ingame_menu.map.MARKER_SIZE = 24
  self.hud.ingame_menu.map.ROTATE_SPEED = 2
  self.hud.ingame_menu.map.MARKER_PULSE_FROM = 28
  self.hud.ingame_menu.map.MARKER_PULSE_TO = 36
  self.hud.ingame_menu.map.MARKER_PULSE_SPEED = 4
  self.hud.ingame_menu.map.TAG_TEXTURE = "hud_tag_map_icon"
  self.hud.ingame_menu.map.TIME_BETWEEN_ANIMATION_STARTS = 0.75
  self.hud.ingame_menu.map.FIRST_ANIMATION_DELAY = 0.4
  self.hud.ingame_menu.map.RANDOM_ROTATION = 15
  self.hud.ingame_menu.help = {}
  self.hud.ingame_menu.help.game_modes = {}
  self.hud.ingame_menu.help.game_modes.strawberry_pwk = "lag_manual_text_2_1"
  self.hud.ingame_menu.help.game_modes.sog_vs = "lag_manual_text_2_2"
  self.hud.ingame_menu.help.game_modes.sog = "lag_manual_text_2_3"
  self.hud.ingame_menu.help.game_modes.kth_conquest = "lag_manual_text_2_4"
  self.hud.ingame_menu.help.game_modes.coop = "lag_manual_text_2_5"
  self.hud.ingame_menu.help.game_modes.tdm = "lag_manual_text_2_6"
  self.hud.ingame_menu.help.game_modes.practice = "lag_manual_text_2_7"
  self.hud.ingame_menu.help.game_modes.pwk_vs = "lag_manual_text_2_8"
  self.hud.trapped_panel = {}
  self.hud.trapped_panel.MAX_TIME_IN_TRAP = 8.5
  self.hud.welcome_panel = {}
  self.hud.welcome_panel.always_show = true
  self.hud.hint_panel = {}
  if SystemInfo:language() == "japanese" then
    self.hud.hint_panel.font = "gmfont_22"
    self.hud.hint_panel.font_scale = 0.65
    self.hud.hint_panel.caption_font = "gmfont_22"
    self.hud.hint_panel.caption_font_scale = 0.9
    self.hud.hint_panel.crt_font = "gmfont_22_crt"
  else
    self.hud.hint_panel.font = "gmfont_44"
    self.hud.hint_panel.font_scale = 0.35
    self.hud.hint_panel.caption_font = "gmfont_44"
    self.hud.hint_panel.caption_font_scale = 0.5
    self.hud.hint_panel.crt_font = "gmfont_22_crt"
  end
  self.flare = {}
  self.flare.order = {
    1,
    3,
    3,
    3,
    3,
    4,
    3,
    3,
    2,
    3,
    3
  }
  self.flare.offset = {
    1,
    -0.5,
    -1.7,
    -3.9,
    -4.2,
    -4.7,
    -5.4,
    -7.3,
    -7.6,
    -8.4,
    -9
  }
  self.flare.scale = {
    4,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1
  }
  self.flare.alpha = {
    1,
    0.3,
    0.3,
    0.3,
    0.3,
    0.3,
    0.3,
    0.3,
    0.3,
    0.2,
    0.1
  }
  self.compass = {}
  self.compass.COMPASS_RADIUS = 16000
  self.compass.CM_TO_PIXEL = 0.006666667
  self.compass.WIDTH = 82
  self.compass.HEIGHT = 82
  self.compass.OFFSET_SPEED = 95
  self.compass.POI_FPS = 30
  self.compass.CLOSE_FADE_START = 1000
  self.compass.CLOSE_FADE_END = 300
  self.compass.SONAR_UPDATE = 1.7
  self.compass.SONAR_FADE_TIME = 0.75
  self.compass.FLASH_MAX_ALPHA = 0
  self.compass.FLASH_DECREASE_MOD = 0.57
  self.compass.INDICATOR_FADE_IN = 0.25
  self.compass.INDICATOR_FADE_OUT = 0.25
  self.compass.HELP_TEXT_FADE_IN = 0.25
  self.compass.HELP_TEXT_FADE_OUT = 0.25
  self.compass.HELP_TEXT_FADE_STAY = 1.25
  self.compass.poi_type = {}
  self.compass.poi_type.exit = {}
  self.compass.poi_type.exit.TEXTURE = "gui_compass_icon_waypoint"
  self.compass.poi_type.exit.COLOR = self.hud.colors.WAYPOINT_GREEN
  self.compass.poi_type.exit.FPS = 20
  self.compass.poi_type.exit.FRAMES_X = 4
  self.compass.poi_type.exit.FRAMES_Y = 4
  self.compass.poi_type.exit.KEEP_ON_BRIM = true
  self.compass.poi_type.relay = {}
  self.compass.poi_type.relay.TEXTURE = "gui_compass_icon_relay"
  self.compass.poi_type.relay.COLOR = self.hud.colors.RELAY_ORANGE
  self.compass.poi_type.relay.FPS = 20
  self.compass.poi_type.relay.FRAMES_X = 4
  self.compass.poi_type.relay.FRAMES_Y = 4
  self.compass.poi_type.weapondrop = {}
  self.compass.poi_type.weapondrop.TEXTURE = "gui_compass_icon_weapondrop"
  self.compass.poi_type.weapondrop.COLOR = self.hud.colors.WDROP_CYAN
  self.compass.poi_type.weapondrop.FPS = 20
  self.compass.poi_type.weapondrop.FRAMES_X = 4
  self.compass.poi_type.weapondrop.FRAMES_Y = 4
  self.compass.poi_type.enemy = {}
  self.compass.poi_type.enemy.TEXTURE = "gui_icon_enemy"
  self.compass.poi_type.enemy.COLOR = self.hud.colors.ENEMY_RED
  self.compass.poi_type.enemy.FPS = 20
  self.compass.poi_type.enemy.FRAMES_X = 4
  self.compass.poi_type.enemy.FRAMES_Y = 4
  self.compass.poi_type.enemy.NO_ON_SCREEN_INDICATOR = true
  self.compass.poi_type.smash = {}
  self.compass.poi_type.smash.TEXTURE = "gui_smash_indicator"
  self.compass.poi_type.smash.COLOR = self.hud.colors.WAYPOINT_GREEN
  self.compass.poi_type.smash.FPS = 10
  self.compass.poi_type.smash.FRAMES_X = 4
  self.compass.poi_type.smash.FRAMES_Y = 4
  self.compass.status = {}
  self.compass.status.normal = {}
  self.compass.status.normal.STATIC_IMAGE = false
  self.compass.status.normal.POI_WIDTH = 32
  self.compass.status.normal.POI_HEIGHT = 32
  self.compass.status.display_name = {}
  self.compass.status.display_name.STATIC_IMAGE = false
  self.compass.status.display_name.POI_WIDTH = 32
  self.compass.status.display_name.POI_HEIGHT = 32
  self.compass.status.display_name.HELP_TEXT = true
  self.compass.status.visited = {}
  self.compass.status.visited.COLOR = Color(0.44705883, 0.44705883, 0.44705883)
  self.compass.status.visited.TONE_OUT = true
  self.compass.status.hide = {}
  self.compass.status.hide.HIDE = true
  self.compass.status.hide.HIDE_INDICATOR = true
  self.compass.status.multiplayer_blue = {}
  self.compass.status.multiplayer_blue.TEXTURE = "gui_icon_ctf_flag"
  self.compass.status.multiplayer_blue.POI_WIDTH = 32
  self.compass.status.multiplayer_blue.POI_HEIGHT = 32
  self.compass.status.multiplayer_blue.COLOR = self.hud.colors.MP_TEAM_BLUE
  self.compass.status.multiplayer_red = {}
  self.compass.status.multiplayer_red.TEXTURE = "gui_icon_ctf_flag"
  self.compass.status.multiplayer_red.POI_WIDTH = 32
  self.compass.status.multiplayer_red.POI_HEIGHT = 32
  self.compass.status.multiplayer_red.COLOR = self.hud.colors.MP_TEAM_RED
  self.compass.status.grenade = {}
  self.compass.status.grenade.TEXTURE = "hud_ammo_explosive_grenade"
  self.compass.status.grenade.STATIC_IMAGE = true
  self.compass.status.grenade.HIDE = true
  self.compass.status.grenade.HIDE_INDICATOR = false
  self.compass.status.grenade.POI_WIDTH = 16
  self.compass.status.grenade.POI_HEIGHT = 32
  self.compass.status.grenade.BLINK = true
  self.compass.status.grenade.UNIT_DATA_BLINK_VAR = "_new_tick"
  self.compass.status.grenade.COLOR = self.hud.colors.PLAYER_WHITE
  self.compass.status.grenade.BLINK_COLOR = self.hud.colors.ENEMY_RED
  self.compass.status.boss = {}
  self.compass.status.boss.TEXTURE = "gui_compass_icon_boss"
  self.compass.status.boss.POI_WIDTH = 32
  self.compass.status.boss.POI_HEIGHT = 32
  self.compass.status.boss.COLOR = Color(0.90588236, 0, 0.05882353)
  self.compass.status.boss.ROTATION_SPEED = 180
  self.compass.status.armada = {}
  self.compass.status.armada.TEXTURE = "gui_compass_icon_boss"
  self.compass.status.armada.POI_WIDTH = 32
  self.compass.status.armada.POI_HEIGHT = 32
  self.compass.status.armada.COLOR = Color(0.90588236, 0, 0.05882353)
  self.compass.status.weaponpod_empty = {}
  self.compass.status.weaponpod_empty.TEXTURE = "gui_compass_icon_weapondrop_empty"
  self.backmenu = {}
  self.backmenu.FLIP_TIME = 0.15
  self.overview = {}
  self.overview.MOST_ZOOMED_OUT_SIZE = 12.5
  self.overview.MOST_ZOOMED_IN_SIZE = 1.5
  self.overview.ZOOM_TIME = 2.5
  self.overview.DETAIL_DELAY_TIME = 0.2
  self.overview.PULSE_DIMINISH = 0.5
  self.overview.MAX_RELAY_PULSE_DISTANCE = 15000
  self.overview.RELAY_PULSE_SPEED = 8500
  self.overview.DETAIL_MIN_DELAY_TIME = 1
  self.overview.DETAIL_FADE_IN_TIME = 1
  self.overview.MOVE_TOP_SPEED = 1400
  self.overview.MOVE_ACCELERATION_SPEED = 0.5
  self.overview.MOVE_BREAK_SPEED = 0.4
  self.overview.ZOOM_SPEED = 0.005
  self.overview.ZOOM_STIFFNESS = 0.1
  self.overview.labels = {}
  self.overview.labels[0] = 0
  self.overview.labels[1] = 0.55
  self.overview.labels[2] = 0.85
  self.overview.legend = {}
  self.overview.legend.player = {}
  self.overview.legend.player.SHOW_AT = 0
  self.overview.legend.player.SIZE = 32
  self.overview.legend.player.COLOR = self.hud.colors.PLAYER_WHITE
  self.overview.legend.player.FPS = 17
  self.overview.legend.exit = {}
  self.overview.legend.exit.SHOW_AT = 0
  self.overview.legend.exit.SIZE = 30
  self.overview.legend.exit.COLOR = self.hud.colors.WAYPOINT_GREEN
  self.overview.legend.exit.FPS = 20
  self.overview.legend.relay = {}
  self.overview.legend.relay.SHOW_AT = 0.5
  self.overview.legend.relay.SIZE = 30
  self.overview.legend.relay.COLOR = self.hud.colors.RELAY_ORANGE
  self.overview.legend.relay.FPS = 20
  self.overview.legend.pulse = {}
  self.overview.legend.pulse.SHOW_AT = 0.9
  self.overview.legend.pulse.COLOR = self.hud.colors.RELAY_ORANGE
  self.overview.legend.weapondrop = {}
  self.overview.legend.weapondrop.SHOW_AT = 0.75
  self.overview.legend.weapondrop.SIZE = 30
  self.overview.legend.weapondrop.COLOR = self.hud.colors.WDROP_CYAN
  self.overview.legend.weapondrop.FPS = 20
  self.overview.legend.enemy = {}
  self.overview.legend.enemy.SHOW_AT = 0.9
  self.overview.legend.enemy.SIZE = 20
  self.overview.legend.enemy.COLOR = self.hud.colors.ENEMY_RED
  self.overview.legend.enemy.FPS = 15
  self.overview.legend.enemy.PULSE_FADE_TIME = 1
  self.overview.legend.smash = {}
  self.overview.legend.smash.SHOW_AT = 0
  self.overview.legend.smash.SIZE = 32
  self.overview.legend.smash.COLOR = self.hud.colors.WAYPOINT_GREEN
  self.overview.legend.smash.FPS = 20
  self.radiation = {}
  self.radiation.OUTER_DAMAGE = 1
  self.radiation.OUTER_DAMAGE_INSIDE = 100000
  self.radiation.OUTER_DAMAGE_INTERVAL = 0.2
  self.radiation.OUTER_DAMAGE_INTERVAL_INSIDE = 0
  self.radiation.OUTER_DAMAGE_DISTANCE = 0
  self.radiation.OUTER_INDICATION_DISTANCE = 1000
  self.radiation.OUTER_MAX_INDICATION_DISTANCE = 200
  self.radiation.OUTER_FIELD_CHECK_COUNT = 50
  self.radiation.INNER_DAMAGE = 1
  self.radiation.INNER_DAMAGE_INSIDE = 1
  self.radiation.INNER_DAMAGE_INTERVAL = 0.2
  self.radiation.INNER_DAMAGE_INTERVAL_INSIDE = 0.2
  self.radiation.INNER_DAMAGE_DISTANCE = 0
  self.radiation.INNER_INDICATION_DISTANCE = 700
  self.radiation.INNER_MAX_INDICATION_DISTANCE = 200
  self.radiation.INNER_FIELD_CHECK_COUNT = 2
  self.radiation.MIN_SOUND_INTERVAL = 0
  self.radiation.MAX_SOUND_INTERVAL = 1
  self.enemy = {}
  self.enemy.weapon = {}
  self.enemy.weapon.carbine = {}
  self.enemy.weapon.carbine.FIRE_DELAY = 0.14
  self.enemy.weapon.carbine.CHARGEUP_DELAY = 0.5
  self.enemy.weapon.carbine.CHARGEUP_MAX_DIST = 3000
  self.enemy.weapon.carbine.DAMAGE = 1
  self.enemy.weapon.carbine.SPREAD_STD = {
    normal = 0.7,
    heavy = 0.7,
    sniper = 0.7,
    leader = 0.1,
    rpg = 0.7
  }
  self.enemy.weapon.carbine.CHANCE_TO_HIT_MODIFIER = {
    normal = 0,
    heavy = 0,
    sniper = 0,
    leader = 50,
    rpg = 0
  }
  self.enemy.weapon.carbine.SPREAD_WATERWATCHER = 2
  self.enemy.weapon.grenade = {}
  self.enemy.weapon.grenade.FIRE_DELAY = 4
  self.enemy.weapon.mgsj = {}
  self.enemy.weapon.mgsj.FIRE_DELAY = 0.1
  self.enemy.weapon.mgsj.DAMAGE = 0.5
  self.enemy.weapon.mgsj.HEAT_TO_OVERHEAT = 5
  self.enemy.weapon.mgsj.COOLDOWN_MULTIPLIER = 1
  self.enemy.weapon.mgsj.MAX_SPREAD = 15
  self.enemy.weapon.mgsj.MIN_SPREAD = 1
  self.enemy.weapon.mgsj.DIST_SPREAD_TRESHOLD = 1000
  self.enemy.weapon.mgsj.DIST_SPREAD_MOD = 2
  self.enemy.weapon.mgsj.VEL_SPREAD_MOD = 0.01
  self.enemy.weapon.sniper = {}
  self.enemy.weapon.sniper.DAMAGE = 6
  self.enemy.weapon.sniper.MIN_AIM_TIME = 1
  self.enemy.weapon.sniper.AIM_SPEED_MULTIPLIER = 40
  self.enemy.weapon.sniper.MAX_OSCILLATION = 30
  self.enemy.weapon.sniper.OSCILLATION_SPEED = 0.125
  self.enemy.weapon.sniper.RELOAD_TIME = 0.8
  self.enemy.weapon.sniper.MAX_RAND_RELOAD_TIME = 1.5
  self.enemy.weapon.sniper.MIN_VEL_OFFSET = 1.7
  self.enemy.weapon.sniper.MAX_VEL_OFFSET = 25.5
  self.enemy.weapon.sniper.VEL_OFFSET_MOD = 0.0255
  self.enemy.weapon.sniper.LERP_SPEED = 0.32
  self.enemy.weapon.sniper.RANGE = 20000
  self.sequences = {}
  self.sequences.LIGHT_HEALTH = 2
  self.sequences.MEDIUM_HEALTH = 5
  self.sequences.HEAVY_HEALTH = 10
  self.sequences.LIGHT_DAMAGE_INTERVAL = 1
  self.sequences.MEDIUM_DAMAGE_INTERVAL = 2
  self.sequences.HEAVY_DAMAGE_INTERVAL = 4
  self.sequences.COLLISION_SOUND_T_MAX = 6000
  self.ai = {}
  self.ai.search_graph_util = {}
  self.ai.search_graph_util.GROUND_SLOT_MASK = "standable"
  self.ai.search_graph_util.DEFAULT_COLLISION_SLOT_MASK = "movement_blockers"
  self.ai.search_graph_util.DEFAULT_QUICK_COLLISION_SLOT_MASK = "movement_restricters"
  self.ai.search_graph_util.SHORTCUT_HOLE_CHECK_STEP = 50
  self.ai.search_graph_util.SHORTCUT_HOLE_CHECK_RADIUS_THRESHOLD = 50
  self.ai.search_graph_util.SHORTCUT_MAX_HEIGHT_DIFFERENCE = 170
  self.ai.search_graph_util.SHORTCUT_SLAM_RAY_DEPTH = 40
  self.ai.search_graph_util.DYNAMIC_BLOCKER_MAX_VELOCITY = 10
  self.ai.search_graph_util.DEFAULT_MAX_SEARCH_GRAPH_NODES = 100
  self.ai.search_graph_util.FIND_COVER_MAX_SEARCH_GRAPH_NODES = 10
  self.ai.event = {}
  self.ai.event.player = {}
  self.ai.event.player.LIGHT_DANGER = 1
  self.ai.event.player.MEDIUM_DANGER = 2
  self.ai.event.player.HEAVY_DANGER = 3
  self.ai.event.player.LIGHT_AUDIBLE_RANGE = 1000
  self.ai.event.player.MEDIUM_AUDIBLE_RANGE = 4500
  self.ai.event.player.HEAVY_AUDIBLE_RANGE = 5000
  self.ai.event.player.LIGHT_VISIBLE_RANGE = 1000
  self.ai.event.player.MEDIUM_VISIBLE_RANGE = 4500
  self.ai.event.player.HEAVY_VISIBLE_RANGE = 5000
  self.ai.event.player.LIGHT_AUDIBLE_DURATION = 0.5
  self.ai.event.player.MEDIUM_AUDIBLE_DURATION = 1
  self.ai.event.player.HEAVY_AUDIBLE_DURATION = 1
  self.ai.event.player.LIGHT_VISIBLE_DURATION = 1
  self.ai.event.player.MEDIUM_VISIBLE_DURATION = 1
  self.ai.event.player.HEAVY_VISIBLE_DURATION = 1
  self.ai.event.world = {}
  self.ai.event.world.LIGHT_DANGER = 1
  self.ai.event.world.MEDIUM_DANGER = 2
  self.ai.event.world.HEAVY_DANGER = 3
  self.ai.event.world.LIGHT_AUDIBLE_RANGE = 4000
  self.ai.event.world.MEDIUM_AUDIBLE_RANGE = 4500
  self.ai.event.world.HEAVY_AUDIBLE_RANGE = 5000
  self.ai.event.world.LIGHT_VISIBLE_RANGE = 4000
  self.ai.event.world.MEDIUM_VISIBLE_RANGE = 4500
  self.ai.event.world.HEAVY_VISIBLE_RANGE = 5000
  self.ai.event.world.LIGHT_AUDIBLE_DURATION = 1
  self.ai.event.world.MEDIUM_AUDIBLE_DURATION = 1
  self.ai.event.world.HEAVY_AUDIBLE_DURATION = 1
  self.ai.event.world.LIGHT_VISIBLE_DURATION = 1
  self.ai.event.world.MEDIUM_VISIBLE_DURATION = 1
  self.ai.event.world.HEAVY_VISIBLE_DURATION = 1
  self.ai.event.world.LIGHT_DANGER_RANGE = 300
  self.ai.event.world.MEDIUM_DANGER_RANGE = 500
  self.ai.event.world.HEAVY_DANGER_RANGE = 1000
  self.ai.event.grunt = {}
  self.ai.event.grunt.DIE_DANGER = 3
  self.ai.event.grunt.DIE_DANGER_RANGE = 0
  self.ai.event.grunt.DIE_AUDIBLE_RANGE = 3000
  self.ai.event.grunt.DIE_AUDIBLE_DURATION = 1
  self.ai.event.weapon = {}
  self.ai.event.weapon.maingun = {}
  self.ai.event.weapon.maingun.SHOOT_DANGER = 1
  self.ai.event.weapon.maingun.SHOOT_DANGER_RANGE = 0
  self.ai.event.weapon.maingun.SHOOT_AUDIBLE_RANGE = 4000
  self.ai.event.weapon.maingun.SHOOT_VISIBLE_RANGE = 1000
  self.ai.event.weapon.maingun.SHOOT_AUDIBLE_DURATION = 1
  self.ai.event.weapon.maingun.SHOOT_VISIBLE_DURATION = 1
  self.ai.event.weapon.maingun.SHOOT_AUDIBLE_DELAY = 0.5
  self.ai.event.weapon.maingun.SHOOT_VISIBLE_DELAY = 0.5
  self.ai.event.weapon.maingun.IMPACT_DANGER = 1
  self.ai.event.weapon.maingun.IMPACT_DANGER_RANGE = 0
  self.ai.event.weapon.maingun.IMPACT_AUDIBLE_RANGE = 1000
  self.ai.event.weapon.maingun.IMPACT_VISIBLE_RANGE = 1000
  self.ai.event.weapon.maingun.IMPACT_AUDIBLE_DURATION = 1
  self.ai.event.weapon.maingun.IMPACT_VISIBLE_DURATION = 1
  self.ai.event.weapon.maingun.IMPACT_AUDIBLE_DELAY = 0.5
  self.ai.event.weapon.maingun.IMPACT_VISIBLE_DELAY = 0.5
  self.ai.event.weapon.maingun.SLOWSHOT_DANGER = 1
  self.ai.event.weapon.maingun.SLOWSHOT_DANGER_RANGE = 0
  self.ai.event.weapon.maingun.SLOWSHOT_AUDIBLE_RANGE = 4000
  self.ai.event.weapon.maingun.SLOWSHOT_VISIBLE_RANGE = 1000
  self.ai.event.weapon.maingun.SLOWSHOT_AUDIBLE_DELAY = 0.5
  self.ai.event.weapon.maingun.SLOWSHOT_VISIBLE_DELAY = 0.5
  self.ai.event.weapon.mgsj = {}
  self.ai.event.weapon.mgsj.SHOOT_DANGER = 3
  self.ai.event.weapon.mgsj.SHOOT_DANGER_RANGE = 0
  self.ai.event.weapon.mgsj.SHOOT_AUDIBLE_RANGE = 4000
  self.ai.event.weapon.mgsj.SHOOT_VISIBLE_RANGE = 1000
  self.ai.event.weapon.mgsj.SHOOT_AUDIBLE_DURATION = 1
  self.ai.event.weapon.mgsj.SHOOT_VISIBLE_DURATION = 1
  self.ai.event.weapon.mgsj.SHOOT_AUDIBLE_DELAY = 0.5
  self.ai.event.weapon.mgsj.SHOOT_VISIBLE_DELAY = 0.5
  self.ai.event.weapon.mgsj.IMPACT_DANGER = 3
  self.ai.event.weapon.mgsj.IMPACT_DANGER_RANGE = 0
  self.ai.event.weapon.mgsj.IMPACT_AUDIBLE_RANGE = 1000
  self.ai.event.weapon.mgsj.IMPACT_VISIBLE_RANGE = 1000
  self.ai.event.weapon.mgsj.IMPACT_AUDIBLE_DURATION = 1
  self.ai.event.weapon.mgsj.IMPACT_VISIBLE_DURATION = 1
  self.ai.event.weapon.mgsj.IMPACT_AUDIBLE_DELAY = 0.5
  self.ai.event.weapon.mgsj.IMPACT_VISIBLE_DELAY = 0.5
  self.ai.event.weapon.mgsj.SLOWSHOT_DANGER = 3
  self.ai.event.weapon.mgsj.SLOWSHOT_DANGER_RANGE = 0
  self.ai.event.weapon.mgsj.SLOWSHOT_AUDIBLE_RANGE = 4000
  self.ai.event.weapon.mgsj.SLOWSHOT_VISIBLE_RANGE = 1000
  self.ai.event.weapon.mgsj.SLOWSHOT_AUDIBLE_DELAY = 0.5
  self.ai.event.weapon.mgsj.SLOWSHOT_VISIBLE_DELAY = 0.5
  self.psn = {}
  self.psn.signature = "1337"
  self.menu = {}
  self.menu.CRT_ALPHA = 0.8
  self.menu.GAMMA_CHANGE_STEP = 0.05
  self.menu.MIN_GAMMA = 0
  self.menu.MAX_GAMMA = 2
  self.menu.NODE_COLOR = Color(255, 0, 82, 92) / 255
  self.menu.MAX_CLANTAG = 5
  self.menu.SPIN_BACK_GUN = true
  self.menu.USE_BLACK_EDGES = false
  self.menu.MIN_TIME_LEFT_FOR_JOINING_SERVERS = -1
  self.menu.MIN_TIME_SERVER = 60
  self.menu.default = {}
  self.menu.default.FONT = "gmfont_22"
  self.menu.default.FONT_SCALE = 0.6
  self.menu.default.FONT_SCALE_CRT = 0.8
  self.menu.default.CAPTION_FONT = "gmfont_header"
  if SystemInfo:language() == "japanese" then
    self.menu.default.CAPTION_FONT_SCALE = 1.6
  else
    self.menu.default.CAPTION_FONT_SCALE = 0.6
  end
  self.menu.default.CAPTION_FONT_SCALE_CRT = 0.8
  if SystemInfo:language() == "japanese" then
    self.menu.default.CAPTION_SMALL_FONT_SCALE = 0.75
  else
    self.menu.default.CAPTION_SMALL_FONT_SCALE = 0.25
  end
  self.menu.default.CAPTION_SMALL_FONT_SCALE_CRT = 0.3
  self.menu.default.MOUSE_OVER_FONT_SCALE = 0.7
  self.menu.default.RED = Color.red:with_alpha(0.6)
  self.menu.default.CAPTION_RED = Color.red:with_alpha(0.6)
  self.menu.default.TEAM_RED = Color.red:with_alpha(0.3)
  self.menu.default.TEAM_BLUE = self.hud.colors.MP_TEAM_BLUE_TINT:with_alpha(0.5)
  self.menu.default.UNSELECTED_ALPHA = 0.4
  self.menu.default.DISABLED_ALPHA = 0.2
  self.menu.default.UNSELECTED_ALPHA_FULL_SERVER = 0.15
  self.menu.default.SWITCH_LIST_ROW_HEIGHT = 18
  self.menu.default.BTN_FONT_SCALE_MULTIPLIER_CRT = 1.3
  self.menu.default.MENU_LIST_FONT_SCALE = 0.7
  self.menu.btn_info = {}
  self.menu.btn_info.FONT = self.menu.default.FONT
  self.menu.btn_info.COLOR = Color.white
  self.menu.btn_info.SCALE = self.menu.default.FONT_SCALE
  self.menu.settings = {}
  self.menu.settings.crt_limit = 720
  self.menu.settings.panel_height = 620
  self.menu.settings.caption_x = 20
  self.menu.settings.caption_y = 105
  self.menu.settings.caption_width = 160
  self.menu.settings.buttons_y = 350
  self.menu.settings.text_left_padding = 40
  self.menu.settings.text_left_padding_no_arrows = 20
  self.menu.settings.text_field_height = 32
  self.menu.settings.picture_x = 450
  self.menu.settings.picture_y = 105
  self.menu.settings.team_list_x = 450
  self.menu.settings.team_list_y = 340
  self.menu.settings.list_padding = 15
  self.menu.settings.halves = 1
  self.menu.settings.page_active_delay = 0.3
  self.menu.settings.page_active_delay = 0.3
  self.menu.settings.hide_full_servers = false
  self.menu.settings.max_servers_steam = 25
  self.menu.settings.max_servers_steam_presented = 5000
  self.menu.settings.auto_refresh_players_online = 10
  self.menu.settings.ping_update_interval = 0.5
  self.menu.settings.ping_numbers = 6
  self.menu.settings.ping_samples = 4
  self.menu.settings.hide_server_rankings = true
  self.menu.cancel_timeout = {}
  self.menu.cancel_timeout.steam = 30
  self.menu.cancel_timeout.psn = 30
  self.menu.cancel_timeout.xbox = 30
  self.menu.option_box = {}
  self.menu.option_box.INACTIVE_ALPHA = 0.5
  self.menu.option_box.ACTIVE_ALPHA = 1
  self.menu.quick_match = {}
  self.menu.quick_match.start_on_create_server = true
  self.menu.loading_screen = {}
  self.menu.loading_screen.hints = {}
  self.menu.loading_screen.hints.ghostface_killer = {
    texture = "menu_hint_using_keg",
    text_id = "loadscreen_hint_ghostface_killer"
  }
  self.menu.loading_screen.hints.flashlight = {
    texture = "menu_hint_using_keg",
    text_id = "loadscreen_hint_flashlight"
  }
  self.menu.loading_screen.hints.cutthroat = {
    texture = "menu_hint_using_keg",
    text_id = "loadscreen_hint_cutthroat"
  }
  self.menu.loading_screen.hints.cloaking = {
    texture = "menu_hint_using_keg",
    text_id = "loadscreen_hint_cloaking"
  }
  self.menu.loading_screen.hints.LOS = {
    texture = "menu_hint_using_keg",
    text_id = "loadscreen_hint_LOS"
  }
  self.menu.loading_screen.hints.staytogether = {
    texture = "menu_hint_using_keg",
    text_id = "loadscreen_hint_staytogether"
  }
  self.menu.loading_screen.hints.sneak = {
    texture = "menu_hint_using_keg",
    text_id = "loadscreen_hint_sneak"
  }
  self.menu.loading_screen.hints.BBB = {
    texture = "menu_hint_using_keg",
    text_id = "loadscreen_hint_BBB"
  }
  self.menu.loading_screen.hints.basement = {
    texture = "menu_hint_using_keg",
    text_id = "loadscreen_hint_basement"
  }
  self.menu.loading_screen.hints.dare = {
    texture = "menu_hint_using_keg",
    text_id = "loadscreen_hint_dare"
  }
  self.menu.loading_screen.hints.rightback = {
    texture = "menu_hint_using_keg",
    text_id = "loadscreen_hint_rightback"
  }
  self.menu.loading_screen.hints.suspect = {
    texture = "menu_hint_using_keg",
    text_id = "loadscreen_hint_suspect"
  }
  self.menu.loading_screen.hints.notover = {
    texture = "menu_hint_using_keg",
    text_id = "loadscreen_hint_notover"
  }
  self.menu.loading_screen.hints.virgin = {
    texture = "menu_hint_using_keg",
    text_id = "loadscreen_hint_virgin"
  }
  self.menu.loading_screen.hints.using_keg = {
    texture = "menu_hint_using_keg",
    text_id = "loadscreen_hint_using_keg_id"
  }
  self.menu.loading_screen.hints.trapper = {
    texture = "menu_hint_trapper",
    text_id = "loadscreen_hint_trapper_id"
  }
  self.menu.loading_screen.hints.sacked_dropped_time = {
    texture = "menu_hint_sack_dropped_time",
    text_id = "loadscreen_hint_sack_dropped_time_id"
  }
  self.menu.loading_screen.hints.sack_deliver = {
    texture = "menu_hint_sack_deliver",
    text_id = "loadscreen_hint_sack_deliver_id"
  }
  self.menu.loading_screen.hints.sack_defend = {
    texture = "menu_hint_sack_defend",
    text_id = "loadscreen_hint_sack_defend_id"
  }
  self.menu.loading_screen.hints.sack_attack = {
    texture = "menu_hint_sack_attack",
    text_id = "loadscreen_hint_sack_attack_id"
  }
  self.menu.loading_screen.hints.respawn_flag_return = {
    texture = "menu_hint_respawn_flag_return",
    text_id = "loadscreen_hint_respawn_flag_return_id"
  }
  self.menu.loading_screen.hints.pick_archetype = {
    texture = "menu_hint_pick_archetype",
    text_id = "loadscreen_hint_pick_archetype_id"
  }
  self.menu.loading_screen.hints.gunslinger = {
    texture = "menu_hint_gunslinger",
    text_id = "loadscreen_hint_gunslinger_id"
  }
  self.menu.loading_screen.hints.deputy = {
    texture = "menu_hint_deputy",
    text_id = "loadscreen_hint_deputy_id"
  }
  self.menu.loading_screen.hints.control_zone = {
    texture = "menu_hint_control_zone",
    text_id = "loadscreen_hint_control_zone_id"
  }
  self.menu.loading_screen.hints.blowing_up_shiny = {
    texture = "menu_hint_blowing_up_shiny",
    text_id = "loadscreen_hint_blowing_up_shiny_id"
  }
  self.menu.loading_screen.hints.blowing_up_objects = {
    texture = "menu_hint_blowing_up_objects",
    text_id = "loadscreen_hint_blowing_up_objects_id"
  }
  self.menu.loading_screen.hints.blaster = {
    texture = "menu_hint_blaster",
    text_id = "loadscreen_hint_blaster_id"
  }
  self.menu.intro = {}
  self.menu.intro.PLAY_BINK = false
  self.menu.invitation = {}
  self.menu.invitation.ps3 = {}
  self.menu.invitation.ps3.EXP_MIN = 5
  self.menu.chat = {}
  self.menu.chat.max_chars = 150
  self.menu.chat.max_chat_items = 20
  self.menu.chat.delay_until_full_hide = 10
  self.menu.chat.delay_until_msg_fade_out = 3
  self.menu.version = {}
  self.menu.version.url = "91.123.194.213"
  self.menu.version.page = "/version_1_7_2.txt"
  self.menu.version.host = "www.fatshark.se"
  self.menu.version.always_show = false
  self.menu.version.client = "0.1"
  self.menu.version.server = "1.7"
  self.web_config = {}
  self.web_config.url = "91.123.194.213"
  self.web_config.page = "/webconfig.txt"
  self.web_config.host = "www.fatshark.se"
  self.web_config.enable_ping = true
  self.web_config.enabled = false
  self.dedicated_server = {}
  self.dedicated_server.max_failed_login_attempts = 3
  self.dedicated_server.allow_console_in_server_browser = true
  self.dedicated_server.alternate_lan_serverlist_refresh = false
  self.dedicated_server.cap_framerate = 60
  self.dedicated_server.speed_check_threshold = 825
  self.stats_steam = {}
  self.stats_steam.punish_leave_time = 120
  self.network = {}
  self.network.wait_for_level_and_gamemode_timeout = 10
  self.network.steam = {}
  self.network.steam.start_gameserver = false
  self.network.steam.gameserver_auth_from_connection_details = false
  self.network.steam.gamedir = "leadandgoldinternalbeta"
  self.network.steam.server = {}
  self.network.steam.server.port_authentication = 8766
  self.network.steam.server.port_server = 27015
  self.network.steam.server.port_spectator = 0
  self.network.steam.server.port_master_server_update = 27016
  self.network.steam.server.server_mode = 2
  self.network.steam.server.game_dir = self.network.steam.gamedir
  self.network.steam.server.server_version = "1.0.0.0"
  self.version = {}
  self.version[1] = "EXE VERSION: " .. Application:version()
  self.version[2] = Application:revision() ~= "" and " SVN REVISION: " .. Application:revision() or ""
  self.level = {}
  self.level.dont_play_music = false
  self.gamemode = {}
  self.gamemode.max_human_players = 10
  self.ps3_region_id = 2
end
function TweakData:add_reload_callback(func)
  TweakData.last_reload_callback_id = TweakData.last_reload_callback_id + 1
  TweakData.reload_callback_map[TweakData.last_reload_callback_id] = func
  return TweakData.last_reload_callback_id
end
function TweakData:remove_reload_callback(id)
  TweakData.reload_callback_map[id] = nil
end
function TweakData:reloaded()
  for _, func in pairs(TweakData.reload_callback_map) do
    func()
  end
end
if not tweak_data or tweak_data.RELOAD then
  tweak_data = TweakData:new()
end
