---
description: "Phase 5 — route open tasks to Squad agents by capability matching and annotate tasks.md + update .squad/routing.md."
---

# SDD Orchestrator — Route Tasks (Phase 5)

Read open tasks from `tasks.md` and assign each to the most appropriate
Squad agent. Annotates `tasks.md` with `→AgentName` and updates
`.squad/routing.md` with any new patterns.

This command is triggered automatically by the `after_tasks` hook.

## User Input

```text
$ARGUMENTS
```

## Steps

1. **Verify prerequisites**:
   - Read `.specify/feature.json` to find `FEATURE_DIR`. If missing, look for
     the most recently modified directory under `specs/`.
   - `<FEATURE_DIR>/tasks.md` must exist; if not, tell the user to run
     `/speckit.tasks` first and stop.
   - `.squad/` must exist; if not, tell the user to run
     `/speckit.sdd-orchestrator.init` first and stop.
   - At least one active agent must exist in `.squad/agents/`; if not, tell the
     user to run `/speckit.sdd-orchestrator.generate` first and stop.

2. **Load Squad agents and routing rules** from `.squad/`:
   - Read each agent from `.squad/agents/{name}/charter.md` (or
     `.squad/agents/{name}.md`). Only consider agents with `status: active`.
   - For each agent, extract its name and capability keywords from the
     `capabilities` array in its charter.
   - Read `.squad/routing.md` for existing keyword → agent mappings.

3. **Read open tasks** from `<FEATURE_DIR>/tasks.md`. Parse each unchecked
   task (`- [ ]`) — its ID, description, phase label, and any existing
   `→AgentName` annotation. Tasks already annotated may be re-routed if the
   annotation is wrong.

4. **Map tasks to agents** (capability-match strategy):

   - Extract domain keywords from each task title and description.
   - Match against the Squad agents loaded in Step 2 AND against existing rules
     in `.squad/routing.md`.
   - If multiple agents match, prefer the one with the highest specificity match.
   - If no agent matches a task, do NOT assign a fallback — instead flag the
     task with `⚠️ no agent match` and instruct the user to run
     `/speckit.sdd-orchestrator.generate` so a new Squad agent covering that
     domain is created before retrying.

5. **Annotate `tasks.md`**: For each matched task, append `→AgentName` after
   the task description if not already present, or replace the existing
   annotation. Use the Squad agent's name exactly as defined in its charter.
   Format: `- [ ] T001 [P] Description →Jorge`

6. **Output a routing table**:

   ```
   Task Routing Summary — <FEATURE_DIR>
   ─────────────────────────────────────────────────────────────────────────
   Task    Description                              Agent               Phase
   ─────────────────────────────────────────────────────────────────────────
   T001    Create editable-model entity             →Jorge              2
   T002    Implement update service logic           →Jorge              3
   T003    Add auth guard for platform templates    →Ana                3
   T004    Write unit tests for service             →Carlos             3
   ─────────────────────────────────────────────────────────────────────────
   Routed: N / N total   ⚠️ No agent match: N
   ```

7. **Update `.squad/routing.md`**: Add any new keyword → agent mappings inferred
   from this task batch that are not already covered. Do not remove existing
   rules — only append or update.

8. **Print completion**:

   ```
   ✅ Route complete
      tasks.md annotated: <N> tasks
      .squad/routing.md updated
      ⚠️  <N> tasks need manual assignment — run /speckit.sdd-orchestrator.generate

   Next: /speckit.sdd-orchestrator.implement — execute tasks by phase
   ```
