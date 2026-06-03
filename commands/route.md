---
description: "Phase 5 — route open tasks to Squad agents by capability matching, annotate tasks.md, and update .squad/routing.md."
---

## User Input

```text
$ARGUMENTS
```

---

## Purpose

Assign every unchecked task in `tasks.md` to a specialist execution agent by
adding a `→AgentName` annotation. This is the only modification allowed —
task content, acceptance criteria, and descriptions must NOT be changed (RULE-008).

> This command is triggered automatically by the `after_tasks` hook and can also
> be run directly: `/speckit.sdd-orchestrator.route`.

---

## Steps

### Step 1 — Verify prerequisites

- Run `bash .specify/scripts/bash/check-prerequisites.sh --json --require-tasks` and parse `FEATURE_DIR`.
  If missing, look for the most recently modified directory under `specs/`.
- `<FEATURE_DIR>/tasks.md` must exist; if not, tell the user to run `/speckit.tasks` first and stop.
- `.squad/` must exist; if not, tell the user to run `/speckit.sdd-orchestrator.init` first and stop.
- At least one active agent must exist in `.squad/agents/`; if not, tell the user to run
  `/speckit.sdd-orchestrator.generate` first and stop.

### Step 2 — Load Squad agents and routing rules

- Read each agent from `.squad/agents/{name}/charter.md` (or `.squad/agents/{name}.md`).
  Only consider agents with `status: active`.
- For each agent, extract its name and capability keywords from the `capabilities` array.
- Read `.squad/routing.md` for existing keyword → agent mappings.

Also load for domain context:
- `<FEATURE_DIR>/spec.md`
- `<FEATURE_DIR>/plan.md`
- `.codebase/architecture-analysis.md` (if exists)

### Step 3 — Read open tasks

Read all unchecked tasks (`- [ ]`) from `<FEATURE_DIR>/tasks.md`.
Parse each task: ID, description, phase label, and any existing `→AgentName` annotation.
Tasks already annotated may be re-routed if the annotation is wrong.

### Step 4 — Map tasks to agents (capability-match strategy)

Extract domain keywords from each task title and description.
Match against Squad agents (Step 2) AND existing rules in `.squad/routing.md`.
If multiple agents match, prefer the highest specificity match.
If no agent matches, do NOT assign a fallback — flag with `⚠️ no agent match`.

---

## Routing Rules

### Available Agents

| Agent | Handles |
|---|---|
| `speckit.sdd-orchestrator.backend` | NestJS modules, services, controllers, DTOs, use cases, application layer |
| `speckit.sdd-orchestrator.database` | Entities, TypeORM migrations, repositories, query optimization |
| `speckit.sdd-orchestrator.infra` | Docker Compose, CI/CD, environment config, deployment |
| `speckit.sdd-orchestrator.security` | Auth guards, JWT config, input validation, OWASP checklist |
| `speckit.sdd-orchestrator.qa` | Unit tests, integration tests, E2E tests, test factories, mocks |
| `speckit.sdd-orchestrator.reviewer` | Code review, acceptance criteria sign-off, architectural review |

### Classification Hints

- "entity", "migration", "repository", "query", "table", "column" → `speckit.sdd-orchestrator.database`
- "service", "controller", "module", "DTO", "use case", "handler" → `speckit.sdd-orchestrator.backend`
- "guard", "JWT", "auth", "permission", "role", "validate", "sanitize" → `speckit.sdd-orchestrator.security`
- "test", "spec", "mock", "fixture", "factory", "coverage" → `speckit.sdd-orchestrator.qa`
- "docker", "compose", "CI", "workflow", "env", "deploy", "infra" → `speckit.sdd-orchestrator.infra`
- "review", "verify", "sign-off", "acceptance" → `speckit.sdd-orchestrator.reviewer`

When a task spans multiple domains, assign the **primary** domain owner and note
the co-owner as a comment:

```
- [ ] T005 →speckit.sdd-orchestrator.backend Add UserService.findByEmail method
  <!-- co-owner: speckit.sdd-orchestrator.database (needs repository method) -->
```

### Annotation Format

Add the `→AgentName` annotation inline after the task ID. Do not change anything else:

```markdown
- [ ] T001 →speckit.sdd-orchestrator.database Create users entity with TypeORM
- [ ] T002 →speckit.sdd-orchestrator.backend Create UserModule with UserService
- [ ] T003 →speckit.sdd-orchestrator.security Add JWT auth guard to UserController
- [ ] T004 →speckit.sdd-orchestrator.qa Write unit tests for UserService
```

---

### Step 5 — Annotate tasks.md

For each matched task, append `→AgentName` after the task description if not already
present, or replace the existing annotation. Use the Squad agent's name exactly as
defined in its charter.

---

## Phase Balance Check

After annotating all tasks, produce a workload distribution table:

```
| Agent                               | Tasks | Phases |
|-------------------------------------|-------|--------|
| speckit.sdd-orchestrator.backend    |   N   |  1,2   |
| speckit.sdd-orchestrator.database   |   N   |  1     |
| speckit.sdd-orchestrator.qa         |   N   |  2,3   |
| speckit.sdd-orchestrator.security   |   N   |  2     |
| speckit.sdd-orchestrator.infra      |   N   |  3     |
| speckit.sdd-orchestrator.reviewer   |   N   |  3     |
```

Flag any agent with 0 tasks (may be unused for this feature — that's fine).
Flag any phase where ALL tasks go to a single agent (potential bottleneck).

---

## Update `.squad/routing.md`

After annotating tasks, infer any new keyword → agent patterns from this task
batch that are not already present in `.squad/routing.md` and append them.
Do not remove or overwrite existing rules.

---

## Completion

After updating `tasks.md` and `.squad/routing.md`, output:

```
✅ Task Routing complete
   File: <FEATURE_DIR>/tasks.md
   Tasks routed: <N>
   .squad/routing.md updated

Distribution:
<workload table>

⚠ RULE-008 compliance: task content was NOT modified, only →AgentName annotations added.
⚠️  <N> tasks need manual assignment — run /speckit.sdd-orchestrator.generate

Next: /speckit.sdd-orchestrator.implement — execute tasks phase by phase in parallel.
```
