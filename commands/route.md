---
description: "Phase 5 — route open tasks to specialist agents by capability matching and annotate tasks.md + update .squad/routing.md."
---

# SDD Orchestrator — Route Tasks (Phase 5)

Read open tasks from `tasks.md` and assign each to the most appropriate
specialist execution agent. Annotates `tasks.md` with `→AgentName` and updates
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

2. **Load Squad agents and routing rules** from `.squad/`:
   - Read each agent from `.squad/agents/{name}/charter.md` (or
     `.squad/agents/{name}.md`). Only consider agents with `status: active`.
   - Read `.squad/routing.md` for existing keyword → agent mappings.

3. **Read open tasks** from `<FEATURE_DIR>/tasks.md`. Parse each unchecked
   task (`- [ ]`) — its ID, description, phase label, and any existing
   `→AgentName` annotation. Tasks already annotated may be re-routed if the
   annotation is wrong.

4. **Map tasks to agents** (capability-match strategy):

   | Agent | Domain keywords |
   | ----- | --------------- |
   | `speckit.sdd-orchestrator.backend`  | service, controller, module, DTO, NestJS, endpoint, API, business logic |
   | `speckit.sdd-orchestrator.database` | entity, migration, repository, query, schema, table, relation, TypeORM |
   | `speckit.sdd-orchestrator.security` | auth, guard, permission, OWASP, validation, sanitization, JWT, RBAC |
   | `speckit.sdd-orchestrator.qa`       | test, spec, factory, coverage, E2E, unit, integration, jest |
   | `speckit.sdd-orchestrator.infra`    | Docker, CI/CD, env, pipeline, deploy, config, secrets |
   | `speckit.sdd-orchestrator.reviewer` | review, audit, acceptance, sign-off, checklist |

   - Extract domain keywords from the task title and description.
   - Match against the agent capability table above AND against existing rules
     in `.squad/routing.md`.
   - If multiple agents match, prefer the one with the highest specificity match.
   - If no agent matches, assign `speckit.sdd-orchestrator.backend` as default
     and flag it with `⚠️ no direct match`.

5. **Annotate `tasks.md`**: For each task, append `→AgentName` after the task
   description if not already present, or replace the existing annotation.
   Format: `- [ ] T001 [P] Description →speckit.sdd-orchestrator.backend`

6. **Output a routing table**:

   ```
   Task Routing Summary — <FEATURE_DIR>
   ─────────────────────────────────────────────────────────────────────────
   Task    Description                              Agent               Phase
   ─────────────────────────────────────────────────────────────────────────
   T001    Create editable-model entity             →database           2
   T002    Implement update service logic           →backend            3
   T003    Add auth guard for platform templates    →security           3
   T004    Write unit tests for service             →qa                 3
   ─────────────────────────────────────────────────────────────────────────
   Routed: N / N total   ⚠️ Needs review: N
   ```

7. **Update `.squad/routing.md`**: Add any new keyword → agent mappings inferred
   from this task batch that are not already covered. Do not remove existing
   rules — only append or update.

8. **Print completion**:

   ```
   ✅ Route complete
      tasks.md annotated: <N> tasks
      .squad/routing.md updated

   Next: /speckit.sdd-orchestrator.implement — execute tasks by phase
   ```
