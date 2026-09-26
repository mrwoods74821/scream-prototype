#!/usr/bin/env python3
"""Diesel .diesel model -> glTF exporter for the Scream Prototype (GRIN-era Diesel, BNDL v2 era).
Format per kythyria/payday2-model-tool Research Notes (shared ancestor format).
"""
import struct, os, sys, glob, json, re, math

TAGS = {
    0x5DC011B8:'AnimationData', 0x7623C465:'Author', 0x29276B1D:'MaterialGroup',
    0x3C54609C:'Material', 0x0FFCD100:'Object3D', 0x62212D88:'ModelData',
    0x7AB072D3:'Geometry', 0x4C507A13:'Topology', 0xE3A3B1CA:'PassthroughGP',
    0x03B634BD:'TopologyIP', 0x648A206C:'QuatLinearRot', 0x197345A5:'QuatBezRot',
    0x65CC1825:'SkinBones', 0x2EB43C77:'Bones', 0xFFA13B80:'Light',
    0x33552583:'LightSet', 0x26A5128C:'LinearVector3', 0x76BF5B66:'LinearFloat',
    0x679D695B:'LookAtConstr', 0x46BF31A7:'Camera',
}
SIZE_INDEX = {0:0, 1:4, 2:8, 3:12, 4:16, 5:4, 6:4, 7:8, 8:12}
TYPE_NAME = {1:'position', 2:'normal', 7:'uv', 20:'tangent', 21:'binormal'}

def parse_sections(d):
    if struct.unpack_from('<i', d, 0)[0] == -1:
        _, nsec = struct.unpack_from('<II', d, 4)
        off = 12
    else:
        nsec, = struct.unpack_from('<I', d, 0)
        off = 4
    secs = []
    for _ in range(nsec):
        typ, sid, size = struct.unpack_from('<III', d, off)
        off += 12
        secs.append({'tag':typ, 'name':TAGS.get(typ,'?'), 'id':sid, 'data':d[off:off+size]})
        off += size
    return secs

def read_name(data, off):
    """Length-prefixed string: u32 len + bytes? or null-terminated. Detect."""
    e = data.index(b'\x00', off)
    return data[off:e].decode('latin1'), e+1

def parse_geometry(data):
    item_count, type_count = struct.unpack_from('<ii', data, 0)
    off = 8
    types = []
    for _ in range(type_count):
        ts, tt = struct.unpack_from('<II', data, off)
        types.append((ts, tt)); off += 8
    stride = sum(SIZE_INDEX.get(s,0) for s,t in types)
    return item_count, types, data[off:off+item_count*stride]

def parse_topology(data):
    unk, icount = struct.unpack_from('<Ii', data, 0)
    off = 8
    idx = struct.unpack_from(f'<{icount}h', data, off)
    return idx

def parse_object3d(data):
    # cstring name; then transform blocks per docs
    name, off = read_name(data, 0)
    # remainder: count + items each (u32,u32,u32, mat4, vec3, u32 parent)
    return name, data[off:]

def parse_modeldata(data):
    name, off = read_name(data, 0)
    rest = data[off:]
    return name, rest

def f32s(buf, off, n):
    return struct.unpack_from(f'<{n}f', buf, off)

def diesel_to_gltf(path, matconfigs, texture_dir, out_path):
    d = open(path,'rb').read()
    secs = parse_sections(d)
    by_id = {s['id']: s for s in secs}

    # gather model data entries: name, version, passthrough/topology ids, materialgroup
    meshes = []          # glTF mesh index
    nodes = []
    materials = []       # (name, texture_png_path)
    images = []
    texs = []
    matname_by_id = {}
    for s in secs:
        if s['tag'] == 0x3C54609C:  # Material
            name, _ = read_name(s['data'], 8+48+4+ (struct.unpack_from('<I', s['data'], 8+48)[0])*8) if False else (None, None)
            # material name is embedded as cstring near the end; find printable strings
            strs = re.findall(rb'[ -~]{5,}', s['data'])
            nm = strs[0].decode('latin1') if strs else f'mat_{s["id"]:x}'
            matname_by_id[s['id']] = nm

    # material configs from xml: material name -> diffuse texture file stem
    # group modeldatas: each ModelData = one object; v5 has geometry/topology refs
    accessors = []; buffer_views = []; bin_chunks = []; scenes_nodes = []
    POSITION = []; NORMAL = []; UV = []; IDX = []; mesh_entries = []

    def add_bin(chunk):
        buffer_views.append({'buffer':0, 'byteOffset': len(b''.join(bin_chunks)) if not bin_chunks else sum(len(c) for c in bin_chunks),
                             'byteLength': len(chunk)})
        bin_chunks.append(chunk)
        return len(buffer_views)-1

    def add_accessor(comp_type, ncomp, count, bview, mins=None, maxs=None):
        acc = {'bufferView': bview, 'componentType': comp_type, 'count': count,
               'type': {1:'SCALAR',2:'VEC2',3:'VEC3',4:'VEC4'}[ncomp]}
        if mins: acc['min'] = [round(v,5) for v in mins]; acc['max'] = [round(v,5) for v in maxs]
        accessors.append(acc)
        return len(accessors)-1

    # walk Object3D hierarchy: object name -> children
    objects = []
    for s in secs:
        if s['tag'] == 0x0FFCD100:
            name, rest = parse_object3d(s['data'])
            objects.append({'id':s['id'], 'name':name, 'raw':rest})
    pt_ids = {s['id'] for s in secs if s['tag']==0xE3A3B1CA}
    tip_ids = {s['id'] for s in secs if s['tag']==0x03B634BD}
    mg_ids = {s['id'] for s in secs if s['tag']==0x29276B1D}

    for s in secs:
        if s['tag'] != 0x62212D88: continue
        name, rest = parse_modeldata(s['data'])
        # v5 layout drifts; resolve refs by scanning for known section ids
        pt_id = tip_id = mg_id = None
        for off in range(0, len(rest)-3):
            v, = struct.unpack_from('<I', rest, off)
            if v in pt_ids and pt_id is None: pt_id = v
            elif v in tip_ids and tip_id is None: tip_id = v
            elif v in mg_ids and mg_id is None: mg_id = v
        if pt_id is None: continue
        pt = by_id.get(pt_id)
        geo_id = top_id = None
        if pt and pt['tag'] == 0xE3A3B1CA:
            geo_id, top_id = struct.unpack_from('<II', pt['data'], 0)
        if geo_id is None: continue
        geo = by_id.get(geo_id); top = by_id.get(top_id)
        if not geo or not top: continue
        try:
            ic, types, vbuf = parse_geometry(geo['data'])
            idx = parse_topology(top['data'])
        except Exception:
            continue
        if ic == 0 or len(idx) < 3: continue
        stride = sum(SIZE_INDEX.get(s,0) for s,t in types)
        tmap = {}
        o = 0
        for ts, tt in types:
            tmap[TYPE_NAME.get(tt, f't{tt}')] = (o, SIZE_INDEX.get(ts,0)//4)  # byte offset, float count
            o += SIZE_INDEX.get(ts,0)
        pos = []; norms = []; uvs = []
        for i in range(ic):
            base = i*stride
            if 'position' in tmap:
                po, pc = tmap['position']
                pos.append(f32s(vbuf, base+po, 3) if pc>=3 else (0,0,0))
            if 'normal' in tmap and 'position' in tmap:
                no, nc = tmap['normal']
                norms.append(f32s(vbuf, base+no, 3) if nc>=3 else (0,1,0))
            if 'uv' in tmap:
                uo, uc = tmap['uv']
                if uc >= 2:
                    u,v = f32s(vbuf, base+uo, 2)
                    uvs.append((u, 1.0-v))
                else:
                    uvs.append((0,0))
        # material: matgroup -> material ids -> names
        mg = by_id.get(mg_id)
        mat_name = None
        if mg and mg['tag'] == 0x29276B1D:
            mc, = struct.unpack_from('<I', mg['data'], 0)
            mids = struct.unpack_from(f'<{mc}I', mg['data'], 4)
            if mids and mids[0] in matname_by_id:
                mat_name = matname_by_id[mids[0]]
        mat_idx = None
        if mat_name and mat_name in matconfigs:
            tex = matconfigs[mat_name]
            png = os.path.join(texture_dir, tex + '.png')
            if os.path.exists(png):
                mat_entry = {'name': mat_name,
                             'pbrMetallicRoughness': {'baseColorTexture': {'index': len(images)},
                                                      'metallicFactor': 0.0, 'roughnessFactor': 1.0}}
                materials.append(mat_entry)
                images.append({'uri': os.path.relpath(png, os.path.dirname(out_path))})
                texs.append({'source': len(images)-1})
                mat_idx = len(materials)-1
        # write buffers
        pba = struct.pack(f'<{len(pos)*3}f', *[v for t in pos for v in t])
        bv = add_bin(pba)
        pa = add_accessor(5126, 3, len(pos), bv,
                          [min(p[0] for p in pos), min(p[1] for p in pos), min(p[2] for p in pos)],
                          [max(p[0] for p in pos), max(p[1] for p in pos), max(p[2] for p in pos)])
        ia = None
        if idx:
            iba = struct.pack(f'<{len(idx)}H', *idx)
            bv2 = add_bin(iba)
            ia = add_accessor(5123, 1, len(idx), bv2)
        na = None
        if norms:
            nba = struct.pack(f'<{len(norms)*3}f', *[v for t in norms for v in t])
            bv3 = add_bin(nba)
            na = add_accessor(5126, 3, len(norms), bv3)
        ua = None
        if uvs:
            uba = struct.pack(f'<{len(uvs)*2}f', *[v for t in uvs for v in t])
            bv4 = add_bin(uba)
            ua = add_accessor(5126, 2, len(uvs), bv4)
        prim = {'attributes': {'POSITION': pa}, 'indices': ia, 'material': mat_idx}
        if na is not None: prim['attributes']['NORMAL'] = na
        if ua is not None: prim['attributes']['TEXCOORD_0'] = ua
        mesh_entries.append({'name': name, 'primitives': [prim]})

    if not mesh_entries:
        return False
    # node per mesh, one scene
    for i, me in enumerate(mesh_entries):
        nodes.append({'mesh': i, 'name': me['name']})
    gltf = {
        'asset': {'version': '2.0', 'generator': 'd0g diesel2gltf'},
        'scenes': [{'nodes': list(range(len(nodes)))}],
        'nodes': nodes, 'meshes': [ {'name': m['name'], 'primitives': m['primitives']} for m in mesh_entries],
        'accessors': accessors, 'bufferViews': buffer_views,
        'buffers': [{'byteLength': sum(len(c) for c in bin_chunks)}],
        'materials': materials, 'images': images, 'textures': texs,
    }
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    with open(out_path, 'wb') as f:
        blob = b''.join(c for c in bin_chunks)
        while len(blob) % 4: blob += b'\x00'
        json_str = json.dumps(gltf)
        jsonb = json_str.encode()
        while len(jsonb) % 4: jsonb += b' '
        total = 12 + 8 + len(jsonb) + 8 + len(blob)
        f.write(b'glTF'); f.write(struct.pack('<II', 2, total))
        f.write(struct.pack('<I', len(jsonb))); f.write(b'JSON'); f.write(jsonb)
        f.write(struct.pack('<I', len(blob))); f.write(b'BIN\x00'); f.write(blob)
    return True

def load_matconfig_dir(dirpath):
    """Parse material_config xml -> {material_name: diffuse_texture_stem}"""
    out = {}
    for p in glob.glob(dirpath + '/**/*.xml', recursive=True):
        try: t = open(p, 'r', errors='ignore').read()
        except: continue
        for m in re.finditer(r'<material[^>]*name="([^"]+)"', t):
            name = m.group(1)
            dm = re.search(r'<diffuse_texture file="([^"]+)"', t)
            if dm: out[name] = dm.group(1)
    return out

if __name__ == '__main__':
    base = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), 'extracted')
    matconfigs = load_matconfig_dir(base + '/quick/db/material_config')
    print('matconfigs:', len(matconfigs))
    texture_dir = base + '/quick/db/texture'
    models = sorted(glob.glob(base + '/quick/db/model/*/*.diesel'))
    outdir = base + '/models'
    ok = fail = 0
    for p in models:
        rel = os.path.relpath(p, base + '/quick/db/model')
        outp = os.path.join(outdir, os.path.splitext(rel)[0] + '.gltf')
        try:
            if diesel_to_gltf(p, matconfigs, texture_dir, outp): ok += 1
            else: fail += 1
        except Exception as ex:
            fail += 1
            if fail <= 5: print('ERR', rel, ex)
    print(f'exported {ok}, failed {fail}')
