Application:debug("coresetup1\n")
require("core/setups/CoreNanoSetup")
if not core_nano_setup.initialized() then
  core_nano_setup.init()
end
function cap_framerate_hijack(app, framerate)
  framerate = Application:dedicated_server() and 60 or framerate
  Global.application_framerate_cap = tonumber(framerate) or 0
  app:hijacked_cap_framerate(Global.application_framerate_cap)
end
Global.application_framerate_cap = Global.application_framerate_cap or 0
hijack_func(Application, "cap_framerate", callback(nil, _G, "cap_framerate_hijack"))
function coroutine_resume_hijack(...)
  local result = {
    coroutine.hijacked_resume(...)
  }
  if not result[1] then
    Application:stack_dump_error(result[2])
  end
  return unpack(result)
end
hijack_func(coroutine, "resume", callback(nil, _G, "coroutine_resume_hijack"))
base_require("core/utils/dev/ews/CoreEWS", nil, "DEBUG")
base_require("core/units/CoreSpawnSystem", nil, "RELEASE")
base_require("core/units/data/CoreScriptUnitData", nil, "RELEASE")
base_require("core/units/data/CoreWireData", nil, "RELEASE")
base_require("core/units/data/CoreCutsceneData", nil, "RELEASE")
base_require("core/managers/controller/CoreControllerManager", nil, "RELEASE")
base_require("core/managers/cutscene/CoreCutsceneManager", nil, "RELEASE")
base_require("core/managers/CoreSlotManager", nil, "RELEASE")
base_require("core/managers/CoreViewportManager", nil, "RELEASE")
base_require("core/managers/CoreEnvironmentManager", nil, "RELEASE")
base_require("core/managers/CoreAiHiveBrain", nil, "RELEASE")
base_require("core/managers/CoreDebugManager", nil, "DEBUG")
base_require("core/managers/CoreConfigManager", nil, "RELEASE")
base_require("core/managers/CoreVolumeManager", nil, "RELEASE")
base_require("core/managers/CoreDOFManager", nil, "RELEASE")
base_require("core/managers/CoreRumbleManager", nil, "RELEASE")
core:require_module("CoreShadowManager")
core:require_module("CoreMusicManager")
core:require_module("CoreNewsReportManager")
core:require_module("CoreSubtitleManager")
base_require("core/managers/CoreSequenceManager", nil, "RELEASE")
base_require("core/managers/CoreGenericStateManager", nil, "RELEASE")
base_require("core/managers/CoreWorldManager", nil, "RELEASE")
base_require("core/managers/CoreExpressionManager", nil, "RELEASE")
base_require("core/managers/CoreBenchmarkManager", nil, "RELEASE")
base_require("core/managers/CoreWorldCameraManager", nil, "RELEASE")
base_require("core/managers/CoreShapeManager", nil, "RELEASE")
base_require("core/managers/CorePortalManager", nil, "RELEASE")
base_require("core/managers/CoreGTextureManager", nil, "RELEASE")
base_require("core/managers/CoreDatabaseManager", nil, "DEBUG")
base_require("core/managers/CoreSoundEnvironmentManager", nil, "RELEASE")
base_require("core/managers/CoreEnvironmentAreaManager", nil, "RELEASE")
base_require("core/managers/CoreListenerManager", nil, "RELEASE")
base_require("core/managers/CoreEnvironmentEffectsManager", nil, "RELEASE")
base_require("core/managers/CoreOverlayEffectManager", nil, "RELEASE")
base_require("core/units/CoreUnitDamage", nil, "RELEASE")
base_require("core/units/CoreEditableGui", nil, "RELEASE")
base_require("core/utils/dev/Utils", nil, "RELEASE")
base_require("core/utils/dev/Tablescan", nil, "RELEASE")
base_require("core/utils/dev/Luaspy", nil, "DEBUG")
base_require("core/utils/dev/ToolHub", nil, "DEBUG")
base_require("core/utils/dev/CoreLuaDump", nil, "DEBUG")
base_require("core/utils/dev/CoreFreeFlight", nil, "RELEASE")
base_require("core/utils/dev/netews/CoreNetEWSWidget", nil, "DEBUG")
base_require("core/utils/dev/netews/CoreNetEWSUtils", nil, "DEBUG")
base_require("core/utils/dev/netews/CoreNetEWS", nil, "DEBUG")
base_require("core/utils/dev/netews/CoreNetEWSServer", nil, "DEBUG")
core:require_module("CoreMusicEditor2")
core:require_module("CoreMusicMonitor")
core:require_module("CoreLuaProfilerViewer")
base_require("core/utils/dev/tools/CoreVolumeEditor", nil, "DEBUG")
base_require("core/utils/dev/tools/CoreUnitReloader", nil, "DEBUG")
base_require("core/utils/dev/tools/CoreUnitTestBrowser", nil, "DEBUG")
base_require("core/utils/dev/tools/CoreEnvEditor", nil, "DEBUG")
base_require("core/utils/dev/tools/CoreDatabaseBrowser", nil, "DEBUG")
base_require("core/utils/dev/tools/CoreBenchmarkEditor", nil, "DEBUG")
base_require("core/utils/dev/tools/CoreLuaProfiler", nil, "DEBUG")
base_require("core/utils/dev/tools/CoreXMLEditor", nil, "DEBUG")
base_require("core/utils/dev/tools/CorePrefHud", nil, "DEBUG")
base_require("core/utils/dev/tools/CoreResourceExporter", nil, "DEBUG")
base_require("core/utils/dev/tools/CoreMacroToolbar", nil, "DEBUG")
base_require("core/utils/dev/tools/CorePuppeteer", nil, "DEBUG")
base_require("core/utils/dev/tools/material_editor/CoreMaterialEditor", nil, "DEBUG")
base_require("core/utils/dev/tools/material_editor2/CoreMaterialEditor2", nil, "DEBUG")
base_require("core/utils/dev/tools/particle_editor/CoreParticleEditor", nil, "DEBUG")
base_require("core/utils/dev/tools/unit_editor/CoreUnitEditor", nil, "DEBUG")
base_require("core/utils/dev/tools/cutscene_editor/CoreCutsceneEditor", nil, "DEBUG")
base_require("core/utils/dev/editor/CoreEditor", nil, "DEBUG")
base_require("core/utils/dev/editor/WorldHolder", nil, "RELEASE")
d = managers.debug
Global.category_print = Global.category_print or {}
Global.category_print_initialized = Global.category_print_initialized or {}
if base_is_required("DEBUG") then
  NetEWS:new()
  NetEWSServer:new()
end
function core_setup.pre_init()
end
function core_setup.init()
  min_exe_version("1.0.0.7000", "Core Systems")
  rawset(_G, "UnitDamage", rawget(_G, "UnitDamage") or CoreUnitDamage)
  rawset(_G, "EditableGui", rawget(_G, "EditableGui") or CoreEditableGui)
  core_setup.setup_category_print()
  core_setup.flag_rs_apply = false
  if not Application:editor() then
    if SystemInfo:platform() == "WIN32" then
      core_setup_resolution()
    elseif SystemInfo:platform() == "X360" or SystemInfo:platform() == "PS3" and SystemInfo:widescreen() then
      core_setup.wide = true
      core_setup.aspect_ratio = 1.7777778
    else
      core_setup.wide = false
      core_setup.aspect_ratio = 1.3333334
    end
  else
    core_nano_setup.setup_postprocessor_environment()
  end
  managers.controller = core_or_local("ControllerManager")
  managers.slot = core_or_local("SlotManager")
  managers.listener = core_or_local("ListenerManager")
  managers.viewport = core_or_local("ViewportManager")
  managers.config = core_or_local("ConfigManager", "data/lib/managers/xml/configmanager.xml")
  managers.environment = core_prepare_full_load(core_or_local("EnvironmentManager"), managers.environment)
  managers.volume = core_or_local("VolumeManager", "data/lib/managers/xml/volumemanager.xml")
  managers.aihivebrain = core_or_local("AiMachine")
  managers.music = CoreMusicManager.MusicManager:new()
  managers.shadow = CoreShadowManager.ShadowManager:new()
  managers.music2 = managers.music:player()
  managers.sequence = core_or_local("SequenceManager")
  managers.sequence:internal_load()
  managers.world = core_or_local("WorldManager")
  managers.expression = core_or_local("ExpressionManager")
  managers.benchmark = core_or_local("BenchmarkManager")
  managers.worldcamera = core_or_local("WorldCameraManager")
  managers.environment_effects = core_or_local("EnvironmentEffectsManager")
  managers.portal = core_or_local("PortalManager")
  managers.debug = core_or_local("DebugManager")
  managers.global_texture = core_prepare_full_load(core_or_local("GTextureManager"), managers.global_texture)
  managers.sound_environment = core_or_local("SoundEnvironmentManager")
  managers.shape = core_or_local("ShapeManager")
  managers.environment_area = core_or_local("EnvironmentAreaManager")
  managers.cutscene = not Application:no_rendering() and core_or_local("CutsceneManager")
  managers.rumble = core_or_local("RumbleManager")
  managers.DOF = core_or_local("DOFManager")
  managers.subtitle = not Application:no_rendering() and CoreSubtitleManager.SubtitleManager:new()
  managers.overlay_effect = core_or_local("OverlayEffectManager")
  if Application:ews_enabled() then
    managers.news = CoreNewsReportManager.NewsReportManager:new()
  end
  if base_is_required("DEBUG") then
    managers.database = core_or_local("DatabaseManager")
    managers.prefhud = core_or_local("PrefHud")
  end
  d = managers.debug
  if Application:ews_enabled() then
    managers.toolhub = managers.toolhub or ToolHub:new()
    if not Application:editor() then
      managers.toolhub:add("Unit Reloader", get_core_or_local("UnitReloader"))
    end
    managers.toolhub:add("Environment Editor", get_core_or_local("EnvEditor"))
    managers.toolhub:add(CoreMusicEditor2.TOOLHUB_NAME, CoreMusicEditor2.CoreMusicEditor2)
    managers.toolhub:add(CoreMusicMonitor.TOOLHUB_NAME, CoreMusicMonitor.CoreMusicMonitor)
    managers.toolhub:add(CoreLuaProfilerViewer.TOOLHUB_NAME, CoreLuaProfilerViewer.LuaProfilerViewer)
    managers.toolhub:add("Database Browser", get_core_or_local("DatabaseBrowser"))
    managers.toolhub:add(get_core_or_local("MaterialEditor2").TOOLHUB_NAME, get_core_or_local("MaterialEditor2"))
    managers.toolhub:add("Benchmark Editor", get_core_or_local("BenchmarkEditor"))
    managers.toolhub:add("LUA Profiler", get_core_or_local("LuaProfiler"))
    managers.toolhub:add("XML Editor", get_core_or_local("XMLEditor"))
    managers.toolhub:add("Particle Editor", get_core_or_local("ParticleEditor"))
    managers.toolhub:add(get_core_or_local("ResourceExporter").TOOLHUB_NAME, get_core_or_local("ResourceExporter"))
    managers.toolhub:add(get_core_or_local("Puppeteer").EDITOR_TITLE, get_core_or_local("Puppeteer"))
    managers.toolhub:add(get_core_or_local("UnitEditor").TOOLHUB_NAME, get_core_or_local("UnitEditor"))
    managers.toolhub:add(get_core_or_local("CutsceneEditor").EDITOR_TITLE, get_core_or_local("CutsceneEditor"))
    if not Global.NEW_CORE_GENERATION_2 then
      managers.toolhub:add("Material Editor", get_core_or_local("MaterialEditor"))
      managers.toolhub:add("Volume Editor", get_core_or_local("VolumeEditor"))
      managers.toolhub:add("Unit Test Browser", get_core_or_local("UnitTestBrowser"))
      managers.toolhub:add("Luaspy", LuaSpy)
    end
  end
end
function core_setup.post_init()
  managers.sequence:preload()
  if managers.cutscene then
    managers.cutscene:post_init()
  end
end
function core_setup_resolution()
  local vid_res, fullscreen, render_setting_vars = core_setup_get_mode()
  local current_res = RenderSettings.resolution
  core_setup_apply_aspect_settings()
  local shadow_quality = tostring(render_setting_vars.shadow_quality)
  local current_shadow_quality = RenderSettings.shadow_quality
  local max_anisotropy = tonumber(render_setting_vars.max_anisotropy)
  local current_max_anisotropy = RenderSettings.max_anisotropy
  local ssao = toboolean(render_setting_vars.ssao)
  if ssao == nil then
    ssao = true
  end
  local current_ssao = RenderSettings.ssao
  local dof = toboolean(render_setting_vars.dof)
  local current_dof = RenderSettings.dof
  local bloom = toboolean(render_setting_vars.bloom)
  local current_bloom = RenderSettings.bloom
  local shader_settings_changed = ssao ~= current_ssao or dof ~= current_dof or bloom ~= current_bloom
  if vid_res.x ~= current_res.x or vid_res.y ~= current_res.y or vid_res.z ~= current_res.z or fullscreen ~= RenderSettings.fullscreen or shadow_quality ~= current_shadow_quality or max_anisotropy ~= current_max_anisotropy or shader_settings_changed then
    RenderSettings.resolution = vid_res
    RenderSettings.fullscreen = fullscreen
    RenderSettings.shadow_quality = shadow_quality
    RenderSettings.max_anisotropy = max_anisotropy
    RenderSettings.ssao = ssao
    RenderSettings.dof = dof
    RenderSettings.bloom = bloom
    core_setup.flag_rs_apply = true
  end
end
function core_setup_apply_aspect_settings()
  core_setup.aspect_ratio = core_setup_get_aspect()
  core_setup.wide = core_setup.aspect_ratio > 1.34
end
-- Resolve the best display mode for the current desktop from the C++-enumerated
-- modes: 1) exact match; 2) otherwise the largest mode at-or-below the desktop
-- in both axes (a multi-monitor desktop wider than any single panel, e.g.
-- 3840x1080, has no exact mode - fall to the biggest that fits, never upscale);
-- 3) otherwise the current RenderSettings.resolution.
function core_setup_pick_mode()
  local desk = SystemInfo:desktop_resolution()
  local winner = RenderSettings.resolution
  if desk and desk.y > 0 then
    for _, res in ipairs(RenderSettings.modes) do
      if res.x == desk.x and res.y == desk.y then
        return res
      end
    end
    local best_area = -1
    for _, res in ipairs(RenderSettings.modes) do
      if res.x <= desk.x and res.y <= desk.y then
        local area = res.x * res.y
        if area > best_area then
          best_area = area
          winner = res
        end
      end
    end
  end
  return winner
end
function core_setup_display_mode()
  local winner = core_setup_pick_mode()
  return Vector3(winner.x, winner.y, winner.z)
end
function core_setup_get_mode()
  local render_settings = Application:render_settings_filename()
  local resolution = RenderSettings.resolution
  local fullscreen = RenderSettings.fullscreen
  local render_setting_vars = {
    shadow_quality = RenderSettings.shadow_quality,
    max_anisotropy = RenderSettings.max_anisotropy,
    ssao = RenderSettings.ssao,
    dof = RenderSettings.dof,
    bloom = RenderSettings.bloom
  }
  if File:config_exists(render_settings) then
    for child in File:parse_xml(render_settings):children() do
      if child:name() == "d3d_device" then
        if Application:render_settings_dirty() then
          resolution = core_setup_auto_detect_resolution()
        else
          resolution = math.string_to_vector(child:parameter("resolution"))
        end
        resolution = Vector3(resolution.x, resolution.y, tonumber(child:parameter("refresh_rate")))
        fullscreen = child:parameter("windowed") == "false"
      elseif child:name() == "render_settings" then
        for variable in child:children() do
          if variable:name() == "variable" then
            local key = variable:parameter("name")
            local value = variable:parameter("value")
            render_setting_vars[key] = value
          end
        end
      end
    end
  else
    resolution, fullscreen = core_setup_display_sync()
  end
  -- sync the internal render resolution to the display native mode so the
  -- game renders at the display resolution (borderless window already fills it)
  _G.D0GDBG = core_setup_display_mode_debug()
  resolution = core_setup_display_mode()
  return resolution, fullscreen, render_setting_vars
end
function core_setup_display_sync()
  -- Pick the display native mode (the one whose dimensions match the desktop)
  -- from the modes the C++ layer enumerated. Falls back to the current
  -- RenderSettings.resolution if the desktop resolution is not in the list.
  -- Pick the best fitting display mode (see core_setup_pick_mode): exact match,
  -- else the largest mode at-or-below the desktop (multi-monitor wide desktops
  -- have no exact mode), else the current resolution. The C++ device reads this
  -- config at creation on the NEXT boot, so writing the correct mode here is
  -- what makes the game start at the display native resolution (borderless).
  local winner = core_setup_pick_mode()
  -- Apply the mode to the C++ render binding so the re-serializer persists it
  RenderSettings.resolution = winner
  RenderSettings.fullscreen = true
  -- Set the Lua-side aspect from the actual native resolution (16:9 etc.)
  core_setup.aspect_ratio = winner.x / winner.y
  core_setup.wide = core_setup.aspect_ratio > 1.34
  local fullscreen = true
  local render_setting_vars_tag = "\t<render_settings>\n" .. "\t\t<variable name=\"shadow_quality\" value=\"" .. tostring(RenderSettings.shadow_quality) .. "\"/>\n" .. "\t\t<variable name=\"max_anisotropy\" value=\"" .. tostring(RenderSettings.max_anisotropy) .. "\"/>\n" .. "\t\t<variable name=\"ssao\" value=\"" .. tostring(RenderSettings.ssao) .. "\"/>\n" .. "\t\t<variable name=\"dof\" value=\"" .. tostring(RenderSettings.dof) .. "\"/>\n" .. "\t\t<variable name=\"bloom\" value=\"" .. tostring(RenderSettings.bloom) .. "\"/>\n" .. "\t</render_settings>\n"
  local f = File:open(Application:render_settings_filename(), "w")
  f:puts([[
<renderer_config>
\t<d3d_device adapter="]] .. RenderSettings.adapter .. "\" resolution=\"" .. winner.x .. " " .. winner.y .. "\" refresh_rate=\"" .. winner.z .. "\" windowed=\"" .. tostring(not fullscreen) .. "\" aspect_ratio=\"" .. (winner.x / winner.y) .. "\"/>\n" .. render_setting_vars_tag .. "</renderer_config>")
  f:close()
  return winner, true
end
function core_setup_auto_detect_resolution()
  local default_mode = 921600
  local point = math.huge
  local winner = RenderSettings.resolution
  local aspect_ratio = RenderSettings.resolution.x / RenderSettings.resolution.y
  for _, res in ipairs(RenderSettings.modes) do
    local res_point = math.abs(default_mode - res.x * res.y)
    if res.z == winner.z and point > res_point and res.x / res.y == aspect_ratio then
      point = res_point
      winner = res
    end
  end
  local render_setting_vars_tag = "\t<render_settings>\n" .. "\t\t<variable name=\"shadow_quality\" value=\"" .. tostring(RenderSettings.shadow_quality) .. "\"/>\n" .. "\t\t<variable name=\"max_anisotropy\" value=\"" .. tostring(RenderSettings.max_anisotropy) .. "\"/>\n" .. "\t\t<variable name=\"ssao\" value=\"" .. tostring(RenderSettings.ssao) .. "\"/>\n" .. "\t\t<variable name=\"dof\" value=\"" .. tostring(RenderSettings.dof) .. "\"/>\n" .. "\t\t<variable name=\"bloom\" value=\"" .. tostring(RenderSettings.bloom) .. "\"/>\n" .. "\t</render_settings>\n"
  local f = File:open(Application:render_settings_filename(), "w")
  f:puts([[
<renderer_config>
\t<d3d_device adapter="]] .. RenderSettings.adapter .. "\" resolution=\"" .. winner.x .. " " .. winner.y .. "\" refresh_rate=\"" .. winner.z .. "\" windowed=\"" .. tostring(not RenderSettings.fullscreen) .. "\" aspect_ratio=\"" .. winner.x / winner.y .. "\"/>\n" .. render_setting_vars_tag .. "</renderer_config>")
  f:close()
  return winner
end
function core_setup_display_aspect()
  local desk = SystemInfo:desktop_resolution()
  if desk and desk.y > 0 then
    return desk.x / desk.y
  end
  return 1.3333334
end
function core_setup_get_aspect()
  if File:config_exists(Application:render_settings_filename()) then
    for child in File:parse_xml(Application:render_settings_filename()):children() do
      if child:name() == "d3d_device" and child:parameter("aspect_ratio") ~= "" then
        return tonumber(child:parameter("aspect_ratio"))
      end
    end
  end
  return core_setup_display_aspect()
end
function core_setup.update(time, rel_time)
  if core_setup.flag_rs_apply then
    -- The C++ D3D device does not exist on the first update after init, and
    -- RenderSettings.modes is empty until the device enumerates its video
    -- modes. So core_setup_resolution() at init time picked the C++
    -- pre-seeded default (e.g. 1280x720). apply_render_settings is a no-op
    -- until the device exists. Therefore: keep the flag set until the modes
    -- list is populated, then RE-PICK the native display mode (largest-fitting
    -- for multi-monitor) and commit it, so the device renders at the display
    -- native resolution from the very first frame.
    if RenderSettings.modes and #RenderSettings.modes > 0 then
      local winner = core_setup_pick_mode()
      RenderSettings.resolution = winner
      RenderSettings.fullscreen = true
      core_setup.aspect_ratio = winner.x / winner.y
      core_setup.wide = core_setup.aspect_ratio > 1.34
      Application:apply_render_settings()
      core_setup.flag_rs_apply = false
      if managers.viewport then
        managers.viewport:resolution_changed()
      end
    end
  end
  if managers.controller.update then
    managers.controller:update(time, rel_time)
  end
  if managers.cutscene and managers.cutscene.update then
    managers.cutscene:update()
  end
  if managers.aihivebrain.update then
    managers.aihivebrain:update(time, rel_time)
  end
  if managers.environment.update then
    managers.environment:update(time, rel_time)
  end
  if managers.volume.update then
    managers.volume:update(time, rel_time)
  end
  if managers.config.update then
    managers.config:update(time, rel_time)
  end
  if managers.music.update then
    managers.music:update(time, rel_time)
  end
  if managers.sequence.update then
    managers.sequence:update(time, rel_time)
  end
  if managers.worldcamera.update then
    managers.worldcamera:update(time, rel_time)
  end
  if managers.environment_effects.update then
    managers.environment_effects:update(time, rel_time)
  end
  if managers.sound_environment then
    managers.sound_environment:update(time, rel_time)
  end
  if managers.environment_area then
    managers.environment_area:update(time, rel_time)
  end
  if managers.expression.update then
    managers.expression:update(time, rel_time)
  end
  if managers.benchmark.update then
    managers.benchmark:update(time, rel_time)
  end
  if managers.global_texture.update then
    managers.global_texture:update(time, rel_time)
  end
  if managers.prefhud and managers.prefhud.update then
    managers.prefhud:update(time, rel_time)
  end
  if managers.toolhub and managers.toolhub.update then
    managers.toolhub:update(time, rel_time)
  end
  if managers.subtitle and managers.subtitle.update then
    managers.subtitle:update(TimerManager:game_animation():time(), TimerManager:game_animation():delta_time())
  end
  if managers.rumble.update then
    managers.rumble:update(time, rel_time)
  end
  if managers.shadow.update then
    managers.shadow:update(time, rel_time)
  end
  if managers.DOF.update then
    managers.DOF:update(time, rel_time)
  end
  if managers.overlay_effect.update then
    managers.overlay_effect:update(time, rel_time)
  end
  if managers.debug and managers.debug.update then
    managers.debug:update(TimerManager:wall():time(), TimerManager:wall():delta_time())
  end
  if rawget(_G, "NET_EWS_CLIENT") and NET_EWS_CLIENT.update then
    NET_EWS_CLIENT:update(time, rel_time)
  end
  if rawget(_G, "NET_EWS_SERVER") and NET_EWS_SERVER.update then
    NET_EWS_SERVER:update(time, rel_time)
  end
end
function core_setup.paused_update(time, rel_time)
  if core_setup.flag_rs_apply then
    if RenderSettings.modes and #RenderSettings.modes > 0 then
      local winner = core_setup_pick_mode()
      RenderSettings.resolution = winner
      RenderSettings.fullscreen = true
      core_setup.aspect_ratio = winner.x / winner.y
      core_setup.wide = core_setup.aspect_ratio > 1.34
      Application:apply_render_settings()
      core_setup.flag_rs_apply = false
    end
  end
  if managers.controller.update then
    managers.controller:paused_update(time, rel_time)
  end
  if managers.cutscene and managers.cutscene.paused_update then
    managers.cutscene:paused_update(time, rel_time)
  end
  if managers.aihivebrain.paused_update then
    managers.aihivebrain:paused_update(time, rel_time)
  end
  if managers.environment.update then
    managers.environment:update(time, rel_time)
  end
  if managers.volume.paused_update then
    managers.volume:paused_update(time, rel_time)
  end
  if managers.config.paused_update then
    managers.config:paused_update(time, rel_time)
  end
  if managers.music.paused_update then
    managers.music:paused_update(time, rel_time)
  end
  if managers.sequence.paused_update then
    managers.sequence:paused_update(time, rel_time)
  end
  if managers.expression.paused_update then
    managers.expression:paused_update(time, rel_time)
  end
  if managers.benchmark.paused_update then
    managers.benchmark:paused_update(time, rel_time)
  end
  if managers.DOF.paused_update then
    managers.DOF:paused_update(time, rel_time)
  end
  if managers.rumble.paused_update then
    managers.rumble:paused_update(time, rel_time)
  end
  if managers.toolhub and managers.toolhub.paused_update then
    managers.toolhub:paused_update(time, rel_time)
  end
  if managers.shadow.paused_update then
    managers.shadow:paused_update(time, rel_time)
  end
  if managers.overlay_effect.paused_update then
    managers.overlay_effect:paused_update(time, rel_time)
  end
  if managers.debug and managers.debug.paused_update then
    managers.debug:paused_update(TimerManager:wall():time(), TimerManager:wall():delta_time())
  end
  if managers.global_texture.paused_update then
    managers.global_texture:paused_update(time, rel_time)
  end
  if rawget(_G, "NET_EWS_CLIENT") and NET_EWS_CLIENT.paused_update then
    NET_EWS_CLIENT:paused_update(time, rel_time)
  end
  if rawget(_G, "NET_EWS_SERVER") and NET_EWS_SERVER.paused_update then
    NET_EWS_SERVER:paused_update(time, rel_time)
  end
end
function core_setup.end_update(t, dt)
  if managers.environment and managers.environment.end_update then
    managers.environment:end_update()
  end
  if managers.toolhub and managers.toolhub.end_update then
    managers.toolhub:end_update(t, dt)
  end
end
function core_setup.paused_end_update(t, dt)
  if managers.environment.end_update then
    managers.environment:end_update()
  end
end
function core_setup.render()
  if managers.portal.render then
    managers.portal:render()
  end
end
function core_setup.setup_category_print()
  if Global.category_print_initialized.core_setup then
    return
  end
  Global.category_print.debug = true
  Global.category_print.editor = false
  Global.category_print.sequence = false
  Global.category_print.controller_manager = false
  Global.category_print_initialized.core_setup = true
end
function core_setup.destroy()
  if managers.toolhub then
    managers.toolhub:destroy()
  end
  if managers.global_texture.destroy then
    managers.global_texture:destroy()
  end
  if managers.cutscene then
    managers.cutscene:destroy()
  end
  if managers.subtitle then
    managers.subtitle:destroy()
  end
  if managers.viewport then
    managers.viewport:destroy()
  end
  if managers.worldcamera then
    managers.worldcamera:destroy()
  end
  if managers.editor then
    managers.editor:destroy()
  end
  if managers.volume then
    managers.volume:destroy()
  end
  if managers.music then
    managers.music:destroy()
  end
  if managers.debug then
    managers.debug:destroy()
  end
end
