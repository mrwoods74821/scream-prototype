require("ai/behavior_tree/BTBrain")
require("ai/behavior_tree/BTNode")
require("ai/behavior_tree/BTConditions")
require("ai/behavior_tree/BTSelector")
require("ai/behavior_tree/BTRandomSelector")
require("ai/behavior_tree/actions/BTUtilityFunctions")
require("ai/behavior_tree/actions/BTMoveAction")
require("ai/behavior_tree/actions/BTIdleAction")
require("ai/behavior_tree/actions/BTShootAction")
require("ai/behavior_tree/actions/BTShootAdvanceAction")
require("ai/behavior_tree/actions/BTShootCircleAction")
require("ai/behavior_tree/actions/BTApproachAction")
require("ai/behavior_tree/actions/BTApproachWalkAction")
require("ai/behavior_tree/actions/BTKnockedOutAction")
require("ai/behavior_tree/actions/BTReturnAction")
require("ai/behavior_tree/actions/BTGuardAction")
require("ai/behavior_tree/actions/BTPopBrainAction")
require("ai/behavior_tree/actions/BTPushBrainAction")
require("ai/behavior_tree/actions/BTEvadeAction")
require("ai/behavior_tree/actions/BTTrappedAction")
require("ai/behavior_tree/actions/BTReviveAction")
require("ai/behavior_tree/actions/BTBotUtility")
require("ai/behavior_tree/actions/BTWanderAction")
require("ai/behavior_tree/actions/BTFleeAction")
require("ai/behavior_tree/actions/BTObjectiveAction")
require("ai/behavior_tree/actions/BTStalkAction")
require("ai/behavior_tree/actions/BTExecuteAction")
require("ai/behavior_tree/actions/BTHuntAction")
BehaviorTreeAux = BehaviorTreeAux or {}
BehaviorTree = BehaviorTree or class()
BehaviorTree._types = {
  Selector = BTSelector,
  RandomSelector = BTRandomSelector,
  BTMoveAction = BTMoveAction,
  BTShootAction = BTShootAction,
  BTShootAdvanceAction = BTShootAdvanceAction,
  BTShootCircleAction = BTShootCircleAction,
  BTApproachAction = BTApproachAction,
  BTApproachWalkAction = BTApproachWalkAction,
  BTIdleAction = BTIdleAction,
  BTKnockedOutAction = BTKnockedOutAction,
  BTReturnAction = BTReturnAction,
  BTGuardAction = BTGuardAction,
  BTPopBrainAction = BTPopBrainAction,
  BTPushBrainAction = BTPushBrainAction,
  BTEvadeAction = BTEvadeAction,
  BTTrappedAction = BTTrappedAction,
  BTReviveAction = BTReviveAction,
  BTWanderAction = BTWanderAction,
  BTFleeAction = BTFleeAction,
  BTObjectiveAction = BTObjectiveAction,
  BTStalkAction = BTStalkAction,
  BTExecuteAction = BTExecuteAction,
  BTHuntAction = BTHuntAction
}
function BehaviorTree:init(tree_node)
  self._root = nil
  self:parse_tree(tree_node)
end
function BehaviorTree:root()
  return self._root
end
function BehaviorTree:name()
  return self._name
end
function BehaviorTree:parse_tree(tree_node)
  local root_node = tree_node:child(0)
  local root_type = tree_node:child(0):name()
  self._name = tree_node:child(0):parameter_map().name
  assert(self._name and "Behavior Tree root selector needs a name")
  self._root = BehaviorTreeAux.create_btnode_from_xmlnode(root_node)
  self:parse_node(root_node, self._root)
end
function BehaviorTree:parse_node(XMLnode, parent)
  for child in XMLnode:children() do
    local bt_node = BehaviorTreeAux.create_btnode_from_xmlnode(child, parent)
    if parent then
      parent:add_child(bt_node)
    end
    self:parse_node(child, bt_node)
  end
end
function BehaviorTreeAux.create_btnode_from_xmlnode(xmlnode, parent_btnode)
  local class_name = xmlnode:parameter_map().type or xmlnode:name()
  local identifier = xmlnode:parameter_map().name or xmlnode:parameter_map().id or "no_id"
  local condition_name = xmlnode:parameter_map().condition or "always_true"
  local hook_name = xmlnode:parameter_map().hook
  return BehaviorTreeAux.create_node(class_name, parent_btnode, condition_name, hook_name, identifier)
end
function BehaviorTreeAux.create_node(class_name, parent, condition_name, hook_name, identifier)
  local class_type = BehaviorTree._types[class_name]
  if not class_type then
    assert(false, "[BehaviorTreeAux.create_node( ... )] No class registered named(" .. class_name .. ")")
  else
    return class_type:new(identifier, parent, condition_name, hook_name, identifier)
  end
end
