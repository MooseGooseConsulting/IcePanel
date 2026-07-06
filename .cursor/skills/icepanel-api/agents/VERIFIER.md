# Verifier agent brief

Confirm the landscape tells a **correct C4 story**, not just "diagram count > 0".

Read: [anti-patterns.md](../anti-patterns.md) · [c4-methodology.md](../c4-methodology.md)

---

## Inputs

- `{landscapeId}` — portfolio: `Efdez5uW6BfQjErrQ4Gx`
- `reports/portfolio-model-map.json` (expected systems/apps/components)
- `imports/diagrams/portfolio-l*.json` (expected diagram set)

---

## Checks

### 1. Model

```http
GET .../model/objects
GET .../model/connections
```

```
[ ] systems exist for each portfolio domain area
[ ] apps parentId → system (not domain)
[ ] components parentId → app/store
```

### 2. Diagram inventory

```http
GET .../diagrams
```

```
[ ] exactly 1 context-diagram (L1), pinned
[ ] app-diagram per major system (L2) — expect ~6 for portfolio
[ ] component-diagrams only where components exist (L3) — expect ~5 for portfolio
[ ] NO diagrams named Variant / Hub / Panorama / Layer Stack / master-only
[ ] total ~12 for current portfolio (adjust if scope changed)
```

### 3. Level correctness (spot-check content)

For L1 diagram id:

```http
GET .../diagrams/{l1Id}/content
```

```
[ ] all diagram objects type ∈ {actor, system}
[ ] zero objects type app / store / component
[ ] readable density (~10–20 boxes)
```

For each L2:

```
[ ] modelId scopes to a system
[ ] objects are apps, stores, groups — not actors
```

### 4. Export proof

```http
POST .../diagrams/{l1Id}/export/image
```

Save: `reports/diagrams/portfolio-l1-context.png`

### 5. Share link

```
[ ] https://s.icepanel.io/BKWC9YAovn1qa9/{handle} loads L1
[ ] drill: system → L2 diagram exists in sidebar
```

### 6. Flows (optional)

```
[ ] PR review flow exists if phase completed
```

---

## Failure report

| Check | Status | Evidence |
|-------|--------|----------|
| L1 has no apps | pass/fail | content object types |
| L2 per system | pass/fail | diagram list |
| No variants | pass/fail | diagram names |
| L1 PNG | pass/fail | file path |

Write to `reports/diagram-verify.md`.

---

## Common failures → fix

| Symptom | Fix |
|---------|-----|
| Apps on L1 | Regenerate: `gen-portfolio-c4-levels.py` + push-c4-levels |
| Variant diagrams in sidebar | push-c4-levels (deletes all, pushes clean set) |
| L2 missing | Add `portfolio-l2-*.json` for that system |
| Components invisible | Add L3 for parent app |
| diagram count = 0 | Run push script |
