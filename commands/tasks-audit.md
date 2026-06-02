---
description: "tasks-audit — post-implementation audit pipeline: verifies tasks-auditor Squad agent exists, then delegates full audit and retry loop to it."
---

# SDD Orchestrator — Tasks Audit

Runs the post-implementation audit pipeline:

1. Verifies the `tasks-auditor` Squad agent exists in `.squad/agents/`.
2. If absent, triggers agent generation via `speckit.sdd-orchestrator.generate`.
3. Delegates the full audit, classification, retry loop, and escalation logic
   to the `tasks-auditor` Squad agent.

This command is triggered automatically by the `after_implement` hook.

## User Input

```text
$ARGUMENTS
```

## Steps

### Step 1 — Verify tasks-auditor Squad agent exists

Check whether either of the following paths exists:
- `.squad/agents/tasks-auditor/charter.md`
- `.squad/agents/tasks-auditor.md`

**If found:** proceed to Step 2.

**If NOT found:**

Emit:
```
EXECUTE_COMMAND: speckit.sdd-orchestrator.generate
```

Wait for `generate` to complete. Confirm the agent now exists before continuing.
If it still does not exist after `generate` completes, report the failure and stop:

> "tasks-auditor Squad agent could not be created. Check that
> `.specify/extensions/sdd-orchestrator/templates/agents/speckit.sdd-orchestrator.tasks-auditor.agent.md`
> exists and re-run `/speckit.sdd-orchestrator.generate`."

### Step 2 — Delegate to tasks-auditor Squad agent

Run the `tasks-auditor` Squad agent by emitting:

```
EXECUTE_COMMAND: speckit.sdd-orchestrator.tasks-auditor
```

The agent handles the full audit cycle:
- Reads `.specify/feature.json` → resolves FEATURE_DIR
- Loads `{FEATURE_DIR}/tasks.md`
- Classifies every task: ✅ done | ⚠️ partial | ❌ missing | 🔴 broken
- Re-routes failing tasks to their `→AgentName` agents (up to 3 cycles)
- Escalates to the user if tasks still fail after 3 cycles
