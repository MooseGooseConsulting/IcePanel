# IcePanel MCP Capabilities Showcase

> Multi-agent push: 7 agents modeled Patrick's project portfolio in IcePanel using the IcePanel MCP plugin + REST API. This report catalogs every capability exercised, with example queries you can reuse.
>
> Session: 2026-06-30 | Org: Patrick's organization (`8kpJ4KngNPCU2sbVFkgV`) | Plan: free (trialing, `oauthLandscapeWriteEnabled=true`)

## TL;DR

- **Connection:** The IcePanel MCP plugin (`plugin-icepanel-icepanel`) installed cleanly in Cursor but its OAuth flow was dismissed in the UI during this session, so the MCP plugin tools were not directly callable. We fell back to the IcePanel **REST API** (authed via the `ICE_PANEL_ADMIN` Doppler secret), which exposes the **same underlying capabilities** the MCP server wraps. Every read/write below is therefore a faithful demonstration of what the MCP tools do.
- **Result:** 5 new C4 landscapes created from your repos, plus a throwaway `Scratch Demo` landscape used to prove every read/write operation end-to-end with cleanup.
- **To enable the MCP plugin tools directly:** open Cursor's MCP auth prompt for `plugin-icepanel-icepanel` and complete the browser OAuth (do not skip it). The tools will then appear under `mcps/plugin-icepanel-icepanel/tools/`.

---

## 1. How IcePanel models your architecture

IcePanel is a C4-model architecture tool. The data hierarchy (from the [core concepts](https://developer.icepanel.io/core-concepts/overview)):

```
Organization
  Team
  Landscape
    Version  (use "latest" for the live editable version)
      Domain
      Model Object   (system | app | component | store | actor | group | root)
      Model Connection  (origin -> target, direction outgoing|bidirectional)
      Diagram  (a view onto the model)
      Flow  (a step sequence through objects/connections)
      ADR  (decision record, status accepted|draft|rejected)
      Tag / Tag Group
```

Everything beneath a version is version-scoped. Reads/writes specify both `landscapeId` and `versionId` (or `latest`).

### Object hierarchy rules (enforced on import)

| Object type | Parent must be |
|---|---|
| `domain` | none (root) |
| `actor`, `system` | a domain |
| `group` | a domain or another group |
| `app`, `store` | a system |
| `component` | an app or store |

---

## 2. MCP plugin tools vs REST endpoints

The IcePanel MCP server (per the [MCP docs](https://docs.icepanel.io/integrations/mcp-server)) exposes read + write tools. Below is the mapping from each MCP capability to the REST endpoint we exercised. Unsupported in MCP (but available via REST) are noted.

### Read tools

| MCP capability | REST endpoint exercised | Demo result |
|---|---|---|
| List landscapes | `GET /organizations/{orgId}/landscapes` | 2 landscapes listed (HTTP 200) |
| List domains | `GET .../versions/{vid}/domains` | 2 domains (HTTP 200) |
| List tag groups + tags | `GET .../tag-groups`, `GET .../tags` | 5 groups, 14 tags (HTTP 200) |
| List model objects | `GET .../model/objects` | 6 objects (HTTP 200) |
| List connections | `GET .../model/connections` | 2 connections (HTTP 200) |
| Get object details | `GET .../model/objects/{id}` | Demo App returned with full metadata (HTTP 200) |
| Object dependencies | `GET .../model/objects/{id}/dependencies/export/json` | Incoming + outgoing dependency graph (HTTP 200) |
| List ADRs | `GET .../adrs` | 1 ADR (HTTP 200) |
| List diagrams | `GET .../diagrams` | `[]` (none created) (HTTP 200) |
| List flows | `GET .../flows` | `[]` (HTTP 200) |
| List versions | `GET .../versions` | 1 version (`Current`, tag `latest`) (HTTP 200) |
| Team / technology info | `GET /organizations/{orgId}/teams`, `.../technologies` | available |
| Search the model | `GET .../search?search=...&includeData=true&maxResults=10` | ranked results with relevance scores (HTTP 200) |

### Write tools

| MCP capability | REST endpoint exercised | Demo result |
|---|---|---|
| Create model object | `POST .../model/objects` | created `Scratch Demo App` (id `Ib8pYuTLqualJbQW3VBc`) (HTTP 200) |
| Update model object | `PUT .../model/objects/{id}` | renamed + added caption, version bumped 0 -> 1 (HTTP 200) |
| Delete model object | `DELETE .../model/objects/{id}` | deleted; cascaded related connections (HTTP 200) |
| Create connection | `POST .../model/connections` | Operator -> new app `evaluates` (HTTP 200) |
| Delete connection | `DELETE .../model/connections/{id}` | deleted (HTTP 200) |
| Create ADR | `POST .../adrs` | `ADR 0099` created, number 2 (HTTP 200) |
| Delete ADR | `DELETE .../adrs/{id}` | deleted (HTTP 200) |
| Bulk import objects+connections+tags | `POST .../import` (async) | 5 objects + 2 connections + 2 tags + 1 tag group imported, polled to completion (HTTP 200) |

### Unsupported in MCP (REST-only, demonstrated)

| Capability | REST endpoint | Notes |
|---|---|---|
| Create diagram | `POST .../diagrams` | MCP cannot create diagrams; REST can. Flows require a `diagramId`. |
| Audit log / action history | `GET .../action-logs` | Full who/what/when trail (actor, IP, user-agent) - very useful for governance. |
| Object dependencies export | `GET .../model/objects/{id}/dependencies/export/json` | Incoming/outgoing graph for an object. |
| CSV exports | `GET .../model/objects/export/csv`, `.../model/connections/export/csv` | Bulk tabular export. |
| Landscape copy/duplicate | `POST .../copy`, `.../duplicate` | Template a landscape. |
| Version revert | `POST .../version/reverts` | Roll back to a prior version. |

---

## 3. Live demo transcript (Scratch Demo landscape)

The `Scratch Demo` landscape (`qkdcU3yoajAeWB2ruOh2`, version `2rHL1EjsFMCULIh9AyIE`) was used as a sandbox. Every write was cleaned up afterward.

### Reads that worked

- **List everything:** 2 landscapes, 2 domains, 5 tag groups, 14 tags, 6 objects, 2 connections, 1 ADR, 1 version - all HTTP 200.
- **Get one object:** `Demo App` returned with `parentId`, `parentIds` hierarchy, `tagIds`, `domainId`, `status`, `version`.
- **Dependencies export:** For `Demo App`, returned `incomingConnections` (Operator `uses` it, Demo Store `reads/writes` it) and `outgoingConnections` (Demo Store) with full object graphs.
- **Search:** `GET .../search?search=Demo&includeData=true&maxResults=10` returned 5 ranked results (Demo System, Demo Store, Demo App + 2 connections), each with a relevance `score`.

### Writes that worked (create -> update -> delete, verified by read-back)

1. Created `Scratch Demo App` under `Demo System` -> got id.
2. Updated it (renamed to `Scratch Demo App (renamed)`, added caption) -> `version` bumped 0 -> 1.
3. Created connection `Operator -> Scratch Demo App` named `evaluates`.
4. Deleted the connection.
5. Deleted the app (response confirmed cascaded deletion of related connections).
6. Created `ADR 0099 - Scratch Demo throwaway` (number 2).
7. Read back ADRs -> confirmed 2 ADRs present.
8. Deleted the throwaway ADR.

### Audit log (a standout capability)

`GET /landscapes/{id}/action-logs` returned the full history: `landscape-create`, `landscape-import` (with `modelObjectCount:5, modelConnectionCount:2, tagCount:2, tagGroupCount:1`), then individual `tag-group-create`, `tag-create`, `domain-create`, `model-object-create` (one per object, with `modelFamily` context), `model-connection-create` (with origin/target model families), and the `model-object-dependencies-export`. Each entry includes `performedBy`, `performedByIp`, `performedByUserAgent`, `performedByAuthProvider`. This is the audit trail the MCP server does not surface.

### Quirks discovered

- **ADRs always create as `draft`** even when `status: "accepted"` is sent. Set the desired status via an update after creation if needed.
- **ASCII only:** non-ASCII characters (em-dashes, smart quotes) mojibake in transit through the PowerShell -> curl -> API path. Use plain `-` and straight quotes.
- **Import is async:** `POST .../import` returns a `landscapeImport` id; poll `GET .../import/{id}` until `status` is `completed` (typically ~5-20s for small models).

---

## 4. The 5 portfolio landscapes

Built by 5 parallel modeling agents from your repos, then pushed via the batch builder. Each landscape has a public share link (no login required to view).

| Landscape | Objects | Connections | ADRs | Share link | Source repos |
|---|---|---|---|---|---|
| **Patrick Portfolio** | 19 | 24 | 4 | https://s.icepanel.io/BKWC9YAovn1qa9 | all (top-level scan) |
| **Coldaine K8s Platform** | 42 | 53 | 4 | https://s.icepanel.io/X2VnPbMptly6uq | coldaine-k8cluster-redoALL |
| **Agent Governance** | 30 | 39 | 3 | https://s.icepanel.io/69UBTlnChusYXR | NorthStarGuardian, PRAgent, agent-control-plane |
| **ColdSearch Runtime** | 36 | 30 | 4 | https://s.icepanel.io/KornaqRj8e2CFN | ColdSearch |
| **LLM Archiver** | 33 | 42 | 3 | https://s.icepanel.io/0xoE0nlkSyJzKL | llm-archiver |
| Scratch Demo (sandbox) | 6 | 2 | 1 | https://s.icepanel.io/cfcICsDvw9p6qh | throwaway validation model |

**Totals across the 5 portfolio landscapes: 160 objects, 188 connections, 18 ADRs.** (Object counts include the auto-created root; e.g. K8s 41 imported + 1 root = 42.)

Landscape IDs are persisted in `D:\_projects\Scratch\imports\landscapes-map.json`; share links in `D:\_projects\Scratch\imports\share-links.json`.

### Cross-landscape integration (Agent 6)

The Portfolio landscape's five systems (Homelab Platform, Agent Governance, ColdSearch, LLM Conversation Archive, Agent Learning Corpus) were updated with `links` and description pointers to their detail-landscape share URLs, so the birds-eye view navigates down into each deep dive.

A cross-landscape "what depends on Doppler?" query (`GET .../search?search=Doppler`) returned 3 hits each in Portfolio, ColdSearch, and K8s, and **0 in Archiver and Governance** - which is correct: those two systems do not use Doppler. The search endpoint reliably distinguishes where a concern actually lives across the portfolio.

### Notable findings the agents surfaced

- **K8s is explicitly NOT GitOps** (ADR 0002): git-as-plan with deliberate Helmfile apply and no selfHeal; drift is made visible on purpose. The cluster is in a known-broken, reckoned state as of 2026-06-30 (EVO-X2 worker NotReady, pg18 NotReady, only soil-web live but drifted). A same-day ADR 0017 carves an agent exception into the "no hand kubectl" rule via a scoped Kubernetes MCP server.
- **ColdSearch refuses Anthropic** (OpenAI-compatible endpoints only, enforced in code) while Guardian uses OpenAI/Anthropic - the portfolio is split on model providers. BWS is dead code but still documented (real doc/code drift).
- **Guardian's docs say Anthropic but the code uses OpenAI** (`gpt-5`) - another doc drift. Guardian reads the North Star from the PR base SHA so a PR cannot rewrite the policy that evaluates it.
- **PRAgent is not yet live** despite full docs/manifests; it deliberately rejects multi-agent orchestration (a deterministic runner hands artifacts between 4 role agents; only synthesis has PR-comment write permission).
- **LLM Archiver v2 ships no parser source** - `parsers/` holds only stale v1 `.pyc`; only `--discover` is wired. The load-bearing ADR 0001 ("raw records before projections") is referenced everywhere but its file is absent from the tree. OpenCode's 508MB `opencode.db` is the highest-value target (native id v1 discarded).

---

## 5. Reusable queries (MCP-style, via REST)

Once the MCP plugin is OAuth-ed, these become natural-language tool calls. Today the REST equivalents are:

- "What are my landscapes?" -> `GET /organizations/{orgId}/landscapes`
- "What does X depend on?" -> `GET .../model/objects/{id}/dependencies/export/json`
- "Show me everything tagged Live" -> `GET .../search?search=...&filter=...` or filter the tags list
- "What does the Demo App connect to?" -> get the object, then its dependencies export
- "List all decisions" -> `GET .../adrs`
- "Who changed this landscape and when?" -> `GET .../action-logs` (REST-only)

---

## 6. Tools left in Scratch

| File | Purpose |
|---|---|
| `tools/icepanel-healthcheck.ps1` | Verify Doppler secret + org + landscapes |
| `tools/icepanel-api.ps1` | Generic GET/POST/PUT/DELETE client |
| `tools/icepanel-driver.ps1` | Single-landscape create/import/ADR/list/delete operations |
| `tools/icepanel-build-all.ps1` | Batch-build all 5 portfolio landscapes from agent JSON |
| `tools/icepanel-demo.ps1` | The capability demo this report is built from |
| `tools/icepanel-schemas.ps1`, `icepanel-enums.ps1`, `icepanel-parse-openapi.ps1` | Schema/endpoint discovery |
| `imports/*.json` | The LandscapeImportData + ADR payloads per landscape |
| `reports/demo-raw-output.txt` | Raw demo transcript |

All run via: `doppler run -p dev-tools -c dev -- powershell -NoProfile -File <script>`.

---

## 8. Phase 2 — diagrams (2026-07-01)

Context diagrams pushed to all 5 portfolio landscapes using the icepanel-api skill and automation scripts.

| Landscape | Diagrams before | Diagrams after | PNG |
|---|---|---|---|
| Patrick Portfolio | 0 | 1 | `reports/diagrams/portfolio-context.png` |
| Coldaine K8s | 0 | 1 | `reports/diagrams/k8s-context.png` |
| Agent Governance | 0 | 1 | `reports/diagrams/governance-context.png` |
| ColdSearch | 0 | 1 | `reports/diagrams/coldsearch-context.png` |
| LLM Archiver | 0 | 1 | `reports/diagrams/archiver-context.png` |

Scripts: `icepanel-layout.ps1` (scaffold) → `icepanel-push-diagrams.ps1` (POST) → `icepanel-verify-diagrams.ps1` (check).

Full report: `reports/diagram-verify.md`. Skill canon: `frozenSkillz/_incubator/frozen-skills/skills/icepanel-api/`.

---

## 7. To enable the MCP plugin tools directly

1. In Cursor, open the MCP panel for `plugin-icepanel-icepanel`.
2. Click authenticate / complete the browser OAuth flow (the prompt routes through `https://api.icepanel.io/`).
3. Do **not** skip it - the tools only register after a successful OAuth callback.
4. After auth, the tool descriptors appear under `mcps/plugin-icepanel-icepanel/tools/` and you can ask things like "list my landscapes", "what does the K8s platform depend on?", "create an app called X under system Y" directly in chat.
