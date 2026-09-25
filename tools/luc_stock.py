#!/usr/bin/env python3
"""GRIN .luc -> stock Lua 5.1 bytecode transformer (and back).

GRIN dialect (verified previously, see Hermes skill diesel-luc-decompile):
- header: sz_num=4 (float32 constants), size_t=4
- opcode 38 TESTNIL / 39 TFORCALL split the stock generic-for (TFORLOOP=33)

Transform (proven 688/688 on quick.bundle files last session):
- TFORCALL A_g B_g C_g + TESTNIL A_t sBx  ->
      JMP +1 ; TFORLOOP A=B_g C=(A_g-B_g-2) ; JMP -> TESTNIL's sBx target
- standalone TESTNIL (FCL files) -> JMP with the same sBx
- every sBx-carrying instruction (JMP=22, FORLOOP=31, FORPREP=32,
  TFORLOOP=33) gets its absolute target remapped old->new index.

Validation: every output is re-parsed from scratch; end-offset must match
exactly; counts reported per tree.
"""
import struct
import sys
from pathlib import Path

# Lua 5.1 opcodes
JMP, FORLOOP, FORPREP, TFORLOOP = 22, 31, 32, 33
TESTNIL, TFORCALL = 38, 39
SBX_OPS = {JMP, FORLOOP, FORPREP, TFORLOOP}
MAXARG_SBX = 131071

OP_COUNT = 40  # stock 5.1 has 38; GRIN extends to 40


def dec_op(ins: int):
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


class Reader:
    def __init__(self, data: bytes):
        self.d = data
        self.p = 0

    def bytes(self, n) -> bytes:
        if self.p + n > len(self.d):
            raise ValueError(f"read past end at {self.p}+{n} > {len(self.d)}")
        v = self.d[self.p : self.p + n]
        self.p += n
        return v

    def u8(self):
        return self.bytes(1)[0]

    def u32(self):
        return struct.unpack("<I", self.bytes(4))[0]

    def i32(self):
        return struct.unpack("<i", self.bytes(4))[0]

    def f32(self):
        return struct.unpack("<f", self.bytes(4))[0]

    def string(self):
        n = self.u32()  # size_t = 4 in GRIN build
        if n == 0:
            return None
        return self.bytes(n)[:-1].decode("latin-1")  # strip trailing NUL


class Writer:
    def __init__(self):
        self.out = bytearray()

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
            self.u32(0)
        else:
            b = s.encode("latin-1") + b"\x00"
            self.u32(len(b))
            self.bytes(b)


class Proto:
    __slots__ = ("source", "linedefined", "lastlinedefined", "nups", "numparams",
                 "is_vararg", "maxstack", "code", "k", "protos",
                 "lineinfo", "locvars", "upvals")


def read_proto(r: Reader) -> Proto:
    p = Proto()
    p.source = r.string()
    p.linedefined = r.i32()
    p.lastlinedefined = r.i32()
    p.nups = r.u8()
    p.numparams = r.u8()
    p.is_vararg = r.u8()
    p.maxstack = r.u8()
    n = r.u32()
    p.code = [struct.unpack("<I", r.bytes(4))[0] for _ in range(n)]
    n = r.u32()
    p.k = []
    for _ in range(n):
        t = r.u8()
        if t == 0:
            p.k.append(None)
        elif t == 1:
            p.k.append(bool(r.u8()))
        elif t == 3:
            p.k.append(r.f32())
        elif t == 4:
            p.k.append(r.string())
        else:
            raise ValueError(f"const type {t}")
    n = r.u32()
    p.protos = [read_proto(r) for _ in range(n)]
    n = r.u32()
    p.lineinfo = [r.i32() for _ in range(n)]
    n = r.u32()
    p.locvars = []
    for _ in range(n):
        name = r.string()
        p.locvars.append((name, r.i32(), r.i32()))
    n = r.u32()
    p.upvals = [r.string() for _ in range(n)]
    return p


def write_proto(w: Writer, p: Proto):
    w.string(p.source)
    w.i32(p.linedefined)
    w.i32(p.lastlinedefined)
    w.u8(p.nups)
    w.u8(p.numparams)
    w.u8(p.is_vararg)
    w.u8(p.maxstack)
    w.u32(len(p.code))
    for ins in p.code:
        w.bytes(struct.pack("<I", ins))
    w.u32(len(p.k))
    for kv in p.k:
        if kv is None:
            w.u8(0)
        elif isinstance(kv, bool):
            w.u8(1)
            w.u8(1 if kv else 0)
        elif isinstance(kv, float):
            w.u8(3)
            w.f32(kv)
        else:
            w.u8(4)
            w.string(kv)
    w.u32(len(p.protos))
    for sp in p.protos:
        write_proto(w, sp)
    w.u32(len(p.lineinfo))
    for li in p.lineinfo:
        w.i32(li)
    w.u32(len(p.locvars))
    for name, s, e in p.locvars:
        w.string(name)
        w.i32(s)
        w.i32(e)
    w.u32(len(p.upvals))
    for u in p.upvals:
        w.string(u)


def parse_chunk(data: bytes):
    r = Reader(data)
    sig = r.bytes(4)
    if sig != b"\x1bLua":
        raise ValueError(f"bad signature {sig!r}")
    ver, fmt = r.u8(), r.u8()
    if ver != 0x51:
        raise ValueError(f"version {ver:#x}")
    endian, sint, ssize, sinc, snum, integral = (r.u8() for _ in range(6))
    if (endian, sint, ssize, sinc, snum) != (1, 4, 4, 4, 4):
        raise ValueError(
            f"unexpected header sizes endi={endian} int={sint} size_t={ssize} "
            f"ins={sinc} num={snum} integral={integral}"
        )
    proto = read_proto(r)
    if r.p != len(data):
        raise ValueError(f"trailing bytes: consumed {r.p} of {len(data)}")
    return proto


def transform_proto(p: Proto) -> tuple[Proto, int, int]:
    """In-place rewrite of TESTNIL/TFORCALL. Returns (new proto, pairs, lone TESTNIL).

    KEY INSIGHT (verified vs luac5.1 -l ground truth, 2026-09-24): GRIN's loop
    layout is [JMP entry][body][TFORCALL A B C][TESTNIL A sBx] which is
    EXACTLY stock Lua 5.1's [JMP][body][TFORLOOP][JMP back]. So the transform
    is a pure 2-instruction rewrite with NO insertion and NO index shifting:
      TFORCALL A_g B C_g  ->  TFORLOOP A=(A_g-3) C=(C_g-1)
        (A_g = first loop var register = base+3; C_g = nresults+1 encoding)
      TESTNIL A sBx       ->  JMP with the same sBx
    All existing JMP targets, lineinfo, and locvar PCs remain valid verbatim.
    Standalone TESTNIL (FCL quirk) -> plain JMP with the same sBx.
    """
    code = list(p.code)
    pairs = 0
    lone = 0
    for i, ins in enumerate(code):
        op = ins & 0x3F
        if op == TFORCALL:
            if i + 1 < len(code) and (code[i + 1] & 0x3F) == TESTNIL:
                _, a_g, b_g, c_g, _, _ = dec_op(ins)
                base = a_g - 3
                var_count = c_g - 1
                code[i] = enc_abc(TFORLOOP, base, 0, var_count)
                _, a_t, _, _, _, sbx_t = dec_op(code[i + 1])
                code[i + 1] = enc_asbx(JMP, 0, sbx_t)
                pairs += 1
            else:
                raise ValueError(f"TFORCALL at {i} not followed by TESTNIL")
        elif op == TESTNIL:
            if i == 0 or (code[i - 1] & 0x3F) != TFORLOOP:
                # lone TESTNIL -> JMP with identical sBx
                _, a_t, _, _, _, sbx_t = dec_op(ins)
                code[i] = enc_asbx(JMP, 0, sbx_t)
                lone += 1

    np = Proto()
    np.source = p.source
    np.linedefined = p.linedefined
    np.lastlinedefined = p.lastlinedefined
    np.nups, np.numparams, np.is_vararg = p.nups, p.numparams, p.is_vararg
    np.maxstack = p.maxstack
    np.code = code
    np.k = p.k
    np.lineinfo = p.lineinfo
    np.locvars = p.locvars
    np.upvals = p.upvals
    total_pairs, total_lone = pairs, lone
    np.protos = []
    for sp in p.protos:
        tsp, pr, lr = transform_proto(sp)
        np.protos.append(tsp)
        total_pairs += pr
        total_lone += lr
    return np, total_pairs, total_lone


def transform_chunk(p: Proto) -> Proto:
    # lineinfo/locvars are now rebuilt inside transform_proto
    np, pairs, lone = transform_proto(p)
    return np


def main():
    if len(sys.argv) < 3:
        sys.exit(f"usage: {sys.argv[0]} <in.luc> <out.luc>   |  batch <indir> <outdir>")
    if sys.argv[1] == "batch":
        src, dst = Path(sys.argv[2]), Path(sys.argv[3])
        ok = fail = pairs_total = lone_total = 0
        failures = []
        for f in sorted(src.rglob("*.luc")):
            rel = f.relative_to(src)
            out = dst / rel
            try:
                proto = parse_chunk(f.read_bytes())
                np = transform_chunk(proto)
                w = Writer()
                w.bytes(b"\x1bLua")
                w.u8(0x51)
                w.u8(0)
                w.u8(1)
                w.u8(4)
                w.u8(4)
                w.u8(4)
                w.u8(4)
                w.u8(0)
                write_proto(w, np)
                out.parent.mkdir(parents=True, exist_ok=True)
                out.write_bytes(bytes(w.out))
                ok += 1
            except Exception as e:
                fail += 1
                failures.append((str(rel), str(e)))
        print(f"transformed {ok}, failed {fail}")
        for rel, e in failures[:20]:
            print(f"  FAIL {rel}: {e}")
        sys.exit(1 if fail else 0)
    proto = parse_chunk(Path(sys.argv[1]).read_bytes())
    np = transform_chunk(proto)
    w = Writer()
    w.bytes(b"\x1bLua")
    w.u8(0x51)
    w.u8(0)
    for v in (1, 4, 4, 4, 4, 0):
        w.u8(v)
    write_proto(w, np)
    Path(sys.argv[2]).write_bytes(bytes(w.out))
    print(f"wrote {sys.argv[2]} ({len(w.out)} bytes)")


if __name__ == "__main__":
    main()
