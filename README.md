# IcePanel — Patrick Portfolio C4

Dedicated repo for modeling Patrick's infrastructure and AI PR review stack in [IcePanel](https://icepanel.io) using proper C4 levels (L1 context → L2 containers → L3 components).

**Start here for context:** [HANDOFF.md](HANDOFF.md) — what you asked for, lessons learned, gaps for next session.

---

## Quick start

```powershell
cd d:\_projects\IcePanel
doppler run -p dev-tools -c dev -- powershell -File .\tools\icepanel-healthcheck.ps1
```

Open editor: https://app.icepanel.io/landscapes/Efdez5uW6BfQjErrQ4Gx/versions/latest

After model changes:

```powershell
doppler run -p dev-tools -c dev -- powershell -File .\tools\icepanel-dump-model.ps1 portfolio
python tools/gen-portfolio-c4-levels.py
doppler run -p dev-tools -c dev -- powershell -File .\tools\icepanel-push-c4-levels.ps1
```

---

## Layout

```
IcePanel/
├── AGENT_BRIEF.md              Modeler contract
├── imports/
│   ├── portfolio-megamap-full.json   Active model
│   ├── diagrams/portfolio-l*.json    12 C4 diagrams
│   └── archive/                      Deprecated + satellite staging
├── tools/                      REST automation
├── reports/                    Model maps, verification, PNG exports
├── scripts/                    Merge utilities
└── .cursor/skills/icepanel-api/      Agent skill + methodology
```

Skill entry: [.cursor/skills/icepanel-api/SKILL.md](.cursor/skills/icepanel-api/SKILL.md)

---

## What belongs here

- IcePanel model JSON, diagram payloads, push scripts
- C4 methodology skill and agent briefs
- Portfolio landscape IDs and verification reports

## What does not

- Unrelated agent experiments, K8s post-mortems, GitHub audit dumps → use `d:\_projects\Scratch` or the relevant project repo
