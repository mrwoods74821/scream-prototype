require("core/CorePatches")
require("core/CoreModule")
reloading = reloading or false
if not reloading then
  core:replace_core_module("managers/CoreLocalizationManager")
end
core:replace_core_module("managers/subtitle/CoreSubtitlePresenter")
require("core/setups/CoreSetup")
Global.demo = Database:has("special", "demo")
base_require("TweakData", nil, "RELEASE")
base_require("configs/MaterialConfig", nil, "RELEASE")
base_require("configs/UnitSizeConfig", nil, "RELEASE")
base_require("units/UnitDamage", nil, "RELEASE")
base_require("units/UnitEffects", nil, "RELEASE")
base_require("units/props/ThrowUnitDamage", nil, "RELEASE")
base_require("units/props/ThrowableUnitDamage", nil, "RELEASE")
base_require("units/props/RayEffectUnitDamage", nil, "RELEASE")
base_require("units/UnitCallbackHandler", nil, "RELEASE")
base_require("units/DynamicAIGraph", nil, "RELEASE")
base_require("Base", nil, "RELEASE")
base_require("managers/ControllerWrapper", nil, "RELEASE")
base_require("managers/ControllerWrapperGamepad", nil, "RELEASE")
base_require("managers/ControllerWrapperPC", nil, "RELEASE")
base_require("managers/ControllerWrapperXbox360", nil, "RELEASE")
base_require("units/beings/Puppet", nil, "RELEASE")
base_require("units/mp/players/MPAnimGlobal", nil, "RELEASE")
base_require("units/beings/player/Camera", nil, "RELEASE")
base_require("units/mp/players/MPObserver", nil, "RELEASE")
base_require("units/beings/player/ObserverCamera", nil, "RELEASE")
base_require("units/beings/actor/Actor", nil, "RELEASE")
base_require("units/beings/player/PlayerBase", nil, "RELEASE")
base_require("units/beings/player/Player", nil, "RELEASE")
base_require("units/beings/player/PlayerDamage", nil, "RELEASE")
base_require("units/beings/player/PlayerInventory", nil, "RELEASE")
base_require("units/beings/player/PlayerCutscene", nil, "RELEASE")
base_require("units/beings/player/Aim", nil, "RELEASE")
base_require("units/beings/player/gui/PlayerHud", nil, "RELEASE")
base_require("units/beings/player/gui/ObserverHud", nil, "RELEASE")
base_require("units/beings/player/IkPlayer", nil, "RELEASE")
base_require("units/beings/player/OccationalSounds", nil, "RELEASE")
base_require("units/beings/player/PlayerVoice", nil, "RELEASE")
base_require("units/beings/player/synergy/PlayerSynergy", nil, "RELEASE")
base_require("units/beings/player/synergy/PlayerSynergyHusk", nil, "RELEASE")
base_require("units/beings/player/CutsceneBase", nil, "RELEASE")
base_require("units/beings/player/Face", nil, "RELEASE")
base_require("units/cutscene/CutsceneSniperTarget", nil, "RELEASE")
base_require("units/beings/player/gui/PlayerTeammateOutline", nil, "RELEASE")
base_require("units/beings/player/stalker_checker/StalkerChecker", nil, "RELEASE")
base_require("units/usableext/UsableExt", nil, "RELEASE")
base_require("units/weapons/BaseWeapon", nil, "RELEASE")
base_require("units/weapons/PlayerBaseWeapon", nil, "RELEASE")
base_require("units/props/RelayBase", nil, "RELEASE")
base_require("units/props/Water", nil, "RELEASE")
base_require("units/AIGraphSplitter", nil, "RELEASE")
base_require("units/data/AiData", nil, "RELEASE")
base_require("units/data/EnemyData", nil, "RELEASE")
base_require("units/data/ScriptUnitData", nil, "RELEASE")
base_require("units/data/StairUnitData", nil, "RELEASE")
base_require("units/data/BridgeUnitData", nil, "RELEASE")
base_require("units/data/DamageData", nil, "RELEASE")
base_require("units/data/PlayerData", nil, "RELEASE")
base_require("units/data/WeaponData", nil, "RELEASE")
base_require("units/data/GrappleData", nil, "RELEASE")
base_require("units/data/AiGraphData", nil, "RELEASE")
base_require("units/data/MapData", nil, "RELEASE")
base_require("units/data/CompassData", nil, "RELEASE")
base_require("units/effects/Streaks", nil, "RELEASE")
base_require("network/NetworkAux", nil, "RELEASE")
base_require("managers/AreaManager", nil, "RELEASE")
base_require("managers/camera/CameraManager", nil, "RELEASE")
base_require("managers/EnvironmentManager", nil, "RELEASE")
base_require("managers/ViewportManager", nil, "RELEASE")
base_require("managers/SequenceManager", nil, "RELEASE")
base_require("managers/StaticGeometryManager", nil, "RELEASE")
base_require("managers/SlotManager", nil, "RELEASE")
base_require("managers/WorldManager", nil, "RELEASE")
base_require("managers/AIEventManager", nil, "RELEASE")
base_require("managers/AIGraphManager", nil, "RELEASE")
base_require("managers/PlatformManager", nil, "RELEASE")
base_require("managers/TransitionManager", nil, "RELEASE")
base_require("managers/MainMenuManager", nil, "RELEASE")
base_require("managers/MenuPageManager", nil, "RELEASE")
base_require("managers/DialogManager", nil, "RELEASE")
base_require("managers/MenuMouseManager", nil, "RELEASE")
base_require("managers/PlayerManager", nil, "RELEASE")
base_require("managers/CutsceneManager", nil, "RELEASE")
base_require("managers/GameplayManager", nil, "RELEASE")
base_require("managers/ActorManager", nil, "RELEASE")
base_require("managers/EnvironmentEffectsManager", nil, "RELEASE")
base_require("managers/RadiationManager", nil, "RELEASE")
base_require("managers/SaveManager", nil, "RELEASE")
base_require("managers/NetworkManager", nil, "RELEASE")
base_require("managers/ZonesManager", nil, "RELEASE")
base_require("managers/WorldCameraManager", nil, "RELEASE")
base_require("managers/UniqueItemManager", nil, "RELEASE")
base_require("managers/UnlockManager", nil, "RELEASE")
base_require("managers/BenchmarkManager", nil, "RELEASE")
base_require("managers/RumbleManager", nil, "RELEASE")
base_require("managers/AchievementManager", nil, "RELEASE")
base_require("managers/CompassManager", nil, "RELEASE")
base_require("managers/WaterManager", nil, "RELEASE")
base_require("managers/WeaponDropManager", nil, "RELEASE")
base_require("managers/BackMenuManager", nil, "RELEASE")
base_require("managers/RewardManager", nil, "RELEASE")
base_require("managers/OverlayEffectManager", nil, "RELEASE")
base_require("managers/SoundEnvironmentManager", nil, "RELEASE")
base_require("managers/WorldRotationManager", nil, "RELEASE")
base_require("managers/DOFManager", nil, "RELEASE")
base_require("managers/FeedBackManager", nil, "RELEASE")
base_require("managers/IngameVideoManager", nil, "RELEASE")
base_require("managers/VolumeManager", nil, "RELEASE")
base_require("managers/ControllerInfoGuiManager", nil, "RELEASE")
base_require("managers/PlayerMemoryManager", nil, "RELEASE")
base_require("managers/RelayManager", nil, "RELEASE")
base_require("managers/LocInfoManager", nil, "RELEASE")
base_require("managers/DebugManager", nil, "DEBUG")
base_require("managers/GameCentralManager", nil, "RELEASE")
base_require("managers/DemoManager", nil, "RELEASE")
base_require("shared/action_event/ActionEventManager", nil, "RELEASE")
base_require("managers/StatisticsManager", nil, "RELEASE")
base_require("managers/HudMarkerListManager", nil, "RELEASE")
base_require("managers/PlayerHudManager", nil, "RELEASE")
base_require("managers/PlayerSwitchableHudManager", nil, "RELEASE")
base_require("managers/SteamManager", nil, "RELEASE")
base_require("managers/PSNManager", nil, "RELEASE")
base_require("managers/ServerRankingManager", nil, "RELEASE")
base_require("managers/WebConfigManager", nil, "RELEASE")
base_require("utils/dev/FreeFlight", nil, "RELEASE")
base_require("utils/dev/DebugInfo", nil, "RELEASE")
base_require("utils/dev/editor/WorldDefinition", nil, "RELEASE")
base_require("utils/dev/tools/WorldEditor", nil, "DEBUG")
base_require("utils/dev/tools/EnvEditor", nil, "DEBUG")
base_require("utils/dev/ActorEditor", nil, "DEBUG")
base_require("utils/dev/StopTimer", nil, "DEBUG")
base_require("utils/dev/TestFactory", nil, "RELEASE")
base_require("viewers/UnitViewer", nil, "DEBUG")
base_require("viewers/AnimViewer", nil, "DEBUG")
base_require("viewers/UnitTweaker", nil, "DEBUG")
base_require("viewers/MindProbe", nil, "DEBUG")
base_require("viewers/PickupEditor", nil, "DEBUG")
base_require("viewers/AnimationInspector", nil, "DEBUG")
base_require("units/data/ElementData", nil, "RELEASE")
base_require("network/elements/ElementForcefield", nil, "RELEASE")
base_require("network/elements/ElementFlag", nil, "RELEASE")
base_require("network/elements/ElementRespawn", nil, "RELEASE")
base_require("network/elements/Carriable", nil, "RELEASE")
base_require("network/elements/ObjectiveUnit", nil, "RELEASE")
base_require("units/mp/data/MPMovingUnit", nil, "RELEASE")
base_require("units/mp/pickups/MPFlag", nil, "RELEASE")
base_require("units/mp/weapons/MPWesternWeapon", nil, "RELEASE")
base_require("units/mp/weapons/MPWesternShotgun", nil, "RELEASE")
base_require("units/mp/weapons/MPWesternSingleAction", nil, "RELEASE")
base_require("units/mp/weapons/MPWesternSniperRifle", nil, "RELEASE")
base_require("units/mp/weapons/MPWesternMountedGatling", nil, "RELEASE")
base_require("units/mp/weapons/MPMelee", nil, "RELEASE")
base_require("units/mp/weapons/MPFlashLight", nil, "RELEASE")
base_require("units/mp/weapons/MPDynamiteUnit", nil, "RELEASE")
base_require("units/mp/weapons/MPDynamiteUnitHusk", nil, "RELEASE")
base_require("units/mp/weapons/MPBearTrapUnit", nil, "RELEASE")
base_require("units/mp/NetworkLocalUnitDamage", nil, "RELEASE")
base_require("units/mp/NetworkHuskUnitDamage", nil, "RELEASE")
base_require("units/mp/objective_visualizer/ObjectiveVisualizer", nil, "RELEASE")
base_require("units/mp/players/states/MPPlayerOnGround", nil, "RELEASE")
base_require("units/mp/players/states/MPPlayerKnockedOut", nil, "RELEASE")
base_require("units/mp/players/states/MPPlayerInAirAnimMove", nil, "RELEASE")
base_require("units/mp/players/MPFreeFlight", nil, "RELEASE")
base_require("units/mp/players/MPPlayerHusk", nil, "RELEASE")
base_require("units/mp/players/MPPlayerInventory", nil, "RELEASE")
base_require("units/mp/players/MPPlayerInventoryHusk", nil, "RELEASE")
base_require("units/mp/players/MPPlayerDamage", nil, "RELEASE")
base_require("units/mp/players/MPPlayerDamageHusk", nil, "RELEASE")
base_require("units/mp/NetworkUnitDamage", nil, "RELEASE")
base_require("units/mp/ObjectiveUnitDamage", nil, "RELEASE")
base_require("units/mp/players/MPDummy", nil, "RELEASE")
base_require("units/mp/NetworkAreaDamage", nil, "RELEASE")
base_require("units/mp/npc/MPNpc", nil, "RELEASE")
base_require("units/mp/npc/damage/MPNpcDamage", nil, "RELEASE")
base_require("units/props/MatrixDoorDamage", nil, "RELEASE")
base_require("shared/external/Debug", nil, "RELEASE")
base_require("shared/external/Table", nil, "RELEASE")
base_require("shared/external/Iterators", nil, "RELEASE")
base_require("shared/external/AnimationTools", nil, "RELEASE")
base_require("shared/external/ClassAux", nil, "RELEASE")
base_require("shared/external/LinkedList", nil, "RELEASE")
base_require("shared/external/Stack", nil, "RELEASE")
base_require("shared/external/Queue", nil, "RELEASE")
base_require("shared/SharedMath", nil, "RELEASE")
base_require("ai/common/NavigationGraphUtilities", nil, "RELEASE")
base_require("ai/common/MovementUtilities", nil, "RELEASE")
base_require("ai/behavior_tree/BehaviorTree", nil, "RELEASE")
base_require("ai/behavior_tree/BTBrain", nil, "RELEASE")
base_require("ai/behavior_tree/BTNode", nil, "RELEASE")
base_require("ai/behavior_tree/BTConditions", nil, "RELEASE")
base_require("ai/behavior_tree/BTSelector", nil, "RELEASE")
base_require("ai/beings/BTBrainData", nil, "RELEASE")
base_require("ai/behavior_tree/BrainManager", nil, "RELEASE")
base_require("managers/BotManager", nil, "RELEASE")
base_require("statistics/DataCollection", nil, "RELEASE")
base_require("statistics/DataChannel", nil, "RELEASE")
base_require("statistics/DataObserver", nil, "RELEASE")
base_require("statistics/StatisticsHelper", nil, "RELEASE")
base_require("statistics/ExperienceSystem", nil, "RELEASE")
base_require("statistics/Punisher", nil, "RELEASE")
base_require("statistics/IdleKick", nil, "RELEASE")
base_require("statistics/rewards/Reward", nil, "RELEASE")
base_require("statistics/rewards/UnlockableReward", nil, "RELEASE")
base_require("statistics/rewards/KillStreak", nil, "RELEASE")
base_require("statistics/rewards/MultiKill", nil, "RELEASE")
base_require("statistics/rewards/Avarice", nil, "RELEASE")
base_require("statistics/rewards/FirstBlood", nil, "RELEASE")
base_require("statistics/rewards/BeginnersLuck", nil, "RELEASE")
base_require("statistics/rewards/ADocOnHoliday", nil, "RELEASE")
base_require("statistics/rewards/LewisAndClark", nil, "RELEASE")
base_require("statistics/rewards/Goodfellow", nil, "RELEASE")
base_require("statistics/rewards/ForceMultiplier", nil, "RELEASE")
base_require("statistics/rewards/PackMule", nil, "RELEASE")
base_require("statistics/rewards/FishInABarrel", nil, "RELEASE")
base_require("statistics/rewards/Barrage", nil, "RELEASE")
base_require("statistics/rewards/OneStepAhead", nil, "RELEASE")
base_require("statistics/rewards/NaturalBornLeader", nil, "RELEASE")
base_require("statistics/rewards/ToTheVictorBelongTheSpoils", nil, "RELEASE")
base_require("statistics/rewards/RisingScourgeOfTheWest", nil, "RELEASE")
base_require("statistics/rewards/ScourgeOfTheWest", nil, "RELEASE")
base_require("statistics/rewards/UltimateScourgeOfTheWest", nil, "RELEASE")
base_require("statistics/rewards/HatTrick", nil, "RELEASE")
base_require("statistics/rewards/HatsOffToYouSir", nil, "RELEASE")
base_require("statistics/rewards/TheyWereAllHatNoCattle", nil, "RELEASE")
base_require("statistics/rewards/AceHigh", nil, "RELEASE")
base_require("statistics/rewards/Quigley", nil, "RELEASE")
base_require("statistics/rewards/FistfulOfTNT1", nil, "RELEASE")
base_require("statistics/rewards/FistfulOfTNT2", nil, "RELEASE")
base_require("statistics/rewards/FistfulOfTNT3", nil, "RELEASE")
base_require("statistics/rewards/SidearmSavvy1", nil, "RELEASE")
base_require("statistics/rewards/SidearmSavvy2", nil, "RELEASE")
base_require("statistics/rewards/SidearmSavvy3", nil, "RELEASE")
base_require("statistics/rewards/Nightingale1", nil, "RELEASE")
base_require("statistics/rewards/Nightingale2", nil, "RELEASE")
base_require("statistics/rewards/Nightingale3", nil, "RELEASE")
base_require("statistics/rewards/Goldrush1", nil, "RELEASE")
base_require("statistics/rewards/Goldrush2", nil, "RELEASE")
base_require("statistics/rewards/Goldrush3", nil, "RELEASE")
base_require("statistics/rewards/Conqueror1", nil, "RELEASE")
base_require("statistics/rewards/Conqueror2", nil, "RELEASE")
base_require("statistics/rewards/Conqueror3", nil, "RELEASE")
base_require("statistics/rewards/NoblePrize1", nil, "RELEASE")
base_require("statistics/rewards/NoblePrize2", nil, "RELEASE")
base_require("statistics/rewards/NoblePrize3", nil, "RELEASE")
base_require("statistics/rewards/Marshal1", nil, "RELEASE")
base_require("statistics/rewards/Marshal2", nil, "RELEASE")
base_require("statistics/rewards/Marshal3", nil, "RELEASE")
base_require("statistics/rewards/LureOfTheHuntress1", nil, "RELEASE")
base_require("statistics/rewards/LureOfTheHuntress2", nil, "RELEASE")
base_require("statistics/rewards/LureOfTheHuntress3", nil, "RELEASE")
base_require("statistics/rewards/WildBill1", nil, "RELEASE")
base_require("statistics/rewards/WildBill2", nil, "RELEASE")
base_require("statistics/rewards/WildBill3", nil, "RELEASE")
base_require("statistics/rewards/Feedback", nil, "RELEASE")
base_require("statistics/rewards/Sharpshooter", nil, "RELEASE")
base_require("statistics/rewards/LeadPusher", nil, "RELEASE")
base_require("statistics/rewards/Unforgiven", nil, "RELEASE")
base_require("statistics/rewards/Goldsnatcher", nil, "RELEASE")
base_require("statistics/rewards/Shootist", nil, "RELEASE")
base_require("statistics/rewards/Headhunter", nil, "RELEASE")
base_require("statistics/rewards/Survivor", nil, "RELEASE")
base_require("statistics/rewards/Ghost", nil, "RELEASE")
base_require("statistics/rewards/CoureurDesBois", nil, "RELEASE")
base_require("statistics/rewards/Artemis", nil, "RELEASE")
base_require("statistics/rewards/Decapitator", nil, "RELEASE")
base_require("statistics/rewards/Spotter", nil, "RELEASE")
base_require("statistics/rewards/EagleEye", nil, "RELEASE")
base_require("statistics/rewards/Finisher", nil, "RELEASE")
base_require("statistics/rewards/AngelOfDeath", nil, "RELEASE")
base_require("statistics/rewards/MedicineMan", nil, "RELEASE")
base_require("statistics/rewards/RoadAgent", nil, "RELEASE")
base_require("statistics/rewards/Quickshot", nil, "RELEASE")
base_require("statistics/rewards/Grenadier", nil, "RELEASE")
base_require("statistics/rewards/Buckshot", nil, "RELEASE")
base_require("statistics/rewards/Powerhouse", nil, "RELEASE")
base_require("statistics/rewards/MadHatter", nil, "RELEASE")
base_require("statistics/rewards/FortyNiner", nil, "RELEASE")
base_require("statistics/rewards/Leprechaun", nil, "RELEASE")
base_require("statistics/rewards/Detonator", nil, "RELEASE")
base_require("statistics/rewards/Kegmeister", nil, "RELEASE")
base_require("statistics/rewards/HeadHoncho", nil, "RELEASE")
base_require("statistics/rewards/Royalty", nil, "RELEASE")
base_require("statistics/rewards/Demolisher", nil, "RELEASE")
base_require("statistics/rewards/DeadMeat", nil, "RELEASE")
base_require("statistics/rewards/DaisyPusher", nil, "RELEASE")
base_require("units/beings/locomotion/LocomotionController", nil, "RELEASE")
base_require("units/beings/locomotion/LocomotionData", nil, "RELEASE")
base_require("units/mp/players/PlayerSoundHelper", nil, "RELEASE")
setup = setup or {}
script_data = script_data or {}
unit_test = unit_test or {}
preload = preload or {}
end_update_callback_map = end_update_callback_map or {}
last_end_update_callback_id = last_end_update_callback_id or 0
paused_end_update_callback_map = paused_end_update_callback_map or {}
last_paused_end_update_callback_id = last_paused_end_update_callback_id or 0
pre_render_callback_map = pre_render_callback_map or {}
last_pre_render_callback_id = last_pre_render_callback_id or 0
remove_callback_map = remove_callback_map or false
Global.zone_data = Global.zone_data or {}
local _mindprobe
Debug = FatsharkDebug:new()
function setup.init()
  Application:debug("setup.init()")
  rawset(_G, "material_config", MaterialConfig:new())
  init_globals()
  core_setup.init()
  if Application:dedicated_server() then
    Application:cap_framerate(60)
  end
  setup.call_preload(Player.preload, "both")
  managers.localizer = managers.localization
  local platform = SystemInfo:platform()
  managers.platform = (GenericPlatformManager.PLATFORM_CLASS_MAP[platform] or GenericPlatformManager):new()
  managers.relay = RelayManager:new()
  managers.zones = ZonesManager:new()
  managers.save = SaveManager:new()
  managers.rumble:post_setup()
  managers.volume:post_setup()
  setup_debug_variables()
  setup_script_data()
  TimerManager:make_timer("player", TimerManager:game())
  managers.static_geometry = StaticGeometryManager:new()
  managers.achievement = AchievementManager:new()
  managers.transition = TransitionManager:new()
  managers.action_event = ActionEventManager:new()
  setup.define_action_events()
  managers.statistics = StatisticsManager:new()
  if Global.steam_init_success then
    managers.steam = managers.steam or SteamManager:new()
    managers.steam:initialize()
  end
  managers.gameplay = GameplayManager:new()
  managers.actormanager = ActorManager:new()
  managers.radiation = RadiationManager:new()
  managers.network = NetworkManager:new()
  managers.uniqueitem = UniqueItemManager:new()
  managers.ai_event = AIEventManager:new()
  managers.compass = CompassManager:new()
  managers.water = WaterManager:new()
  managers.weapondrop = WeaponDropManager:new()
  managers.world_rotation = WorldRotationManager:new()
  managers.feedback = FeedBackManager:new()
  managers.ingamevideo = IngameVideoManager:new()
  managers.controller_info_gui = ControllerInfoGuiManager
  managers.ai_graph = AIGraphManager:new()
  managers.locinfo = LocInfoManager:new()
  managers.game_central = GameCentralManager:new()
  managers.brain = BrainManager:new()
  managers.bot = BotManager:new()
  setup.setup_camera_manager()
  managers.aihivebrain:parse_data()
  if Global.demo then
    managers.demo = DemoManager:new()
    if not managers.demo:setup() then
      managers.demo = nil
    end
  end
  if Application:ews_enabled() == true then
    cat_print("jimmy", "setup.init(): ToolHub online.")
    managers.toolhub:add("Unit Viewer", UnitViewer)
    managers.toolhub:add("Unit Tweaker", UnitTweaker)
    managers.toolhub:add("Anim Viewer", AnimViewer)
    managers.toolhub:add("Mind Probe", MindProbe)
    managers.toolhub:add("Actor Editor", ActorEditor)
    managers.toolhub:add("StopTimer", StopTimer)
    managers.toolhub:add("Pickup Editor", PickupEditor)
    managers.toolhub:add("Animation Inspector", AnimationInspector)
    managers.toolhub:buildmenu()
    if Application:net_ews_enabled() then
      managers.toolhub:show()
    end
  else
    cat_print("jimmy", "setup.init(): ToolHub offline, no EWS active.")
  end
  script_debug._freeflight = nil
  script_debug._info_box = script_debug._info_box or DebugInfo:new()
  script_debug._ai = false
  Global.swing_indicator = true
  Global.auto_launch = true
  if SystemInfo:platform() == "PS3" then
    managers.psn = managers.psn or PSNManager:new()
    managers.psn:initialize()
  end
  managers.player = PlayerManager:new()
  managers.player_memory = PlayerMemoryManager:new()
  managers.dialog = DialogManager:new()
  managers.menu_mouse = MenuMouseManager:new()
  managers.menu_pages = MenuPageManager:new()
  managers.menu = MainMenuManager:new({ingame = true})
  managers.unlock = UnlockManager:new()
  managers.backmenu = BackMenuManager:new()
  if not Global.dedicated then
    managers.reward = RewardManager:new()
  end
  managers.markers = HudMarkerListManager:new()
  managers.server_ranking = ServerRankingManager:new()
  managers.statistics:add_observer(PlayerSoundHelper:new())
  managers.statistics:add_observer(Punisher:new())
  managers.statistics:add_observer(IdleKick:new())
  if not Application:dedicated_server() then
    if tweak_data.version_config.switchable_huds then
      managers.player_hud = PlayerSwitchableHudManager:new()
    else
      managers.player_hud = PlayerHudManager:new()
    end
    managers.web_config = WebConfigManager:new()
  end
  if Application:editor() then
    managers.editor = (rawget(_G, "WorldEditor") or rawget(_G, "CoreEditor")):new()
    managers.editor:toggle()
  end
  if not Network:multiplayer() and not Application:editor() and not setup.benchmark and not setup.slave then
    managers.transition:intro()
  end
  for _, arg in ipairs(Application:argv()) do
    if arg == "-test_done" then
      unit_test.browser = CoreUnitTestBrowser:new()
      unit_test.browser._autorun = true
      break
    elseif arg == "-test" and managers.aihivebrain then
      managers.aihivebrain:set_enable(false)
      break
    end
  end
  managers.network:register_matchmaking_callbacks()
  World:occlusion_manager():set_max_occluder_tests(8)
  managers.save:post_setup_load()
  setup.next_steam_update = 0
end
function setup.setup_camera_manager()
  managers.camera = CameraManager:new()
  managers.camera:load_cameras("data/cameras/player_camera.xml")
  managers.camera:load_cameras("data/cameras/observer_camera.xml")
end
function setup.call_preload(func, mode)
  local is_multiplayer = Network:multiplayer()
  local call = "invalid"
  if mode == "both" then
    call = true
  elseif mode == "single-player" then
    call = not is_multiplayer
  elseif mode == "multiplayer" then
    call = is_multiplayer
  end
  if call == "invalid" then
    Application:throw_exception("Invalid preload mode '" .. tostring(v.mode) .. "' selected for function '" .. tostring(v.func) .. "'. See ZonesManager:add_post_init_callback() for valid options.")
    return
  end
  if call == true then
    func()
  end
end
function setup.post_init()
  if rawget(_G, "_class") and _class.post_init then
    _class:post_init()
  end
  core_setup.post_init()
  managers.zones:post_init()
  if not Application:dedicated_server() then
    managers.viewport:effects_load_resources()
  end
  managers.save:post_init()
end
function setup.update_dedicated(time, rel_time)
  if managers.sequence and managers.sequence.update then
    managers.sequence:update(time, rel_time)
  end
  if managers.world then
    managers.world:update(time, rel_time)
  end
  if managers.transition then
    managers.transition:update(time, rel_time)
  end
  if managers.gameplay then
    managers.gameplay:update(time, rel_time)
  end
  managers.network:update(time, rel_time)
  managers.ai_event:update(time, rel_time)
  managers.ai_graph:update(time, rel_time)
  managers.action_event:update(time, rel_time)
  update_tickets()
  if time > setup.next_steam_update then
    Steam:update()
    setup.next_steam_update = time + 2
  end
end
function setup.update(time, rel_time)
  if Global.dedicated then
    setup.update_dedicated(time, rel_time)
    return
  end
  if managers.platform.update then
    managers.platform:update(time, rel_time)
  end
  managers.save:update(time, rel_time)
  managers.statistics:register_time_update(time, rel_time)
  core_setup.update(time, rel_time)
  managers.world:update(time, rel_time)
  if script_debug._freeflight then
    script_debug._freeflight:update(time, rel_time)
  end
  if script_debug._info_box then
    script_debug._info_box:update(time, rel_time)
  end
  if managers.demo then
    managers.demo:update(time, rel_time)
  end
  if managers.editor then
    managers.editor:update(time, rel_time)
  end
  managers.transition:update(time, rel_time)
  if managers.dialog then
    managers.dialog:update(time, rel_time)
  end
  if managers.dialog and not managers.dialog.active then
    managers.menu:update(time, rel_time)
    managers.menu_pages:update(time, rel_time)
  end
  if managers.menu_mouse then
    managers.menu_mouse:update(time, rel_time)
  end
  if managers.player then
    managers.player:update(time, rel_time)
    managers.player:increase_total_play_time(rel_time)
  end
  if managers.gameplay then
    managers.gameplay:update(time, rel_time)
  end
  managers.actormanager:update(time, rel_time)
  managers.radiation:update(time, rel_time)
  managers.network:update(time, rel_time)
  managers.ai_event:update(time, rel_time)
  if _mindprobe ~= nil then
    _mindprobe:update(time, TimerManager:wall():delta_time())
  end
  managers.ai_graph:update(time, rel_time)
  managers.water:update(time, rel_time)
  managers.world_rotation:update(time, rel_time)
  managers.viewport:update(time, rel_time)
  managers.camera:update(time, rel_time)
  managers.action_event:update(time, rel_time)
  Debug:_draw_sticky_shapes()
  update_tickets()
  managers.markers:update(time, rel_time)
  managers.player_hud:update(time, rel_time)
  if Global.steam_init_success then
    managers.steam:update(time, rel_time)
  end
  if managers.psn then
    managers.psn:update(time, rel_time)
  end
end
function setup.paused_update(time, rel_time)
  if managers.platform.update then
    managers.platform:update(time, rel_time)
  end
  managers.save:update(time, rel_time)
  core_setup.paused_update(time, rel_time)
  if managers.demo then
    managers.demo:update(time, rel_time)
  end
  if script_debug._freeflight then
    script_debug._freeflight:update(time, rel_time)
  end
  if script_debug._info_box then
    script_debug._info_box:update(time, rel_time)
  end
  if managers.editor ~= nil then
    managers.editor:update(time, rel_time)
  end
  managers.transition:update(time, rel_time)
  managers.dialog:update(time, rel_time)
  if not managers.dialog.active then
    managers.menu_pages:update(time, rel_time)
    managers.menu:update(time, rel_time)
  end
  managers.menu_mouse:update(time, rel_time)
  managers.player:paused_update(time, rel_time)
  managers.ingamevideo:paused_update(time, rel_time)
  if _mindprobe ~= nil then
    _mindprobe:update(time, TimerManager:wall():delta_time())
  end
  managers.viewport:paused_update(time, rel_time)
  if Global.steam_init_success then
    managers.steam:update(time, rel_time)
  end
  if managers.psn then
    managers.psn:update(time, rel_time)
  end
end
function setup.add_pre_render_callback(func)
  last_pre_render_callback_id = last_pre_render_callback_id + 1
  pre_render_callback_map[last_pre_render_callback_id] = func
  return last_pre_render_callback_id
end
function setup.remove_pre_render_callback(id, in_parse)
  if in_parse then
    remove_callback_map = remove_callback_map or {}
    remove_callback_map[id] = true
  else
    pre_render_callback_map[id] = nil
  end
end
function setup.add_end_update_callback(func)
  last_end_update_callback_id = last_end_update_callback_id + 1
  end_update_callback_map[last_end_update_callback_id] = func
  return last_end_update_callback_id
end
function setup.remove_end_update_callback(id, in_parse)
  if in_parse then
    remove_callback_map = remove_callback_map or {}
    remove_callback_map[id] = true
  else
    end_update_callback_map[id] = nil
  end
end
function setup.add_paused_end_update_callback(func)
  last_paused_end_update_callback_id = last_paused_end_update_callback_id + 1
  paused_end_update_callback_map[last_paused_end_update_callback_id] = func
  return last_paused_end_update_callback_id
end
function setup.remove_paused_end_update_callback(id, in_parse)
  if in_parse then
    remove_callback_map = remove_callback_map or {}
    remove_callback_map[id] = true
  else
    paused_end_update_callback_map[id] = nil
  end
end
function setup.end_update(t, dt)
  core_setup.end_update(t, dt)
  managers.game_central:end_update(t, dt)
  for id, func in pairs(end_update_callback_map) do
    func(id)
  end
  if remove_callback_map then
    for id, func in pairs(remove_callback_map) do
      end_update_callback_map[id] = nil
    end
    remove_callback_map = false
  end
end
function setup.paused_end_update(t, dt)
  core_setup.paused_end_update(t, dt)
  managers.viewport:update_viewports()
  for id, func in pairs(paused_end_update_callback_map) do
    func(id)
  end
  if remove_callback_map then
    for id, func in pairs(remove_callback_map) do
      paused_end_update_callback_map[id] = nil
    end
    remove_callback_map = false
  end
end
function setup.render()
  if Global.dedicated then
    return
  end
  core_setup.render()
  for id, func in pairs(pre_render_callback_map) do
    func(id)
  end
  managers.viewport:update_viewports()
  if remove_callback_map then
    for id, func in pairs(remove_callback_map) do
      pre_render_callback_map[id] = nil
    end
    remove_callback_map = false
  end
  managers.viewport:render()
end
function setup.pre_init()
  core_setup.pre_init()
  local start_mindprobe = false
  local start_unitviewer = false
  for i, v in ipairs(Application:argv()) do
    if v == "-mind" then
      start_mindprobe = true
    end
  end
  if start_mindprobe then
    _mindprobe = MindProbe:new()
  end
end
function setup.save(data)
  managers.sequence:save(data)
  managers.area:save(data)
  managers.DOF:save(data)
end
function setup.load(data)
  managers.sequence:load(data)
  managers.area:load(data)
  managers.viewport:load(data)
  managers.DOF:load(data)
  managers.network:load(data)
end
function setup.destroy()
  core_setup.destroy()
  if rawget(_G, "_class") and _class.destroy then
    _class:destroy()
  end
  if script_debug._freeflight then
    script_debug._freeflight:destroy()
  end
  managers.dialog:destroy()
  managers.menu_pages:destroy()
  managers.menu:destroy()
  managers.menu_mouse:destroy()
  managers.backmenu:destroy()
  managers.transition:destroy()
  managers.ingamevideo:destroy()
  managers.player:destroy()
  if managers.player_hud then
    managers.player_hud:destroy()
  end
  if managers.steam then
    managers.steam:destroy()
  end
  if managers.psn then
    managers.psn:destroy()
  end
end
function setup.animations_reloaded()
end
function setup.script_reloaded()
  if tweak_data.RELOAD then
    tweak_data:reloaded()
  end
  managers.feedback:reload()
  managers.rumble:setup_preset_rumbles()
  if managers.psn then
    managers.psn:on_script_reload()
  end
end
function setup_debug_variables()
  script_debug.render_world = true
  script_debug.render_overlay = true
  script_debug.draw_enabled = false
  script_debug.mindprobe_unit = nil
  script_debug.brightscale = 1
  script_debug.aircam = "aircam"
  script_debug.aircamparam = nil
  script_debug.ghost = false
end
function setup_script_data()
  script_data.hub_elements = {}
  script_data.bionic_units = {}
  script_data.dynamic_aigraphs = {}
  script_data.last_thrown_grenade = 0
  script_data.usable_ext = {}
  script_data.player_unit_name = Global.player_unit or "player"
end
function setup.define_action_events()
  local event_actions = {
    "main_menu_activated",
    "main_menu_deactivated",
    "ingame_menu_activated",
    "ingame_menu_deactivated",
    "who_killed_who",
    "accolade",
    "title",
    "achievement",
    "experience_gained",
    "hit_effect",
    "update_stats",
    "show_scoreboard",
    "level_up",
    "unit_player_dead",
    "unit_player_entered_mounted_weapon_area",
    "unit_player_left_mounted_weapon_area",
    "unit_explosion",
    "unit_camera_shake",
    "unit_afro_hit",
    "unit_land",
    "unit_player_close_to_revivable_teammember",
    "unit_player_damage",
    "unit_player_melee_damage",
    "unit_player_spawned",
    "player_close_to_carriable",
    "knocked_out_friendly",
    "enemy_tagged",
    "teams_updated",
    "mission_markers_updated",
    "mission_units_updated",
    "marker_list_updated",
    "attach_carriable",
    "team_msg",
    "synch_respawn_timer",
    "flag_camera_enter",
    "show_compass_unit",
    "start_game",
    "start_round",
    "round_over",
    "done_loading",
    "match_over",
    "mission_objective",
    "mission_objective_completed",
    "game_over_forefit",
    "trap_triggered",
    "allow_archetype_special",
    "weapon_fire",
    "team_score_updated",
    "sync_capture_zone",
    "trap_set",
    "hud_message",
    "sync_time",
    "loading_network_client_status",
    "loading_network_clients_done",
    "show_error_message",
    "hide_error_message",
    "freeflight_mode",
    "player_archetype_selection_acknowledged",
    "player_archetype_selection_rejected",
    "player_revived",
    "carriable_despawn_timer",
    "interact_when_knocked_down",
    "trophy",
    "voice_detected",
    "player_on_mounted_weapon",
    "punishment",
    "lobby_member_added",
    "player_switched_teams",
    "carriable_stopped",
    "is_inside_immortality_zone",
    "new_chat_message",
    "new_console_message",
    "player_vote_requested",
    "vote_result_updated",
    "reselect_archetype",
    "leaving_the_game",
    "stalker_ability_triggered"
  }
  managers.action_event:define_actions(event_actions)
end
