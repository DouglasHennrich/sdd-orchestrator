---
description: "Phase 5 — annotate tasks.md with →AgentName assignments for specialist execution agents."
---

# SDD Orchestrator — Route (Phase 5)

## User Input

```text
$ARGUMENTS
```

Run the `speckit.sdd-orchestrator.route` agent. It reads the authoritative
`tasks.md` in the active feature directory and annotates each task with a
`→AgentName` assignment, mapping work to the specialist execution agents defined
in `.github/agents` (backend, database, security, qa, infra, reviewer).

This command is triggered automatically by the `after_tasks` hook once
`/speckit.tasks` completes.
