---
name: icepanel-api
description: >-
  Models architecture in IcePanel using proper C4 levels (L1 context, L2 containers,
  L3 components), flows, and ADRs. Use for IcePanel, icepanel.io, C4 diagrams,
  landscape import, portfolio modeling, ICE_PANEL_ADMIN, or fixing blank canvas /
  spaghetti diagrams / all-Level-1 mistakes.
---

# IcePanel API

> **Base:** `https://api.icepanel.io/v1` · **Docs:** [Core Concepts](https://developer.icepanel.io/core-concepts/overview) · [llms.txt](https://developer.icepanel.io/llms.txt)

IcePanel is a **C4 architecture product**: one **model graph**, multiple **zoom-level views**, optional **flows** and **ADRs**. It is not a generic node canvas and not a batch-import pipeline.

**Read first if anything went wrong:** [anti-patterns.md](anti-patterns.md) · [c4-methodology.md](c4-methodology.md)

---

## The one rule

| Layer | What it is | Created how |
|-------|------------|-------------|
| **Model** | Objects + connections (truth) | Import JSON or CRUD |
| **Diagrams** | C4 views at L1 / L2 / L3 | `POST .../diagrams` per level |
| **Flows** | Sequences on a diagram | After diagram exists |
| **ADRs** | Decisions linked to model | `POST .../adrs` |

**Never** put apps on a context diagram. **Never** ship five "variants" at Level 1. **Never** confuse import success with a good diagram.

---

## Decision router

| You need to… | Read |
|--------------|------|
| Understand object types and C4 levels | [c4-methodology.md](c4-methodology.md) |
| See what we did wrong before | [anti-patterns.md](anti-patterns.md) |
| Model from repos (JSON only) | [agents/MODELER.md](agents/MODELER.md) · `AGENT_BRIEF.md` |
| Build L1 / L2 / L3 diagrams | [agents/DIAGRAMMER.md](agents/DIAGRAMMER.md) · [diagrams.md](diagrams.md) |
| End-to-end workflow | [workflows.md](workflows.md) |
| Flows on diagrams | [reference/flows-storytelling.md](reference/flows-storytelling.md) |
| API endpoints / schemas | [endpoints.md](endpoints.md) · [schemas.md](schemas.md) |
| This repo: IDs, tools, commands | [overlay.md](overlay.md) |
| **Session handoff — read first** | [HANDOFF.md](../../../HANDOFF.md) |
| Auth / MCP | [reference/mcp-auth.md](reference/mcp-auth.md) |

---

## C4 levels (IcePanel native — not our invention)

| Level | `type` | `modelId` scope | Objects on canvas |
|-------|--------|-----------------|-------------------|
| **L1** | `context-diagram` | domain | **actors**, **systems**, external systems |
| **L2** | `app-diagram` | one **system** | **apps**, **stores**, **groups** (areas) |
| **L3** | `component-diagram` | one **app** or **store** | **components** |

Same model object may appear on **multiple diagrams** at the correct level. Drill down: L1 system → open its L2 app diagram → open L3 component diagram.

**Dependencies view** (UI + share mode `dependencies`) auto-renders the full graph — do not hand-draw spaghetti to replace it.

---

## Model object types (hierarchy enforced on import)

```
domain
├── actor
├── system          ← L1 boxes (internal)
├── system (external: true)   ← L1 boxes (external)
├── group           ← optional; renders as area on L2
│   ├── app         ← L2 boxes
│   │   └── component   ← L3 boxes
│   └── store
```

Parent rules: [schemas.md](schemas.md) · `AGENT_BRIEF.md`

---

## Patrick portfolio (primary landscape)

| Slug | landscapeId | Role |
|------|-------------|------|
| `portfolio` | `Efdez5uW6BfQjErrQ4Gx` | **Primary** — one model, L1+L2+L3 diagram set |

Satellite landscapes (`k8s`, `governance`, `coldsearch`, `archiver`) are **legacy detail imports**. New work merges into `portfolio` unless explicitly scoped otherwise.

Target diagram set for portfolio (minimum):

```
portfolio-l1-context.json           L1  pinned
portfolio-l2-<system>.json          L2  one per major system
portfolio-l3-<app>.json             L3  only where components exist
```

Generate: `python tools/gen-portfolio-c4-levels.py`  
Push: `doppler run -p dev-tools -c dev -- powershell -File .\tools\icepanel-push-c4-levels.ps1`

---

## Quality bar (human-visible)

A good IcePanel deliverable:

1. **L1** is sparse (~10–20 boxes): who, which systems, which externals — readable in 30 seconds
2. **L2** opens from a system: containers inside that system only
3. **L3** exists only when components are modeled and worth showing
4. **Flows** tell one story (e.g. PR debounce → review → comment) on the relevant L2 diagram
5. **ADRs** capture decisions (BYOK, advisory-only, debounce), not decoration
6. **No** overlapping apps on L1, **no** diagram titled "Variant A/B/C/D"

Verify: [agents/VERIFIER.md](agents/VERIFIER.md)

---

## Auth

```powershell
doppler run -p dev-tools -c dev -- powershell -File .\tools\icepanel-healthcheck.ps1
```

Header: `Authorization: ApiKey $ICE_PANEL_ADMIN`

---

## Reference library (unchanged API detail)

| Doc | Contents |
|-----|----------|
| [diagrams.md](diagrams.md) | Layout, connectors, level-specific rules |
| [workflows.md](workflows.md) | Model → L1 → L2 → L3 → flows → verify |
| [examples.md](examples.md) | Payload shapes |
| [reference/core-concepts.md](reference/core-concepts.md) | Official terminology |
| [reference/visuals.md](reference/visuals.md) | Tags, share modes, export |

---

## Deprecated (do not use)

- Multi-agent "phase gates" as primary methodology
- `portfolio-variant-*` diagram pattern (A/B/C/D GitHub hub / panorama / layer stack)
- `portfolio-master.json` single-canvas everything blob
- `icepanel-layout.ps1` three-column context-only scaffold as final deliverable
- One landscape per repo as default end state without portfolio merge

See [anti-patterns.md](anti-patterns.md) for why.
