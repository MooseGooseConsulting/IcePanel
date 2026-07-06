# External diagram patterns

Complementary skills and tools (not duplicated here).

---

## robertanton81/architecture-diagram-skill

GitHub: https://github.com/robertanton81/architecture-diagram-skill

| Aspect | Their skill | This skill |
|--------|-------------|------------|
| Input | Codebase scan (`analyze_codebase.py`) | Import JSON + REST model GET |
| Output | Mermaid or IcePanel push | Full REST operator manual |
| IcePanel | `push_to_icepanel.py` plan JSON | `DiagramCreate` + phase gates |
| Flows | Interactive branching flows | [flows-storytelling.md](flows-storytelling.md) |

**Patterns worth borrowing:**

- Topic-focused diagrams (payment flow, login) map to IcePanel **flows** on app diagrams
- Monorepo scoping maps to multiple **app-diagram** per system
- Merge-with-existing via read-before-write — use `GET .../model/objects` + id match before import
- Pre-push **plan JSON** step — our equivalent is `imports/diagrams/<slug>-*.json` before `icepanel-push-diagrams.ps1`

**Use together:** Run codebase analysis skill for greenfield repos; use this skill for import/diagram/verify operations and portfolio orchestration.

---

## IcePanel product guidance

- Visual storytelling flows: https://docs.icepanel.io/visual-storytelling/flows
- C4 in IcePanel: https://icepanel.io/c4-model/
