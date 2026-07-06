# Visual design — tags, icons, themes, share modes

IcePanel has no per-diagram custom hex colors in the API. Visual richness comes from **tag colors**, **catalog technology icons**, **diagram layout**, **area boundaries**, and **export theme**.

---

## TagColor (full enum)

| Value | UI swatch | Recommended use |
|-------|-----------|-----------------|
| `blue` | 🔵 | Core platform, infra |
| `dark-blue` | 🔷 | Security, compliance, governance |
| `green` | 🟢 | Live, production, healthy |
| `yellow` | 🟡 | WIP, beta, caution |
| `orange` | 🟠 | Integration, API boundary |
| `red` | 🔴 | Deprecated, external, critical |
| `purple` | 🟣 | AI agents, ML pipelines |
| `pink` | 🩷 | Product, user-facing |
| `beaver` | 🦫 | Homelab, personal projects |
| `grey` | ⚪ | Unclassified |
| `white` | ⬜ | Placeholder / draft |
| `black` | ⬛ | Legacy, removed |

Apply via `tags[].color` in import or `POST .../tags`.

---

## TagGroupIcon (full enum)

`bug` · `calendar-check` · `calendar-times` · `cloud` · `cog` · `database` · `exclamation-triangle` · `file` · `globe` · `laptop-code` · `lightbulb` · `lock` · `microchip` · `minus` · `mobile` · `network-wired` · `plus` · `poo` · `robot` · `rocket` · `sack-dollar` · `server` · `sledding` · `snowman` · `star` · `times` · `toolbox` · `trash` · `users` · `wifi`

Suggested groupings:

| Icon | Group name example |
|------|-------------------|
| `server` | Platform |
| `robot` | Agents / automation |
| `lock` | Security |
| `database` | Data stores |
| `network-wired` | Networking |
| `rocket` | Deployment |
| `users` | Actors / teams |
| `lightbulb` | ADR / decisions |

---

## CatalogTechnologyType

`data-storage` · `deployment` · `framework-library` · `gateway` · `other` · `language` · `message-broker` · `network` · `protocol` · `runtime` · `service-tool`

Attach to objects/connections via `technologyIds`. Platform catalog: `GET /catalog/technologies`. Org catalog: `GET /organizations/{orgId}/technologies`.

`CatalogRestriction`: which object types may use a technology — `actor`, `app`, `component`, `connection`, `group`, `store`, `system`.

---

## Diagram visual vocabulary

| Element | API field | Effect |
|---------|-----------|--------|
| System box | `shape: "box"`, `type: "system"` | Standard C4 system |
| Group boundary | `shape: "area"`, `type: "group"` | Dashed region around children |
| Store | `type: "store"` | Cylinder-style in UI |
| Actor | `type: "actor"` | Person stick figure |
| Curved edge | `lineShape: "curved"` | Default, readable |
| Orthogonal edge | `lineShape: "square"` | Dense diagrams |
| Straight edge | `lineShape: "straight"` | Minimal |

Connectors (12-point): `top-left` through `left-top` — see [diagrams.md](../diagrams.md).

---

## Export themes

**Diagram image export** (`POST .../export/image`):

| Field | Values |
|-------|--------|
| `theme` | `light`, `dark` |
| `maxWidth` | pixels (e.g. 2048) |

Response `fileUrls`: `png`, `svg` when ready.

**Landscape export** (`POST .../export?type=...`):

| type | Output |
|------|--------|
| `pdf` | Full landscape PDF |
| `markdown` | Docs-friendly |
| `html` | Standalone HTML |
| `llms` | LLM-optimized text bundle |
| `json` | Full model + metadata |
| `object-csv` | Objects spreadsheet |
| `connection-csv` | Connections spreadsheet |

Pass `draftId` in export options to preview draft state before merge.

---

## ShareLinkOptions modes

| mode | Opens |
|------|-------|
| `overview` | Landscape home |
| `diagrams` | Diagram list |
| `diagram` | Single diagram (requires `diagramId`) |
| `flows` | Flow list |
| `flow` | Single flow (requires `flowId`) |
| `model-objects` | Object browser |
| `model-connections` | Connection browser |
| `model-viewer` | 3D-style model viewer |
| `dependencies` | Dependency graph |
| `technologies` | Tech catalog view |
| `adrs` | ADR list |

Deep link anatomy:

```
https://s.icepanel.io/{shareShortId}/{optionsHandle}
                              ↑ required — without it, link 404s
```

Create/update: `POST|PATCH .../share-link` with `ShareLinkOptions`.

---

## Layout density guide

| Diagram size | Column gap | Row gap | lineShape |
|--------------|------------|---------|-----------|
| ≤ 8 objects | 320px | 160px | curved |
| 9–16 objects | 280px | 140px | curved or square |
| 17+ objects | 240px | 120px | square + areas |

Default box: **280×120**. Default area: **600×400**. Origin: **(80, 80)**.

Left column = actors. Center = owned systems/apps. Right = external systems.
