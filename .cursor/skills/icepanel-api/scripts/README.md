# Optional automation scripts

Scripts live in repo root `tools/`. Document paths in [overlay.md](../overlay.md).

## Primary (C4 set — use these)

| Script | Purpose |
|--------|---------|
| `gen-portfolio-c4-levels.py` | Build L1/L2/L3 diagram JSON from model map |
| `icepanel-push-c4-levels.ps1` | Delete all diagrams; push `portfolio-l*.json` |
| `icepanel-dump-model.ps1` | Export live ids to `reports/<slug>-model-map.json` |

```powershell
doppler run -p dev-tools -c dev -- powershell -File .\tools\icepanel-dump-model.ps1 portfolio
python tools/gen-portfolio-c4-levels.py
doppler run -p dev-tools -c dev -- powershell -File .\tools\icepanel-push-c4-levels.ps1
```

## Supporting

| Script | Purpose |
|--------|---------|
| `icepanel-driver.ps1` | General REST driver (import, diagram POST) |
| `icepanel-ui-debug.ps1` | Blank canvas / diagram count diagnostic |
| `icepanel-healthcheck.ps1` | Auth smoke test |

## Deprecated (do not use for new work)

| Script | Why |
|--------|-----|
| `icepanel-layout.ps1` | Context-only scaffold; no L2/L3 |
| `icepanel-push-diagrams.ps1` | Superseded by push-c4-levels |
| `gen-portfolio-master.py` | Single-canvas megamap anti-pattern |
