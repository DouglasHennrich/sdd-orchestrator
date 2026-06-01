---
description: "Detect API-impacting tasks and prepare API.md contract documentation from Squad template"
---

# Squad Bridge: API Contract Template

Analyze the current Speckit task list and prepare API contract documentation only
when tasks include API surface changes (new route or request/response contract
changes in existing route).

This command is intended to run in the `after_tasks` hook.

## User Input

$ARGUMENTS

## Steps

1. **Verify prerequisites**:
   - `specs/<id>/tasks.md` exists; if not, ask user to run `/speckit.tasks` first and stop.
   - `.specify/extensions/squad/templates/API.md` exists; if not, report error and stop.

2. **Load active tasks** from `specs/<id>/tasks.md`.

3. **Detect API-impacting tasks**. Mark as API-impacting if task title/description mentions at least one of:
   - New endpoint/route/controller action
   - Changes in request body/query/path params
   - Changes in response shape/status codes
   - API contract/openapi/swagger updates
   - Web/mobile integration blocked by backend contract

   Suggested keywords (pt/en):
   - `api`, `endpoint`, `route`, `controller`, `request`, `response`, `dto`, `swagger`, `openapi`, `contract`, `payload`, `query param`, `path param`, `header`
   - `rota`, `endpoint`, `controlador`, `requisicao`, `resposta`, `contrato`, `body`, `query`, `param`, `cabecalho`

4. **If no API-impacting task is found**:
   - Print: `No API contract changes detected in tasks.md. Skipping API template generation.`
   - Exit with no file changes.

5. **Resolve destination for API doc**:
   - If `$ARGUMENTS` contains `--output=<path>`, use it.
   - Else, if there is an existing feature folder in `docs/features/` for the active spec, update/create `API.md` there.
   - Else, create `specs/<id>/API.md`.

6. **Materialize template**:
   - Copy `.specify/extensions/squad/templates/API.md` into destination when file does not exist.
   - If destination already exists, preserve current content and append only missing endpoint sections from detected tasks.

7. **Assign ownership to squad agents**:
   - Read latest routing assignments (from `.squad/routing.md` and task annotations if present).
   - Add an `Owner` line under each endpoint section in API.md with the assigned agent.
   - If more than one agent is involved, add `Owner` and `Reviewers` lines.
   - If no mapping is found, set owner to `coordinator` and flag `needs-manual-assignment`.

8. **Output summary**:
   - Total tasks analyzed
   - API-impacting tasks found
   - Destination path used
   - Endpoint sections created/updated
   - Owners assigned and pending manual assignments

## Notes

- Keep placeholders for unknown data; do not invent endpoint contracts.
- Prefer conservative detection: only generate/update API.md when contract impact is explicit.
- This command does not replace `/speckit.squad.route`; it complements routing with API documentation ownership.
