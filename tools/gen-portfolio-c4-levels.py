#!/usr/bin/env python3
"""Generate proper C4 multi-level diagrams for Patrick Portfolio."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MAP = json.loads((ROOT / "reports/portfolio-model-map.json").read_text(encoding="utf-8-sig"))
OUT = ROOT / "imports/diagrams"

DOMAIN_ID = MAP["domainId"]
objects = [o for o in MAP["objects"] if o["type"] != "root" and o.get("name")]
by_id = {o["id"]: o for o in objects}
connections = MAP["connections"]

W_SYS, H_SYS = 280, 120
W_APP, H_APP = 240, 100
W_ACT = 220
GAP = 260


def conn_for(do_map, conns):
    dcs = {}
    n = 0
    for c in conns:
        o, t = c["originId"], c["targetId"]
        if o not in do_map or t not in do_map:
            continue
        dcs[f"dc-{n}"] = {
            "id": f"dc-{n}",
            "modelId": c["id"],
            "originId": do_map[o],
            "targetId": do_map[t],
            "lineShape": "square",
            "originConnector": "right-middle",
            "targetConnector": "left-middle",
            "labelPosition": 0.5,
            "points": [],
        }
        n += 1
    return dcs


def write_diagram(name, handle, dtype, model_id, index, pinned, objs, conns, desc=""):
    body = {
        "name": name,
        "handleId": handle,
        "type": dtype,
        "modelId": model_id,
        "index": index,
        "pinned": pinned,
        "description": desc,
        "objects": objs,
        "connections": conns,
        "comments": {},
    }
    path = OUT / f"{handle}.json"
    path.write_text(json.dumps(body, indent=2), encoding="utf-8")
    print(f"  {path.name}: objects={len(objs)} connections={len(conns)} type={dtype}")


# --- L1 Context: actors + systems + externals ONLY (no apps/stores/components) ---
print("L1 Context")
l1_objs = {}
l1_do = {}
y = 80
# actors left
for i, mid in enumerate(["TzxKu9jYZJyG9YQuYeEX", "wdEjC1pfpdliKPJa1SNa"]):
    if mid not in by_id:
        continue
    o = by_id[mid]
    k = f"do-{i}"
    l1_objs[k] = {"id": k, "modelId": mid, "type": "actor", "shape": "box", "x": 80, "y": y + i * 140, "width": W_ACT, "height": 100}
    l1_do[mid] = k

# internal systems center
internal = [
    "TwpQ6c0P5EAziZyIKNTy",  # Homelab
    "LR0pM5V6J5X3rDTxObwS",  # Governance
    "vfiraZL9zlC53x6saWT2",  # AI PR Review
    "KSFOe5pCnNLC3pAlexNZ",  # ColdSearch
    "CeIoHeGfqAf89BE2ombJ",  # Archive
    "sEQBYlNn4fn1sTXTOZ8B",  # Corpus
    "aUCX6dpnsQEEsuivcbdn",  # Tools
    "vffQBjnrkEKDGFCgKJ3v",  # Control
]
for i, mid in enumerate(internal):
    if mid not in by_id:
        continue
    k = f"do-sys-{i}"
    l1_objs[k] = {"id": k, "modelId": mid, "type": "system", "shape": "box", "x": 400, "y": 80 + i * 130, "width": W_SYS, "height": H_SYS}
    l1_do[mid] = k

# externals right
externals = [
    "5wBngeCOekozxQaNKbCN",
    "lc5wm71XbLTKBMIlhGSL",
    "QzeK7d4BvVgeSTkvrqc0",
    "a4Ye2RduBbuSKocU0y93",
    "fBRxx9piJNoWhecTVSqp",
    "aZaKxiYMZ6Q3blofRMsh",
    "00g87kidVb2u2UCX6D8E",
]
for i, mid in enumerate(externals):
    if mid not in by_id:
        continue
    k = f"do-ext-{i}"
    l1_objs[k] = {"id": k, "modelId": mid, "type": "system", "shape": "box", "x": 780, "y": 80 + i * 110, "width": W_SYS, "height": H_SYS}
    l1_do[mid] = k

# L1 connections: only between objects on this diagram
l1_conn_ids = set(l1_do.keys())
l1_conns = [c for c in connections if c["originId"] in l1_conn_ids and c["targetId"] in l1_conn_ids]

write_diagram(
    "Portfolio - Context (L1)",
    "portfolio-l1-context",
    "context-diagram",
    DOMAIN_ID,
    0,
    True,
    l1_objs,
    conn_for(l1_do, l1_conns),
    "C4 Level 1: actors, portfolio systems, external systems. Drill into L2 app diagrams per system.",
)


def app_diagram(system_id, system_name, slug, index, child_filter=None):
    """L2 app-diagram for one system."""
    if system_id not in by_id:
        return
    apps = [o for o in objects if o.get("parentId") == system_id and o["type"] in ("app", "store")]
    if child_filter:
        apps = [a for a in apps if child_filter(a)]
    if not apps:
        return
    objs = {}
    do_map = {system_id: "do-sys"}
    objs["do-sys"] = {
        "id": "do-sys",
        "modelId": system_id,
        "type": "system",
        "shape": "box",
        "x": 80,
        "y": 200,
        "width": W_SYS,
        "height": H_SYS,
    }
    for i, a in enumerate(apps):
        k = f"do-app-{i}"
        objs[k] = {
            "id": k,
            "modelId": a["id"],
            "type": a["type"],
            "shape": "box",
            "x": 420 + (i % 3) * GAP,
            "y": 80 + (i // 3) * 140,
            "width": W_APP,
            "height": H_APP,
        }
        do_map[a["id"]] = k
    # connections internal + to/from system
    app_ids = {a["id"] for a in apps} | {system_id}
    rel = [c for c in connections if c["originId"] in app_ids and c["targetId"] in app_ids]
    write_diagram(
        f"{system_name} - Containers (L2)",
        f"portfolio-l2-{slug}",
        "app-diagram",
        system_id,
        index,
        False,
        objs,
        conn_for(do_map, rel),
        f"C4 Level 2: apps and stores inside {system_name}.",
    )


print("L2 App diagrams")
systems_l2 = [
    ("TwpQ6c0P5EAziZyIKNTy", "Homelab Platform", "homelab", 1),
    ("vfiraZL9zlC53x6saWT2", "AI PR Review Pipeline", "aireview", 2),
    ("LR0pM5V6J5X3rDTxObwS", "Agent Governance", "governance", 3),
    ("KSFOe5pCnNLC3pAlexNZ", "ColdSearch", "coldsearch", 4),
    ("CeIoHeGfqAf89BE2ombJ", "LLM Conversation Archive", "archive", 5),
    ("sEQBYlNn4fn1sTXTOZ8B", "Agent Learning Corpus", "corpus", 6),
]
for sid, name, slug, idx in systems_l2:
    app_diagram(sid, name, slug, idx)


def component_diagram(app_id, app_name, slug, index):
    if app_id not in by_id:
        return
    comps = [o for o in objects if o.get("parentId") == app_id and o["type"] == "component"]
    if not comps:
        return
    objs = {}
    do_map = {app_id: "do-app"}
    objs["do-app"] = {
        "id": "do-app",
        "modelId": app_id,
        "type": "app",
        "shape": "box",
        "x": 80,
        "y": 180,
        "width": W_APP,
        "height": H_APP,
    }
    for i, c in enumerate(comps):
        k = f"do-comp-{i}"
        objs[k] = {
            "id": k,
            "modelId": c["id"],
            "type": "component",
            "shape": "box",
            "x": 380 + i * 280,
            "y": 80,
            "width": 240,
            "height": 90,
        }
        do_map[c["id"]] = k
    comp_ids = {c["id"] for c in comps} | {app_id}
    rel = [c for c in connections if c["originId"] in comp_ids and c["targetId"] in comp_ids]
    write_diagram(
        f"{app_name} - Components (L3)",
        f"portfolio-l3-{slug}",
        "component-diagram",
        app_id,
        index,
        False,
        objs,
        conn_for(do_map, rel),
        f"C4 Level 3: components inside {app_name}.",
    )


print("L3 Component diagrams")
l3_apps = [
    ("D1kHVFUTBL23yW0UBDxg", "AI PR Review Workflow", "workflow", 10),
    ("OyzKKf3fzSJKsrB7c9jX", "OpenHands PR Review", "openhands", 11),
    ("zBsSgLaXIh5Dx0Atsd8L", "LiteLLM Gateway", "litellm", 12),
    ("pFE6co2KK3HyqJgkwXzj", "NorthStarGuardian", "guardian", 13),
    ("2mheYeoY30HpnGBL7IKs", "AI Review", "aireview-comp", 14),
]
for aid, name, slug, idx in l3_apps:
    component_diagram(aid, name, slug, idx)

print("Done.")
