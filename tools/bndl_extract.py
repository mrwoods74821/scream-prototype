#!/usr/bin/env python3
"""BNDL v2 extractor for GRIN-era Diesel bundles (quick.bundle / stream.bundle).

Format (see Hermes skill diesel-bundle-extraction):
  Header: 'BNDL', u32 version(=2), u32 index_end (ABSOLUTE offset: index ends,
          payloads begin), u32 zero.
  Index (offset 16..index_end), tag stream:
    01 01 <cstr>  push directory component
    02 <u64 off> <u32 len>  file record
    01 <cstr>     set filename on most recent 02 record (may precede/follow it)
    03            pop directory (never underflow the stack)
  Payloads are raw uncompressed slices data[off:off+len].

The index MUST be read as one contiguous read from the same stream after the
header (re-reading from offset 0 misaligns it).
"""
import struct
import sys
from collections import Counter
from pathlib import Path


def read_cstr(buf: bytes, pos: int) -> tuple[str, int]:
    end = buf.find(b"\x00", pos)
    return buf[pos:end].decode("latin-1"), end + 1


def parse_index(index_bytes: bytes):
    files = []          # (dir_stack_snapshot, name, offset, length)
    dir_stack = []
    pending = None      # most recent file record dict
    pos = 0
    n = len(index_bytes)
    while pos < n:
        tag = index_bytes[pos]
        if tag == 0x01:
            if pos + 1 < n and index_bytes[pos + 1] == 0x01:
                # push dir
                name, p = read_cstr(index_bytes, pos + 2)
                dir_stack.append(name)
                pos = p
            else:
                # filename for most recent 02 record
                name, p = read_cstr(index_bytes, pos + 1)
                if pending is None:
                    raise ValueError(f"filename tag with no file record at {pos}")
                pending["name"] = name
                pos = p
        elif tag == 0x02:
            off, ln = struct.unpack_from("<QI", index_bytes, pos + 1)
            pending = {"dir": list(dir_stack), "name": None, "off": off, "len": ln}
            files.append(pending)
            pos += 13
        elif tag == 0x03:
            if dir_stack:
                dir_stack.pop()
            # a 03 closing a file-record group must not underflow the dir stack
            pos += 1
        else:
            raise ValueError(f"bad tag {tag} (chr {chr(tag)!r}) at index offset {pos}")
    return files


def main(bundle_path: Path, out_dir: Path):
    bundle_path, out_dir = Path(bundle_path), Path(out_dir)
    with open(bundle_path, "rb") as f:
        header = f.read(16)
        if header[:4] != b"BNDL":
            sys.exit(f"not a BNDL file: {header[:4]!r}")
        version, index_end, zero = struct.unpack("<III", header[4:16])
        if version != 2:
            sys.exit(f"unsupported BNDL version {version}")
        index_bytes = f.read(index_end - 16)  # ONE stream, no re-read
        files = parse_index(index_bytes)
        print(f"{len(files)} file records, index_end={index_end}")

        ext_counter = Counter()
        skipped_zero = 0
        data = None
        out_dir.mkdir(parents=True, exist_ok=True)
        for i, rec in enumerate(files):
            if rec["name"] is None:
                raise ValueError(f"record {i} has no filename: {rec}")
            rel = Path(*rec["dir"]) / rec["name"] if rec["dir"] else Path(rec["name"])
            ext = rel.suffix.lower().lstrip(".")
            ext_counter[ext] += 1
            dest = out_dir / rel
            if rec["len"] == 0:
                skipped_zero += 1
                dest.parent.mkdir(parents=True, exist_ok=True)
                dest.touch()
                continue
            if rec["off"] + rec["len"] > bundle_path.stat().st_size:
                raise ValueError(
                    f"record {i} ({rel}) exceeds file: off={rec['off']} len={rec['len']}"
                )
            f.seek(rec["off"])
            payload = f.read(rec["len"])
            if len(payload) != rec["len"]:
                raise ValueError(f"short read for {rel}")
            dest.parent.mkdir(parents=True, exist_ok=True)
            with open(dest, "wb") as o:
                o.write(payload)
            if (i + 1) % 2000 == 0:
                print(f"  {i + 1}/{len(files)}...")
        print("extension inventory:", dict(ext_counter.most_common()))
        print(f"zero-length stubs touched: {skipped_zero}")
        print(f"done -> {out_dir}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(f"usage: {sys.argv[0]} <bundle> <outdir>")
    bundle_p, out_p = Path(sys.argv[1]), Path(sys.argv[2])
    main(bundle_p, out_p)
