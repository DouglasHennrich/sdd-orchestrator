---
description: "Orchestrated implement — verifies task routing then fans out to specialist agents per phase (Phase 6)."
---

# SDD Orchestrator — Implement (Phase 6)

This is the orchestrated entry point for implementation. Run it instead of
`/speckit.implement` to get parallel, routed execution.

## User Input

```text
$ARGUMENTS
```

## What this command does

Run the `speckit.sdd-orchestrator.implement` agent. It executes everything inline
in the conversation:

1. Processes `before_implement` hooks via `EXECUTE_COMMAND:` markers.
2. Verifies `tasks.md` has `→AgentName` routing annotations — if not, runs
   `speckit.sdd-orchestrator.route` (via `EXECUTE_COMMAND:`) first.
3. Executes tasks phase-by-phase, dispatching the specialist execution agents
   (backend, database, security, qa, infra, reviewer) in parallel per phase.
   Every agent follows Test Driven Development (RULE-012).
4. Processes `after_implement` hooks via `EXECUTE_COMMAND:` markers.

The agent never begins implementation before routing is complete (RULE-014).
