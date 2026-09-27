#!/usr/bin/env python3
"""dev_compile.py - compile edited Lua sources into the dev tree the engine reads.

Walks lua/<tree>/<platform>/<path>.lua (tree = fcl|quick, platform = win32)
and writes devroot/compiled/win32_fcl/<path>.luc via tools/float32luac.py
(the dev tree is the merged quick tree + FCL overlay — the two source trees
have zero path collisions, verified 2026-09-26). Stock Lua 5.1 loop encoding,
snum=4 float32 constants — verified identical to the depot files modulo
srcname/snum/f32, see docs/11-dev-ready-plan.md "Phase 1 evidence".

Source-name rule (verified 2026-09-26 against all 1,026 depot .luc files and
the existing devroot .luc files): the depot's srcname is the path RELATIVE TO
THE win32 PLATFORM ROOT, with backslashes, keeping the .lua extension, e.g.
'data\\lib\\managers\\menu\\MenuServerInformationSteam.lua'. If a source has a
compiled counterpart in devroot (or luc/), we mirror the stored srcname of the
existing .luc verbatim; otherwise we derive it from the tree-relative path.
(The engine reports these names in runtime errors; the existing devroot files
all carry exactly this shape, so mirroring keeps the trees consistent.)

Usage:
  dev_compile.py --all                 # compile every lua/ file
  dev_compile.py --changed --file LIST # compile the listed files (one path
                                       # per line, project-relative or absolute)
  dev_compile.py --changed             # read the file list from stdin

Strict rule: never overwrite
devroot/compiled/win32_fcl/data/lib/managers/menu/MenuControllerBindNode.luc
(it carries the patch_mcbn.py nil-guard patch); it is skipped with a note.
Exit 0 iff no file failed.
"""
import argparse
import importlib.util
import os
import subprocess
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TOOL = os.path.join(ROOT, "tools", "float32luac.py")
LUA_ROOT = os.path.join(ROOT, "lua")
DEVROOT = os.path.join(ROOT, "devroot", "compiled", "win32_fcl")
LUC_ROOT = os.path.join(ROOT, "luc")

# lua/<platform>/<tree>/... -> <platform>/<tree> under lua/
PLATFORM = "win32"
TREES = ("fcl", "quick")

# path (relative to devroot/compiled/win32_fcl) of the never-overwrite file
MCBN = os.path.join("data", "lib", "managers", "menu", "MenuControllerBindNode.luc")

spec = importlib.util.spec_from_file_location("fl", TOOL)
fl = importlib.util.module_from_spec(spec)  # type: ignore[arg-type]
assert spec and spec.loader
spec.loader.exec_module(fl)


def srcname_for(tree, rel_path):
    """Determine the stored source name for lua/<tree>/<rel_path>.lua."""
    # 1) mirror the existing devroot .luc if present
    dev_luc = os.path.join(DEVROOT, rel_path + ".luc")
    if os.path.exists(dev_luc):
        try:
            return fl.parse_chunk(open(dev_luc, "rb").read())[0]
        except Exception:
            pass
    # 2) mirror the luc/ (depot-transformed) .luc if present
    luc = os.path.join(LUC_ROOT, tree, PLATFORM, rel_path + ".luc")
    if os.path.exists(luc):
        try:
            return fl.parse_chunk(open(luc, "rb").read())[0]
        except Exception:
            pass
    # 3) derive: platform-root-relative, backslash, .lua kept
    return rel_path.replace("/", "\\") + ".lua"


def compile_one(lua_path, out_path, srcname):
    cmd = [sys.executable, TOOL, lua_path, out_path, "--srcname", srcname]
    p = subprocess.run(cmd, capture_output=True)
    if p.returncode != 0:
        return p.stderr.decode("latin-1", "replace").strip()
    data = open(out_path, "rb").read()
    try:
        fl.parse_chunk(data)  # hard re-parse; trailing-byte mismatch fails
    except Exception as e:
        return f"re-parse: {e}"
    return None


def gather_all():
    """Yield (lua_path, out_path) for every lua/<platform>/<tree>/<rel>.lua."""
    for tree in TREES:
        base = os.path.join(LUA_ROOT, tree, PLATFORM)
        for dirpath, _dirnames, filenames in os.walk(base):
            for fn in sorted(filenames):
                if not fn.endswith(".lua"):
                    continue
                full = os.path.join(dirpath, fn)
                rel = os.path.relpath(full, base)  # tree-relative, no platform
                if rel.endswith(".lua"):
                    rel = rel[:-4]
                yield full, os.path.join(DEVROOT, rel + ".luc")


def resolve_input(path):
    """Map a user-supplied path (project-relative or absolute) to
    (lua_path, out_path); None if it is not a known lua/ source."""
    p = path.strip()
    if not p:
        return None
    ap = os.path.abspath(p)
    if not os.path.isabs(p):
        ap2 = os.path.abspath(os.path.join(ROOT, p))
        if os.path.exists(ap2):
            ap = ap2
    if not os.path.exists(ap):
        return None
    rel_to_lua = os.path.relpath(ap, LUA_ROOT)
    parts = rel_to_lua.split(os.sep)
    # expected layout: lua/<tree>/<platform>/<rel>.lua
    if len(parts) < 3 or parts[0] not in TREES or parts[1] != PLATFORM:
        return None
    tree = parts[0]
    rel = os.sep.join(parts[2:])
    if rel.endswith(".lua"):
        rel = rel[:-4]
    cand = os.path.join(LUA_ROOT, tree, PLATFORM, rel + ".lua")
    if os.path.exists(cand):
        return cand, os.path.join(DEVROOT, rel + ".luc")
    return None


def run(inputs, all_mode):
    compiled = skipped = failed = 0
    skipped_list = []
    failed_list = []
    if all_mode:
        items = list(gather_all())
    else:
        items = []
        for inp in inputs:
            r = resolve_input(inp)
            if r is None:
                failed_list.append((inp, "not a lua/ source (expected lua/<tree>/win32/<path>.lua)"))
                continue
            items.append(r)

    for lua_path, out_path in items:
        rel_out = os.path.relpath(out_path, DEVROOT)
        if rel_out == MCBN:
            skipped += 1
            skipped_list.append(rel_out)
            print(f"SKIP {rel_out} (nil-guard patch — never overwritten)")
            continue
        tree = os.path.relpath(lua_path, LUA_ROOT).split(os.sep)[0]
        rel = os.path.relpath(lua_path, os.path.join(LUA_ROOT, tree, PLATFORM))
        if rel.endswith(".lua"):
            rel = rel[:-4]
        srcname = srcname_for(tree, rel)
        os.makedirs(os.path.dirname(out_path), exist_ok=True)
        err = compile_one(lua_path, out_path, srcname)
        if err:
            failed += 1
            failed_list.append((os.path.relpath(lua_path, ROOT), err))
            print(f"FAIL {os.path.relpath(lua_path, ROOT)}: {err}")
        else:
            compiled += 1
    return compiled, skipped, failed, skipped_list, failed_list


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    mode = ap.add_mutually_exclusive_group(required=True)
    mode.add_argument("--all", action="store_true", help="compile every lua/ file")
    mode.add_argument("--changed", action="store_true", help="compile the listed files")
    ap.add_argument("--file", help="file with the changed-file list (one per line); default: stdin")
    args = ap.parse_args()

    inputs = []
    if args.changed:
        if args.file:
            with open(args.file) as f:
                inputs = [ln for ln in (l.strip() for l in f) if ln and not ln.startswith("#")]
        else:
            inputs = [ln.strip() for ln in sys.stdin if ln.strip() and not ln.strip().startswith("#")]

    compiled, skipped, failed, skipped_list, failed_list = run(inputs, args.all)
    print(f"\ncompiled={compiled} skipped={skipped} failed={failed}")
    for s in skipped_list:
        print(f"  skipped: {s}")
    for name, why in failed_list:
        print(f"  failed: {name}: {why}")
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
