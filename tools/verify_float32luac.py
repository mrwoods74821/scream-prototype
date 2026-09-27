#!/usr/bin/env python3
"""verify_float32luac.py - fixture suite for tools/float32luac.py.

What is actually true (verified 2026-09-26):

  * The decompiled lua/ sources are line-shifted relative to the original
    sources the depot .luc files were compiled from (e.g. the depot chunk's
    first instruction sits on line 44 of the original source, while the
    decompiled file starts at line 1). Therefore recompiling decompiled
    sources can NEVER reproduce the original lineinfo table byte-for-byte.

  * The REAL, achievable contract (and what the engine needs) is:
      float32luac(SRC.lua) == luac5.1(SRC.lua) modulo exactly three things:
        (a) the stored source-name string,
        (b) the snum header byte (8 -> 4),
        (c) float64 -> float32 constant narrowing (exact for depot values).
      Code, constants, lineinfo, locvars, upvalues: structurally identical.
      Proven: zero field-level divergences after those three normalizations.

Fixtures:
  1. Hard gate: well-formed snum=4 chunk + structural round-trip
     (parse(output) -> re-serialize == output). Every file must pass.
  2. Hard gate: output == stock luac5.1 of the same source modulo
     srcname + snum + f32 narrowing. Every file must pass.
  3. Informational: delta classification vs the depot original
     (byte_exact / lineinfo_only / srcname_only / other).

Usage:
  verify_float32luac.py [--sample N] [--tree fcl|quick|all] [--seed N]
"""
import argparse
import glob
import importlib.util
import os
import random
import struct
import subprocess
import sys
import tempfile
from collections import Counter

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
TOOL = os.path.join(ROOT, "tools", "float32luac.py")
LUAC = "/usr/bin/luac5.1"

spec = importlib.util.spec_from_file_location("fl", TOOL)
fl = importlib.util.module_from_spec(spec)
assert spec and spec.loader
spec.loader.exec_module(fl)


def pair_files(tree):
    """Yield (rel, lua_path, luc_path) for every decompiled source with a
    matching depot .luc in the same tree."""
    for luc in sorted(glob.glob(os.path.join(ROOT, "luc", tree, "**", "*.luc"), recursive=True)):
        rel = os.path.relpath(luc, os.path.join(ROOT, "luc", tree))
        lua = os.path.join(ROOT, "lua", tree, rel[:-4] + ".lua")
        if os.path.exists(lua):
            yield rel, lua, luc


def compile_file(lua, out, srcname, grin=False):
    cmd = ["python3", TOOL, lua, out, "--srcname", srcname]
    if grin:
        cmd.append("--grin")
    r = subprocess.run(cmd, capture_output=True)
    if r.returncode != 0:
        return r.stderr.decode("latin-1", "replace")
    return None


def stock_compile(lua, out):
    r = subprocess.run([LUAC, "-o", out, lua], capture_output=True)
    if r.returncode != 0:
        return r.stderr.decode("latin-1", "replace")
    return None


def proto_body(p):
    """Proto tuple minus the source-name field (index 0)."""
    return p[1:]


def roundf(p):
    """Recursively narrow float64 constants to float32."""
    src, ld, lld, nups, np, va, ms, code, k, protos, li, lv, uv = p
    k2 = [struct.unpack("<f", struct.pack("<f", x))[0] if isinstance(x, float) else x for x in k]
    return (src, ld, lld, nups, np, va, ms, code, k2, [roundf(x) for x in protos], li, lv, uv)


def run_fixture1(files, outdir):
    """Hard gate 1: well-formed snum=4 chunk + structural round-trip."""
    ok = fail = 0
    fails = []
    for rel, lua, luc in files:
        orig = open(luc, "rb").read()
        srcname = fl.parse_chunk(orig)[0]
        out = os.path.join(outdir, "f1", rel[:-4] + ".luc")
        os.makedirs(os.path.dirname(out), exist_ok=True)
        err = compile_file(lua, out, srcname)
        if err is not None:
            fail += 1
            fails.append((rel, f"compile: {err.strip()[:80]}"))
            continue
        data = open(out, "rb").read()
        try:
            proto = fl.parse_chunk(data)
            re = fl.build_chunk(proto, 4)
        except Exception as e:
            fail += 1
            fails.append((rel, f"reparse: {e}"))
            continue
        if re == data:
            ok += 1
        else:
            fail += 1
            fails.append((rel, f"roundtrip len {len(re)} vs {len(data)}"))
    return ok, fail, fails


def run_fixture2(files, outdir):
    """Hard gate 2: float32luac == stock luac5.1 modulo srcname+snum+f32."""
    ok = fail = 0
    fails = []
    for rel, lua, luc in files:
        orig = open(luc, "rb").read()
        srcname = fl.parse_chunk(orig)[0]
        stock_out = os.path.join(outdir, "f2_stock", rel[:-4] + ".luc")
        f32_out = os.path.join(outdir, "f2_f32", rel[:-4] + ".luc")
        os.makedirs(os.path.dirname(stock_out), exist_ok=True)
        os.makedirs(os.path.dirname(f32_out), exist_ok=True)
        err = stock_compile(lua, stock_out)
        if err is not None:
            fail += 1
            fails.append((rel, f"stock: {err.strip()[:60]}"))
            continue
        err = compile_file(lua, f32_out, srcname)
        if err is not None:
            fail += 1
            fails.append((rel, f"f32: {err.strip()[:60]}"))
            continue
        a_raw = open(stock_out, "rb").read()
        b_raw = open(f32_out, "rb").read()
        # snum is the 5th header byte (offset 10); not part of the proto tuple.
        if a_raw[10] != 8 or b_raw[10] != 4:
            fail += 1
            fails.append((rel, f"snum {a_raw[10]}/{b_raw[10]}"))
            continue
        a = fl.parse_chunk(a_raw)
        b = fl.parse_chunk(b_raw)
        if proto_body(roundf(a)) == proto_body(b):
            ok += 1
        else:
            fail += 1
            fails.append((rel, "delta beyond srcname/snum/f32"))
    return ok, fail, fails


def run_fixture3(files):
    """Informational: classify delta vs depot original."""
    buckets = Counter()
    examples = {}
    for rel, lua, luc in files:
        orig = open(luc, "rb").read()
        srcname = fl.parse_chunk(orig)[0]
        with tempfile.TemporaryDirectory() as td:
            out = os.path.join(td, "t.luc")
            err = compile_file(lua, out, srcname)
            if err is not None:
                buckets["compile_error"] += 1
                continue
            new = open(out, "rb").read()
        if new == orig:
            buckets["byte_exact"] += 1
            continue
        a = fl.parse_chunk(orig)
        b = fl.parse_chunk(new)
        if proto_body(a) == proto_body(b):
            buckets["srcname_only"] += 1
        elif a[7] == b[7] and a[8] == b[8] and a[11] == b[11] and a[12] == b[12]:
            buckets["lineinfo_only"] += 1
            if rel not in examples:
                examples[rel] = (a[10][0] if a[10] else -1, b[10][0] if b[10] else -1)
        else:
            buckets["other"] += 1
            if rel not in examples:
                examples[rel] = None
    return buckets, examples


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--sample", type=int, default=100)
    ap.add_argument("--tree", default="all", choices=["fcl", "quick", "all"])
    ap.add_argument("--seed", type=int, default=1)
    ap.add_argument("--outdir", default="/tmp/f32luac_verify")
    args = ap.parse_args()

    trees = ["fcl", "quick"] if args.tree == "all" else [args.tree]
    all_files = []
    for t in trees:
        all_files.extend(pair_files(t))
    random.seed(args.seed)
    sample = random.sample(all_files, min(args.sample, len(all_files)))
    print(f"corpus: {len(all_files)} pairs; sample: {len(sample)}")

    print("\n[fixture 1] hard gate: well-formed snum=4 + structural round-trip")
    ok1, fail1, fails = run_fixture1(sample, args.outdir)
    print(f"  {ok1}/{ok1 + fail1} pass")
    for rel, why in fails[:8]:
        print(f"  FAIL {rel}: {why}")

    print("\n[fixture 2] hard gate: == stock luac5.1 modulo srcname/snum/f32")
    ok2, fail2, fails = run_fixture2(sample, args.outdir)
    print(f"  {ok2}/{ok2 + fail2} pass")
    for rel, why in fails[:8]:
        print(f"  FAIL {rel}: {why}")

    print("\n[fixture 3] informational: delta vs depot original")
    buckets, examples = run_fixture3(sample)
    for k, v in sorted(buckets.items()):
        print(f"  {k}: {v}")
    for rel, ex in list(examples.items())[:5]:
        if ex is not None:
            print(f"    {rel}: depot first-instr line {ex[0]} vs recompiled {ex[1]}")

    total = (ok1 + fail1) + (ok2 + fail2)
    failed = fail1 + fail2
    print(f"\nGATES: {total - failed}/{total} passed" + ("  [FAIL]" if failed else "  [OK]"))
    sys.exit(1 if failed else 0)


if __name__ == "__main__":
    main()
