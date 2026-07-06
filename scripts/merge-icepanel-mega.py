#!/usr/bin/env python3
"""Merge satellite IcePanel import JSON models into Patrick Portfolio."""

from __future__ import annotations

import json
import math
import os
import sys
import time
import urllib.error
import urllib.request
from pathlib import Path

LANDSCAPE_ID = "Efdez5uW6BfQjErrQ4Gx"
BASE = "https://api.icepanel.io/v1"
REPO = Path(__file__).resolve().parent.parent
IMPORTS = REPO / "imports" / "archive" / "models"

# Satellite sources to merge (portfolio is already the target landscape; we only add satellites).
SATELLITES = [
    ("k8s", "k8s.json"),
    ("gov", "governance.json"),
    ("cs", "coldsearch.json"),
    ("arch", "archiver.json"),
]

# Domains we force into portfolio so satellite clusters have homes.
DOMAIN_SEEDS = [
    ("dom-homelab", "Homelab / K8s", "Kubernetes cluster and host path (merged from k8s landscape)."),
    ("dom-pr-review", "PR Review Runtime", "AI-assisted PR review pipeline (merged from portfolio expansion)."),
    ("dom-governance", "Governance / Policy", "Policy engines and compliance (merged from governance landscape)."),
    ("dom-coldsearch", "Coldsearch / Retrieval", "Search and retrieval stack (merged from coldsearch landscape)."),
    ("dom-archiver", "Archiver / Storage", "Long-term archive and retention (merged from archiver landscape)."),
]


def api(method: str, path: str, body: dict | None = None) -> dict | list | None:
    key = os.environ.get("ICEPANEL_API_KEY")
    if not key:
        raise SystemExit("ICEPANEL_API_KEY missing")
    url = f"{BASE}{path}"
    data = None if body is None else json.dumps(body).encode()
    req = urllib.request.Request(
        url,
        data=data,
        method=method,
        headers={
            "Authorization": f"ApiKey {key}",
            "Content-Type": "application/json",
            "Accept": "application/json",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            raw = resp.read().decode()
            return json.loads(raw) if raw else None
    except urllib.error.HTTPError as e:
        err = e.read().decode(errors="replace")
        raise RuntimeError(f"{method} {path} -> {e.code}: {err[:500]}") from e


def load_import(name: str) -> dict:
    path = IMPORTS / name
    return json.loads(path.read_text(encoding="utf-8"))


def main() -> int:
    # Discover version
    landscape = api("GET", f"/landscapes/{LANDSCAPE_ID}")
    version_id = (
        landscape.get("landscape", {}).get("inProgressVersionId")
        or landscape.get("inProgressVersionId")
        or landscape.get("landscape", {}).get("versions", [{}])[0].get("id")
    )
    if not version_id:
        # fall back to known version from prior runs
        version_id = "XfUcaibutBRgTzMrizFw"
    print(f"landscape={LANDSCAPE_ID} version={version_id}")

    models_resp = api("GET", f"/landscapes/{LANDSCAPE_ID}/versions/{version_id}/models")
    models = models_resp.get("modelObjects", models_resp.get("models", models_resp))
    if isinstance(models, dict):
        models = list(models.values())
    existing_by_name = {((m.get("name") or "").strip().lower()): m for m in models}
    existing_ids = {m.get("id") for m in models if m.get("id")}
    print(f"existing models: {len(models)}")

    # Ensure cluster domains exist
    for dom_id, name, desc in DOMAIN_SEEDS:
        if name.lower() in existing_by_name:
            print(f"domain exists: {name}")
            continue
        created = api(
            "POST",
            f"/landscapes/{LANDSCAPE_ID}/versions/{version_id}/models",
            {
                "type": "root",
                "name": name,
                "description": desc,
                "status": "future",
                "icon": "cube",
            },
        )
        obj = created.get("modelObject", created)
        existing_by_name[name.lower()] = obj
        existing_ids.add(obj.get("id"))
        print(f"created domain: {name} -> {obj.get('id')}")
        time.sleep(0.15)

    # Map satellite domain-ish names to portfolio domain ids
    domain_map = {
        "homelab": existing_by_name.get("homelab / k8s", {}).get("id"),
        "k8s": existing_by_name.get("homelab / k8s", {}).get("id"),
        "kubernetes": existing_by_name.get("homelab / k8s", {}).get("id"),
        "pr review": existing_by_name.get("pr review runtime", {}).get("id"),
        "ai pr review": existing_by_name.get("pr review runtime", {}).get("id"),
        "governance": existing_by_name.get("governance / policy", {}).get("id"),
        "policy": existing_by_name.get("governance / policy", {}).get("id"),
        "coldsearch": existing_by_name.get("coldsearch / retrieval", {}).get("id"),
        "retrieval": existing_by_name.get("coldsearch / retrieval", {}).get("id"),
        "archiver": existing_by_name.get("archiver / storage", {}).get("id"),
        "storage": existing_by_name.get("archiver / storage", {}).get("id"),
    }

    id_remap: dict[str, str] = {}  # satellite_id -> portfolio_id
    created_count = 0
    skipped_count = 0

    for prefix, filename in SATELLITES:
        payload = load_import(filename)
        objs = payload.get("objects") or payload.get("modelObjects") or []
        cons = payload.get("connections") or payload.get("modelConnections") or []
        print(f"\n=== satellite {prefix}: {filename} objects={len(objs)} connections={len(cons)}")

        # Pass 1: create/map objects
        for obj in objs:
            old_id = obj.get("id")
            name = (obj.get("name") or "").strip()
            if not name or not old_id:
                continue
            key = name.lower()
            if key in existing_by_name:
                id_remap[old_id] = existing_by_name[key]["id"]
                skipped_count += 1
                continue

            # parent: prefer mapped parent, else domain by nameserver hint
            parent_id = None
            old_parent = obj.get("parentId") or obj.get("parent")
            if old_parent and old_parent in id_remap:
                parent_id = id_remap[old_parent]
            else:
                # best-effort: attach top-level to satellite domain
                for token, dom_id in domain_map.items():
                    if token in key or token in (obj.get("description") or "").lower():
                        parent_id = dom_id
                        break
                if not parent_id:
                    # default by satellite prefix
                    defaults = {
                        "k8s": "homelab",
                        "gov": "governance",
                        "cs": "coldsearch",
                        "arch": "archiver",
                    }
                    parent_id = domain_map.get(defaults[prefix])

            body = {
                "type": obj.get("type") or "app",
                "name": name,
                "description": (obj.get("description") or "")[:2000],
                "status": obj.get("status") or "live",
                "icon": obj.get("icon") or "cube",
            }
            if parent_id:
                body["parentId"] = parent_id

            try:
                created = api(
                    "POST",
                    f"/landscapes/{LANDSCAPE_ID}/versions/{version_id}/models",
                    body,
                )
                new_obj = created.get("modelObject", created)
                new_id = new_obj.get("id")
                id_remap[old_id] = new_id
                existing_by_name[key] = new_obj
                existing_ids.add(new_id)
                created_count += 1
                if created_count % 10 == 0:
                    print(f"  created {created_count} objects...")
                time.sleep(0.12)
            except Exception as e:
                print(f"  FAIL object {name}: {e}")

        # Pass 2: connections
        conn_ok = 0
        for con in cons:
            # IcePanel import formats vary
            src = con.get("originId") or con.get("source") or con.get("from") or con.get("origin")
            dst = con.get("targetId") or con.get("target") or con.get("to") or con.get("destination")
            name = con.get("name") or con.get("label") or ""
            src_id = id_remap.get(src, src if src in existing_ids else None)
            dst_id = id_remap.get(dst, dst if dst in existing_ids else None)
            if not src_id or not dst_id or src_id == dst_id:
                continue
            body = {
                "name": name[:120] if name else "uses",
                "originId": src_id,
                "targetId": dst_id,
                "direction": con.get("direction") or "outgoing",
                "style": con.get("style") or "solid",
            }
            try:
                api(
                    "POST",
                    f"/landscapes/{LANDSCAPE_ID}/versions/{version_id}/model-connections",
                    body,
                )
                conn_ok += 1
                time.sleep(0.08)
            except Exception as e:
                # try alternate path
                try:
                    api(
                        "POST",
                        f"/landscapes/{LANDSCAPE_ID}/versions/{version_id}/connections",
                        body,
                    )
                    conn_ok += 1
                except Exception as e2:
                    print(f"  FAIL conn {name}: {e2}")
        print(f"  connections posted: {conn_ok}")

    print(f"\nobjects created={created_count} skipped_existing={skipped_count}")

    # Refresh models
    models_resp = api("GET", f"/landscapes/{LANDSCAPE_ID}/versions/{version_id}/models")
    models = models_resp.get("modelObjects", models_resp.get("models", models_resp))
    if isinstance(models, dict):
        models = list(models.values())
    print(f"total models now: {len(models)}")

    # Delete prior diagrams (thin alternate tabs)
    try:
        diagrams = api("GET", f"/landscapes/{LANDSCAPE_ID}/versions/{version_id}/diagrams")
        dlist = diagrams.get("diagrams", diagrams)
        if isinstance(dlist, dict):
            dlist = list(dlist.values())
        for d in dlist or []:
            did = d.get("id")
            if not did:
                continue
            try:
                api("DELETE", f"/landscapes/{LANDSCAPE_ID}/versions/{version_id}/diagrams/{did}")
                print(f"deleted diagram {d.get('name')} ({did})")
                time.sleep(0.1)
            except Exception as e:
                print(f"could not delete diagram {did}: {e}")
    except Exception as e:
        print(f"diagram list failed: {e}")

    # One dense diagram: grid all non-root/groupish objects
    roots = [m for m in models if (m.get("type") or "") in ("root", "group", "domain")]
    leaves = [m for m in models if m.get("id") and m not in roots]
    # prefer showing everything that has a name
    show = [m for m in models if m.get("name") and m.get("id")]
    show.sort(key=lambda m: ((m.get("type") or ""), (m.get("name") or "").lower()))

    cols = max(8, int(math.ceil(math.sqrt(len(show) * 1.4))))
    cell_w, cell_h = 280, 160
    objects = {}
    for i, m in enumerate(show):
        col = i % cols
        row = i // cols
        oid = f"do-{i}"
        objects[oid] = {
            "id": oid,
            "modelId": m["id"],
            "type": m.get("type") or "app",
            "name": m.get("name"),
            "x": 40 + col * cell_w,
            "y": 40 + row * cell_h,
            "width": 240,
            "height": 120,
        }

    diagram_body = {
        "name": "Patrick Portfolio - FULL SYSTEM (all clusters)",
        "type": "graph",
        "objects": objects,
        "connections": {},
        "description": (
            "Single dense canvas: portfolio + k8s + governance + coldsearch + archiver + PR review. "
            "No alternate tabs. Edit this diagram only."
        ),
    }
    created = api(
        "POST",
        f"/landscapes/{LANDSCAPE_ID}/versions/{version_id}/diagrams",
        diagram_body,
    )
    diagram = created.get("diagram", created)
    print(f"\nMEGA DIAGRAM id={diagram.get('id')} objects={len(objects)}")
    print(f"URL: https://app.icepanel.io/landscapes/{LANDSCAPE_ID}/versions/{version_id}/diagrams/{diagram.get('id')}")
    return 0


if __name__ == "__main__":
    try:
        raise SystemExit(main())
    except Exception as e:
        print(f"FATAL: {e}", file=sys.stderr)
        raise
