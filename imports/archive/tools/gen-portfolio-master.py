#!/usr/bin/env python3
"""Generate ONE unified Patrick Portfolio master diagram (all objects, all edges)."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MAP = json.loads((ROOT / "reports/portfolio-model-map.json").read_text(encoding="utf-8-sig"))

DOMAIN_ID = MAP["domainId"]
objects = [o for o in MAP["objects"] if o["type"] not in ("root",) and o.get("name")]
connections = MAP["connections"]

by_id = {o["id"]: o for o in objects}
by_import = {o.get("importOriginalId"): o for o in objects if o.get("importOriginalId")}

# --- layout zones (large canvas ~4200 x 2600) ---
W_SYS, H_SYS = 260, 110
W_APP, H_APP = 220, 95
W_ACT, H_ACT = 220, 100

diagram_objects = {}
do_for_model = {}

def add_do(key, model_id, otype, x, y, w, h, parent=None):
    entry = {
        "id": key,
        "modelId": model_id,
        "type": otype,
        "shape": "box",
        "x": x,
        "y": y,
        "width": w,
        "height": h,
    }
    if parent:
        entry["parentId"] = parent
    diagram_objects[key] = entry
    do_for_model[model_id] = key

def add_area(key, model_id, x, y, w, h):
    diagram_objects[key] = {
        "id": key,
        "modelId": model_id,
        "type": "group",
        "shape": "area",
        "x": x,
        "y": y,
        "width": w,
        "height": h,
    }
    do_for_model[model_id] = key

# Areas
area_homelab = "area-homelab"
area_gov = "area-governance"
area_aireview = "area-aireview"
area_data = "area-data"
area_externals = "area-externals"

if "vlxpv0ObZvMTmlY1LNru" in by_id:
    add_area(area_homelab, "vlxpv0ObZvMTmlY1LNru", 320, 320, 720, 520)
if "Ab1BI62SUEIfn4JHMmkY" in by_id:
    add_area(area_gov, "Ab1BI62SUEIfn4JHMmkY", 320, 900, 720, 380)
if "S7ChzZCil6w5SixPc9yh" in by_id:
    add_area(area_data, "S7ChzZCil6w5SixPc9yh", 2120, 320, 820, 960)

# AI PR review band - no area wrapper (system is not a group)
AIREVIEW_X = 1080
add_do("do-operator", "TzxKu9jYZJyG9YQuYeEX", "actor", 40, 480, W_ACT, H_ACT)
add_do("do-agents", "wdEjC1pfpdliKPJa1SNa", "actor", 40, 640, W_ACT, H_ACT)

# GitHub hub (center spine)
add_do("do-github", "5wBngeCOekozxQaNKbCN", "system", 860, 120, 300, 120)

# Externals top row
ext_y = 40
ext_x = 1280
ext_ids = [
    "lc5wm71XbLTKBMIlhGSL",  # Doppler
    "QzeK7d4BvVgeSTkvrqc0",  # Cloudflare
    "a4Ye2RduBbuSKocU0y93",  # LLM runtimes
    "fBRxx9piJNoWhecTVSqp",  # Search providers
    "aZaKxiYMZ6Q3blofRMsh",  # Linear
    "00g87kidVb2u2UCX6D8E",  # frozenSkillz
]
for i, mid in enumerate(ext_ids):
    if mid in by_id:
        o = by_id[mid]
        add_do(f"do-ext-{i}", mid, o["type"], ext_x + i * 280, ext_y, W_SYS, H_SYS)

# Homelab cluster inside area
homelab_layout = [
    ("TwpQ6c0P5EAziZyIKNTy", 360, 380, "system"),  # Homelab Platform
    ("xWsoNAvV3Dm7zRTTJCqX", 360, 520, "app"),     # Proxmox
    ("QdPtEM2FRZrcqF8JD38L", 620, 520, "app"),     # Talos
    ("MpRhQjqByiLr5YceVarb", 620, 660, "app"),     # Qwen LXC
]
for mid, x, y, t in homelab_layout:
    if mid in by_id:
        w, h = (W_SYS, H_SYS) if t == "system" else (W_APP, H_APP)
        add_do(f"do-h-{mid[:6]}", mid, t, x, y, w, h, area_homelab)

# Governance inside area
gov_layout = [
    ("LR0pM5V6J5X3rDTxObwS", 360, 940, "system"),
    ("pFE6co2KK3HyqJgkwXzj", 360, 1080, "app"),  # Guardian
    ("NuXP843vvNEwY06RrUbu", 620, 1080, "app"),  # PRAgent
]
for mid, x, y, t in gov_layout:
    if mid in by_id:
        w, h = (W_SYS, H_SYS) if t == "system" else (W_APP, H_APP)
        add_do(f"do-g-{mid[:6]}", mid, t, x, y, w, h, area_gov)

# AI PR Review pipeline (right center - dense row)
aireview_layout = [
    ("vfiraZL9zlC53x6saWT2", AIREVIEW_X, 360, "system"),
    ("D1kHVFUTBL23yW0UBDxg", AIREVIEW_X, 500, "app"),
    ("kHi8SBWeX7mvi234tAbl", AIREVIEW_X + 240, 500, "app"),
    ("OyzKKf3fzSJKsrB7c9jX", AIREVIEW_X + 480, 500, "app"),
    ("2mheYeoY30HpnGBL7IKs", AIREVIEW_X + 720, 500, "app"),
    ("zBsSgLaXIh5Dx0Atsd8L", AIREVIEW_X + 480, 640, "app"),
    ("Ow02lvMoGzbLYW3VxouY", AIREVIEW_X + 720, 640, "store"),
]
for mid, x, y, t in aireview_layout:
    if mid in by_id:
        w, h = (W_SYS, H_SYS) if t == "system" else (W_APP, H_APP)
        add_do(f"do-ar-{mid[:6]}", mid, t, x, y, w, h, None)

# Data / search / archive / corpus (far right)
data_layout = [
    ("KSFOe5pCnNLC3pAlexNZ", 2160, 380, "system"),   # ColdSearch
    ("AZ2PK56G0IweXTRsVzd8", 2160, 520, "app"),
    ("CeIoHeGfqAf89BE2ombJ", 2400, 380, "system"),   # Archive
    ("aSGY2iXy7j3fgQ9Q1Hf0", 2400, 520, "app"),
    ("sEQBYlNn4fn1sTXTOZ8B", 2640, 380, "system"),   # Corpus
    ("0tAiPOH554uqpXwLOQeo", 2640, 520, "app"),
    ("aUCX6dpnsQEEsuivcbdn", 2160, 720, "system"),   # Tools
    ("vffQBjnrkEKDGFCgKJ3v", 2400, 720, "system"),   # Control
]
for mid, x, y, t in data_layout:
    if mid in by_id:
        w, h = (W_SYS, H_SYS) if t == "system" else (W_APP, H_APP)
        add_do(f"do-d-{mid[:6]}", mid, t, x, y, w, h, area_data)

# Diagram connections - all model connections
diagram_connections = {}
for i, c in enumerate(connections):
    oid, tid = c["originId"], c["targetId"]
    if oid not in do_for_model or tid not in do_for_model:
        continue
    diagram_connections[f"dc-{i}"] = {
        "id": f"dc-{i}",
        "modelId": c["id"],
        "originId": do_for_model[oid],
        "targetId": do_for_model[tid],
        "lineShape": "square",
        "originConnector": "right-middle",
        "targetConnector": "left-middle",
        "labelPosition": 0.5,
        "points": [],
    }

# Flip connectors for edges going left/up as needed - simple heuristic
for dc in diagram_connections.values():
    o_key = dc["originId"]
    t_key = dc["targetId"]
    ox = diagram_objects[o_key]["x"]
    tx = diagram_objects[t_key]["x"]
    if tx < ox:
        dc["originConnector"] = "left-middle"
        dc["targetConnector"] = "right-middle"

body = {
    "name": "Patrick Portfolio - Master Map",
    "handleId": "portfolio-master",
    "type": "context-diagram",
    "modelId": DOMAIN_ID,
    "index": 0,
    "pinned": True,
    "description": "Single unified canvas: homelab, governance, BYOK PR review, search, archive, corpus, externals, all connections.",
    "objects": diagram_objects,
    "connections": diagram_connections,
    "comments": {},
}

out = ROOT / "imports/diagrams/portfolio-master.json"
out.write_text(json.dumps(body, indent=2), encoding="utf-8")
print(f"Wrote {out}")
print(f"objects={len(diagram_objects)} connections={len(diagram_connections)}")
