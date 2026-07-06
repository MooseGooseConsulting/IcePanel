#!/usr/bin/env python3
"""Generate portfolio-variant-c-layer-stack.json DiagramCreate payload."""
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MODEL_PATH = ROOT / "reports" / "portfolio-model-map.json"
OUT_PATH = ROOT / "imports" / "diagrams" / "portfolio-variant-c-layer-stack.json"

BOX_W, BOX_H = 240, 100
APP_W, APP_H = 200, 90
STORE_W, STORE_H = 180, 80
ACTOR_W, ACTOR_H = 200, 90
COL = 260

# modelId -> diagram object key
KEY = {
    "00g87kidVb2u2UCX6D8E": "do-ext-frozenskillz",
    "0tAiPOH554uqpXwLOQeo": "do-app-corpus-queue",
    "2mheYeoY30HpnGBL7IKs": "do-app-aireview",
    "5wBngeCOekozxQaNKbCN": "do-ext-github",
    "AZ2PK56G0IweXTRsVzd8": "do-app-coldsearch-cli",
    "Ab1BI62SUEIfn4JHMmkY": "do-area-governance",
    "CeIoHeGfqAf89BE2ombJ": "do-sys-archive",
    "D1kHVFUTBL23yW0UBDxg": "do-app-workflow",
    "KSFOe5pCnNLC3pAlexNZ": "do-sys-coldsearch",
    "LR0pM5V6J5X3rDTxObwS": "do-sys-governance",
    "MpRhQjqByiLr5YceVarb": "do-app-qwen",
    "NuXP843vvNEwY06RrUbu": "do-app-pragent",
    "Ow02lvMoGzbLYW3VxouY": "do-store-policy",
    "OyzKKf3fzSJKsrB7c9jX": "do-app-openhands",
    "QdPtEM2FRZrcqF8JD38L": "do-app-talos",
    "QzeK7d4BvVgeSTkvrqc0": "do-ext-cloudflare",
    "S7ChzZCil6w5SixPc9yh": "do-area-data",
    "TwpQ6c0P5EAziZyIKNTy": "do-sys-homelab",
    "TzxKu9jYZJyG9YQuYeEX": "do-actor-operator",
    "a4Ye2RduBbuSKocU0y93": "do-ext-llm",
    "aSGY2iXy7j3fgQ9Q1Hf0": "do-app-archiver",
    "aUCX6dpnsQEEsuivcbdn": "do-sys-tools",
    "aZaKxiYMZ6Q3blofRMsh": "do-ext-linear",
    "fBRxx9piJNoWhecTVSqp": "do-ext-search-providers",
    "kHi8SBWeX7mvi234tAbl": "do-app-runner",
    "kpRaY0I26jePPy6lnsza": "do-root-domain",
    "lc5wm71XbLTKBMIlhGSL": "do-ext-doppler",
    "pFE6co2KK3HyqJgkwXzj": "do-app-guardian",
    "plj099xOqpHenbwyEZ2x": "do-root-empty",
    "sEQBYlNn4fn1sTXTOZ8B": "do-sys-corpus",
    "vffQBjnrkEKDGFCgKJ3v": "do-sys-control",
    "vfiraZL9zlC53x6saWT2": "do-area-aireview-pipeline",
    "vlxpv0ObZvMTmlY1LNru": "do-area-platform",
    "wdEjC1pfpdliKPJa1SNa": "do-actor-agents",
    "xWsoNAvV3Dm7zRTTJCqX": "do-app-proxmox",
    "zBsSgLaXIh5Dx0Atsd8L": "do-app-litellm",
}

def box(do_id, model_id, obj_type, x, y, w=BOX_W, h=BOX_H, shape="box", parent_id=None):
    o = {
        "id": do_id,
        "modelId": model_id,
        "type": obj_type,
        "shape": shape,
        "x": x,
        "y": y,
        "width": w,
        "height": h,
    }
    if parent_id:
        o["parentId"] = parent_id
    return o


def build_objects():
    objs = {}

    # Band 1 — EXTERNALS (y=60 content row)
    externals = [
        ("do-ext-github", "5wBngeCOekozxQaNKbCN", "system"),
        ("do-ext-doppler", "lc5wm71XbLTKBMIlhGSL", "system"),
        ("do-ext-cloudflare", "QzeK7d4BvVgeSTkvrqc0", "system"),
        ("do-ext-llm", "a4Ye2RduBbuSKocU0y93", "system"),
        ("do-ext-linear", "aZaKxiYMZ6Q3blofRMsh", "system"),
        ("do-ext-search-providers", "fBRxx9piJNoWhecTVSqp", "system"),
        ("do-ext-frozenskillz", "00g87kidVb2u2UCX6D8E", "system"),
    ]
    for i, (dk, mid, t) in enumerate(externals):
        objs[dk] = box(dk, mid, t, 80 + i * COL, 60, BOX_W, BOX_H)

    # Band 2 — PLATFORM (y=280)
    objs["do-area-platform"] = box(
        "do-area-platform",
        "vlxpv0ObZvMTmlY1LNru",
        "group",
        60,
        280,
        1280,
        200,
        shape="area",
    )
    objs["do-sys-homelab"] = box(
        "do-sys-homelab",
        "TwpQ6c0P5EAziZyIKNTy",
        "system",
        90,
        310,
        280,
        100,
        parent_id="do-area-platform",
    )
    platform_apps = [
        ("do-app-proxmox", "xWsoNAvV3Dm7zRTTJCqX"),
        ("do-app-talos", "QdPtEM2FRZrcqF8JD38L"),
        ("do-app-qwen", "MpRhQjqByiLr5YceVarb"),
    ]
    for i, (dk, mid) in enumerate(platform_apps):
        objs[dk] = box(
            dk, mid, "app", 400 + i * 280, 330, APP_W, APP_H, parent_id="do-area-platform"
        )

    # Band 3 — APPLICATIONS (y=560)
    objs["do-area-data"] = box(
        "do-area-data", "S7ChzZCil6w5SixPc9yh", "group", 60, 560, 720, 280, shape="area"
    )
    objs["do-sys-coldsearch"] = box(
        "do-sys-coldsearch",
        "KSFOe5pCnNLC3pAlexNZ",
        "system",
        90,
        590,
        BOX_W,
        BOX_H,
        parent_id="do-area-data",
    )
    objs["do-app-coldsearch-cli"] = box(
        "do-app-coldsearch-cli",
        "AZ2PK56G0IweXTRsVzd8",
        "app",
        90,
        710,
        APP_W,
        APP_H,
        parent_id="do-area-data",
    )
    objs["do-sys-archive"] = box(
        "do-sys-archive", "CeIoHeGfqAf89BE2ombJ", "system", 360, 590, BOX_W, BOX_H, parent_id="do-area-data"
    )
    objs["do-app-archiver"] = box(
        "do-app-archiver",
        "aSGY2iXy7j3fgQ9Q1Hf0",
        "app",
        360,
        710,
        APP_W,
        APP_H,
        parent_id="do-area-data",
    )
    objs["do-sys-corpus"] = box(
        "do-sys-corpus", "sEQBYlNn4fn1sTXTOZ8B", "system", 600, 590, BOX_W, BOX_H, parent_id="do-area-data"
    )
    objs["do-app-corpus-queue"] = box(
        "do-app-corpus-queue",
        "0tAiPOH554uqpXwLOQeo",
        "app",
        600,
        710,
        APP_W,
        APP_H,
        parent_id="do-area-data",
    )

    objs["do-sys-tools"] = box("do-sys-tools", "aUCX6dpnsQEEsuivcbdn", "system", 820, 620, BOX_W, BOX_H)
    objs["do-sys-control"] = box("do-sys-control", "vffQBjnrkEKDGFCgKJ3v", "system", 820, 740, BOX_W, BOX_H)

    objs["do-area-governance"] = box(
        "do-area-governance", "Ab1BI62SUEIfn4JHMmkY", "group", 1100, 560, 520, 280, shape="area"
    )
    objs["do-sys-governance"] = box(
        "do-sys-governance",
        "LR0pM5V6J5X3rDTxObwS",
        "system",
        1130,
        590,
        BOX_W,
        BOX_H,
        parent_id="do-area-governance",
    )
    objs["do-app-guardian"] = box(
        "do-app-guardian",
        "pFE6co2KK3HyqJgkwXzj",
        "app",
        1130,
        710,
        APP_W,
        APP_H,
        parent_id="do-area-governance",
    )
    objs["do-app-pragent"] = box(
        "do-app-pragent",
        "NuXP843vvNEwY06RrUbu",
        "app",
        1370,
        710,
        APP_W,
        APP_H,
        parent_id="do-area-governance",
    )

    # AI PR Review Pipeline system + children in row
    objs["do-area-aireview-pipeline"] = box(
        "do-area-aireview-pipeline",
        "vfiraZL9zlC53x6saWT2",
        "system",
        1660,
        580,
        1520,
        90,
    )
    pipeline_children = [
        ("do-app-workflow", "D1kHVFUTBL23yW0UBDxg", "app"),
        ("do-app-runner", "kHi8SBWeX7mvi234tAbl", "app"),
        ("do-app-openhands", "OyzKKf3fzSJKsrB7c9jX", "app"),
        ("do-app-aireview", "2mheYeoY30HpnGBL7IKs", "app"),
        ("do-app-litellm", "zBsSgLaXIh5Dx0Atsd8L", "app"),
        ("do-store-policy", "Ow02lvMoGzbLYW3VxouY", "store"),
    ]
    for i, (dk, mid, t) in enumerate(pipeline_children):
        w, h = (STORE_W, STORE_H) if t == "store" else (APP_W, APP_H)
        objs[dk] = box(dk, mid, t, 1680 + i * 250, 700, w, h)

    # Band 4 — ACTORS (y=900)
    objs["do-actor-operator"] = box(
        "do-actor-operator", "TzxKu9jYZJyG9YQuYeEX", "actor", 200, 900, ACTOR_W, ACTOR_H
    )
    objs["do-actor-agents"] = box(
        "do-actor-agents", "wdEjC1pfpdliKPJa1SNa", "actor", 520, 900, ACTOR_W, ACTOR_H
    )

    # Domain roots (corner metadata)
    objs["do-root-domain"] = box(
        "do-root-domain", "kpRaY0I26jePPy6lnsza", "root", 3380, 40, 200, 60
    )
    objs["do-root-empty"] = box(
        "do-root-empty", "plj099xOqpHenbwyEZ2x", "root", 3380, 110, 120, 40
    )

    return objs


def connector_for_layer(origin_y, target_y):
    """Pick connectors for vertical layer flow."""
    if origin_y < target_y:
        return "bottom-center", "top-center"
    if origin_y > target_y:
        return "top-center", "bottom-center"
    return "right-middle", "left-middle"


def build_connections(model, objs):
    mid_to_do = {v["modelId"]: k for k, v in objs.items()}
    conns = {}
    idx = 0
    for c in model["connections"]:
        oid, tid = c["originId"], c["targetId"]
        if oid not in mid_to_do or tid not in mid_to_do:
            continue
        do_o, do_t = mid_to_do[oid], mid_to_do[tid]
        oy = objs[do_o]["y"]
        ty = objs[do_t]["y"]
        oc, tc = connector_for_layer(oy, ty)
        # GitHub review chain: prefer horizontal square routing at externals band
        if mid_to_do.get(oid) == "do-ext-github" or mid_to_do.get(tid) == "do-ext-github":
            if oy == ty:
                oc, tc = "right-middle", "left-middle"
            elif oy > ty:
                oc, tc = "top-center", "bottom-center"
            else:
                oc, tc = "bottom-center", "top-center"
        cid = f"dc-{idx}"
        conns[cid] = {
            "id": cid,
            "modelId": c["id"],
            "originId": do_o,
            "targetId": do_t,
            "lineShape": "square",
            "originConnector": oc,
            "targetConnector": tc,
            "labelPosition": 0.5,
            "points": [],
        }
        idx += 1
    return conns


def main():
    with open(MODEL_PATH, encoding="utf-8-sig") as f:
        model = json.load(f)

    objects = build_objects()
    assert len(objects) == 36, f"expected 36 objects, got {len(objects)}"

    connections = build_connections(model, objects)

    payload = {
        "name": "Portfolio — Layer Stack (C)",
        "handleId": "portfolio-variant-c-layer-stack",
        "type": "context-diagram",
        "modelId": "kpRaY0I26jePPy6lnsza",
        "index": 3,
        "objects": objects,
        "connections": connections,
        "comments": {},
    }

    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    with open(OUT_PATH, "w", encoding="utf-8") as f:
        json.dump(payload, f, indent=2, ensure_ascii=True)
        f.write("\n")

    print(f"Wrote {OUT_PATH}")
    print(f"objects: {len(objects)}")
    print(f"connections: {len(connections)}")


if __name__ == "__main__":
    main()
