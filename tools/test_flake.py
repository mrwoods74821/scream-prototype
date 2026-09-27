#!/usr/bin/env python3
"""test_flake.py — test whether holding a console connection keeps the
engine alive past the 8-14s early-exit window, and whether 'go' releases
the console gate.

Procedure:
  1. launch engine (bare wine, devroot, -fl_boot)
  2. connect a TCP socket to 20249 as soon as it opens
  3. optionally send 'go' (EXECUTE_COMMAND)
  4. sample engine liveness every 2s for 30s
  5. report lifetime + crash.txt + last file opened
"""
import os, socket, struct, subprocess, sys, time

ROOT = "/home/elijah/projects/scream-prototype"
EXE = os.path.join(ROOT, "game/scream_win32_public_dev.exe")
DEV = os.path.join(ROOT, "devroot")
PREFIX = os.path.expanduser("~/.wine-scream")
PORT = 20249

MODE = sys.argv[1] if len(sys.argv) > 1 else "control"  # control | plain | go | touch
EXTRA = sys.argv[2:] if len(sys.argv) > 2 else []   # extra args, e.g. -wait 30

env = dict(os.environ, DISPLAY=":0", WINEPREFIX=PREFIX, WINEDEBUG="-all,fixme")

# preflight
subprocess.run(["pkill", "-f", "scream_win32_public_de[v]"], capture_output=True)
time.sleep(1)
for f in [os.path.join(ROOT, "game/crash.txt"), os.path.join(DEV, "_file_access_log.xml")]:
    if os.path.exists(f): os.remove(f)

p = subprocess.Popen(
    ["wine", EXE, "-d", ".", "-o", "context.xml", "-s", "-fl_boot"] + EXTRA,
    cwd=DEV, env=env,
    stdout=open("/tmp/flake_stdout.log", "wb"), stderr=subprocess.STDOUT)

def alive():
    return p.poll() is None

def connect_and_send(cmd=None, hold=True):
    deadline = time.time() + 20
    while time.time() < deadline:
        try:
            s = socket.create_connection(("127.0.0.1", PORT), timeout=2)
            if cmd:
                data = cmd.encode()
                s.sendall(struct.pack("<III", 1, len(data)+4, len(data)) + data)
                print(f"    sent: {cmd!r}", flush=True)
            time.sleep(0.5)
            return s if hold else None
        except OSError:
            if not alive():
                break
            time.sleep(0.3)
    return None

t0 = time.time()
print(f"mode={MODE} extra={EXTRA} engine started t=0", flush=True)
conn = None
events = []

# main loop: 30s of liveness sampling, connect at first chance
while time.time() - t0 < 30:
    t = int(time.time() - t0)
    if not alive():
        events.append(f"t={t} DIED")
        break
    if MODE in ("plain", "go") and conn is None:
        conn = connect_and_send(cmd="go" if MODE == "go" else None, hold=True)
        if conn:
            events.append(f"t={t} CONNECTED")
    if t % 5 == 0:
        portup = socket.socket().connect_ex(("127.0.0.1", PORT)) == 0
        events.append(f"t={t} alive port={portup}")
    if MODE == "touch":
        subprocess.run(["xdotool", "search", "--name", "Scream", "getwindowname", "%1"],
                       capture_output=True, timeout=3)
    time.sleep(1)

lifetime = time.time() - t0
print(f"engine lifetime: {lifetime:.1f}s (mode={MODE})")
for e in events:
    print("  " + e)

crash = ""
cf = os.path.join(ROOT, "game/crash.txt")
if os.path.exists(cf):
    crash = open(cf).readlines()[1].strip() if len(open(cf).readlines()) > 1 else "(empty)"
print(f"crash.txt: {crash or 'none'}")
fl = os.path.join(DEV, "_file_access_log.xml")
if os.path.exists(fl) and os.path.getsize(fl) > 0:
    last = open(fl).read().strip().rsplit("<file ", 1)[-1]
    import re
    m = re.search(r'path="([^"]+)"', last)
    print(f"last file opened: {m.group(1) if m else last[:80]}")
else:
    print("last file opened: (none)")

# kill
p.terminate()
try: p.wait(timeout=5)
except subprocess.TimeoutExpired: p.kill()
print("done")
