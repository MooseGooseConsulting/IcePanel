# Patrick Portfolio - IcePanel Model Summary

> **Stale snapshot (June 2026).** For current state see [HANDOFF.md](../HANDOFF.md).  
> Live: **42 objects**, **46 connections**, **12 C4 diagrams**, **0 flows**, **0 ADRs**.

---

## Historical note (pre-megamap / pre-C4)

The text below describes the original 19-object portfolio with cross-landscape share links — an approach we **rejected** in favor of one merged model with L1/L2/L3 drill-down.

<details>
<summary>Original summary (archived)</summary>

The birds-eye C4 context for Patrick's whole portfolio. High-level systems, actors, and external dependencies - the map that links down into each detail landscape.

## Structure

- **Domain:** Patrick Portfolio
- **Actors:** Operator (Patrick), AI Coding Agents (Cursor/Codex/Claude)
- **Internal systems:** Homelab Platform, Agent Governance, ColdSearch, LLM Conversation Archive, Agent Learning Corpus, Portfolio Control Service, Personal Tools and Experiments
- **Governance apps:** NorthStarGuardian (live), PRAgent (future)
- **External systems:** GitHub, Doppler, LLM and Agent Runtimes (OpenAI/Anthropic/Letta), Cloudflare, Linear, Search/Extract Providers

## Cross-landscape links (Agent 6)

Five Portfolio systems were linked to their detail-landscape share URLs:

| Portfolio system | Detail landscape | Link |
|---|---|---|
| Homelab Platform | Coldaine K8s Platform | https://s.icepanel.io/X2VnPbMptly6uq |
| Agent Governance | Agent Governance | https://s.icepanel.io/69UBTlnChusYXR |
| ColdSearch | ColdSearch Runtime | https://s.icepanel.io/KornaqRj8e2CFN |
| LLM Conversation Archive | LLM Archiver | https://s.icepanel.io/0xoE0nlkSyJzKL |
| Agent Learning Corpus | LLM Archiver | https://s.icepanel.io/0xoE0nlkSyJzKL |

## ADRs (4)

1. Git is the plan, not a controller
2. Advisory agents never block merge
3. Transcripts are ground truth; repos hold distilled learnings
4. Secrets fail loud; no secret values in git

## Cross-landscape query: "what depends on Doppler?"

Search for "Doppler" across all 5 landscapes returned 3 hits here (Portfolio), 3 in ColdSearch, 3 in K8s, and 0 in Archiver and Governance - confirming Doppler is a homelab + search-runtime concern, not a governance or archiver one.

## Key flows modeled

- agents -> ColdSearch (search)
- agents -> LLM Conversation Archive -> Agent Learning Corpus -> agents (skills promotion)
- GitHub <-> governance apps (PR review)
- Doppler -> Homelab Platform (ESO) and ColdSearch (key injection)
- Homelab Platform -> agents (internal Qwen LLM endpoint at 192.168.30.31:8080)
- Archive -> Homelab Platform (Postgres corpus)

</details>
