#!/usr/bin/env python3
"""FCL + LHD patch-container extractor (boot.fcl / boot_common.fcl + game.lhd).

VERIFIED layout (re-derived 2026-09-24 against game.lhd + boot.fcl, validated
by tree-record size fields: 863/863 exact with the shifted convention):

FCL: u32 chunk_count; u32 version (0x00010000);
     chunk_count x (u32 abs_offset, u32 length), each one zlib stream;
     concatenated decompression = ONE flat byte stream (39,714,816 bytes for
     boot.fcl). NOTE: boot.fcl and boot_common.fcl in this depot are
     byte-identical (md5 7a03375a...).

LHD: u32 token_count; tokens (NUL-terminated; directory tokens keep their
     trailing backslash);
     u32 tree_record_count; records of 4xi32 (parent_TOKEN_idx, name_token_idx,
     size, flag) — parent indexes the TOKEN table (dir tokens end with '\\'),
     NOT the record table. flag -1 = dir, 0 = file.
     Trailer section A: 4 words (10, 0, entry_count, 0), then
       (entry_count-1) tree-record indices, then entry_count cumulative
       stream offsets.
     Trailer section B: 3 words (1158, entry_count, 0), then the same shape.
     Both sections carry identical indices/offsets in this depot (same file
     list for boot and boot_common).

Extraction convention (the ONE-ENTRY SHIFT): file i = tree record idxs[i],
byte interval offs[i+1]..offs[i+2]. Pairing interval i with offs[i]..offs[i+1]
tiles the stream completely but slices files at wrong boundaries (796/863 size
mismatches) — a complete tiling is NOT proof of correct mapping.

Validation: extracted length == tree-record size for every file; magic checks
(.xmb 'XML\\x01', .dds 'DDS ', .luc '\\x1bLuaQ'; .xml may have leading
whitespace before '<').
"""
import struct
import sys
import zlib
from pathlib import Path

MAGICS = {".xmb": b"XML\x01", ".dds": b"DDS ", ".luc": b"\x1bLuaQ"}


def read_fcl_stream(fcl_path: Path) -> bytes:
    data = fcl_path.read_bytes()
    chunk_count, version = struct.unpack_from("<II", data, 0)
    assert version == 0x00010000, f"unexpected FCL version {version:#x}"
    out = bytearray()
    for i in range(chunk_count):
        off, ln = struct.unpack_from("<II", data, 8 + 8 * i)
        out += zlib.decompress(data[off : off + ln])
    return bytes(out)


def parse_lhd(lhd_path: Path):
    """Return (tokens, records, sections) where sections = [(idxs, offs), ...]."""
    data = lhd_path.read_bytes()
    tok_count = struct.unpack_from("<I", data, 0)[0]
    pos = 4
    tokens = []
    for _ in range(tok_count):
        end = data.find(b"\x00", pos)
        tokens.append(data[pos:end].decode("latin-1"))
        pos = end + 1
    rec_count = struct.unpack_from("<I", data, pos)[0]
    pos += 4
    records = [struct.unpack_from("<iiii", data, pos + 16 * i) for i in range(rec_count)]
    pos += 16 * rec_count
    words = list(struct.unpack_from("<" + "I" * ((len(data) - pos) // 4), data, pos))

    sections = []
    w = 0
    while w + 3 < len(words):
        # section header: (x, entry_count, 0); section A carries an extra
        # leading word (10), so at w==0 skip one word first.
        scan = w + 1 if w == 0 else w
        if scan + 2 < len(words) and words[scan + 2] == 0 and 0 < words[scan + 1] < 10000:
            count = words[scan + 1]
            start = scan + 3
            if start + count - 1 + count <= len(words):
                idxs = words[start : start + count - 1]
                offs = words[start + count - 1 : start + count - 1 + count]
                if idxs and offs[0] == 0 and max(idxs) < rec_count:
                    sections.append((idxs, offs))
                    w = start + count - 1 + count
                    continue
        w += 1
    return tokens, records, sections


def extract(stream: bytes, idxs, offs, records, tokens, out_dir: Path):
    """File i (idxs[i]) occupies stream interval offs[i+1]..offs[i+2].

    Two verified quirks of this depot:
    - tree record 0 (version.xmb) is NOT in idxs; it is interval offs[0]..offs[1].
    - The final interval runs to stream end but the last file's true size is
      its tree-record size; ~48KB of unlisted orphan DDS payload follows.
    """
    files, errors = [], []

    def write(rel: str, seg: bytes, size: int):
        dest = out_dir / rel
        dest.parent.mkdir(parents=True, exist_ok=True)
        dest.write_bytes(seg)
        files.append(rel)
        if len(seg) != size:
            errors.append((rel, f"size mismatch tree={size} got={len(seg)}"))
            return
        magic = MAGICS.get(Path(rel).suffix.lower())
        if magic and not seg.startswith(magic):
            errors.append((rel, f"bad magic {seg[:8]!r}"))
        if rel.endswith(".luc"):
            stem = Path(rel).stem.encode("latin-1")
            if stem not in seg:
                errors.append((rel, "filename stem not embedded"))

    # unlisted record 0 = interval 0
    p, n, s, f = records[0]
    write((tokens[p] + tokens[n]).replace("\\", "/"), stream[offs[0] : offs[1]], s)

    last = len(idxs) - 1
    for i, rec_idx in enumerate(idxs):
        p, n, s, f = records[rec_idx]
        start = offs[i + 1]
        end = offs[i + 2] if i + 2 < len(offs) else len(stream)
        if i == last:
            end = min(end, start + s)  # clamp: orphan payload follows last file
        write((tokens[p] + tokens[n]).replace("\\", "/"), stream[start:end], s)
    return files, errors


def main(lhd: Path, out_root: Path):
    bundles = lhd.parent
    tokens, records, sections = parse_lhd(lhd)
    print(f"tokens={len(tokens)} records={len(records)} sections={len(sections)}")
    for s, (idxs, offs) in enumerate(sections):
        n_files = sum(1 for i in idxs if records[i][3] == 0)
        print(f"  section {s}: {len(idxs)} indices ({n_files} files), "
              f"stream span 0..{offs[-1]}")

    boot = bundles / "boot.fcl"
    boot_common = bundles / "boot_common.fcl"
    identical = boot.read_bytes() == boot_common.read_bytes()
    print(f"boot.fcl == boot_common.fcl: {identical}")

    stream = read_fcl_stream(boot)
    total_errors = []
    for s, (idxs, offs) in enumerate(sections):
        out_dir = out_root / ("boot" if s == 0 else f"boot_common_{s}")
        files, errors = extract(stream, idxs, offs, records, tokens, out_dir)
        total_errors += errors
        print(f"  section {s} -> {out_dir}: {len(files)} files, {len(errors)} errors")
        if identical and s == 0 and len(sections) > 1:
            print("  (remaining sections use the identical stream; "
                  "extracting for completeness)")

    if total_errors:
        print("VALIDATION FAILURES:")
        for p, e in total_errors[:40]:
            print(f"  {p}: {e}")
        if len(total_errors) > 40:
            print(f"  ... and {len(total_errors) - 40} more")
        sys.exit(1)
    print("ALL VALIDATION PASSED")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        sys.exit(f"usage: {sys.argv[0]} <game.lhd> <outdir>")
    main(Path(sys.argv[1]), Path(sys.argv[2]))
