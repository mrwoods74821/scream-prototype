#!/usr/bin/env python3
"""Compile and deploy the Scream bot feature into the loose dev boot.

The bundled game/ directory is not used for new XML unit definitions. Launch
PROTON=1 scripts/launch_dev.sh so the engine compiles db_fcl and config XML.
"""
from pathlib import Path
import subprocess
import shutil
import sys

ROOT = Path(__file__).resolve().parents[1]
SOURCES = [
    "lua/fcl/win32/data/lib/units/data/AiData.lua",
    "lua/fcl/win32/data/lib/TweakData.lua",
    "lua/fcl/win32/data/lib/network/NetworkGameManager.lua",
    "lua/fcl/win32/data/lib/network/gamemodes/Gametype.lua",
    "lua/quick/win32/data/lib/ai/behavior_tree/BehaviorTree.lua",
    "lua/quick/win32/data/lib/ai/behavior_tree/BTConditions.lua",
    "lua/quick/win32/data/lib/ai/behavior_tree/BrainManager.lua",
    "lua/quick/win32/data/lib/ai/behavior_tree/actions/BTBotUtility.lua",
    "lua/quick/win32/data/lib/ai/behavior_tree/actions/BTWanderAction.lua",
    "lua/quick/win32/data/lib/ai/behavior_tree/actions/BTFleeAction.lua",
    "lua/quick/win32/data/lib/ai/behavior_tree/actions/BTObjectiveAction.lua",
    "lua/quick/win32/data/lib/ai/behavior_tree/actions/BTStalkAction.lua",
    "lua/quick/win32/data/lib/ai/behavior_tree/actions/BTExecuteAction.lua",
    "lua/quick/win32/data/lib/ai/behavior_tree/actions/BTHuntAction.lua",
    "lua/quick/win32/data/lib/managers/BotManager.lua",
    "lua/quick/win32/data/lib/setups/Setup.lua",
    "lua/quick/win32/data/lib/units/mp/npc/MPNpc.lua",
    "lua/quick/win32/data/lib/units/mp/npc/MPNpcStates.lua",
]

compile_result = subprocess.run(
    [sys.executable, str(ROOT / "tools/dev_compile.py"), "--changed"],
    cwd=ROOT,
    input="\n".join(SOURCES) + "\n",
    text=True,
    capture_output=True,
)
print(compile_result.stdout, end="")
print(compile_result.stderr, end="", file=sys.stderr)
if compile_result.returncode:
    raise SystemExit(compile_result.returncode)

for source in SOURCES:
    relative = source.split("/win32/", 1)[1]
    compiled = ROOT / "devroot/compiled/win32_fcl" / Path(relative).with_suffix(".luc")
    deployed = ROOT / "devroot/compiled/win32_fcl" / Path(relative).with_suffix(".luc")
    if not compiled.is_file():
        raise SystemExit(f"Missing compiler output: {compiled}")
    if compiled.resolve() != deployed.resolve():
        shutil.copy2(compiled, deployed)

for name in ("survivor", "ghostface"):
    source = ROOT / f"lua/quick/win32/data/lib/ai/beings/npc/{name}.xml"
    for target in (
        ROOT / f"devroot/config/data/lib/ai/beings/npc/{name}.xml",
        ROOT / f"devroot/compiled/win32_fcl/data/lib/ai/beings/npc/{name}.xml",
    ):
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(source, target)

source = ROOT / "lua/quick/win32/db/unit/m/mp_npc_ghostface.xml"
for target in (
    ROOT / "devroot/config/db/unit/m/mp_npc_ghostface.xml",
    ROOT / "devroot/db_fcl/unit/m/mp_npc_ghostface.xml",
):
    target.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(source, target)
print("Bot sources compiled and deployed. Use PROTON=1 scripts/launch_dev.sh.")
