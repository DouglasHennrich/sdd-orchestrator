---
description: "after_tasks orchestrator — runs Phase 5 routing then API contract detection in sequence."
---

# SDD Orchestrator — After Tasks Pipeline

Runs the full `after_tasks` pipeline in order:

1. **Phase 5 – Route**: annotate `tasks.md` with `→AgentName` assignments.
2. **API Contract**: detect API-impacting tasks and scaffold `API.md` when needed.

This command is triggered automatically by the `after_tasks` hook.

## User Input

```text
$ARGUMENTS
```

## Steps

### Step 1 — Route tasks (Phase 5)

Execute the full logic defined in `speckit.sdd-orchestrator.route`:

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

---

### Step 2 — API Contract detection

Execute the full logic defined in `speckit.sdd-orchestrator.api-contract`:

1. **Verify prerequisites**:
   - `specs/<id>/tasks.md` exists (already confirmed in Step 1).
   - `.specify/extensions/squad/templates/API.md` exists; if not, report a
     warning and skip this step (do not abort the pipeline).

2. **Detect API-impacting tasks** from the tasks loaded in Step 1.
   Mark a task as API-impacting if its title or description mentions at least
   one of the following (pt/en):

   - New endpoint/route/controller action
   - Changes in request body/query/path params
   - Changes in response shape/status codes
   - API contract/openapi/swagger updates
   - Web/mobile integration blocked by backend contract

   Keywords: `api`, `endpoint`, `route`, `controller`, `request`, `response`,
   `dto`, `swagger`, `openapi`, `contract`, `payload`, `query param`,
   `path param`, `header`, `rota`, `controlador`, `requisicao`, `resposta`,
   `contrato`, `body`, `query`, `param`, `cabecalho`

3. **If no API-impacting task is found**:
   - Print: `No API contract changes detected in tasks.md. Skipping API template generation.`
   - Continue to the completion message (Step 4).

4. **Resolve destination for API doc**:
   - If `$ARGUMENTS` contains `--output=<path>`, use it.
   - Else, if there is an existing feature folder in `docs/features/` for the
     active spec, update/create `API.md` there.
   - Else, create `specs/<id>/API.md`.

5. **Materialize template**:
   - Copy `.specify/extensions/squad/templates/API.md` into destination when
     the file does not exist.
   - If destination already exists, preserve current content and append only
     missing endpoint sections from the detected tasks.

6. **Assign ownership to squad agents**:
   - Read latest routing assignments from `.squad/routing.md` and the
     `→AgentName` annotations written in Step 1.
   - Add an `Owner` line under each endpoint section in `API.md` with the
     assigned agent.
   - If more than one agent is involved, add `Owner` and `Reviewers` lines.
   - If no mapping is found, set owner to `coordinator` and flag
     `needs-manual-assignment`.

7. **Output API contract summary**:
   ```
   API Contract Summary
   ─────────────────────────────────────────────────────────────────────────
   Tasks analyzed   : N
   API-impacting    : N
   Destination      : <path>
   Sections created : N
   Owners assigned  : N   ⚠️ Needs manual assignment: N
   ```

---

### Completion

Print a unified completion message:

```
✅ after_tasks pipeline complete
   Route    — tasks.md annotated: N tasks | .squad/routing.md updated
   API doc  — <path created or "skipped (no API impact)">

Next: /speckit.sdd-orchestrator.implement — execute tasks by phase
```
