# Live-validated portfolio C4 diagram set

Validated 2026-07-06 — landscape `Efdez5uW6BfQjErrQ4Gx`.

**Methodology:** L1 context + L2 per system + selective L3 — not variant diagrams or single megamap.

---

## Diagram inventory (12)

| Level | Name pattern | File |
|-------|--------------|------|
| L1 | Portfolio - Context (L1) | `portfolio-l1-context.json` |
| L2 | *System* - Containers (L2) | `portfolio-l2-*.json` (6) |
| L3 | *App* - Components (L3) | `portfolio-l3-*.json` (5) |

Systems with L2: Homelab, AI PR Review, Governance, ColdSearch, Archive, Corpus.

Apps with L3: workflow, OpenHands, LiteLLM, Guardian, AI Review components.

---

## Generate and push

```powershell
doppler run -p dev-tools -c dev -- powershell -File .\tools\icepanel-dump-model.ps1 portfolio
python tools/gen-portfolio-c4-levels.py
doppler run -p dev-tools -c dev -- powershell -File .\tools\icepanel-push-c4-levels.ps1
```

---

## L1 validation rules

- `type`: `context-diagram`
- Canvas objects: **actors + systems only** (no apps)
- ~15–20 boxes
- `pinned`: true

Proof: `reports/diagrams/portfolio-l1-context.png`

---

## Links

- Share: https://s.icepanel.io/BKWC9YAovn1qa9
- Editor: https://app.icepanel.io/landscapes/Efdez5uW6BfQjErrQ4Gx/versions/latest

---

## Superseded (do not use)

- `imports/diagrams/portfolio-context.json` — single L1 only, pre-C4-set
- `portfolio-variant-*.json` — layout experiments at wrong level
- `portfolio-master.json` — everything-on-one-canvas anti-pattern

See [anti-patterns.md](../anti-patterns.md).
