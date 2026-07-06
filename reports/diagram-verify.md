# Phase 2+ diagram verification

> **Superseded context:** July 1 2026 — five landscapes, one context diagram each, zero L2/L3.  
> **Current state:** See [HANDOFF.md](../HANDOFF.md) — Patrick Portfolio has **12 C4 diagrams**, **42 objects**, **0 flows**, **0 ADRs** (verified 2026-07-06).

Re-run verification after the next work session:

```powershell
doppler run -p dev-tools -c dev -- powershell -File .\tools\icepanel-ui-debug.ps1
doppler run -p dev-tools -c dev -- powershell -File .\tools\icepanel-verify-diagrams.ps1
```

Use the success checklist in `HANDOFF.md`, not the criteria below.

---

## Historical (July 1 — do not use as target)

| Slug | diagrams | Notes |
|------|----------|-------|
| portfolio | 1 context only | Pre-C4 set |
| k8s, governance, coldsearch, archiver | 1 context each | Satellite silos |

Share URLs and PNG paths from that pass are obsolete for portfolio structure.
