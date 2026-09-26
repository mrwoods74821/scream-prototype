#!/usr/bin/env bash
# Scream Prototype — .luc bytecode pipeline.
#
# The engine ships GRIN-dialect .luc bytecode (Lua 5.1 with float32 constants
# and custom opcodes 38 TESTNIL / 39 TFORCALL). tools/luc_stock.py rewrites
# those into STOCK Lua 5.1 layout so standard tooling (unluac, luadec) can
# read them, and can write them back.
#
# Usage:
#   scripts/rebuild_luc.sh            # batch: luc/ (GRIN) -> /tmp/luc_stock/ (stock 5.1)
#   scripts/rebuild_luc.sh quick      # only the quick tree
#   scripts/rebuild_luc.sh fcl        # only the fcl tree
#
# To decompile a specific stock .luc:  java -jar tools/unluac.jar <file.luc>
#
# ROUND-TRIP NOTE (documented, not yet automated): the engine compiles .lua ->
# .luc with its own internal compiler at boot in loose-file mode
# (context.xml <compile scripts="true">). The shipped depot runs BUNDLED, so a
# modified script must be compiled to .luc and the bundle repacked, or the
# loose-file devroot path used. luc_stock.py's GRIN->stock direction is proven
# 1026/1026; the stock->GRIN direction (needed to hand a modified file back to
# the engine in GRIN dialect) is implemented in luc_stock.py's transform inverse
# but should be validated against a known-pair before shipping a patched .luc.
set -euo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TREE="${1:-all}"
OUT="${OUTDIR:-/tmp/luc_stock}"
case "$TREE" in
  quick) SRC="$ROOT/luc/quick"; DST="$OUT/quick" ;;
  fcl)   SRC="$ROOT/luc/fcl";   DST="$OUT/fcl" ;;
  all)   SRC="$ROOT/luc";       DST="$OUT" ;;
  *) echo "usage: $0 [all|quick|fcl]"; exit 1 ;;
esac
mkdir -p "$DST"
python3 "$ROOT/tools/luc_stock.py" batch "$SRC" "$DST"
echo "stock 5.1 bytecode written to $DST"
