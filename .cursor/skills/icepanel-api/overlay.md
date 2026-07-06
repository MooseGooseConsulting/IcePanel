# Project overlay — Patrick Portfolio in IcePanel

Repo: `d:\_projects\IcePanel\`

---

## Doppler

```powershell
doppler run -p dev-tools -c dev -- powershell -File .\tools\icepanel-healthcheck.ps1
doppler run -p dev-tools -c dev -- powershell -File .\tools\icepanel-push-c4-levels.ps1
```

Secret: `ICE_PANEL_ADMIN` · Org: `8kpJ4KngNPCU2sbVFkgV`

---

## Primary landscape

| Slug | Name | landscapeId | versionId |
|------|------|-------------|-----------|
| **portfolio** | Patrick Portfolio | `Efdez5uW6BfQjErrQ4Gx` | `RlqaJB3HuwzYkFs3EcJW` |

**Editor:** https://app.icepanel.io/landscapes/Efdez5uW6BfQjErrQ4Gx/versions/latest  
**Share:** https://s.icepanel.io/BKWC9YAovn1qa9

Satellite landscape IDs (staging only — detail merges into portfolio): see `imports/landscapes-map.json` and `imports/archive/models/`.

---

## Active files

| Path | Role |
|------|------|
| `imports/portfolio-megamap-full.json` | Model source of truth |
| `imports/portfolio-l3-components-patch.json` | Component patch (merge before import) |
| `imports/portfolio-megamap-patch.json` | Incremental patch |
| `imports/landscapes-map.json` | landscapeId registry |
| `imports/share-links.json` | Share URL handles |
| `imports/diagrams/portfolio-l*.json` | 12 C4 diagrams (L1 + 6 L2 + 5 L3) |
| `reports/portfolio-model-map.json` | Live id map for diagram gen |

Deprecated payloads live under `imports/archive/` — do not push.

---

## Primary workflow

```powershell
doppler run -p dev-tools -c dev -- powershell -File .\tools\icepanel-dump-model.ps1 portfolio
python tools/gen-portfolio-c4-levels.py
doppler run -p dev-tools -c dev -- powershell -File .\tools\icepanel-push-c4-levels.ps1
```

---

## Tools (active)

| Script | Purpose |
|--------|---------|
| `gen-portfolio-c4-levels.py` | Build L1/L2/L3 diagram JSON |
| `icepanel-push-c4-levels.ps1` | Push C4 diagram set |
| `icepanel-dump-model.ps1` | Export model map |
| `icepanel-healthcheck.ps1` | Auth smoke test |
| `icepanel-driver.ps1` | Ad-hoc REST ops |
| `validate-imports.ps1` | Validate import JSON |

Archived scripts: `imports/archive/tools/`

---

## Agent contracts

| Role | Brief |
|------|-------|
| Model | `AGENT_BRIEF.md` + [agents/MODELER.md](agents/MODELER.md) |
| Diagrams | [agents/DIAGRAMMER.md](agents/DIAGRAMMER.md) |
| Merge | [agents/INTEGRATOR.md](agents/INTEGRATOR.md) |
| Verify | [agents/VERIFIER.md](agents/VERIFIER.md) |
