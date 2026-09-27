#!/usr/bin/env python3
"""console_test.py — prove the ConsoleServer REPL: launch a boot, connect to
port 20249, send commands, dump every server response with raw hex.

Modes:
  loose     - bare-wine devroot loose boot (the dev tree)
  bundled   - bare-wine game/ bundled boot (stable ~90s, the reliable window)

Exits 0 if at least one well-formed server response frame was received.
"""
import os, socket, struct, subprocess, sys, time

ROOT = "/home/elijah/projects/scream-prototype"
EXE = os.path.join(ROOT, "game/scream_win32_public_dev.exe")
PREFIX = os.path.expanduser("~/.wine-scream")
PORT = 20249

MODE = sys.argv[1] if len(sys.argv) > 1 else "loose"
if MODE == "loose":
    cwd = os.path.join(ROOT, "devroot")
    args = ["-d", ".", "-o", "context.xml", "-s", "-fl_boot"]
else:
    cwd = os.path.join(ROOT, "game")
    args = ["-s"]

env = dict(os.environ, DISPLAY=":0", WINEPREFIX=PREFIX, WINEDEBUG="-all,fixme")

subprocess.run(["pkill", "-f", "scream_win32_public_de[v]"], capture_output=True)
time.sleep(1)

p = subprocess.Popen(
    ["wine", os.path.relpath(EXE, cwd)] + args,
    cwd=cwd, env=env,
    stdout=open("/tmp/cons_stdout.log", "wb"), stderr=subprocess.STDOUT)

def frame(level: bytes, text: bytes) -> bytes:
    """dsl::ConsoleIOPort nibble chunk: 8B header (u32 type + u32 expected)
    + u32 len + level + u32 len + text (little-endian, see dslConsole)."""
    payload = struct.pack("<I", len(level)) + level + struct.pack("<I", len(text)) + text
    return struct.pack("<II", 0, len(payload)) + payload   # type=TEXT, len field

def main():
    s = None
    deadline = time.time() + 25
    while time.time() < deadline and p.poll() is None:
        try:
            s = socket.create_connection(("127.0.0.1", PORT), timeout=1)
            break
        except OSError:
            time.sleep(0.3)
    if s is None:
        print(f"FAIL: no port 20249 in 25s (engine alive={p.poll() is None})")
        p.kill(); return 2
    s.settimeout(3)
    print(f"connected at t={time.time()-t0:.1f}s", flush=True)

    got = 0
    cmds = ["counters", "stats", "toggle_console_output"]
    for cmd in cmds:
        data = cmd.encode()
        pkt = struct.pack("<III", 1, len(data) + 4, len(data)) + data
        s.sendall(pkt)
        print(f"sent: {cmd!r}", flush=True)
        time.sleep(0.5)

    # drain: 30s. The engine starts its console connection window late (t≈20s);
    # resend the commands at t=22s so they land after the engine is ready.
    end = time.time() + 30
    raw = b""
    resent = False
    while time.time() < end:
        try:
            chunk = s.recv(65536)
        except socket.timeout:
            chunk = b""
        if not chunk:
            break
        raw += chunk
        if not resent and time.time() - t0 > 22:
            for c in cmds:
                data = c.encode()
                s.sendall(struct.pack("<III", 1, len(data) + 4, len(data)) + data)
                print(f"resent: {c!r}", flush=True)
            resent = True

    with open("/tmp/console_raw.bin", "wb") as f:
        f.write(raw)

    s.close()
    p.terminate()
    try: p.wait(timeout=5)
    except subprocess.TimeoutExpired: p.kill()

    print(f"\n=== raw server bytes: {len(raw)} ===")
    print(raw.hex()[:600])

    # parse frames: 8-byte header (u32 type + u32 payload_len, BIG-ENDIAN),
    # payload = (u32 len, level, u32 len, msg), big-endian lengths.
    off = 0
    frames = []
    while off + 8 <= len(raw):
        t, plen = struct.unpack_from(">II", raw, off)
        if plen > 65536: break
        off += 8
        end = off + plen
        if end > len(raw): break
        i = off
        ln = struct.unpack_from(">I", raw, i)[0]; i += 4
        lvl = raw[i:i+ln].decode("utf8", "replace"); i += ln
        ln2 = struct.unpack_from(">I", raw, i)[0]; i += 4
        text = raw[i:i+ln2].decode("utf8", "replace"); i += ln2
        if not (0 < ln <= 16 and 0 <= ln2 < 4096) or end - i != 0: break
        frames.append((t, lvl, text))
        off = end
    if frames:
        print(f"\n=== {len(frames)} parsed frame(s) ===")
        for t, lvl, txt in frames[:25]:
            print(f"[{lvl}] {txt[:200]}")
        print("\nVERDICT: CONSOLE REPL WORKING")
        return 0
    print("\nVERDICT: no parseable frames (raw hex above for manual read)")
    return 1

t0 = time.time()
sys.exit(main())
