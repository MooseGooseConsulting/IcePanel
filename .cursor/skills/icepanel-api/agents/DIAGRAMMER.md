# Diagrammer agent brief

You create **C4-level diagram JSON** — separate files for L1, L2, and L3. You do not cram all types onto one canvas.

Read first: [c4-methodology.md](../c4-methodology.md) · [anti-patterns.md](../anti-patterns.md) · [diagrams.md](../diagrams.md)

---

## Forbidden

- Apps or components on `context-diagram` (L1)
- Multiple "variant" diagrams at the same level (Panorama / Hub / Layer Stack)
- Single `portfolio-master.json` megamap with everything
- `area` shape with `modelId` pointing to a **system** (use **group**)

---

## Outputs (portfolio convention)

```
imports/diagrams/portfolio-l1-context.json
imports/diagrams/portfolio-l2-<system-slug>.json    one per major system
imports/diagrams/portfolio-l3-<app-slug>.json       selective
```

Each file = complete `DiagramCreate`: metadata + `objects` + `connections`.

**Preferred:** regenerate from model map:

```powershell
python tools/gen-portfolio-c4-levels.py
doppler run -p dev-tools -c dev -- powershell -File .\tools\icepanel-push-c4-levels.ps1
```

---

## ID resolution

Import ids (`pf-sys-homelab`) ≠ live API ids (`Ib8pYuTL...`).

1. `GET .../model/objects` or read `reports/portfolio-model-map.json`
2. Match: `labels.import-original-id` → name → slug
3. `DiagramObject.modelId` = live model id
4. Diagram object keys (`do-homelab`) are canvas-local; connection endpoints use **diagram object keys**

---

## Per-level layout

### L1 — `context-diagram`

| Field | Value |
|-------|-------|
| `modelId` | domain id |
| `name` | `Portfolio - Context (L1)` |
| `pinned` | true |
| `index` | 0 |

| Column x | Contents |
|----------|----------|
| 80 | actors |
| 400 | internal systems |
| 720+ | external systems |

**Max ~20 boxes.** No apps.

### L2 — `app-diagram`

| Field | Value |
|-------|-------|
| `modelId` | **system** id |
| `name` | `{System Name} - Containers (L2)` |

Place apps/stores; groups as `shape: area`, `type: group`.

### L3 — `component-diagram`

| Field | Value |
|-------|-------|
| `modelId` | **app** or **store** id |
| `name` | `{App Name} - Components (L3)` |

Only when components exist in model.

Constants: ORIGIN (80,80), COL_W 320, ROW_H 160, BOX 280×120 — see [diagrams.md](../diagrams.md).

---

## Minimum deliverables

```
[ ] 1 × L1 context (actors + systems + externals only)
[ ] 1 × L2 per major system with apps modeled
[ ] L3 only for apps with components
[ ] names include (L1)/(L2)/(L3) — not "Variant B"
[ ] ASCII-only strings
[ ] handleId unique per diagram
```

---

## Return summary

Diagram file paths, object counts **per level**, unresolved model names, note if L1 was kept sparse intentionally.
