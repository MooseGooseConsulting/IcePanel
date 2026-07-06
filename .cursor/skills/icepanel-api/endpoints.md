# IcePanel API — Endpoints by tag

Base: `https://api.icepanel.io/v1`. Path params: `{landscapeId}`, `{versionId}` (`latest` allowed where noted), `{organizationId}`.

**Legend:** 📖 read · ✏️ write · ⚡ async job · 🤖 AI-assisted · ⚠️ deprecated

Unless noted, landscape routes live under `/landscapes/{landscapeId}/versions/{versionId}/`.

## Action logs

| Method | Path | Summary |
|--------|------|---------|
| GET | `/landscapes/{landscapeId}/action-logs` | List action logs (cursor) |
| GET | `/landscapes/{landscapeId}/action-logs/{actionLogId}` | Get log (deprecated) |
| GET | `/landscapes/{landscapeId}/action-logs/{actionLogId}/children` | Child actions |
| GET | `/landscapes/{landscapeId}/action-logs/stats/by-type` | Stats by action type |
| GET | `/landscapes/{landscapeId}/action-logs/stats/by-entity` | Stats by entity |

## ADRs

| Method | Path | Summary |
|--------|------|---------|
| GET | `/landscapes/{landscapeId}/versions/{versionId}/adrs` | List |
| POST | `/landscapes/{landscapeId}/versions/{versionId}/adrs` | Create |
| GET/PATCH/DELETE | `.../adrs/{adrId}` | Get, update, delete |

## Catalog technologies (platform)

| Method | Path | Summary |
|--------|------|---------|
| GET | `/catalog/technologies` | List |
| GET | `/catalog/technologies/{catalogTechnologyId}` | Get |
| GET | `/catalog/technologies/slugs/{slug}` | Get by slug |
| POST | `/catalog/icons/signed-url` | Signed icon URL prefix |
| GET | `/catalog/suggestion/information` | AI suggest from URL |
| GET | `/catalog/suggestion/brand` | Brand suggest from URL |

## Comments

| Method | Path | Summary |
|--------|------|---------|
| GET/POST | `.../versions/{versionId}/comments` | List, create |
| GET/PUT/PATCH/DELETE | `.../comments/{commentId}` | CRUD |
| GET/POST | `.../comments/{commentId}/replies` | List, create replies |
| GET/PUT/PATCH/DELETE | `.../replies/{commentReplyId}` | Reply CRUD |

## Diagrams

| Method | Path | Summary |
|--------|------|---------|
| GET/POST | `.../diagrams` | List, create (+ content) |
| GET/HEAD/PUT/PATCH/DELETE | `.../diagrams/{diagramId}` | CRUD |
| GET/PUT/PATCH | `.../diagrams/{diagramId}/content` | Diagram canvas |
| POST | `.../diagrams/{diagramId}/content/generate-description` | AI description |
| POST | `.../diagrams/{diagramId}/view` | Emit view event |
| POST | `.../diagrams/{diagramId}/action` | Emit diagram action |
| POST | `.../diagrams/{diagramId}/export/image` | Export PNG/SVG job |
| GET | `.../export/image/{diagramExportImageId}` | Export status |
| GET | `.../diagrams/thumbnails` | List thumbnails |
| GET | `.../diagrams/{diagramId}/thumbnail` | Get thumbnail |

## Diagram groups

| Method | Path | Summary |
|--------|------|---------|
| GET/POST | `.../diagram-groups` | List, create |
| GET/HEAD/PUT/PATCH/DELETE | `.../diagram-groups/{diagramGroupId}` | CRUD |

## Domains

| Method | Path | Summary |
|--------|------|---------|
| GET/POST | `.../domains` | List, create |
| GET/HEAD/PUT/PATCH/DELETE | `.../domains/{domainId}` | CRUD |

## Drafts

| Method | Path | Summary |
|--------|------|---------|
| GET/POST | `.../drafts` | List, create |
| GET/PATCH/PUT/DELETE | `.../drafts/{draftId}` | CRUD |
| POST | `.../drafts/{draftId}/rebase` | Rebase onto latest |
| POST | `.../drafts/{draftId}/merge` | Merge into version |
| POST | `.../drafts/{draftId}/view` | Emit view |

## Flows

| Method | Path | Summary |
|--------|------|---------|
| GET/POST | `.../flows` | List, create |
| GET/HEAD/PUT/PATCH/DELETE | `.../flows/{flowId}` | CRUD |
| POST | `.../flows/{flowId}/view` | Emit view |
| GET | `.../flows/thumbnails`, `.../flows/{flowId}/thumbnail` | Thumbnails |
| GET | `.../flows/{flowId}/export/text` | Text export |
| GET | `.../flows/{flowId}/export/code` | Code export |
| GET | `.../flows/{flowId}/export/mermaid` | Mermaid export |

## Landscape

| Method | Path | Summary |
|--------|------|---------|
| GET/PATCH/DELETE | `/landscapes/{landscapeId}` | Get, update, delete |
| POST | `/landscapes/{landscapeId}/duplicate` | Duplicate |
| POST | `/landscapes/{landscapeId}/copy` | Copy into target landscape |
| GET | `.../search` | Full-text search |
| GET | `/landscapes/{landscapeId}/thumbnails/primary` | Primary thumbnail |
| POST | `.../export` | Export job (pdf, json, csv, …) |
| GET | `.../export/{landscapeExportId}` | Export status |
| POST | `.../import` | Import job |
| GET | `.../import/{landscapeImportId}` | Import status |

## Model connections

| Method | Path | Summary |
|--------|------|---------|
| GET/POST | `.../model/connections` | List (cursor), create |
| GET/PUT/PATCH/DELETE | `.../model/connections/{modelConnectionId}` | CRUD |
| GET | `.../model/connections/export/csv` | CSV (deprecated → landscape export) |
| POST | `.../model/connections/{id}/generate-description` | AI description |

## Model objects

| Method | Path | Summary |
|--------|------|---------|
| GET/POST | `.../model/objects` | List (cursor), create |
| GET/PUT/PATCH/DELETE | `.../model/objects/{modelObjectId}` | CRUD |
| GET | `.../model/dependencies` | Dependency graph |
| GET | `.../model/objects/{id}/dependencies/export/json` | Dependency JSON |
| GET | `.../model/objects/export/csv` | CSV (deprecated) |
| POST | `.../model/objects/{id}/generate-description` | AI caption/detailed |

## Organizations

| Method | Path | Summary |
|--------|------|---------|
| GET/POST | `/organizations` | List, create |
| GET/PATCH/DELETE | `/organizations/{organizationId}` | CRUD |
| GET/POST | `/organizations/{organizationId}/landscapes` | List, create landscape |
| GET | `/organizations/{organizationId}/logs` | Org audit logs |
| GET | `/organizations/{organizationId}/logs/stats/by-type` | Org stats |
| GET | `/organizations/{organizationId}/logs/stats/by-entity` | Org stats |

## Organization technologies, users, teams

| Method | Path | Summary |
|--------|------|---------|
| GET/POST | `.../technologies` | Org catalog tech CRUD |
| GET/PATCH/DELETE | `.../technologies/{catalogTechnologyId}` | |
| GET/POST | `.../users/invites` | Invites |
| POST | `.../users/invites/{id}` | Revoke invite |
| GET | `.../users` | List users |
| PATCH/DELETE | `.../users/{userId}` | Update, remove |
| GET/POST | `.../teams` | Teams |
| GET/PATCH/DELETE | `.../teams/{teamId}` | |
| GET | `.../teams/{teamId}/landscapes` | Team landscapes |
| GET | `.../teams/{teamId}/model/objects` | Team-owned objects |

## Share link

| Method | Path | Summary |
|--------|------|---------|
| GET/POST/PATCH/DELETE | `.../share-link` | Share link CRUD |

## Tags

| Method | Path | Summary |
|--------|------|---------|
| GET/POST | `.../tags` | List, create |
| GET/PUT/PATCH/DELETE | `.../tags/{tagId}` | CRUD |
| GET/POST | `.../tag-groups` | Tag groups |
| GET/PUT/PATCH/DELETE | `.../tag-groups/{tagGroupId}` | CRUD |

## Versions

| Method | Path | Summary |
|--------|------|---------|
| GET/POST | `/landscapes/{landscapeId}/versions` | List (cursor), create |
| GET/PATCH/DELETE | `.../versions/{versionId}` | CRUD |
| GET | `.../versions/{versionId}/export/json` | JSON export (deprecated) |
| GET/POST | `/landscapes/{landscapeId}/version/reverts` | List, create revert |
| GET/PATCH | `.../version/reverts/{versionRevertId}` | Get, update revert |

## Webhooks (incoming events)

| Event | Collection | Operations |
|-------|------------|------------|
| `model-connection` | model-connection | created, updated, deleted |
| `model-object` | model-object | created, updated, deleted |
