# IcePanel API — Key schemas and enums

Quick field reference. Full OpenAPI: `tools/openapi-output.txt`.

---

## Error

```json
{ "message": "string", "code": "string", "errors": ["string"] }
```

| HTTP | Meaning |
|------|---------|
| 400 | Bad request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not found |
| 409 | Conflict (commit / draft) |
| 422 | Validation / hierarchy |
| 429 | Rate limited |
| 500 | Server error |
| 503 | Unavailable (retry jobs) |

---

## ModelObjectType

API runtime: `actor` · `app` · `component` · `group` · `root` · `store` · `system`

Import schema: `domain` · `actor` · `app` · `component` · `group` · `store` · `system` (use `domain` not `root` in import JSON)

### Hierarchy (import enforced)

| type | parent |
|------|--------|
| domain | — |
| actor, system | domain |
| group | domain or group |
| app, store | system |
| component | app or store |

### ModelObjectRequired (create)

`name`, `parentId`, `type`, `domainId`, `handleId`

### Notable read fields

`id`, `handleId`, `parentIds`, `childIds`, `status`, `caption`, `description`, `external`, `groupIds`, `tagIds`, `technologyIds`, `teamIds`, `labels`, `links`, `diagrams`, `flows`, `version`, `commit`

---

## ModelConnection

### ModelConnectionRequired

`direction`, `name`, `originId`, `targetId`

Optional: `viaId`, `description`, `status`, `tagIds`, `technologyIds`, `labels`, `links`

Direction: `outgoing` · `bidirectional`

Status: `live` · `future` · `deprecated` · `removed`

---

## DiagramCreate

= `DiagramRequired` + `DiagramContentRequired`

### DiagramRequired

`name`, `type`, `modelId`, `index`

### DiagramContentRequired

`objects`, `connections`, `comments` — each a **map** keyed by canvas id

### DiagramObject required

`id`, `modelId`, `type`, `shape`, `width`, `height`, `x`, `y`

DiagramObjectType: `actor` · `app` · `group` · `component` · `store` · `system`

DiagramObjectShape: `box` · `area`

### DiagramConnection required

`id`, `modelId`, `originId`, `targetId`, `lineShape`, `originConnector`, `targetConnector`, `labelPosition`, `points`

LineShape: `curved` · `straight` · `square`

DiagramType: `context-diagram` · `app-diagram` · `component-diagram`

---

## DiagramContent partial update

```json
{
  "objects": {
    "$add": {},
    "$update": {},
    "$remove": [],
    "$replace": {}
  },
  "connections": {
    "$add": {},
    "$update": {},
    "$remove": [],
    "$replace": {}
  },
  "comments": {
    "$add": {},
    "$update": {},
    "$remove": [],
    "$replace": {}
  }
}
```

---

## LandscapeImportData

Minimal valid payload:

```json
{
  "modelObjects": [
    { "id": "object-1", "name": "Domain", "type": "domain" },
    { "id": "object-2", "name": "System", "parentId": "object-1", "type": "system" }
  ],
  "modelConnections": [
    {
      "id": "connection-1",
      "name": "Connection",
      "direction": "outgoing",
      "originId": "object-2",
      "targetId": "object-3"
    }
  ],
  "tagGroups": [{ "id": "tag-group-1", "name": "Tag Group", "icon": "bug" }],
  "tags": [{ "id": "tag-1", "name": "Tag", "color": "beaver", "groupId": "tag-group-1" }]
}
```

Optional: `namespace` (multi-source merge isolation)

Schema URL: `https://api.icepanel.io/v1/schemas/LandscapeImportData`

---

## LandscapeExportType

`pdf` · `markdown` · `html` · `llms` · `json` · `object-csv` · `connection-csv`

---

## Flow

FlowRequired: `diagramId`, `name`, `index`, `steps`

FlowStepType: `introduction` · `information` · `outgoing` · `conclusion` · `alternate-path` · `parallel-path` · `subflow` · `self-action`

Details: [reference/flows-adrs-drafts.md](reference/flows-adrs-drafts.md)

---

## ADR

ADRRequired: `name`, `status`

ADRStatus: `accepted` · `draft` · `rejected`

---

## Draft

DraftStatus: `in-progress` · `merged` · `archived`

DraftTaskType: landscape mutations prefixed with `draft-` (e.g. `draft-model-object-create`, `draft-diagram-content-update`)

Draft conflicts: `overwrite` · `invalid-entity` · `invalid-entity-reference`

---

## Comments

CommentBodyType: `idea` · `inaccurate` · `new-idea` · `new-inaccurate` · `new-question` · `question`

CommentBodyStatus: `active` · `create` · `dismissed` · `open` · `resolved`

---

## Tags

TagColor: `blue` · `green` · `yellow` · `orange` · `red` · `beaver` · `dark-blue` · `purple` · `pink` · `white` · `grey` · `black`

Visual guide: [reference/visuals.md](reference/visuals.md)

---

## Catalog technology

CatalogTechnologyType: `data-storage` · `deployment` · `framework-library` · `gateway` · `other` · `language` · `message-broker` · `network` · `protocol` · `runtime` · `service-tool`

CatalogRestriction: `actor` · `app` · `component` · `connection` · `group` · `store` · `system`

---

## ShareLinkOptions modes

`overview` · `diagrams` · `flows` · `model-objects` · `model-viewer` · `model-connections` · `dependencies` · `technologies` · `diagram` · `flow` · `adrs`

---

## Reality links

RealityConnector: `github-repo` · `gitlab-repo` · `bitbucket-repo` · `azure-devops-repo` · branch/file/folder variants · `url`

Sync status: `valid` · `invalid`

---

## Version

VersionRequired: `name`, `notes` (10–20000 chars), `modelHandleId` (nullable)

VersionIdPathParam: resource id or `"latest"`

---

## Webhook payload

Collections: `model-object` · `model-connection`

Operations: `created` · `updated` · `deleted`

Verify: `X-IcePanel-Signature` (HMAC SHA256 hex) + `X-IcePanel-Timestamp`

---

## Action types

Full categorized lists: [reference/action-types.md](reference/action-types.md)

---

## Cross-reference index

| Topic | Document |
|-------|----------|
| Endpoints | [endpoints.md](endpoints.md) |
| Examples | [examples.md](examples.md) |
| Diagram layout | [diagrams.md](diagrams.md) |
| Workflows | [workflows.md](workflows.md) |
