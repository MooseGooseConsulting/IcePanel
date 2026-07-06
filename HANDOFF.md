# IcePanel handoff

**Repo:** `d:\_projects\IcePanel`  
**Last verified:** 2026-07-06 (API + `icepanel-ui-debug.ps1`)  
**Conversation:** Cursor transcript `971cbc97-be84-4029-b7ba-110927518989`

Open the **Patrick Portfolio** landscape — not Scratch, not "Patrick's landscape" (the empty default signup landscape with 1 object).

| | |
|---|---|
| **Editor** | https://app.icepanel.io/landscapes/Efdez5uW6BfQjErrQ4Gx/versions/latest |
| **Share (with handle)** | https://s.icepanel.io/BKWC9YAovn1qa9/8wHl |
| **Landscape ID** | `Efdez5uW6BfQjErrQ4Gx` |
| **Version ID** | `RlqaJB3HuwzYkFs3EcJW` |
| **Org ID** | `8kpJ4KngNPCU2sbVFkgV` |

---

## North star (what this work is for)

Model **Patrick's portfolio** in IcePanel the way the product intends: **one model graph**, **C4 drill-down** (L1 → L2 → L3), **flows** for stories, **ADRs** for decisions.

The immediate architecture story is the **runner-native BYOK PR review stack** (not Kodus / CodeRabbit / SaaS):

```text
GitHub PR opened or updated
  → self-hosted runner on tailnet
  → 10-minute debounce + stale SHA guard
  → full checkout of PR head
  → optional lint/test evidence
  → OpenHands PR Review (primary inline reviewer)
  → AI Review (secondary summary)
  → both via LiteLLM → Qwen 3.6 (homelab)
  → comments posted back to GitHub
```

**Advisory-only** — agents never block merge. Human keeps merge authority.

---

## What Patrick asked for (keep these constraints)

1. **One interconnected model** — not five landscapes to click between, not four "variant" tabs, not a megamap with every object on one canvas.
2. **Proper C4 levels** — actors/systems on L1; apps/stores on L2; components on L3. Never apps on a context diagram (the GitHub Hub screenshot failure).
3. **IcePanel as a product** — use Dependencies view, flows, ADRs, drafts, tags — not a homemade import pipeline with phase gates as the methodology.
4. **Readable at a glance AND drillable** — L1 is the 30-second map; the full graph lives in the **model + Dependencies view**; detail is L2/L3; animation is **flows**.
5. **Creativity over checklists** — blank-canvas checks are guardrails only, not the goal.
6. **Dedicated repo** — all assets live here, not in Scratch.

---

## Live state (verified now)

| Metric | Portfolio landscape | Notes |
|--------|---------------------|-------|
| Model objects | **42** | Matches `reports/portfolio-model-map.json` |
| Model connections | **46** | BYOK stack wired in megamap |
| Diagrams | **12** | C4 set pushed — no variants/master in API count |
| Flows | **0** | **Not done** — top priority for storytelling |
| ADRs | **0** | **Not done** — JSON exists in archive only |

Satellite landscapes (k8s, governance, coldsearch, archiver) still exist in the org as **legacy staging**. Do not treat them as the product — merge detail into portfolio.

---

## Repo map (what to touch)

```text
IcePanel/
├── HANDOFF.md                          ← this file
├── AGENT_BRIEF.md                      ← modeler contract (JSON only)
├── imports/
│   ├── portfolio-megamap-full.json     ← SOURCE OF TRUTH for model import
│   ├── portfolio-l3-components-patch.json
│   ├── portfolio-megamap-patch.json
│   ├── landscapes-map.json
│   ├── share-links.json
│   ├── diagrams/portfolio-l*.json      ← 12 active diagram payloads
│   └── archive/                        ← variants, satellites, dead scripts — DO NOT PUSH
├── tools/
│   ├── gen-portfolio-c4-levels.py      ← regen L1/L2/L3 from model map
│   ├── icepanel-push-c4-levels.ps1     ← delete all diagrams; push l*.json
│   └── icepanel-dump-model.ps1         ← refresh reports/portfolio-model-map.json
├── reports/
│   ├── portfolio-model-map.json        ← live IDs for diagram gen
│   └── diagram-verify.md               ← points here; July 1 data archived
└── .cursor/skills/icepanel-api/        ← methodology + API reference
    ├── SKILL.md                        ← router
    ├── anti-patterns.md                ← failure catalog
    ├── c4-methodology.md               ← level rules
    └── overlay.md                      ← IDs, commands
```

**Scratch** (`d:\_projects\Scratch`) — general workbench only. No IcePanel assets remain there.

---

## Diagram set (12 — repo + live)

Entry point: **Portfolio - Context (L1)** (pinned).

| Level | Diagram | File |
|-------|---------|------|
| L1 | Portfolio - Context (L1) | `portfolio-l1-context.json` |
| L2 | Homelab Platform - Containers (L2) | `portfolio-l2-homelab.json` |
| L2 | AI PR Review Pipeline - Containers (L2) | `portfolio-l2-aireview.json` |
| L2 | Agent Governance - Containers (L2) | `portfolio-l2-governance.json` |
| L2 | ColdSearch - Containers (L2) | `portfolio-l2-coldsearch.json` |
| L2 | LLM Conversation Archive - Containers (L2) | `portfolio-l2-archive.json` |
| L2 | Agent Learning Corpus - Containers (L2) | `portfolio-l2-corpus.json` |
| L3 | AI PR Review Workflow - Components (L3) | `portfolio-l3-workflow.json` |
| L3 | OpenHands PR Review - Components (L3) | `portfolio-l3-openhands.json` |
| L3 | LiteLLM Gateway - Components (L3) | `portfolio-l3-litellm.json` |
| L3 | NorthStarGuardian - Components (L3) | `portfolio-l3-guardian.json` |
| L3 | AI Review - Components (L3) | `portfolio-l3-aireview-comp.json` |

---

## Model highlights (must remain)

In `imports/portfolio-megamap-full.json`:

- **System:** AI PR Review Pipeline (OpenHands, AI Review, LiteLLM, runner, workflow, policy store)
- **Components:** Debounce and Stale SHA Guard, OpenHands Agent Script, LiteLLM Model Router, Review Evidence Builder, etc.
- **Homelab:** Proxmox, Talos, Qwen LXC (VLAN 30)
- **Externals:** GitHub, Doppler, Cloudflare, LLM runtimes
- **Cross-portfolio:** Governance, ColdSearch, Archiver, Corpus connections

Search keys: `OpenHands`, `LiteLLM`, `pf-comp-debounce`, `AI PR Review`.

---

## Failures we already made (do not repeat)

| Don't | Do instead |
|-------|------------|
| 5 landscapes as the UX | One portfolio; L2 for detail |
| Variant A/B/C/D at Level 1 | One L1 + N L2 + M L3 |
| `portfolio-master.json` megamap | C4 drill-down |
| Apps on `context-diagram` | Apps on `app-diagram` only |
| `area` shape bound to a **system** | Areas bind to **group** type only |
| Partial patch import (`Parent not found`) | Full `portfolio-megamap-full.json` import |
| Share link without handle suffix | Use `…/BKWC9YAovn1qa9/8wHl` |
| "diagram count ≥ 1" as success | Level-correct, readable L1, flows, ADRs |
| Phase gates as primary workflow | Story-first; see skill `workflows.md` |

Full catalog: `.cursor/skills/icepanel-api/anti-patterns.md`

---

## Next session — priority order

Do these in order. Do not regen diagrams before confirming the model is right.

### 1. Visual sanity check (you, 2 minutes)

Open the editor URL above. Confirm:

- Sidebar shows **12 diagrams**, names include `(L1)` / `(L2)` / `(L3)`
- **No** Variant, Hub, Panorama, Master entries
- L1 has **systems only** — no app boxes
- Click **AI PR Review Pipeline** → L2 shows OpenHands, LiteLLM, runner, workflow

### 2. Flows (highest value gap)

Create on **L2 AI PR Review Pipeline** diagram:

```text
PR opened/synchronize → debounce + stale SHA → runner checkout
  → OpenHands review ∥ AI Review summary
  → LiteLLM → Qwen → GitHub PR comments
```

Guide: `.cursor/skills/icepanel-api/reference/flows-storytelling.md`

### 3. ADRs

**Live landscape has 0 ADRs.** Two batches to POST:

**A — Portfolio-wide** (already written, in `imports/archive/models/portfolio-adrs.json`):

- Git is the plan, not a controller
- Advisory agents never block merge
- Transcripts are ground truth
- Secrets fail loud

**B — PR review stack** (still need authoring):

- BYOK via LiteLLM (no SaaS reviewer subscription)
- Debounce + stale SHA guard
- Self-hosted runner on tailnet
- Optional: evidence collection before review

Promote to active `imports/portfolio-adrs.json`, POST via API. ASCII only.

### 4. Merge satellite detail into portfolio

Source: `imports/archive/models/{k8s,governance,coldsearch,archiver}.json`  
Target: `portfolio-megamap-full.json` under the right **systems** (especially Homelab L2 depth from k8s.json).  
Helper: `scripts/merge-icepanel-mega.py`  
Then: dump → gen → push (commands below).

### 5. Clean stale docs

| File | Problem |
|------|---------|
| `reports/portfolio-model-summary.md` | Partially updated — still has archived June content |
| `reports/icepanel-mcp-showcase.md` | Old Scratch paths |

Re-run verifier after steps 1–4.

### 6. Git

Repo initialized, not committed. Commit when the above stabilizes.

---

## Standard commands

```powershell
cd d:\_projects\IcePanel

# Auth check + diagram count
doppler run -p dev-tools -c dev -- powershell -File .\tools\icepanel-healthcheck.ps1
doppler run -p dev-tools -c dev -- powershell -File .\tools\icepanel-ui-debug.ps1

# After model changes only:
doppler run -p dev-tools -c dev -- powershell -File .\tools\icepanel-dump-model.ps1 portfolio
python tools/gen-portfolio-c4-levels.py
doppler run -p dev-tools -c dev -- powershell -File .\tools\icepanel-push-c4-levels.ps1
```

Import model (when megamap changes):

```powershell
doppler run -p dev-tools -c dev -- powershell -File .\tools\icepanel-driver.ps1 import portfolio imports/portfolio-megamap-full.json
```

---

## Success checklist (use this, not phase gates)

```
[ ] Correct landscape open (not empty "Patrick's landscape")
[ ] L1: ~15 boxes, actors + systems + externals, zero apps
[ ] L2: six system container diagrams, AI PR Review shows full BYOK stack
[ ] L3: five component diagrams where modeled
[ ] ≥1 flow on AI PR Review L2 (debounce → review → comment)
[ ] ≥4 ADRs live (portfolio-wide + PR stack decisions)
[ ] Dependencies view useful without redrawing on L1
[ ] k8s/governance detail merged into portfolio L2 (satellites optional)
[ ] No variant/master diagrams in sidebar
```

---

## For agents reading this

1. Read **this file** first for intent and current state.
2. Read **`.cursor/skills/icepanel-api/anti-patterns.md`** before editing diagrams.
3. Model changes → `AGENT_BRIEF.md` + `imports/portfolio-megamap-full.json`.
4. Never revive `imports/archive/diagrams/portfolio-variant-*` or megamap scripts.
5. Do not add IcePanel files back to Scratch.

---

## Stale satellite landscapes (org — ignore unless merging)

| Slug | landscapeId | Objects (approx) |
|------|---------------|------------------|
| k8s | `JyXDiYoXVfa7Xz3AnEfY` | 42 |
| governance | `Svbe4JxL01yfpIidvbHC` | 30 |
| coldsearch | `DbkFHxfNxrKks6oOISUw` | 36 |
| archiver | `Q6smKpwNRmY1GsLzvqni` | 33 |

Registry: `imports/landscapes-map.json`
