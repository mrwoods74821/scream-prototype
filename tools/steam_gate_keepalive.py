#!/usr/bin/env python3
"""Ensure a wine keepalive process exists in WINEPREFIX and write its live host
PID into HKCU\\Software\\Valve\\Steam\\ActiveProcess\\pid (user.reg direct edit).
Prints the PID. Robust: verifies process actually alive before trusting."""
import subprocess, re, os, time, sys

PREFIX = os.path.expanduser(sys.argv[1] if len(sys.argv) > 1 else '~/.wine-scream')

def alive_pids():
    out = subprocess.run(['ps', '-eo', 'pid,args'], capture_output=True, text=True).stdout
    pids = []
    for line in out.splitlines()[1:]:
        if 'ScreamKeepalive' in line and 'grep' not in line:
            pids.append(int(line.split()[0]))
    return pids

def start_keepalive():
    subprocess.Popen(
        ['env', f'WINEPREFIX={PREFIX}', 'wine', 'cmd', '/c',
         'title ScreamKeepalive & ping -n 86400 127.0.0.1 > nul'],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL,
        start_new_session=True)
    for _ in range(30):
        time.sleep(1)
        p = alive_pids()
        if p:
            return p[0]
    return None

pid = None
existing = alive_pids()
if existing:
    pid = existing[0]
else:
    pid = start_keepalive()

if pid is None:
    sys.exit('ERROR: keepalive failed to start')

# stop wineserver flush races: write via reg (goes through wineserver)
subprocess.run(['env', f'WINEPREFIX={PREFIX}', 'wine', 'reg', 'add',
                r'HKCU\Software\Valve\Steam\ActiveProcess', '/v', 'pid',
                '/t', 'REG_DWORD', '/d', str(pid), '/f'],
               capture_output=True, timeout=30)
# verify
q = subprocess.run(['env', f'WINEPREFIX={PREFIX}', 'wine', 'reg', 'query',
                    r'HKCU\Software\Valve\Steam\ActiveProcess', '/v', 'pid'],
                   capture_output=True, text=True, timeout=30)
m = re.search(r'pid\s+REG_DWORD\s+0x([0-9a-f]+)', q.stdout)
print('pid set to', pid, '| reg says', int(m.group(1), 16) if m else 'NOT FOUND')
