---
description: "Phase 0 — produce a feature-scoped architecture analysis (.codebase/architecture-analysis.md)."
---

# SDD Orchestrator — Codebase Architect (Phase 0)

## User Input

```text
$ARGUMENTS
```

Run the `speckit.sdd-orchestrator.codebase-architect` agent, passing the feature
description from `$ARGUMENTS`. Using the knowledge base from Phase -1, it produces
`.codebase/architecture-analysis.md` covering reuse opportunities, integration
points, and architectural constraints relevant to the feature.

**Prerequisite:** `.codebase/graph.json` must exist (run
`/speckit.sdd-orchestrator.codebase-index` first). This command is normally
invoked automatically by `speckit.sdd-orchestrator.specify` (Phase 0).
