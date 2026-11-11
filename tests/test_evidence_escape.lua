-- Behavioral regression tests for survivor evidence escape.
-- Run with: lua5.1 tests/test_evidence_escape.lua
local ROOT = (... and ... ~= "") and ... or "."
local failures = {}
local checks = 0

local function check(condition, message)
  checks = checks + 1
  if not condition then
    failures[#failures + 1] = message
  end
end

function class(parent)
  local result = parent and setmetatable({}, {__index = parent}) or {}
  result.new = function(self, ...)
    local object = setmetatable({}, {__index = self})
    if object.init then
      object:init(...)
    end
    return object
  end
  return result
end

BTNode = {
  init = function(self, identifier, parent)
    self._identifier = identifier
    self._parent = parent
  end
}
function BTNode:init(identifier, parent)
  self._identifier = identifier
  self._parent = parent
end

local member
local objective
local base = {
  drop_calls = 0
}
function base:get_member()
  return member
end
function base:start_carriable_drop()
  self.drop_calls = self.drop_calls + 1
  objective.data.carriable_carrier = nil
  member.attached = nil
end

local unit = {
  position_value = {x = 0, y = 0, z = 0}
}
function unit:base()
  return base
end
function unit:position()
  return self.position_value
end
function unit:ai_data()
  return self.data
end
function unit:locomotion_data()
  return self.locomotion
end
function unit:rotation()
  return "rotation"
end
function unit:locomotion()
  return {
    stop_movement = function()
      unit.locomotion.stopped = true
    end
  }
end

member = {
  _carriable_data = {evidence = true},
  attached = nil
}
function member:carriable()
  return self.attached
end
objective = {
  data = {
    type = "carriable",
    carriable_carrier = member
  },
  position_value = {x = 100, y = 0, z = 0}
}
function objective:name()
  return "evidence"
end
function objective:element_data()
  return self.data
end
function objective:position()
  return self.position_value
end

function alive(value)
  return value ~= nil
end

local mt = {}
local function vector_subtract(a, b)
  return setmetatable({x = a.x - b.x, y = a.y - b.y, z = a.z - b.z}, mt)
end
mt.__sub = vector_subtract
mt.__index = {
  length = function(v)
    return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
  end
}
setmetatable(unit.position_value, mt)
setmetatable(objective.position_value, mt)
function Vector3(x, y, z)
  return setmetatable({x = x, y = y, z = z}, mt)
end

BTBotUtility = {
  member = function()
    return member
  end,
  stop = function() end,
  set_movement = function() end,
  path_to = function() end,
  distance_to = function(subject, destination)
    return (destination - subject:position()):length()
  end
}
managers = {
  networkgame = {_carriables = {objective}}
}
TimerManager = {
  game = function()
    return {time = function() return 20 end}
  end
}

BTWanderAction = class()
BTFleeAction = class()
BTObjectiveAction = class()
dofile(ROOT .. "/lua/quick/win32/data/lib/ai/behavior_tree/actions/BTFleeAction.lua")
dofile(ROOT .. "/lua/quick/win32/data/lib/ai/behavior_tree/actions/BTObjectiveAction.lua")

-- RED: entering flee must release the attached package through the real
-- member/drop call, and it must retain a recoverable objective reference.
unit.data = {bot_objective = objective, bot_next_objective_scan = 0, bot_objective_cooldown_until = 0}
member.attached = objective
local flee = BTFleeAction:new()
flee:enter(unit, 20, 0.016)
check(base.drop_calls == 1, "flee entry did not drop the attached evidence")
check(objective.data.carriable_carrier == nil, "evidence remains assigned to the fleeing carrier")
check(unit.data.bot_delivering == false, "delivery flag was not cleared when fleeing")
check(unit.data.bot_objective == objective, "the dropped objective reference was not retained")

-- A safe scan must select the same unclaimed package through the existing
-- objective-selection logic after the threat clears.
unit.data.bot_objective_started_at = 20
BTObjectiveAction.scan(unit, 21)
check(unit.data.bot_objective == objective, "safe scan did not recover the dropped package")

-- A package claimed by another survivor must not remain targeted.
objective.data.carriable_carrier = {other_survivor = true}
BTObjectiveAction.scan(unit, 22)
check(unit.data.bot_objective == nil, "stale target remained selected after another survivor claimed it")

if #failures > 0 then
  for _, failure in ipairs(failures) do
    io.stderr:write("FAIL: " .. failure .. "\n")
  end
  io.stderr:write(string.format("%d/%d checks failed\n", #failures, checks))
  os.exit(1)
end
print(string.format("PASS: %d evidence escape checks", checks))
