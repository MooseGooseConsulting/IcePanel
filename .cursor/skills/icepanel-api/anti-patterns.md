# Anti-patterns — lessons from failed IcePanel work

This doc exists because we **failed visibly** in Scratch (July 2026). Read before modeling or diagramming.

---

## 1. Everything on Level 1 (the GitHub Hub blob)

**Symptom:** One `context-diagram` with actors, systems, apps, stores, groups, 30+ overlapping boxes, unreadable labels, curved-edge soup.

**Why it fails:** Context diagrams are **C4 Level 1**. Apps and components belong on L2/L3. IcePanel shows "Level 1" in the UI — stuffing containers into L1 defeats the product.

**Fix:**

- L1: actors + systems + externals only
- L2: one `app-diagram` per system (`modelId` = that system)
- L3: `component-diagram` per app that has components

---

## 2. Multiple "variant" diagrams (A / B / C / D)

**Symptom:** Sidebar full of `Portfolio - Panorama (A)`, `GitHub Hub (B)`, `Layer Stack (C)`, `PR Review Core (D)` — all Level 1.

**Why it fails:** Variants are layout experiments, not architecture. User must pick a canvas; nothing drills down; same mistake repeated four times.

**Fix:** One L1 context + N L2 + M L3. Layout experiments belong in **drafts**, not published diagrams.

---

## 3. Phase gates over C4

**Symptom:** MODELER → DIAGRAMMER → VERIFIER checklists; "diagram count ≥ 1" as success; 15–40 objects per landscape; import completed = done.

**Why it fails:** Optimizes **execution reliability** (blank canvas bug), not **correct architecture storytelling**.

**Fix:** Success = correct level placement + drill path + readable L1. Import/PNG are checks, not the goal.

---

## 4. Five separate landscapes as the product

**Symptom:** `portfolio`, `k8s`, `governance`, `coldsearch`, `archiver` — each with tiny context diagram, no merge, click share link → see 7 boxes.

**Why it fails:** User wants **one interconnected model**, not five silos with share-link hops.

**Fix:** Merge detail into `portfolio` model; L1 shows systems; L2/L3 hold detail. Keep satellites only as import staging if needed.

---

## 5. Groups/systems confused on canvas

**Symptom:** `area` shape with `modelId` pointing to a **system** (not a group) → API 400 or wrong nesting.

**Rule:** `shape: area` → `type: group` only. Systems are boxes on L1 or L2, not area wrappers.

---

## 6. `type: root` on diagram objects

**Symptom:** POST diagram returns 400 — root/domain objects on canvas.

**Rule:** Diagram objects: `actor`, `system`, `app`, `store`, `component`, `group` only. Domain scopes the diagram via `modelId`; it is not drawn.

---

## 7. Patch import without full model context

**Symptom:** `POST import` patch with `parentId: portfolio-dom` → "Parent not found" (live IDs differ from import IDs).

**Fix:** Merge into full `LandscapeImportData` and import, or use live IDs from `reports/<slug>-model-map.json` after dump.

---

## 8. Replacing Dependencies view with manual spaghetti

**Symptom:** Drawing every cross-system edge on one canvas.

**Fix:** L1 shows **architecturally important** edges. Use IcePanel **Dependencies** / share mode `dependencies` for dense exploration.

---

## 9. Components without L3 diagram

**Symptom:** Model has `component` objects but no `component-diagram` — components invisible in UI drill-down.

**Fix:** Add L3 diagram scoped to parent app `modelId`.

---

## 10. ASCII / handleId collisions

**Symptom:** Import mojibake; POST 500 on duplicate `handleId`.

**Fix:** ASCII-only strings in JSON; one handleId per diagram; delete old diagram before re-post with same handle.

---

## Failure screenshot checklist

If the diagram looks like the July 2026 "GitHub Hub" screenshot:

- [ ] Apps visible on L1 context → **wrong level**
- [ ] Groups overlapping apps → **wrong types / layout**
- [ ] Title contains "Variant" or "Hub" → **delete and use C4 set**
- [ ] No L2 in sidebar → **add app-diagrams**
- [ ] Edges unreadable → **reduce L1 edges; move detail to L2**

Correct entry point: **Portfolio - Context (L1)** → click a system → **Containers (L2)**.
