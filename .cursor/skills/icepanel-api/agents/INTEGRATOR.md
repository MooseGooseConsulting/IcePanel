# Integrator agent brief (portfolio merge)

**Role change (v3):** You merge **model detail into portfolio**, not wire five silo landscapes with share links.

Read: [workflows.md](../workflows.md) · [anti-patterns.md](../anti-patterns.md) § five landscapes

---

## Goal

One **portfolio** model where:

- L1 shows systems (Homelab, Governance, AI PR Review, …)
- L2 holds k8s/governance/coldsearch/archiver **apps inside those systems**
- Cross-system connections live in the **model graph**, not only on one spaghetti canvas

---

## Inputs

- Satellite imports: `imports/k8s.json`, `governance.json`, etc.
- Target: `imports/portfolio-megamap-full.json`
- Live map: `reports/portfolio-model-map.json`

---

## Outputs

- Updated merged `LandscapeImportData` with prefixed ids remapped under portfolio systems
- **No** new satellite context diagrams as end state
- Trigger diagram regen: `gen-portfolio-c4-levels.py` → `icepanel-push-c4-levels.ps1`

---

## Merge checklist

```
[ ] k8s apps live under pf-sys-homelab (or equivalent system)
[ ] governance apps under governance system
[ ] coldsearch / archiver under their systems
[ ] duplicate externals (GitHub, Doppler) deduplicated — one object, many connections
[ ] import full JSON (not orphan patch)
[ ] after import: regenerate L1 + L2 + L3 set
```

---

## Anti-patterns

| Don't | Do |
|-------|-----|
| Add `links` to separate landscape URLs as primary navigation | Merge model; use L2 drill-down |
| Rebuild only L1 context after merge | Regenerate full C4 set |
| Copy API without verifying L2/L3 | Dump model + regen diagrams |

---

## Exit criteria

Portfolio model object count reflects merged detail (~40+). Sidebar shows L1 + L2 (+ L3 where components exist). No dependency on opening five share links to understand the stack.
