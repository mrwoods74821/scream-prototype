# Scream Prototype — Internet Play (no LAN) Setup Guide

**Route A: port forwarding + `custom_broadcasts`.** One player hosts, the other
joins over the internet. No Steam, no account, no extra software on the
joining player's side. Verified against the Goldberg emulator source
(`tools/emu-src/dll/network.cpp`) and the live game on OldBeast, 2026-09-27.

---

## How it works (60 seconds)

The game finds its peer by sending a small "announce" packet (its name, its
IP, its port). On a LAN that announce is broadcast; over the internet the
emulator can also send it **directly to a specific IP** listed in a config
file. So each machine lists the other's public IP, the two announce packets
meet, and all game traffic flows straight between the two machines.

One asymmetry, fixed by the nature of home routers:

- The **joining player** only ever sends traffic out. Routers allow that
  freely. Zero setup for them.
- The **host** receives traffic. A home router drops inbound packets it did
  not start. The host's router therefore needs one rule: "let packets for
  ports 26011 (UDP and TCP) through to the host's computer."

That single rule is the entire setup.

---

## What each side needs

| | Host (the server) | Friend (the player who joins) |
|---|---|---|
| Router port forwarding | Yes — UDP 26011 + TCP 26011 | No |
| Edit `custom_broadcasts.txt` | Yes — friend's IP | Yes — host's IP |
| Any other config | No | No |
| Steam / account / extra software | No | No |
| Stable public IP | Required (or a domain name that tracks it) | No — outbound only |

---

## Part 1 — Host setup (one time, ~15 minutes)

### Step 1. Find your public IP

Ask the internet what it sees you as:

```
curl https://ifconfig.me
```

Example output (this machine): `212.104.215.99`. Keep this number handy —
your friend needs it.

Check that it is a *real* public IP (your computer must sit behind a normal
router, not behind a second carrier-grade NAT). The number must be outside
the `100.64.0.0 – 100.127.255.255` range. If it is inside that range, your
provider hides you from the internet and this route will not work for you
as host (the friend can still join other people).

### Step 2. Find your LAN IP

On Linux:

```
ip -brief addr show
```

Look for your main interface. Example (this machine): `192.168.6.98`.

On Windows, open a terminal and run:

```
ipconfig
```

Look for "IPv4 Address" under your Ethernet/Wi-Fi adapter.

### Step 3. Forward the ports on your router

Log into your router's web interface (usually `http://192.168.4.1` for this
network, or whatever your router's address is; the admin password is on a
label or set at first setup).

Find the section usually called **Port Forwarding**, **Virtual Servers**,
**NAT**, or **Port Mapping** (varies by router brand). Create two rules:

| Type | Port | Forward to (LAN IP) |
|------|------|---------------------|
| UDP  | 26011 | your LAN IP from Step 2 |
| TCP  | 26011 | your LAN IP from Step 2 |

Both rules point to the **same machine** — the one running the game. If
your router UI only has one "port" field, make two separate entries, one
for UDP and one for TCP. If it asks for a range, enter `26011-26011`.

Save. Do not reboot the router — not needed.

**Why both UDP and TCP:** the game's networking engine opens one socket for
each. UDP carries the game data; TCP carries the handshake bookkeeping.
Both bind to 26011, so both rules use the same port.

### Step 4. Put your friend's IP in your game

Open the file:

```
game/steam_settings/custom_broadcasts.txt
```

Replace its single line with your friend's public IP, one address per line:

```
<friend's public IP>
```

Multiple friends? One line each. The emulator accepts IPs and domain names
(`getaddrinfo` under the hood). If your friend's IP changes often, have
them use a dynamic-DNS name (see Troubleshooting) and put the name here
once.

### Step 5. (Recommended) Prove the forward works before you invite anyone

From a device **outside your network** (a phone on mobile data), run a TCP
check against your public IP:

```
nc -zv 212.104.215.99 26011
```

`succeeded` = your router is passing the port. `timed out / refused` = the
rule is missing or mis-pointed; re-check Step 3 while the game is running
(the port only exists while the game process is alive, so keep the game
up during the check).

UDP is hard to test from a phone; the definitive test is your friend
connecting, which is Part 3.

---

## Part 2 — Friend setup (you do it for them; they do nothing)

When you hand over the game folder, edit this one file on their copy:

```
steam_settings/custom_broadcasts.txt
```

Put the host's public IP as the single line:

```
212.104.215.99
```

That is the whole friend-side setup. They do not touch their router, do not
forward anything, do not install anything. Their machine only sends traffic
out, which every router allows.

**First run on Windows:** Windows Firewall may pop up a prompt when the
game first binds its ports. Click **Allow access**. If you hand them a
ready-configured folder, test one run yourself to answer the prompt.

---

## Part 3 — Playing together

1. **Host:** launch the game (bundled mode, no args). Go to the
   multiplayer menu, **Create Game**, pick a mode.
   - Cycle the mode selector to **EXPOSE THE KILLER**. Modes flagged
     "NOT INCLUDED IN PROTOTYPE" grey out the create button.
   - Start the game.
2. **Friend:** launch their copy, **Join Game**. The host's server appears
   in the list (the announce arrived via the forwarded port).
3. Both navigate **forward** through every menu page. Do not back out with
   ESC — the server-information page crashes on a nil value if you leave
   the flow early (known quirk, `MenuServerInformationSteam`).
4. In-game: the round runs. The host sees their client; movement, evidence
   HUD, and the round timer all confirm the data path is live.

While someone plays, the host can watch the network side from the terminal:

```
ss -u -a -p | grep 26011
```

A connected peer shows up as an established UDP session to the friend's
public IP.

---

## Troubleshooting

**Friend never sees the server in the join list.**
Work down this list; each step matches a verified failure point:
1. Is the host's game *running* when the friend searches? The port exists
   only while the process lives.
2. Does `nc -zv <host public IP> 26011` from a phone succeed? If no, the
   router rule is wrong (port, protocol, or target LAN IP).
3. Is the host's IP in the friend's `custom_broadcasts.txt` exactly as
   printed by `curl https://ifconfig.me`?
4. Is the friend's IP a line in the host's file?
5. Windows Firewall prompt on the friend's machine answered? (Part 2.)

**It used to work, now the friend cannot find the host.**
Most likely the host's IP changed (dynamic IP). Re-run `curl
https://ifconfig.me` and update the friend's file. If this keeps
happening, switch to a dynamic-DNS name (next item) so the file stops
going stale.

**Host's IP changes often (dynamic IP).**
Get a free dynamic-DNS name (for example a free subdomain from a service
like DuckDNS), point it at the host's current IP, and put the *name* in
both `custom_broadcasts.txt` files. The emulator resolves names through
`getaddrinfo`, so the files stay valid across IP changes.

**Both players are on the same internet connection (same public IP).**
Only one of them can have the port forwarded at a time, so this pairing
will not work. One of them needs a different network (or phone hotspot
with its own IP).

**Host is behind carrier-grade NAT (CGNAT) or has no public IPv4.**
The Step 1 range check (`100.64.0.0 – 100.127.255.255`) catches this. No
router rule can fix it, because there is no public address to point at.
The host can join games, they just cannot host. The long-term fix is the
relay option (Route C: hole-punching + a small relay server inside the
DLL), which removes the requirement for a reachable public IP entirely.

**Connection drops mid-game.**
Check `game/crash.txt` (host) — a crash kills the server. The engine's
timeout (`Connection::bad`) also drops peers that go silent; on a weak
uplink the host side is the usual victim. Nothing to fix in config;
reconnect and note when it happens.

**Joining from far away (high latency).**
Expected and fine for a two-player game. The engine's heartbeat is 0.5 s;
anything under ~250 ms one-way plays smoothly.

---

## Config reference (the four files that matter)

All in `steam_settings/` next to the exe (per player, per copy):

| File | Content | Meaning |
|------|---------|---------|
| `listen_port.txt` | `26011` | Port the engine binds (UDP + TCP). **This is the only file the emulator reads for the port** — the `listen_port` line inside `configs.main.ini` is not used by this code path. |
| `custom_broadcasts.txt` | one IP or domain per line | Addresses to send the discovery announce directly to. This is the file you edit for internet play. |
| `appid.txt` | `42150` | The game's app ID. Leave alone. |
| `player_name.txt` | name | Cosmetic only; the emulator in this build reads the saved name from the profile, not this file. |

The emulator (Goldberg v5, `steam_api.dll`) is the regular non-experimental
build, so it has no built-in LAN-only address blocking; no
`disable_lan_only.txt` is needed or used.
