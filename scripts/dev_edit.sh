#!/usr/bin/env bash
# dev_edit.sh — Scream Prototype dev-loop one-keystroke helper (Task 4.3, 2026-09-26)
#
# Compile a decompiled Lua source back into the loose dev tree, and (by
# default) immediately boot the dev tree so the change is visible.
#
#   dev_edit.sh <path>            compile <path> then boot (default)
#   dev_edit.sh --compile <path>  compile only, no boot
#   dev_edit.sh --boot            boot only (uses whatever is in the tree)
#   dev_edit.sh --path <p> --boot # explicit path + boot
#
# <path> is a decompiled source: either a repo-relative path like
#   lua/fcl/win32/data/lib/managers/menu/MenuTitleScreenNode.lua
# or just a file name (resolved against the lua/ tree, first match wins).
#
# The compiled .luc lands at devroot/compiled/win32_fcl/<data|core>/<subpath>.luc
# with the engine-expected depot srcname. Data XMLs (gametypes, unit xml,
# xmb, ...) are NOT compiled — edit them in devroot directly and use --boot.
#
# The boot step is delegated to scripts/launch_dev.sh (Task 4.3 keeps this
# file free of launch flags; that script is the single source of truth for
# how the dev tree boots).

set -uo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

COMPILER=tools/float32luac.py
DEVROOT=devroot/compiled/win32_fcl
LAUNCHER=scripts/launch_dev.sh

usage() { sed -n '2,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 1; }
[ $# -ge 1 ] || usage

MODE="compile+boot"
PATHARG=""
while [ $# -ge 1 ]; do
  case "$1" in
    --compile) MODE="compile"; shift ;;
    --boot)    MODE="boot";    shift ;;
    --path)    PATHARG="$2"; shift 2 ;;
    -h|--help) usage ;;
    *)         PATHARG="$1"; shift ;;
  esac
done

# --- resolve the lua source + its dev-tree target --------------------------
# (resolution + target derivation live in do_compile)

# The depot srcname for a data/ script is "data\lib\..." (backslashes, no
# drive letter, relative to the tree root). core/ scripts use "core\...".
make_srcname() {
  local rel="$1"   # e.g. data/lib/managers/menu/MenuTitleScreenNode.lua
  printf '%s' "$rel" | tr '/' '\\'
}

# derive the tree-relative subpath (data/lib/.../X.lua) from a repo lua/ path
subpath_of() {
  local rest="${1#lua/}" plat
  rest="${rest#*/}"      # drop the platform (fcl)
  rest="${rest#*/}"      # drop the tree (win32)
  printf '%s' "$rest"
}

do_compile() {
  local SRC SUB TARGET SRCNAME
  # resolve the source (repo-relative or bare filename)
  if [ -n "$PATHARG" ] && [ -f "$PATHARG" ]; then
    SRC="$PATHARG"
  elif [ -n "$PATHARG" ]; then
    SRC="$(find lua -name "$(basename "$PATHARG")" 2>/dev/null | head -1)"
    [ -n "$SRC" ] || { echo "no lua source matching '$PATHARG'" >&2; return 1; }
  else
    echo "no path given" >&2; return 1
  fi
  SUB="$(subpath_of "$SRC")"                       # data/lib/.../X.lua
  TARGET="$DEVROOT/${SUB%.lua}.luc"               # data/lib/.../X.luc
  SRCNAME="$(make_srcname "$SUB")"
  echo "[dev_edit] $SRC -> $TARGET (srcname=$SRCNAME)"
  python3 "$COMPILER" "$SRC" "$TARGET" --srcname "$SRCNAME" || return 1
}

do_boot() {
  if [ -x "$LAUNCHER" ] || [ -f "$LAUNCHER" ]; then
    echo "[dev_edit] delegating boot -> $LAUNCHER"
    "$LAUNCHER"
  else
    echo "[dev_edit] $LAUNCHER not present yet (launch path being built) — boot skipped."
  fi
}

case "$MODE" in
  compile)      do_compile ;;
  boot)         do_boot ;;
  compile+boot) do_compile && do_boot ;;
esac
