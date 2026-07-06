# Modeler agent brief

You build the **model graph** (objects + connections). You do **not** call IcePanel and do **not** layout diagrams.

Read first: [c4-methodology.md](../c4-methodology.md) · [anti-patterns.md](../anti-patterns.md)

---

## Outputs

```
imports/<slug>.json          LandscapeImportData
imports/<slug>-adrs.json     ADR array (optional)
```

Scratch portfolio: prefer contributing to **`imports/portfolio-megamap-full.json`** (merged), not a new silo landscape.

Full contract: repo root `AGENT_BRIEF.md`

---

## Model depth by C4 intent

| Intent | Model | Diagram (later) |
|--------|-------|-----------------|
| Portfolio overview | domain, actors, systems, externals | L1 only first |
| System internals | + apps, stores under each system | L2 per system |
| App internals | + components under key apps | L3 selective |

**Do not** flatten everything as apps under domain to "fit one diagram." Apps belong under **systems**.

---

## Hierarchy (enforced on import)

| type | parent |
|------|--------|
| domain | — |
| actor, system | domain |
| group | domain or group |
| app, store | system |
| component | app or store |

---

## Portfolio modeling rules

1. **One primary landscape** — merge k8s/governance/coldsearch/archiver detail into portfolio systems
2. **Systems at L1** — Homelab, AI PR Review Pipeline, Governance, ColdSearch, Archive, Corpus
3. **External systems** — `external: true` for GitHub, Doppler, Cloudflare, LLM APIs
4. **AI PR Review stack** — system with apps: OpenHands, AI Review, LiteLLM, runner, workflow, policy store
5. **Components** — only when L3 is planned (debounce, evidence, router, agent script, etc.)

Object counts (guidance):

| Scope | Objects |
|-------|---------|
| Portfolio L1-only model | 12–25 |
| Portfolio + L2 apps | 35–50 |
| Portfolio + L3 components | 40–60 |

---

## IDs and ASCII

- Stable kebab-case, slug prefix: `pf-homelab`, `pf-aireview-openhands`
- Connections: verb + protocol names
- **ASCII only** in all strings

---

## Return summary

Object count by type (systems / apps / components), connection count, ADR count, which systems are L2-ready, surprises from repo review.
