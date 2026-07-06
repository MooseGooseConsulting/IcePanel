# Action types — audit log reference

`GET /landscapes/{landscapeId}/action-logs` supports `filter[actionType]`, `filter[performedBy]`, date ranges, `filter[actionId]`.

Stats: `GET .../action-logs/stats/by-type` · `GET .../action-logs/stats/by-entity`

Child actions: `GET .../action-logs/{actionLogId}/children`

---

## OrganizationActionType

| Category | actionType values |
|----------|-------------------|
| **Users** | `user-invite-create`, `user-invite-revoke`, `user-remove`, `user-update` |
| **Teams** | `team-create`, `team-update`, `team-delete` |
| **API keys** | `api-key-create`, `api-key-update`, `api-key-delete` |
| **Org tech** | `organization-technology-create`, `organization-technology-update`, `organization-technology-delete` |
| **Webhooks** | `webhook-subscription-create`, `webhook-subscription-update`, `webhook-subscription-delete` |

---

## LandscapeActionType (model)

| Category | actionType values |
|----------|-------------------|
| **Objects** | `model-object-create`, `model-object-update`, `model-object-delete` |
| **Connections** | `model-connection-create`, `model-connection-update`, `model-connection-delete` |
| **Domains** | `domain-create`, `domain-update`, `domain-delete` |
| **Tags** | `tag-create`, `tag-update`, `tag-delete`, `tag-group-create`, `tag-group-update`, `tag-group-delete` |
| **Technologies** | `technology-create`, `technology-update`, `technology-delete` |

---

## LandscapeActionType (diagrams & flows)

| Category | actionType values |
|----------|-------------------|
| **Diagrams** | `diagram-create`, `diagram-update`, `diagram-delete`, `diagram-content-update`, `diagram-group-create`, `diagram-group-update`, `diagram-group-delete` |
| **Flows** | `flow-create`, `flow-update`, `flow-delete` |
| **Comments** | `comment-create`, `comment-update`, `comment-delete`, `comment-reply-create`, `comment-reply-update`, `comment-reply-delete` |
| **ADRs** | `adr-create`, `adr-update`, `adr-delete` |

---

## LandscapeActionType (landscape ops)

| Category | actionType values |
|----------|-------------------|
| **Import/export** | `landscape-import`, `landscape-export`, `diagram-export-image` |
| **Versions** | `version-create`, `version-update`, `version-delete`, `version-revert-create`, `version-revert-update` |
| **Drafts** | `draft-create`, `draft-update`, `draft-delete`, `draft-merge`, `draft-rebase` |
| **Share** | `share-link-create`, `share-link-update`, `share-link-delete` |
| **Landscape** | `landscape-create`, `landscape-update`, `landscape-delete`, `landscape-duplicate`, `landscape-copy` |
| **Reality links** | `reality-link-create`, `reality-link-update`, `reality-link-delete` |

---

## Forensics recipes

**Did import run?**
```
GET .../action-logs?filter[actionType]=landscape-import&limit=5
```

**Who moved diagram objects?**
```
GET .../action-logs?filter[actionType]=diagram-content-update
```

**Draft merged when?**
```
GET .../action-logs?filter[actionType]=draft-merge
```

**Recent activity by user:**
```
GET .../action-logs?filter[performedBy]={userId}
```

Each log entry includes `actionId`, `performedBy`, `performedAt`, `entityId`, `entityType`, and optional `data` payload.
