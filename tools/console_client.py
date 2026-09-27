#!/usr/bin/env python3
"""console_client.py — minimal DSL ConsoleServer client (port 20249).

Protocol (from HW12Dev/dslConsole, dsl::ConsoleProtocol):
  client -> server command:  u32 type | u32 (len+4) | u32 len | text
      type: 0=TEXT 1=EXECUTE_COMMAND 2=NULL 3=HASH_PAIR 4=UNFINISHED
  server -> client message:  8-byte header | u32 len | level | u32 len | text

Usage:
  console_client.py [cmd ...]      # connect, send commands, dump 5s of server output
  console_client.py --wait         # connect as soon as the port opens (engine starting)
  console_client.py --interactive  # REPL: type commands, print responses
"""
import socket, struct, sys, time, os

PORT = 20249
EXECUTE_COMMAND = 1

def send_cmd(sock: socket.socket, text: str) -> None:
    data = text.encode()
    pkt = struct.pack("<III", EXECUTE_COMMAND, len(data) + 4, len(data)) + data
    sock.sendall(pkt)

def recv_chunk(sock: socket.socket, timeout: float) -> list:
    """Read available server messages for up to `timeout` seconds.
    Returns list of (level, text)."""
    sock.settimeout(timeout)
    buf = b""
    deadline = time.time() + timeout
    out = []
    while time.time() < deadline:
        try:
            chunk = sock.recv(65536)
        except socket.timeout:
            break
        if not chunk:
            break
        buf += chunk
    # parse: skip 8-byte header, then (u32 len, str, u32 len, str) pairs
    off = 0
    while off + 8 <= len(buf):
        off += 8  # packet header (size field, unknown layout)
        if off + 4 > len(buf): break
        ln = struct.unpack_from("<I", buf, off)[0]; off += 4
        if ln > len(buf) - off: break
        level = buf[off:off+ln].decode("utf8", "replace"); off += ln
        if off + 4 > len(buf): break
        ln2 = struct.unpack_from("<I", buf, off)[0]; off += 4
        if ln2 > len(buf) - off: break
        text = buf[off:off+ln2].decode("utf8", "replace"); off += ln2
        out.append((level, text))
    return out

def connect(timeout: float = 30.0) -> socket.socket:
    deadline = time.time() + timeout
    last_err = None
    while time.time() < deadline:
        try:
            s = socket.create_connection(("127.0.0.1", PORT), timeout=2)
            s.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
            return s
        except OSError as e:
            last_err = e
            time.sleep(0.5)
    raise SystemExit(f"could not connect to 127.0.0.1:{PORT}: {last_err}")

def main():
    args = sys.argv[1:]
    interactive = "--interactive" in args
    wait_mode = "--wait" in args
    cmds = [a for a in args if not a.startswith("--")]
    if not cmds and not interactive:
        cmds = ["help"]

    sock = connect(timeout=60 if wait_mode else 30)
    print(f"[client] connected to console server :{PORT}", flush=True)

    if interactive:
        while True:
            try:
                line = input("console> ")
            except EOFError:
                break
            if line.strip().lower() == "quit":
                break
            send_cmd(sock, line)
            for level, text in recv_chunk(sock, 2.0):
                print(f"[{level}] {text}", flush=True)
        sock.close()
        return

    for c in cmds:
        send_cmd(sock, c)
    for level, text in recv_chunk(sock, 5.0):
        print(f"[{level}] {text}", flush=True)
    sock.close()

if __name__ == "__main__":
    main()
