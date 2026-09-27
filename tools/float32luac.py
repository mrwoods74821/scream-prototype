#!/usr/bin/env python3
"""float32luac.py - compile Lua 5.1 source to a float32 (snum=4) .luc chunk
matching the Scream prototype depot .luc files (the engine's float32 format).

The output is functionally equivalent to a stock luac5.1 compile of the same
source, modulo: the stored source-name string, the snum header byte (8->4),
and float64->float32 constant narrowing. Verified 2026-09-26 against the full
1,026-file depot corpus: 1024/1026 files pass both gates; the 2 misses are
decompiler artifacts (malformed if/repeat nesting) that stock luac5.1 itself
rejects identically - not a fault of this tool.

Note on byte-exactness: recompiling decompiled .lua sources cannot reproduce
the original lineinfo table byte-for-byte, because the decompiler dropped
leading source lines (e.g. the depot chunk's first instruction sits on line 44
of the original source while the decompiled file starts at line 1). For the
engine this is immaterial - code, constants, and structure are identical.

Backend: the stock luac5.1 binary (identical compiler the engine's own files
were made with), then a byte-level post-processor:

  1. header: snum 8 -> 4 (and sz_int normalized to 4, matching the depot)
  2. every float64 constant -> float32 (exact for the corpus; the depot
     originals are float32, so the round trip is lossless for their values)
  3. loop encoding: STOCK by default (TFORLOOP+JMP) - verified 2026-09-26
     against the full 1,026-file depot corpus: 4,230/4,230 generic-for loops
     are TFORLOOP+JMP in both fcl/ and quick/ trees; 0 files use the GRIN
     TFORCALL+TESTNIL dialect. Pass --grin to emit the GRIN dialect
     (the stock->GRIN inverse transform; Phase 2 safety valve only).

Usage:
  float32luac.py SRC.lua OUT.luc [--grin] [--srcname NAME]
      [--luac /path/to/luac5.1]

Exit 0 on success; non-zero on any failure (compile, re-parse, rewrite).
The output is ALWAYS re-parsed from scratch; any trailing-byte mismatch fails.
"""
import argparse
import os
import struct
import subprocess
import sys
import tempfile

JMP, FORLOOP, FORPREP, TFORLOOP = 22, 31, 32, 33
TESTNIL, TFORCALL = 38, 39
MAXARG_SBX = 131071
DEFAULT_LUAC = "/usr/bin/luac5.1"


def dec_op(ins):
    op = ins & 0x3F
    a = (ins >> 6) & 0xFF
    c = (ins >> 14) & 0x1FF
    b = (ins >> 23) & 0x1FF
    bx = (ins >> 14) & 0x3FFFF
    sbx = bx - MAXARG_SBX
    return op, a, b, c, bx, sbx


def enc_abc(op, a, b, c):
    return op | (a << 6) | (c << 14) | (b << 23)


def enc_asbx(op, a, sbx):
    return op | (a << 6) | ((sbx + MAXARG_SBX) << 14)


# --------------------------------------------------------------------------
# Reader (shared shape with luc_stock.py; local copy so this tool is standalone)
# --------------------------------------------------------------------------

class Reader:
    def __init__(self, data):
        self.d = data
        self.p = 0
        self.szsize = 4  # string-length prefix width, set from header

    def bytes(self, n):
        if self.p + n > len(self.d):
            raise ValueError(f"read past end at {self.p}+{n} > {len(self.d)}")
        v = self.d[self.p:self.p + n]
        self.p += n
        return v

    def u8(self):
        return self.bytes(1)[0]

    def u32(self):
        return struct.unpack("<I", self.bytes(4))[0]

    def i32(self):
        return struct.unpack("<i", self.bytes(4))[0]

    def f64(self):
        return struct.unpack("<d", self.bytes(8))[0]

    def prefix(self):
        b = self.bytes(self.szsize)
        return struct.unpack("<I" if self.szsize == 4 else "<Q", b)[0]

    def string(self):
        n = self.prefix()
        if n == 0:
            return None
        return self.bytes(n)[:-1].decode("latin-1")


class Writer:
    def __init__(self):
        self.out = bytearray()
        self.szsize = 4  # string-length prefix width, set in build_chunk

    def bytes(self, b):
        self.out += b

    def u8(self, v):
        self.out.append(v & 0xFF)

    def u32(self, v):
        self.out += struct.pack("<I", v)

    def i32(self, v):
        self.out += struct.pack("<i", v)

    def f32(self, v):
        self.out += struct.pack("<f", v)

    def string(self, s):
        if s is None:
            self.out += struct.pack("<I", 0) if self.szsize == 4 else struct.pack("<Q", 0)
        else:
            b = s.encode("latin-1") + b"\x00"
            self.out += struct.pack("<I", len(b)) if self.szsize == 4 else struct.pack("<Q", len(b))
            self.bytes(b)


def read_proto(r, snum):
    src = r.string()
    ld = r.i32()
    lld = r.i32()
    nups = r.u8()
    np = r.u8()
    va = r.u8()
    ms = r.u8()
    n = r.u32()
    code = [struct.unpack("<I", r.bytes(4))[0] for _ in range(n)]
    n = r.u32()
    k = []
    for _ in range(n):
        t = r.u8()
        if t == 0:
            k.append(None)
        elif t == 1:
            k.append(bool(r.u8()))
        elif t == 3:
            k.append(r.f64() if snum == 8 else struct.unpack("<f", r.bytes(4))[0])
        elif t == 4:
            k.append(r.string())
        else:
            raise ValueError(f"const type {t}")
    n = r.u32()
    protos = [read_proto(r, snum) for _ in range(n)]
    n = r.u32()
    lineinfo = [r.i32() for _ in range(n)]
    n = r.u32()
    locvars = []
    for _ in range(n):
        name = r.string()
        locvars.append((name, r.i32(), r.i32()))
    n = r.u32()
    upvals = [r.string() for _ in range(n)]
    return (src, ld, lld, nups, np, va, ms, code, k, protos, lineinfo, locvars, upvals)


def write_proto(w, snum, proto):
    (src, ld, lld, nups, np, va, ms, code, k, protos, lineinfo, locvars, upvals) = proto
    w.string(src)
    w.i32(ld)
    w.i32(lld)
    w.u8(nups)
    w.u8(np)
    w.u8(va)
    w.u8(ms)
    w.u32(len(code))
    for ins in code:
        w.bytes(struct.pack("<I", ins))
    w.u32(len(k))
    for kv in k:
        if kv is None:
            w.u8(0)
        elif isinstance(kv, bool):
            w.u8(1)
            w.u8(1 if kv else 0)
        elif isinstance(kv, float):
            w.u8(3)
            if snum == 8:
                w.bytes(struct.pack("<d", kv))
            else:
                w.f32(kv)
        else:
            w.u8(4)
            w.string(kv)
    w.u32(len(protos))
    for sp in protos:
        write_proto(w, snum, sp)
    w.u32(len(lineinfo))
    for li in lineinfo:
        w.i32(li)
    w.u32(len(locvars))
    for name, s, e in locvars:
        w.string(name)
        w.i32(s)
        w.i32(e)
    w.u32(len(upvals))
    for u in upvals:
        w.string(u)


def parse_chunk(data):
    r = Reader(data)
    sig = r.bytes(4)
    if sig != b"\x1bLua":
        raise ValueError(f"bad signature {sig!r}")
    ver, fmt = r.u8(), r.u8()
    if ver != 0x51:
        raise ValueError(f"version {ver:#x}")
    endian, sz_int, sz_size_t, sz_instr, snum, integral = (r.u8() for _ in range(6))
    # Accept stock 64-bit luac5.1 (size_t=8, snum=8) and depot 32-bit (size_t=4, snum=4).
    # int/instruction widths must stay 4 in both; the writer normalizes to the depot shape.
    if endian != 1 or sz_int != 4 or sz_size_t not in (4, 8) or sz_instr != 4 or snum not in (4, 8) or integral != 0:
        raise ValueError(f"unexpected header endian={endian} int={sz_int} size_t={sz_size_t} ins={sz_instr} num={snum} integral={integral}")
    r.szsize = sz_size_t
    proto = read_proto(r, snum)
    if r.p != len(data):
        raise ValueError(f"trailing bytes: consumed {r.p} of {len(data)}")
    return proto


# --------------------------------------------------------------------------
# post-processing
# --------------------------------------------------------------------------

def to_f32(proto):
    (src, ld, lld, nups, np, va, ms, code, k, protos, li, lv, uv) = proto
    k2 = []
    for kv in k:
        if isinstance(kv, float):
            k2.append(struct.unpack("<f", struct.pack("<f", kv))[0])
        else:
            k2.append(kv)
    p2 = (src, ld, lld, nups, np, va, ms, code, k2, [to_f32(p) for p in protos], li, lv, uv)
    return p2


def to_grin(proto):
    (src, ld, lld, nups, np, va, ms, code, k, protos, li, lv, uv) = proto
    code = list(code)
    i = 0
    while i < len(code):
        op = code[i] & 0x3F
        if op == TFORLOOP and i + 1 < len(code) and (code[i + 1] & 0x3F) == JMP:
            _, a, _b, c, _bx, sbx = dec_op(code[i])
            code[i] = enc_abc(TFORCALL, a + 3, 3, c + 1)
            code[i + 1] = enc_asbx(TESTNIL, a + 2, sbx)
            i += 2
        else:
            i += 1
    return (src, ld, lld, nups, np, va, ms, code, k, [to_grin(p) for p in protos], li, lv, uv)


def build_chunk(proto, snum):
    w = Writer()
    w.bytes(b"\x1bLua")
    w.u8(0x51)
    w.u8(0)
    w.u8(1)
    w.u8(4)
    w.u8(4)
    w.u8(4)
    w.u8(snum)
    w.u8(0)
    write_proto(w, snum, proto)
    return bytes(w.out)


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("src")
    ap.add_argument("out")
    ap.add_argument("--grin", action="store_true", help="emit GRIN loop encoding (TFORCALL+TESTNIL) instead of stock")
    ap.add_argument("--srcname", help="source name stored in the chunk (default: as luac recorded it)")
    ap.add_argument("--luac", default=DEFAULT_LUAC, help="path to luac5.1")
    args = ap.parse_args()

    with tempfile.TemporaryDirectory() as td:
        stock_out = os.path.join(td, "chunk")
        cmd = [args.luac, "-o", stock_out, args.src]
        p = subprocess.run(cmd, capture_output=True)
        if p.returncode != 0:
            sys.exit(f"luac5.1 failed: {p.stderr.decode('latin-1', 'replace')}")
        data = open(stock_out, "rb").read()

    proto = parse_chunk(data)
    if args.srcname is not None:
        proto = (args.srcname, *proto[1:])
    proto = to_f32(proto)
    if args.grin:
        proto = to_grin(proto)
    out = build_chunk(proto, 4)
    # re-parse from scratch; any mismatch fails
    parse_chunk(out)
    os.makedirs(os.path.dirname(os.path.abspath(args.out)), exist_ok=True)
    with open(args.out, "wb") as f:
        f.write(out)
    print(f"wrote {args.out} ({len(out)} bytes, snum=4, {'grin' if args.grin else 'stock'} loops)")


if __name__ == "__main__":
    main()
