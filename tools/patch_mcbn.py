#!/usr/bin/env python3
"""Patch MenuControllerBindNode.luc: replace GETTABLE btn['_btn_string'] with
LOADK '' at the two string.upper() call sites (lines 126 and 132) so
string.upper() never receives nil. Writes engine-native GRIN-layout output
(12-byte header + untransformed proto), ready to drop into the bundle.

Ported 2026-09-26 to the canonical project luc_stock.py API (typed consts,
parse_chunk/dec_op/enc_abc/Writer) so the whole toolchain shares one transformer.
"""
import sys, struct, os
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import luc_stock as L

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
SRC = os.path.join(ROOT, 'extracted', 'boot_fcl', 'boot', 'compiled', 'win32', 'data', 'lib', 'managers', 'menu', 'MenuControllerBindNode.luc')
DST = sys.argv[1] if len(sys.argv) > 1 else '/tmp/MenuControllerBindNode.patched.luc'

# 12-byte GRIN header (same layout parse_chunk validates)
GRIN_HEADER = b'\x1bLua' + bytes([0x51, 0, 1, 4, 4, 4, 4, 0])

def op(c):  return L.dec_op(c)[0]
def A(c):   return L.dec_op(c)[1]
def BX(c):  return L.dec_op(c)[4]

p = L.parse_chunk(open(SRC, 'rb').read())
target = p.protos[7]  # check_button_collision
consts = target.k

# sanity: this proto carries string + upper constants
assert any(v == 'string' for v in consts)
assert any(v == 'upper' for v in consts)

# find GETTABLE (op 6) reading K['_btn_string'] that feeds a 'string' GETGLOBAL (op 5)
sites = []
for j, c in enumerate(target.code):
    if op(c) == 6:
        _, a, b, cc, bx, sbx = L.dec_op(c)
        if cc >= 256 and consts[cc - 256] == '_btn_string':
            ctx = target.code[max(0, j - 4):j + 5]
            if any(op(ccc) == 5 and consts[dec[4]] == 'string' for ccc in ctx for dec in [L.dec_op(ccc)]):
                sites.append((j, c))
print('patch sites:', [(j, f'{c:08x}') for j, c in sites])
assert len(sites) == 2, f'expected 2 sites, found {len(sites)}'

# append an empty-string constant
consts.append('')
empty_idx = len(consts) - 1

for j, c in sites:
    a = A(c)
    target.code[j] = L.enc_abc(1, a, 0, 0) | (empty_idx << 14)  # LOADK A Bx

w = L.Writer()
L.write_proto(w, p)  # code untouched -> engine-native layout
blob = GRIN_HEADER + bytes(w.out)
open(DST, 'wb').write(blob)
print('wrote', DST, len(blob), 'bytes')

# round-trip verify
p2 = L.parse_chunk(open(DST, 'rb').read())
t2 = p2.protos[7]
for j, _ in sites:
    o2 = op(t2.code[j])
    bx2 = BX(t2.code[j])
    assert o2 == 1 and t2.k[bx2] == '', (j, o2, bx2)
print('verified: both sites now LOADK ""')
