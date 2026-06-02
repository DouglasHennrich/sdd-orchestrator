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

## Steps

1. **Process `before_implement` hooks:**

   ```bash
   bash .specify/scripts/bash/list-hooks.sh before_implement
   ```

   Execute mandatory hooks immediately; announce optional hooks for confirmation.

2. **Run the orchestrator agent.** Invoke the
   `speckit.sdd-orchestrator.implement` agent. It verifies that `tasks.md` has
   `→AgentName` routing annotations (if not, it runs
   `speckit.sdd-orchestrator.route` first), then fans out to the specialist
   execution agents in parallel, grouped by phase. All execution agents follow
   TDD (RULE-012).

3. **Process `after_implement` hooks:**

   ```bash
   bash .specify/scripts/bash/list-hooks.sh after_implement
   ```

   Execute every returned hook per the OPTIONAL protocol.
