# IcePanel C4 Model Agent Brief

You build **model JSON** for IcePanel import. You do **not** call IcePanel. Diagrams are a separate step ([`.cursor/skills/icepanel-api/agents/DIAGRAMMER.md`](.cursor/skills/icepanel-api/agents/DIAGRAMMER.md)).

**Read first:** [c4-methodology.md](.cursor/skills/icepanel-api/c4-methodology.md) · [anti-patterns.md](.cursor/skills/icepanel-api/anti-patterns.md)

---

## Primary deliverable: one portfolio model

Default target: **`imports/portfolio-megamap-full.json`** (merged landscape), not a new silo per repo.

Satellite slugs (`k8s`, `governance`, `coldsearch`, `archiver`) are **staging only** — detail merges under portfolio **systems** as apps/stores/components.

---

## Output files

1. `imports\<landscape>.json` — `LandscapeImportData` (prefer `imports/portfolio-megamap-full.json`)
2. `imports\<landscape>-adrs.json` — ADR array

For portfolio work, update the megamap full file rather than creating parallel landscapes.

---

## C4 modeling order

1. **Domain** + **actors** + **systems** (internal + `external: true`) — supports **L1**
2. **Apps** and **stores** under each **system** — supports **L2**
3. **Components** under key **apps** only when L3 is planned — do not componentize everything

```
domain "Patrick Portfolio"
  actor "Operator"
  system "Homelab Platform"
    app "Proxmox"
    app "Talos"
  system "AI PR Review Pipeline"
    app "OpenHands"
    app "LiteLLM"
      component "Router"        ← only if L3 diagram planned
  system "GitHub" (external: true)
```

**Never** parent apps directly under domain to simplify one diagram — that causes L1 soup.

---

## LandscapeImportData schema

```json
{
  "tagGroups": [{ "icon": "<TagGroupIcon>", "id": "<id>", "name": "<Name>" }],
  "tags": [{ "color": "<TagColor>", "groupId": "<tagGroup-id>", "id": "<id>", "name": "<Name>" }],
  "modelObjects": [{
    "id": "<stable-id>",
    "name": "<Name>",
    "type": "<ObjectType>",
    "parentId": "<parent-id>",
    "status": "<Status>",
    "tagIds": ["<tag-id>"],
    "description": "<optional>",
    "external": false
  }],
  "modelConnections": [{
    "id": "<id>",
    "name": "<Name>",
    "direction": "<Direction>",
    "originId": "<object-id>",
    "targetId": "<object-id>"
  }]
}
```

### Enums

- **ObjectType:** `domain`, `actor`, `app`, `component`, `group`, `store`, `system`
- **Status:** `live`, `future`, `deprecated`, `removed`
- **Direction:** `outgoing`, `bidirectional`
- **TagColor:** `blue`, `green`, `yellow`, `orange`, `red`, `beaver`, `dark-blue`, `purple`, `pink`, `white`, `grey`, `black`

### Hierarchy (import rejects violations)

| type | parent |
|------|--------|
| domain | omitted |
| actor, system | domain |
| group | domain or group |
| app, store | system |
| component | app or store |

### IDs

Stable lowercase kebab-case, landscape prefix: `pf-homelab-proxmox`, `pf-aireview-litellm`.

---

## Object count guidance

| Scope | Objects |
|-------|---------|
| Portfolio systems + actors + externals (L1-ready) | 12–25 |
| + apps/stores per system (L2-ready) | 35–50 |
| + selective components (L3-ready) | 40–60 |

Current portfolio reference: ~42 objects, ~46 connections (`reports/portfolio-model-map.json`).

---

## ADRs

```json
[{
  "name": "ADR 0001 - <title>",
  "status": "accepted",
  "description": "<one line>",
  "content": "# ADR 0001\n\n## Status\nAccepted\n\n..."
}]
```

2–4 ADRs: BYOK via LiteLLM, advisory-only reviews, debounce/stale-SHA guard, self-hosted runner.

**ASCII only** — no em-dashes or smart quotes.

---

## Connections

Name with action + protocol: `PR opened/synchronize`, `chat/completions via`, `posts inline PR comments`.

Cross-system edges belong in the **model**; L1 diagram draws only the subset that aids the 30-second map.

---

## After you write JSON

Parent agent:

1. `POST .../import` with **full** merged JSON (not orphan patch)
2. `icepanel-dump-model.ps1 portfolio`
3. `gen-portfolio-c4-levels.py` → `icepanel-push-c4-levels.ps1`

You do not run these steps.

---

## Return summary

Object counts by type (systems / apps / components), connection count, ADR count, which systems are L2-ready, which apps need L3, repo surprises.
