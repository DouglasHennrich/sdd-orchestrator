---
description: "Phase -1 — build or refresh the repository knowledge graph (.codebase/graph.json + knowledge-base.md)."
---

# SDD Orchestrator — Codebase Index (Phase -1)

## User Input

```text
$ARGUMENTS
```

Run the `speckit.sdd-orchestrator.codebase-index` agent. It performs its own
staleness check first: if `.codebase/graph.json` is fresh (< 24h old and no
sentinel files changed), it reports the graph is fresh and exits without
re-scanning. Otherwise it scans the repository and writes:

- `.codebase/graph.json`
- `.codebase/knowledge-base.md`

This command is normally invoked automatically by
`speckit.sdd-orchestrator.specify` (Phase -1), but can be run standalone to
refresh the knowledge base.
