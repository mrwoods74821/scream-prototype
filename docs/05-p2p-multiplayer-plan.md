# 05 — P2P Multiplayer Plan (phased)

Goal: two players on separate machines, each running this depot under Proton, can host and join each other peer-to-peer. Stretch: Steam-invite joins and a server-list style lobby browser.

## Why this is feasible (evidence base)

1. The exe ships a complete Steam P2P netcode compiled in (NETWORK_USE_STEAM_SOCKETS; SteamID-addressed protocol; imports SendP2PPacket etc.).
2. Replication, RPC, lobby, ownership, drop-in, save-sync all exist as engine machinery (03).
3. All multiplayer gamemodes + networked units ship in the data (04).
4. The sibling shipped product (Payday TH, same engine family) ran exactly this model: Steam lobbies + P2P host authority. Lead and Gold shipped dedicated servers from the same codebase.
5. The game currently runs under Goldberg, which implements Steam P2P (LAN/UDP) and lobbies.

## Approach decision — Steam context

The engine requires a functioning Steam API context for its P2P sockets. Options:

| Option | Mechanism | Risk |
|---|---|---|
| A. Goldberg (current) | Emu already in place; supports lobbies + P2P over LAN; needs config (listen port, player name, appid) and cross-machine testing | Goldberg P2P works on LAN reliably; internet play needs the same ports/UDP reachability |
| B. Real Steam client + owned appid | Highest fidelity (Steam relay NAT traversal) | Nobody owns appid 42150/42151 (unreleased leak content); Steam may reject appid spoofing; account risk — avoid |
| C. Spaceworm/Nucleus-style LAN co-op via raw socket path | Engine's `set_plaintext_network` + dsl::network::Socket | Untested entry point; auth sessions gate the handshake in Steam builds; more RE needed |

Plan: drive Option A to a working two-machine session; keep C as fallback research (the symbols show a plain path exists). Never use Elijah's real Steam account to spoof appid 42150 (Option B rejected).

## Phase 0 — Toolchain rebuild (prerequisite for everything)

The old devroot/extracted trees are gone. Rebuild:
1. BNDL v2 extractor (format fully documented in diesel-bundle-extraction skill) → full asset tree.
2. FCL/LHD extractor (same skill; the one-entry-shift pitfall is documented) → boot layer recovery.
3. .luc ↔ Lua source pipeline (diesel-luc-decompile skill: float32 + opcodes 38/39 transform; recompile via context.xml scripts="true" loose mode or direct .luc compile).
4. XMB ↔ XML converter (token-table format; HW12Dev/DieselFormats has a legacy XMB parser as reference).
Deliverable: `extracted/` tree + devroot boot dir that launches loose-file mode (dev exe flags `-d <dir> -o context.xml -s`).

## Phase 1 — Recover the session flow (read-only RE)

1. Decompile: NetworkSystemLinkRDV.luc, HudNetworkClient.luc, menu chain from boot.fcl (MainMenuManager, MenuPageManager), MPPlayerHusk.luc, damage network scripts.
2. Map the Lua-level Host/Join path: fs::Steam::create_lobby/join_lobby → Network::set_server/set_client → hello handshake → Synchronizer full-state sync. Identify what gates it (UI visibility? config flag? Steam running check?).
3. Identify where `Network::using_steam` / `Application::using_steam` branch — Goldberg satisfies SteamAPI_Init, but the game's own lobby code may check more.
4. Recover the FULL gameplay RPC table (boot.fcl network.xml variant) beyond the shipped quick.bundle subset.
Deliverable: written flow map; list of dormant/broken links.

## Phase 2 — Single-machine two-instance test

1. Two Proton prefixes (second: clone compatdata or fresh prefix with PhysX MSI), two Goldberg instances with distinct names/ports (Goldberg settings: different `listen_port`, disable LAN-only if needed).
2. Force the multiplayer menu path (either via Lua edit un-hiding it, or by directly calling the join flow in a console/test Lua hook — dev build exposes script env; `-u` unit-test flag exists).
3. Success criteria: instance A hosts, instance B's client_hello reaches A (verify via `_packet_log`/`_rpc_log`/`_socket_log` toggles — these log switches exist on Network), Synchronizer spawns husks on B, both see each other's players.
4. Iterate on breakage with Network::simulate/UDPSocket::simulate_* and add_fake_clients as offline harnesses.

## Phase 3 — Cross-machine play

1. Same procedure on two machines on LAN (Goldberg P2P is UDP broadcast/LAN-native).
2. Internet play: direct IP (Goldberg `disable_lan_only`/IP config) or port-forward; document the required UDP ports from Goldberg config + packet capture.
3. Harden: timeouts, drop-in join (Synchronizer::drop_in + SavedGameLoader), disconnect handling.

## Phase 4 — UX polish (optional)

- Friend-join via Goldberg lobby list (it emulates RequestLobbyList).
- Gamemode selection UI for the scream_* modes; map rotation across the 8 levels.
- Observer/spectator via existing mp_observer units.

## Key risks / unknowns (honest list)

- Goldberg's SteamNetworking003-era P2P emulation quality vs this game's expectations (interface version from steam_interfaces.txt: SteamNetworking003). Goldberg targets mostly newer interfaces; may need per-version testing or patching Goldberg. THIS IS THE #1 TECHNICAL RISK.
- Auth ticket handshake: AuthenticationSessionHandler may reject emu sessions — test; bypass = find the `set_plaintext_network` / check="none" path.
- Dev exe vs signed exe behavioral differences (three exes ship; test each if weirdness).
- Lua bugs in 15-year-old prototype MP code (the single-player menu crash we already fixed shows the code has landmines).
- `NETWORK_SEND_HASH` packet hash validation across differing builds — both peers must run identical depots.

## Test ladder (each step must pass before the next)

1. Toolchain round-trip: extract → modify → repack → boot (loose + bundled).
2. Lua decompile → edit → recompile → run.
3. Dev console/unit-test path reaches network init (two instances, one machine).
4. Two instances complete hello handshake.
5. Unit synchronization visible (husk appears on peer).
6. Full match in scream_practice → scream_vs on one machine (two windows).
7. LAN two machines.
8. Internet two machines.
