#!/usr/bin/env python3
"""Generate portfolio-variant-d-pr-review-core.json."""
import json
from pathlib import Path

DOMAIN = "kpRaY0I26jePPy6lnsza"
REPO = Path(__file__).resolve().parent.parent
OUT = REPO / "imports" / "diagrams" / "portfolio-variant-d-pr-review-core.json"

OBJECTS = [
    ("TzxKu9jYZJyG9YQuYeEX", "do-op", "actor", 60, 500, 200, 100, "box"),
    ("wdEjC1pfpdliKPJa1SNa", "do-agents", "actor", 60, 640, 200, 100, "box"),
    ("5wBngeCOekozxQaNKbCN", "do-github", "system", 80, 300, 260, 110, "box"),
    ("lc5wm71XbLTKBMIlhGSL", "do-doppler", "system", 420, 30, 240, 100, "box"),
    ("QzeK7d4BvVgeSTkvrqc0", "do-cloudflare", "system", 700, 30, 240, 100, "box"),
    ("a4Ye2RduBbuSKocU0y93", "do-llm-ext", "system", 980, 30, 260, 100, "box"),
    ("fBRxx9piJNoWhecTVSqp", "do-search-prov", "system", 1280, 30, 260, 100, "box"),
    ("aZaKxiYMZ6Q3blofRMsh", "do-linear", "system", 1580, 30, 220, 100, "box"),
    ("00g87kidVb2u2UCX6D8E", "do-frozen", "system", 1580, 160, 220, 100, "box"),
    ("vfiraZL9zlC53x6saWT2", "area-aireview", "system", 260, 190, 980, 340, "area"),
    ("D1kHVFUTBL23yW0UBDxg", "do-workflow", "app", 300, 280, 200, 90, "box"),
    ("kHi8SBWeX7mvi234tAbl", "do-runner", "app", 500, 280, 200, 90, "box"),
    ("OyzKKf3fzSJKsrB7c9jX", "do-openhands", "app", 720, 230, 210, 90, "box"),
    ("2mheYeoY30HpnGBL7IKs", "do-aireview-app", "app", 720, 360, 210, 90, "box"),
    ("zBsSgLaXIh5Dx0Atsd8L", "do-litellm", "app", 940, 295, 200, 90, "box"),
    ("MpRhQjqByiLr5YceVarb", "do-qwen", "app", 1160, 295, 210, 90, "box"),
    ("Ow02lvMoGzbLYW3VxouY", "do-policy", "store", 940, 420, 200, 80, "box"),
    ("Ab1BI62SUEIfn4JHMmkY", "area-governance", "group", 460, 80, 840, 150, "area"),
    ("pFE6co2KK3HyqJgkwXzj", "do-guardian", "app", 500, 120, 220, 90, "box"),
    ("NuXP843vvNEwY06RrUbu", "do-pragent", "app", 760, 120, 200, 90, "box"),
    ("LR0pM5V6J5X3rDTxObwS", "do-gov-sys", "system", 1020, 120, 240, 90, "box"),
    ("aUCX6dpnsQEEsuivcbdn", "do-tools", "system", 300, 580, 240, 100, "box"),
    ("vffQBjnrkEKDGFCgKJ3v", "do-control", "system", 300, 460, 240, 100, "box"),
    ("vlxpv0ObZvMTmlY1LNru", "area-homelab", "group", 40, 760, 520, 320, "area"),
    ("TwpQ6c0P5EAziZyIKNTy", "do-homelab", "system", 70, 800, 220, 100, "box"),
    ("xWsoNAvV3Dm7zRTTJCqX", "do-proxmox", "app", 70, 930, 200, 90, "box"),
    ("QdPtEM2FRZrcqF8JD38L", "do-talos", "app", 300, 930, 220, 90, "box"),
    ("S7ChzZCil6w5SixPc9yh", "area-data", "group", 620, 760, 980, 320, "area"),
    ("KSFOe5pCnNLC3pAlexNZ", "do-coldsearch", "system", 650, 800, 220, 100, "box"),
    ("AZ2PK56G0IweXTRsVzd8", "do-cs-cli", "app", 650, 930, 200, 90, "box"),
    ("CeIoHeGfqAf89BE2ombJ", "do-archive", "system", 920, 800, 240, 100, "box"),
    ("aSGY2iXy7j3fgQ9Q1Hf0", "do-archiver", "app", 920, 930, 220, 90, "box"),
    ("sEQBYlNn4fn1sTXTOZ8B", "do-corpus", "system", 1200, 800, 240, 100, "box"),
    ("0tAiPOH554uqpXwLOQeo", "do-corpus-queue", "app", 1200, 930, 240, 90, "box"),
]

PARENTS = {
    "do-guardian": "area-governance",
    "do-pragent": "area-governance",
    "do-gov-sys": "area-governance",
    "do-workflow": "area-aireview",
    "do-runner": "area-aireview",
    "do-openhands": "area-aireview",
    "do-aireview-app": "area-aireview",
    "do-litellm": "area-aireview",
    "do-qwen": "area-aireview",
    "do-policy": "area-aireview",
    "do-homelab": "area-homelab",
    "do-proxmox": "area-homelab",
    "do-talos": "area-homelab",
    "do-coldsearch": "area-data",
    "do-cs-cli": "area-data",
    "do-archive": "area-data",
    "do-archiver": "area-data",
    "do-corpus": "area-data",
    "do-corpus-queue": "area-data",
}

model_to_do = {m: d for m, d, *_ in OBJECTS}

CONNS = [
    ("AW38GqB28l7UI9uPv9DI", "5wBngeCOekozxQaNKbCN", "D1kHVFUTBL23yW0UBDxg", "square", "right-middle", "left-middle", 0.5),
    ("JbQRhNPqseEeppqLPwPX", "D1kHVFUTBL23yW0UBDxg", "kHi8SBWeX7mvi234tAbl", "square", "right-middle", "left-middle", 0.5),
    ("UYAc8k7u6Mew2pl2g5cu", "kHi8SBWeX7mvi234tAbl", "OyzKKf3fzSJKsrB7c9jX", "square", "right-top", "left-middle", 0.4),
    ("TRnNi7bwsETgsSLFIDq5", "kHi8SBWeX7mvi234tAbl", "2mheYeoY30HpnGBL7IKs", "square", "right-bottom", "left-middle", 0.6),
    ("zh0v7S3B7n8TsxOxMOky", "OyzKKf3fzSJKsrB7c9jX", "zBsSgLaXIh5Dx0Atsd8L", "square", "right-middle", "left-top", 0.45),
    ("INtIB0wp67cWgwXXjpsz", "2mheYeoY30HpnGBL7IKs", "zBsSgLaXIh5Dx0Atsd8L", "square", "right-middle", "left-bottom", 0.55),
    ("VDtCWikk7du1CvDNmTTk", "zBsSgLaXIh5Dx0Atsd8L", "MpRhQjqByiLr5YceVarb", "square", "right-middle", "left-middle", 0.5),
    ("2ystvxPVswKSfVXXMWql", "OyzKKf3fzSJKsrB7c9jX", "5wBngeCOekozxQaNKbCN", "curved", "left-top", "right-top", 0.35),
    ("goSyQQYQMFkw3W08MRSR", "2mheYeoY30HpnGBL7IKs", "5wBngeCOekozxQaNKbCN", "curved", "left-bottom", "right-bottom", 0.65),
    ("yo8hpg9nITVnMKw9eSQp", "OyzKKf3fzSJKsrB7c9jX", "Ow02lvMoGzbLYW3VxouY", "square", "bottom-center", "top-center", 0.5),
    ("8Mk3U6sKT8XLnH4B2Aww", "2mheYeoY30HpnGBL7IKs", "Ow02lvMoGzbLYW3VxouY", "square", "bottom-center", "top-center", 0.5),
    ("FdfbFtIHT2W06L87b9US", "kHi8SBWeX7mvi234tAbl", "TwpQ6c0P5EAziZyIKNTy", "square", "bottom-center", "top-center", 0.5),
    ("x3DmdIxhgRuQJVGgYslm", "5wBngeCOekozxQaNKbCN", "pFE6co2KK3HyqJgkwXzj", "curved", "top-center", "bottom-left", 0.4),
    ("CSZ7257cwaShGtp9ImnR", "5wBngeCOekozxQaNKbCN", "NuXP843vvNEwY06RrUbu", "curved", "top-center", "bottom-left", 0.6),
    ("vQZk0t7FZtfBNl9e7Kd7", "5wBngeCOekozxQaNKbCN", "pFE6co2KK3HyqJgkwXzj", "curved", "left-top", "right-bottom", 0.3),
    ("HhWatSG3ocmgKict3EXg", "pFE6co2KK3HyqJgkwXzj", "5wBngeCOekozxQaNKbCN", "curved", "bottom-left", "top-center", 0.5),
    ("9szRbvEzQcgHDOLAiYVe", "NuXP843vvNEwY06RrUbu", "a4Ye2RduBbuSKocU0y93", "square", "top-center", "bottom-center", 0.5),
    ("oguC0pjBk3OL6g4UrVHD", "pFE6co2KK3HyqJgkwXzj", "a4Ye2RduBbuSKocU0y93", "square", "top-center", "bottom-center", 0.5),
    ("iKTqqsSGPKcGP88j1mJP", "pFE6co2KK3HyqJgkwXzj", "aZaKxiYMZ6Q3blofRMsh", "square", "top-center", "bottom-center", 0.5),
    ("fg3HSMONmm8x9FcMKR7F", "OyzKKf3fzSJKsrB7c9jX", "pFE6co2KK3HyqJgkwXzj", "curved", "top-center", "bottom-center", 0.5),
    ("RkqJFT29pFw7OG06Djl4", "TzxKu9jYZJyG9YQuYeEX", "wdEjC1pfpdliKPJa1SNa", "curved", "bottom-center", "top-center", 0.5),
    ("TJ7YvaqKRTDDnEtG8DZf", "TzxKu9jYZJyG9YQuYeEX", "TwpQ6c0P5EAziZyIKNTy", "square", "bottom-center", "left-middle", 0.5),
    ("SabS7KqBbRZYerWasy3a", "TzxKu9jYZJyG9YQuYeEX", "sEQBYlNn4fn1sTXTOZ8B", "square", "bottom-center", "left-middle", 0.5),
    ("8OiiUUiMRCt9jguKHnw5", "wdEjC1pfpdliKPJa1SNa", "KSFOe5pCnNLC3pAlexNZ", "square", "right-bottom", "left-middle", 0.5),
    ("qa4lVvrjBLdOPT3IVEV0", "wdEjC1pfpdliKPJa1SNa", "CeIoHeGfqAf89BE2ombJ", "square", "right-middle", "left-middle", 0.5),
    ("JybY6c811MpoSWX2txe7", "wdEjC1pfpdliKPJa1SNa", "a4Ye2RduBbuSKocU0y93", "curved", "right-top", "bottom-left", 0.5),
    ("aCefrEUYZQoDTeMKDvUQ", "TwpQ6c0P5EAziZyIKNTy", "wdEjC1pfpdliKPJa1SNa", "square", "left-middle", "right-bottom", 0.5),
    ("9zQVQHnBKdCm3vgTO9f6", "CeIoHeGfqAf89BE2ombJ", "sEQBYlNn4fn1sTXTOZ8B", "square", "right-middle", "left-middle", 0.5),
    ("7ftAqRsEilSlu0XsSw4L", "CeIoHeGfqAf89BE2ombJ", "TwpQ6c0P5EAziZyIKNTy", "square", "bottom-center", "right-top", 0.5),
    ("d71BSYOypDi6O9Rovw9e", "sEQBYlNn4fn1sTXTOZ8B", "wdEjC1pfpdliKPJa1SNa", "square", "left-middle", "right-middle", 0.5),
    ("fCUChY6mPGNHuZXCIHtc", "KSFOe5pCnNLC3pAlexNZ", "lc5wm71XbLTKBMIlhGSL", "curved", "left-top", "bottom-center", 0.5),
    ("HtHLBkyldYaa8DRUnEcr", "KSFOe5pCnNLC3pAlexNZ", "fBRxx9piJNoWhecTVSqp", "square", "top-center", "bottom-center", 0.5),
    ("5mR5HijR7OqTYglcYMVQ", "MpRhQjqByiLr5YceVarb", "AZ2PK56G0IweXTRsVzd8", "square", "bottom-center", "top-center", 0.5),
    ("IZmOr8PxFBNUSCJzisnh", "lc5wm71XbLTKBMIlhGSL", "TwpQ6c0P5EAziZyIKNTy", "square", "bottom-center", "left-top", 0.5),
    ("cT58ZG289TU8CndyS7B1", "QzeK7d4BvVgeSTkvrqc0", "TwpQ6c0P5EAziZyIKNTy", "square", "bottom-center", "left-top", 0.5),
    ("x9IMbznnd72I08H7ZjFX", "TwpQ6c0P5EAziZyIKNTy", "QzeK7d4BvVgeSTkvrqc0", "square", "top-center", "bottom-center", 0.5),
    ("mRBxYiPyJ845P57qt8po", "aUCX6dpnsQEEsuivcbdn", "TwpQ6c0P5EAziZyIKNTy", "square", "bottom-center", "top-center", 0.5),
    ("7BXDcsMku69PjSPmZLAg", "vffQBjnrkEKDGFCgKJ3v", "5wBngeCOekozxQaNKbCN", "curved", "right-top", "bottom-left", 0.5),
    ("SCGLpCjKAi8cOuXlPhBE", "QdPtEM2FRZrcqF8JD38L", "xWsoNAvV3Dm7zRTTJCqX", "square", "left-middle", "right-middle", 0.5),
    ("n6WkBGNPWRtngx5e7tc6", "xWsoNAvV3Dm7zRTTJCqX", "MpRhQjqByiLr5YceVarb", "square", "top-center", "bottom-left", 0.5),
    ("rJFM96Bzqf0Ffm4ZxLQQ", "0tAiPOH554uqpXwLOQeo", "00g87kidVb2u2UCX6D8E", "square", "top-center", "bottom-center", 0.5),
]

CALLOUTS = [
    (
        "cm-debounce",
        "callout-debounce",
        520,
        210,
        "+------------------------------+\n| Debounce: 600s + stale SHA   |\n| guard                        |\n+------------------------------+",
    ),
    (
        "cm-byok",
        "callout-byok",
        980,
        250,
        "+------------------------------+\n| BYOK: LiteLLM qwen-review    |\n| alias                        |\n+------------------------------+",
    ),
    (
        "cm-advisory",
        "callout-advisory",
        520,
        60,
        "+------------------------------+\n| Advisory only: Guardian +    |\n| OpenHands never block merge  |\n+------------------------------+",
    ),
]


def main() -> None:
    objects = {}
    for model_id, cid, typ, x, y, w, h, shape in OBJECTS:
        obj = {
            "id": cid,
            "modelId": model_id,
            "type": typ,
            "shape": shape,
            "x": x,
            "y": y,
            "width": w,
            "height": h,
        }
        if cid in PARENTS:
            obj["parentId"] = PARENTS[cid]
        objects[cid] = obj

    connections = {}
    for i, (mid, om, tm, ls, oc, tc, lp) in enumerate(CONNS):
        connections[f"dc-{i}"] = {
            "id": f"dc-{i}",
            "modelId": mid,
            "originId": model_to_do[om],
            "targetId": model_to_do[tm],
            "lineShape": ls,
            "originConnector": oc,
            "targetConnector": tc,
            "labelPosition": lp,
            "points": [],
        }

    comments = {}
    for cid, comment_id, x, y, text in CALLOUTS:
        comments[cid] = {
            "id": cid,
            "commentId": comment_id,
            "x": x,
            "y": y,
            "content": text,
        }

    diagram = {
        "name": "Portfolio — PR Review Core (D)",
        "handleId": "portfolio-variant-d-pr-review-core",
        "type": "context-diagram",
        "modelId": DOMAIN,
        "index": 4,
        "pinned": True,
        "objects": objects,
        "connections": connections,
        "comments": comments,
    }

    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(diagram, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    print(f"Objects: {len(objects)}")
    print(f"Connections: {len(connections)}")
    print(f"Comments: {len(comments)}")
    print(f"Written: {OUT}")


if __name__ == "__main__":
    main()
