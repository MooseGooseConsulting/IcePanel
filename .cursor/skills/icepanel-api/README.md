# icepanel-api skill

C4-first IcePanel modeling for Patrick's portfolio (`d:\_projects\IcePanel`).

## Start here

1. [SKILL.md](SKILL.md) — router and decision table
2. [c4-methodology.md](c4-methodology.md) — L1 / L2 / L3 rules
3. [anti-patterns.md](anti-patterns.md) — what failed in July 2026
4. [workflows.md](workflows.md) — model → L1 → L2 → L3 → flows → verify
5. [overlay.md](overlay.md) — landscape IDs, tools, commands

## Agent briefs

| Role | File |
|------|------|
| Model | [agents/MODELER.md](agents/MODELER.md) + repo `AGENT_BRIEF.md` |
| Diagrams | [agents/DIAGRAMMER.md](agents/DIAGRAMMER.md) |
| Merge | [agents/INTEGRATOR.md](agents/INTEGRATOR.md) |
| Verify | [agents/VERIFIER.md](agents/VERIFIER.md) |

## Quick commands

```powershell
doppler run -p dev-tools -c dev -- powershell -File .\tools\icepanel-dump-model.ps1 portfolio
python tools/gen-portfolio-c4-levels.py
doppler run -p dev-tools -c dev -- powershell -File .\tools\icepanel-push-c4-levels.ps1
```

Portfolio editor: https://app.icepanel.io/landscapes/Efdez5uW6BfQjErrQ4Gx/versions/latest
