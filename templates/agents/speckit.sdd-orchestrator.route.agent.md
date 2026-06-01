---
description: "SDD Phase 5 — Task Routing. Classifies and assigns tasks from tasks.md to specialist execution agents using →AgentName annotations. Squad routes but does NOT rewrite tasks (RULE-008)."
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

---

## Inputs

Load the following:

1. Run `bash .specify/scripts/bash/check-prerequisites.sh --json --require-tasks` and parse `FEATURE_DIR`.
2. Read `<FEATURE_DIR>/tasks.md` — source of truth for tasks
3. Read `<FEATURE_DIR>/spec.md` — for domain context
4. Read `<FEATURE_DIR>/plan.md` — for technical design context
5. Read `.codebase/architecture-analysis.md` (if exists) — for module assignments

---

## Routing Rules

### Available Agents

| Agent                | Handles                                                                   |
| -------------------- | ------------------------------------------------------------------------- |
| `speckit.sdd-orchestrator.backend`  | NestJS modules, services, controllers, DTOs, use cases, application layer |
| `speckit.sdd-orchestrator.database` | Entities, TypeORM migrations, repositories, query optimization            |
| `speckit.sdd-orchestrator.infra`    | Docker Compose, CI/CD, environment config, deployment                     |
| `speckit.sdd-orchestrator.security` | Auth guards, JWT config, input validation, OWASP checklist                |
| `speckit.sdd-orchestrator.qa`       | Unit tests, integration tests, E2E tests, test factories, mocks           |
| `speckit.sdd-orchestrator.reviewer` | Code review, acceptance criteria sign-off, architectural review           |

### Classification Logic

For each unchecked task (`- [ ]`):

1. Read the task description and acceptance criteria
2. Identify the primary domain: data persistence? API? messaging? auth? testing?
3. Assign the **primary owner** — the agent whose core domain matches the task
4. Note any **co-owners** (agents that need to collaborate) as a comment

Classification hints:

- "entity", "migration", "repository", "query", "table", "column" → `speckit.sdd-orchestrator.database`
- "service", "controller", "module", "DTO", "use case", "handler" → `speckit.sdd-orchestrator.backend`
- "guard", "JWT", "auth", "permission", "role", "validate", "sanitize" → `speckit.sdd-orchestrator.security`
- "test", "spec", "mock", "fixture", "factory", "coverage" → `speckit.sdd-orchestrator.qa`
- "docker", "compose", "CI", "workflow", "env", "deploy", "infra" → `speckit.sdd-orchestrator.infra`
- "review", "verify", "sign-off", "acceptance" → `speckit.sdd-orchestrator.reviewer`

When a task spans multiple domains, assign the **primary** domain owner and note
the co-owner. Example:

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

## Phase Balance Check

After annotating all tasks, produce a workload distribution table:

```
| Agent                | Tasks | Phases |
|---------------------|-------|--------|
| speckit.sdd-orchestrator.backend   |   N   |  1,2   |
| speckit.sdd-orchestrator.database  |   N   |  1     |
| speckit.sdd-orchestrator.qa        |   N   |  2,3   |
| speckit.sdd-orchestrator.security  |   N   |  2     |
| speckit.sdd-orchestrator.infra     |   N   |  3     |
| speckit.sdd-orchestrator.reviewer  |   N   |  3     |
```

Flag any agent with 0 tasks (may be unused for this feature — that's fine).
Flag any phase where ALL tasks go to a single agent (potential bottleneck).

---

## Completion

After updating `tasks.md` with all annotations, output:

```
✅ Task Routing complete
   File: <FEATURE_DIR>/tasks.md
   Tasks routed: <N>

Distribution:
<workload table>

⚠ RULE-008 compliance: task content was NOT modified, only →AgentName annotations added.

Next: /sdd.implement to execute all phases in parallel.
```
