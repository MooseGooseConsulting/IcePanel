# IcePanel API — Examples

All examples use `versions/latest`. Replace ids from live `GET` responses or `imports/landscapes-map.json`.

---

## Minimal LandscapeImportData

```json
{
  "tagGroups": [
    { "id": "tg-platform", "name": "Platform", "icon": "server" }
  ],
  "tags": [
    { "id": "tag-live", "name": "Live", "color": "green", "groupId": "tg-platform" }
  ],
  "modelObjects": [
    { "id": "demo-domain", "name": "Demo Domain", "type": "domain" },
    {
      "id": "demo-system",
      "name": "Demo System",
      "type": "system",
      "parentId": "demo-domain",
      "status": "live",
      "tagIds": ["tag-live"]
    },
    {
      "id": "demo-app",
      "name": "Demo App",
      "type": "app",
      "parentId": "demo-system",
      "status": "live"
    }
  ],
  "modelConnections": [
    {
      "id": "demo-conn",
      "name": "Calls",
      "direction": "outgoing",
      "originId": "demo-app",
      "targetId": "demo-system",
      "status": "live"
    }
  ]
}
```

Push:

```bash
doppler run -- curl -s -X POST \
  -H "Authorization: ApiKey $ICE_PANEL_ADMIN" \
  -H "Content-Type: application/json" \
  -d @imports/demo.json \
  "https://api.icepanel.io/v1/landscapes/Efdez5uW6BfQjErrQ4Gx/versions/latest/import"
```

---

## Context diagram (3 systems + 1 actor)

Assume model ids from import: `pf-domain`, `pf-actor-operator`, `pf-sys-k8s`, `pf-sys-governance`, `pf-sys-coldsearch`, and connection `pf-conn-op-k8s`.

```json
{
  "name": "Portfolio Context",
  "type": "context-diagram",
  "modelId": "pf-domain",
  "index": 0,
  "handleId": "ctx-portfolio",
  "objects": {
    "do-actor": {
      "id": "do-actor",
      "modelId": "pf-actor-operator",
      "type": "actor",
      "shape": "box",
      "x": 80,
      "y": 200,
      "width": 200,
      "height": 100
    },
    "do-k8s": {
      "id": "do-k8s",
      "modelId": "pf-sys-k8s",
      "type": "system",
      "shape": "box",
      "x": 400,
      "y": 120,
      "width": 280,
      "height": 120
    },
    "do-gov": {
      "id": "do-gov",
      "modelId": "pf-sys-governance",
      "type": "system",
      "shape": "box",
      "x": 400,
      "y": 280,
      "width": 280,
      "height": 120
    },
    "do-cs": {
      "id": "do-cs",
      "modelId": "pf-sys-coldsearch",
      "type": "system",
      "shape": "box",
      "x": 400,
      "y": 440,
      "width": 280,
      "height": 120
    }
  },
  "connections": {
    "dc-op-k8s": {
      "id": "dc-op-k8s",
      "modelId": "pf-conn-op-k8s",
      "originId": "do-actor",
      "targetId": "do-k8s",
      "lineShape": "curved",
      "originConnector": "right-middle",
      "targetConnector": "left-middle",
      "labelPosition": 0.5,
      "points": []
    }
  },
  "comments": {}
}
```

POST to `.../diagrams`. Response includes `diagram.id` and full `diagramContent`.

---

## App diagram with area (group) boundary

System scope `modelId` = app's parent system id. Use `shape: "area"` for logical grouping.

```json
{
  "name": "K8s Platform — Apps",
  "type": "app-diagram",
  "modelId": "k8s-system",
  "index": 0,
  "objects": {
    "area-data": {
      "id": "area-data",
      "modelId": "k8s-group-data",
      "type": "group",
      "shape": "area",
      "x": 60,
      "y": 60,
      "width": 640,
      "height": 320
    },
    "do-postgres": {
      "id": "do-postgres",
      "modelId": "k8s-store-postgres",
      "type": "store",
      "shape": "box",
      "x": 100,
      "y": 140,
      "width": 260,
      "height": 120
    },
    "do-cilium": {
      "id": "do-cilium",
      "modelId": "k8s-app-cilium",
      "type": "app",
      "shape": "box",
      "x": 420,
      "y": 140,
      "width": 260,
      "height": 120
    }
  },
  "connections": {},
  "comments": {}
}
```

---

## PATCH — add object to existing diagram

```json
{
  "objects": {
    "$add": {
      "do-new": {
        "id": "do-new",
        "modelId": "<model-object-id>",
        "type": "app",
        "shape": "box",
        "x": 720,
        "y": 140,
        "width": 280,
        "height": 120
      }
    }
  }
}
```

---

## Flow with steps

Create on diagram `diagramId` from prior POST.

```json
{
  "diagramId": "<diagram-id>",
  "name": "Deploy to K8s",
  "handleId": "flow-deploy",
  "index": 0,
  "showConnectionNames": true,
  "showAllSteps": false,
  "steps": {
    "step-1": {
      "id": "step-1",
      "index": 0,
      "description": "Push manifest",
      "type": "introduction",
      "originId": "do-actor",
      "targetId": "do-k8s",
      "viaId": null,
      "parentId": null,
      "paths": null,
      "flowId": null
    },
    "step-2": {
      "id": "step-2",
      "index": 1,
      "description": "Rollout completes",
      "type": "conclusion",
      "originId": "do-k8s",
      "targetId": "do-app",
      "viaId": null,
      "parentId": null,
      "paths": null,
      "flowId": null
    }
  }
}
```

Step types: `introduction` · `information` · `outgoing` · `conclusion` · `alternate-path` · `parallel-path` · `subflow` · `self-action`.

---

## ADR create

```json
{
  "name": "ADR 0001 — Use Talos for Kubernetes",
  "status": "accepted",
  "description": "Immutable OS for cluster nodes",
  "content": "# ADR 0001 - Use Talos\n\n## Status\nAccepted\n\n## Context\n...\n\n## Decision\n...\n\n## Consequences\n...",
  "handleId": "adr-0001"
}
```

POST `.../adrs`. Related items can link diagrams, drafts, external links.

---

### Flow — Agent Governance skill promotion

After context diagram with `do-dev`, `do-corpus`, `do-frozen`, `do-agents`:

```json
{
  "diagramId": "<context-diagram-id>",
  "name": "Skill promotion to frozenSkillz",
  "index": 0,
  "showConnectionNames": true,
  "steps": {
    "intro": {
      "id": "intro", "index": 0, "type": "introduction",
      "description": "Developer promotes an approved skill to the marketplace"
    },
    "s1": {
      "id": "s1", "index": 1, "type": "outgoing",
      "description": "Submit skill package",
      "originId": "do-dev", "targetId": "do-corpus"
    },
    "s2": {
      "id": "s2", "index": 2, "type": "outgoing",
      "description": "Publish to frozenSkillz",
      "originId": "do-corpus", "targetId": "do-frozen"
    },
    "end": {
      "id": "end", "index": 3, "type": "conclusion",
      "description": "Skill live in marketplace"
    }
  }
}
```

Step type reference: [reference/flows-storytelling.md](reference/flows-storytelling.md)

---

1. `GET .../share-link` → `{ url, defaultUrl, shareLink }`
2. `defaultUrl` opens overview; for one diagram set options `mode: "diagram"`, `diagramId: "<id>"`
3. Pattern: `https://s.icepanel.io/BKWC9YAovn1qa9/<optionsHandle>`

App editor: `https://app.icepanel.io/landscapes/Efdez5uW6BfQjErrQ4Gx/versions/latest`

---

## Export diagram PNG (poll loop)

```bash
# 1. Create job
EXPORT_ID=$(doppler run -- curl -s -X POST \
  -H "Authorization: ApiKey $ICE_PANEL_ADMIN" \
  -H "Content-Type: application/json" \
  -d '{"theme":"light","maxWidth":2048}' \
  "https://api.icepanel.io/v1/landscapes/Efdez5uW6BfQjErrQ4Gx/versions/latest/diagrams/{diagramId}/export/image" \
  | jq -r '.diagramExportImage.id')

# 2. Poll until fileUrls.png present
doppler run -- curl -s -H "Authorization: ApiKey $ICE_PANEL_ADMIN" \
  "https://api.icepanel.io/v1/landscapes/.../export/image/$EXPORT_ID"
```

---

## Verification checklist (copy for agents)

```
Landscape: _______________  landscapeId: _______________

Model layer
[ ] GET .../model/objects → count > 0
[ ] GET .../model/connections → expected edges present
[ ] GET .../import/{id} → status completed (if just imported)

Visual layer
[ ] GET .../diagrams → count > 0
[ ] GET .../diagrams/{id}/content → objects map non-empty
[ ] POST .../export/image → PNG URL within 60s

Share / UI
[ ] share-link defaultUrl loads canvas (not empty)
[ ] diagram deep link shows placed objects

Governance (optional)
[ ] GET .../adrs → expected ADRs
[ ] GET .../flows → key flows exist
```
