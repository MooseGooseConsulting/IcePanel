# C4 methodology for IcePanel (Scratch)

IcePanel implements the [C4 model](https://icepanel.io/c4-model/). This is **product-native**, not a Scratch convention.

---

## Mental model

```
         ONE MODEL (all types, all connections)
              │
    ┌─────────┼─────────┐
    ▼         ▼         ▼
   L1        L2        L3        Flows (on L1 or L2)
 context   app-diagram  component   sequence overlay
```

**Diagrams are views.** The model exists without them (API shows objects; UI canvas is blank until diagrams exist).

---

## Object types → C4 element

| IcePanel type | C4 element | Typical parent | Appears on |
|---------------|------------|----------------|------------|
| `domain` | Bounded context | — | scopes diagram (`modelId`) |
| `actor` | Person | domain | **L1** |
| `system` | Software system | domain | **L1** (internal + external) |
| `group` | Logical grouping | domain or group | **L2** as `area` |
| `app` | Container | system | **L2** |
| `store` | Data store | system | **L2** |
| `component` | Component | app or store | **L3** |

---

## What goes on each diagram

### L1 — Context (`context-diagram`)

**Purpose:** 30-second portfolio map — who uses what, which systems talk to which externals.

**On canvas:**

- Actors (left)
- Internal systems (center)
- External systems (right)
- Connections between **only objects on this diagram**

**NOT on canvas:** apps, stores, components (even if they exist in the model).

**Typical count:** 10–20 boxes.

**Example (portfolio):** Operator, AI Agents | Homelab, Governance, AI PR Review, ColdSearch, Archive, Corpus | GitHub, Doppler, Cloudflare, LLM runtimes, …

### L2 — Containers (`app-diagram`)

**Purpose:** Zoom into **one system** — what runs inside it.

**On canvas:**

- Parent system (optional anchor box)
- Apps and stores whose `parentId` = this system
- Group areas if modeled
- Connections where both endpoints are on this diagram (apps calling apps, app → store)

**One diagram per major system** (not optional for portfolio-quality work):

- Homelab Platform
- AI PR Review Pipeline
- Agent Governance
- ColdSearch
- LLM Conversation Archive
- Agent Learning Corpus

**`modelId`:** the system's live API id.

### L3 — Components (`component-diagram`)

**Purpose:** Zoom into **one app** — modules inside a container.

**On canvas:**

- Parent app
- Components whose `parentId` = this app

**Only create when:**

- Components exist in the model, AND
- The internals matter (e.g. debounce guard, OpenHands agent script, LiteLLM router)

**Do not** create L3 for every app "to fill levels."

---

## Modeling depth guide

| Scope | Objects in model | Diagrams |
|-------|------------------|----------|
| Portfolio L1 | Systems + actors + externals | 1 × L1 |
| System detail | + apps, stores under each system | 1 × L2 per system |
| App internals | + components under key apps | 1 × L3 per app (selective) |
| Full k8s drill-down | 40+ objects under Homelab system | L2 Homelab + optional L3 per app |

**Rule of thumb:** Model depth and diagram depth match. If you model components, add L3. If you only model systems, L1 suffices until L2 is built.

---

## Connections

| Level | Draw what |
|-------|-----------|
| L1 | System ↔ system, actor → system, system ↔ external |
| L2 | App ↔ app, app → store, within-system only |
| L3 | Component ↔ component within app |

Cross-level connections (app → external system) appear on **L2** for the app’s parent system, not on L1 as app-level edges.

Name connections with **verbs + protocol**: `PR opened/synchronize`, `chat/completions via`, `posts inline PR comments`.

---

## Flows (fourth dimension)

Flows attach to an **existing diagram** (`diagramId`). They animate a **story** across objects already placed.

**Good portfolio flows:**

1. PR updated → debounce → runner → OpenHands + AI Review → LiteLLM → Qwen → GitHub comments
2. Agent session → archiver → corpus → frozenSkillz promotion
3. Developer merge authority (Process step on actor)

Build flows **after** L2 AI PR Review diagram exists.

---

## ADRs

Attach decisions to the model, not to variants:

- Advisory-only (never block merge)
- BYOK via LiteLLM
- Debounce + stale SHA guard
- Self-hosted runner on tailnet

2–4 ADRs per landscape; ASCII only.

---

## Tags (visual semantics)

Consistent across levels — see [reference/visuals.md](reference/visuals.md).

| Color | Meaning |
|-------|---------|
| purple | AI / agents |
| green | live |
| yellow / orange | future / integration |
| beaver | homelab / evidence |
| dark-blue | governance / security |

---

## Story-first workflow (preferred)

1. **Question:** What should someone understand in 30 seconds? What story needs a flow?
2. **Model:** Objects + connections for that story (systems first, then apps, then components)
3. **L1** → **L2** → **L3** (skip empty levels)
4. **Flows** on the diagram that matches the story
5. **ADRs** for non-obvious decisions
6. **Verify:** L1 readable, L2 opens from system, no variants

Not: import → one context diagram → declare victory.
